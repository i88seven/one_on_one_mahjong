import 'dart:ui';
import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/dealts.dart';
import 'package:one_on_one_mahjong/components/doras.dart';
import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/components/game_dialog.dart';
import 'package:one_on_one_mahjong/components/game_end_button.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/components/hands.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/other_dealts.dart';
import 'package:one_on_one_mahjong/components/other_hands.dart';
import 'package:one_on_one_mahjong/components/trashes.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/constants/game_player_status.dart';
import 'package:one_on_one_mahjong/constants/reach_state.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

class SeventeenGame extends FlameGame with TapDetector {
  Images gameImages = Images();
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');
  late String _myUid;
  final String _roomId;
  bool _isTapping = false;
  Vector2 screenSize;
  final List<GamePlayer> _gamePlayers = [];
  late Dealts _dealtsMe;
  late OtherDeals _dealtsOther;
  late Doras _doras;
  late Hands _handsMe;
  late OtherHands _handsOther;
  late Trashes _trashesMe;
  late Trashes _trashesOther;
  late GameResult _gameResult;
  final FirebaseFirestore _firestoreReference = FirebaseFirestore.instance;
  late DocumentReference<Map<String, dynamic>> _gameDoc;
  final List<StreamSubscription> _streams = [];
  final String _hostUid;
  GameTextButton? _fixHandsButton;
  GameDialog? _gameDialog;
  int _currentOrder = 0; // 0:親, 1:子
  int _currentWind = 1; // 東:1, 南:2, 西:3, 北:4
  int _currentRound = 1; // 局
  bool _isFuriten = false;
  Map<AllTileKinds, WinResult> _reachResult = {};
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this._hostUid, this.screenSize, this.onGameEnd) {
    _gameResult = GameResult(this, _gamePlayers);
    _dealtsMe = Dealts(this);
    _dealtsOther = OtherDeals(this);
    _doras = Doras(this);
    _handsMe = Hands(this);
    _handsOther = OtherHands(this);
    _trashesMe = Trashes(this, true);
    _trashesOther = Trashes(this, false);
    // this.add(GameBackground(this));
  }

  Future<void> initializeHost() async {
    DocumentReference roomDoc =
        _firestoreReference.collection('preparationRooms').doc(_roomId);
    _gameDoc = _firestoreReference.collection('games').doc(_hostUid);
    await deleteGame();
    _streams.add(_gameDoc.snapshots().listen(_onChangeGame));
    final membersSnapshot = await roomDoc.collection('members').get();
    final List<Member> members = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> membersDoc =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            membersSnapshot.docs);
    for (QueryDocumentSnapshot<Map<String, dynamic>> memberDoc in membersDoc) {
      final memberData = memberDoc.data();
      Member member = Member(
        uid: memberDoc.id,
        name: memberData['name'],
      );
      members.add(member);
    }
    members.asMap().forEach((index, member) {
      if (member.uid == _myUid) {
        _currentOrder = index;
      }
    });
    List<String> memberUid = members.map((member) => member.uid).toList();
    memberUid.shuffle();
    String parentUid = memberUid.first;
    for (var member in members) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        GamePlayerStatus.selectHands,
        member.uid == _myUid,
        member.uid == parentUid,
      );
      _gamePlayers.add(gamePlayer);
      await _gameDoc.collection('player_tiles').doc(member.uid).set({
        'dealts': [],
        'hands': [],
        'trashes': [],
      });
      if (member.uid != _myUid) {
        _streams.add(_gameDoc
            .collection('player_tiles')
            .doc(member.uid)
            .snapshots()
            .listen(_onChangeOtherTiles));
      }
    }
    await _gameDoc.set({
      'hostUid': _hostUid,
      'current': 0,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList(),
    });
    await _deal();
    roomDoc.update({
      'status': 'start',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> initializeSlave() async {
    DocumentReference roomDoc =
        _firestoreReference.collection('preparationRooms').doc(_roomId);
    _gameDoc = _firestoreReference.collection('games').doc(_hostUid);
    _streams.add(_gameDoc.snapshots().listen(_onChangeGame));

    final gameSnapshot = await _gameDoc.get();
    await _onChangeGame(gameSnapshot);

    for (GamePlayer gamePlayer in _gamePlayers) {
      if (gamePlayer.uid != _myUid) {
        final otherTilesDoc =
            _gameDoc.collection('player_tiles').doc(gamePlayer.uid);
        _streams.add(otherTilesDoc.snapshots().listen(_onChangeOtherTiles));
        final tiesSnapshot = await otherTilesDoc.get();
        await _onChangeOtherTiles(tiesSnapshot);
      } else {
        final tilesSnapshot =
            await _gameDoc.collection('player_tiles').doc(gamePlayer.uid).get();
        await _initializeMyTiles(tilesSnapshot);
      }
    }

    QuerySnapshot membersSnapshot = await roomDoc.collection('members').get();
    for (QueryDocumentSnapshot element in membersSnapshot.docs) {
      element.reference.delete();
    }
    roomDoc.delete();
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    List<String> allTileImageName =
        allTileKinds.values.map((tileName) => "$tileName.png").toList();
    await gameImages.loadAll([
      'tile-back.png',
      ...allTileImageName,
    ]);
    await _storage.ready;
    _myUid = _storage.getItem('myUid');

    if (_myUid == _hostUid) {
      await initializeHost();
    } else {
      await initializeSlave();
    }

    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.render();
    }
    _handsOther.initialize();
  }

  Future<void> _onChangeGame(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? gameData = snapshot.data();
    if (gameData == null) {
      return;
    }

    if (gameData['current'] != null) {
      _currentOrder = gameData['current'];
    }

    final playersJson = gameData['players'];
    if (_gamePlayers.isEmpty ||
        !mapEquals(playersJson[0], _gamePlayers[0].toJson()) ||
        !mapEquals(playersJson[1], _gamePlayers[1].toJson())) {
      _gamePlayers.clear();
      for (var playerJson in playersJson) {
        GamePlayer gamePlayer =
            GamePlayer.fromJson(this, playerJson['uid'] == _myUid, playerJson);
        _gamePlayers.add(gamePlayer);
      }
      if (_gamePlayers.any((gamePlayer) => gamePlayer.winResult != null) &&
          _gamePlayers.every((gamePlayer) =>
              gamePlayer.status != GamePlayerStatus.waitRound)) {
        // TODO 結果表示の後
        await _processRoundEnd();
      }
    }

    final dorasJson = gameData['doras'] as List<dynamic>?;
    if (dorasJson is List<dynamic>) {
      if (!listEquals(dorasJson, _doras.tiles.map((e) => e.name).toList())) {
        List<AllTileKinds> doras = dorasJson
            .map((tileString) =>
                EnumToString.fromString(AllTileKinds.values, tileString) ??
                AllTileKinds.m1)
            .toList();
        _doras.initialize(doras);
      }
    }

    bool isHandsFixed = _gamePlayers.every(
        (gamePlayer) => gamePlayer.status == GamePlayerStatus.fixedHands);
    if (_myUid == _hostUid && isHandsFixed) {
      for (GamePlayer gamePlayer in _gamePlayers) {
        gamePlayer.setStatus(GamePlayerStatus.selectTrash);
      }
      await _gameDoc.update({
        'players':
            _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
      });
    }
  }

  Future<void> _onChangeOtherTiles(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? otherTilesData = snapshot.data();
    if (otherTilesData == null) {
      return;
    }

    final dealtsJson = otherTilesData['dealts'] as List<dynamic>?;
    if (dealtsJson is List<dynamic>) {
      _dealtsOther.initialize(dealtsJson.length);
    }

    final trashesJson = otherTilesData['trashes'] as List<dynamic>?;
    if (trashesJson is List<dynamic>) {
      List<AllTileKinds> trashes = trashesJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      AllTileKinds? targetTile;
      switch (trashes.length - _trashesOther.tileCount) {
        case 0:
          break;
        case 1:
          _trashesOther.add(trashes.last);
          targetTile = trashes.last;
          break;
        default:
          _trashesOther.initialize(trashes);
      }
      if (!_isFuriten &&
          targetTile != null &&
          _reachResult.containsKey(targetTile)) {
        WinResult winResult = _reachResult[targetTile]!;
        if (_isFirstTurnWin) winResult.addFirstTurnWin();
        if (_isReach) winResult.addReach();
        if (winResult.hans >= 4) {
          // ロン!!!
          _me.setStatus(GamePlayerStatus.ron);
          _me.winResult = winResult;
          await _updateGamePlayers();
          // TODO 結果表示の後
          await _processRoundEnd();
        } else {
          _isFuriten = true;
        }
      }
    }
  }

  Future<void> _initializeMyTiles(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? myTilesData = snapshot.data();
    if (myTilesData == null) {
      return;
    }

    final handsJson = myTilesData['hands'] as List<dynamic>?;
    if (handsJson is List<dynamic>) {
      List<AllTileKinds> hands = handsJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _handsMe.initialize(hands);
    }

    final dealtsJson = myTilesData['dealts'] as List<dynamic>?;
    if (dealtsJson is List<dynamic>) {
      List<AllTileKinds> dealts = dealtsJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _dealtsMe.initialize(dealts);
    }

    final trashesJson = myTilesData['trashes'] as List<dynamic>?;
    if (trashesJson is List<dynamic>) {
      List<AllTileKinds> trashes = trashesJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _trashesMe.initialize(trashes);
    }
  }

  Future<void> _deal() async {
    List<AllTileKinds> stocks = [...allTiles];
    stocks.shuffle();
    _dealtsMe.initialize(stocks.sublist(0, 34));
    stocks.removeRange(0, 34);
    List<AllTileKinds> dealtsOther = stocks.sublist(0, 34);
    sortTiles(dealtsOther);
    _dealtsOther.initialize(dealtsOther.length);
    stocks.removeRange(0, 34);
    _doras.initialize(stocks.sublist(0, 2));
    stocks.removeRange(0, 2);

    await _gameDoc.update({'doras': _doras.jsonValue});
    await _setTilesAtDatabase(dealtsOther);
  }

  Future<void> _processRoundEnd() async {
    if (_myUid != _hostUid) {
      return;
    }
    GamePlayer winPlayer =
        _gamePlayers.firstWhere((gamePlayer) => gamePlayer.winResult != null);
    WinResult winResult = winPlayer.winResult!;
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      if (gamePlayer.winResult != null) {
        gamePlayer.addPoints(winResult.winPoints);
      } else {
        gamePlayer.addPoints(winResult.winPoints * -1);
      }
      gamePlayer.setStatus(GamePlayerStatus.waitRound);
      gamePlayer.render();
    });
    await _updateGamePlayers();
  }

  Future<void> _processNewRound() async {
    _isFuriten = false;
    _reachResult = {};
    if (_myUid != _hostUid) {
      return;
    }
    if (_isGameEnd) {
      _processGameEnd();
      return;
    }
    await _initOnRound();
    await _deal();
  }

  Future<void> _initOnRound() async {
    _currentOrder = 0;
    _gamePlayers.shuffle();
    String parentUid = _gamePlayers.first.uid;
    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.initOnRound(parentUid);
    }
    await _gameDoc.update({
      'current': _currentOrder,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList(),
    });
  }

  void _processGameEnd() {
    _gameResult.render();
    for (var stream in _streams) {
      stream.cancel();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    screenSize = canvasSize;
  }

  @override
  Future<void> onTapUp(info) async {
    if (_isGameEnd) {
      for (final t in children) {
        if (t is GameEndButton &&
            t.toRect().contains(info.eventPosition.global.toOffset())) {
          _gameResult.remove();
          await _gameEnd();
        }
      }
      return;
    }

    if (_isTapping || _isRoundEnd) {
      return;
    }
    if (_me.status == GamePlayerStatus.selectTrash &&
        _me.isParent != (_currentOrder == 0)) {
      return;
    }
    _isTapping = true;

    final touchArea = Rect.fromCenter(
      center: info.eventPosition.global.toOffset(),
      width: 2,
      height: 2,
    );

    for (final c in children) {
      if (c is FrontTile) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == TileState.dealt &&
              _me.status == GamePlayerStatus.selectHands) {
            bool success = await _selectTile(c);
            if (success) {
              break;
            }
          }
          if (c.state == TileState.hand &&
              _me.status == GamePlayerStatus.selectHands) {
            bool success = await _unselectTile(c);
            if (success) {
              break;
            }
          }
          if (c.state == TileState.dealt &&
              _me.status == GamePlayerStatus.selectTrash) {
            bool success = await _discard(c);
            if (success) {
              break;
            }
          }
        }
      }
      if (_canFixHands) {
        if (c is GameTextButton &&
            c.toRect().contains(info.eventPosition.global.toOffset())) {
          if (c.kind == GameButtonKind.fixHands) {
            _fetchReachResult();
            _gameDialog = GameDialog(
                game: this, screenSize: screenSize, reachState: _reachState);
            add(_gameDialog!);
            break;
          }
          if (c.kind == GameButtonKind.dialogCancel) {
            removeAll(_gameDialog!.buttons);
            remove(_gameDialog!);
            break;
          }
          if (c.kind == GameButtonKind.dialogOk) {
            removeAll(_gameDialog!.buttons);
            remove(_gameDialog!);
            remove(_fixHandsButton!);
            await _setTilesAtDatabase(null);
            _me.setStatus(GamePlayerStatus.fixedHands);
            _updateGamePlayers();
            break;
          }
        }
      }
    }
    _isTapping = false;
  }

  Future<bool> _selectTile(FrontTile tile) async {
    if (_handsMe.tileCount >= 13) {
      return true;
    }
    _dealtsMe.select(tile.tileKind);
    _handsMe.add(tile.tileKind);
    if (_canFixHands) {
      _fixHandsButton = GameTextButton('確定', GameButtonKind.fixHands,
          position: Vector2(screenSize.x - 100, screenSize.y - 150));
      add(_fixHandsButton!);
    }

    return true;
  }

  Future<bool> _unselectTile(FrontTile tile) async {
    if (_canFixHands) {
      remove(_fixHandsButton!);
    }
    _dealtsMe.unselect(tile.tileKind);
    _handsMe.discard(tile.tileKind);

    return true;
  }

  Future<bool> _discard(FrontTile tile) async {
    _dealtsMe.discard(tile);
    _trashesMe.add(tile.tileKind);
    await _setTilesAtDatabase(null);

    _gameDoc.update({'current': (_currentOrder + 1) % 2});

    return true;
  }

  GamePlayer get _me {
    return _gamePlayers.firstWhere((gamePlayer) => gamePlayer.uid == _myUid);
  }

  bool get _canFixHands {
    return _me.status == GamePlayerStatus.selectHands &&
        _handsMe.tileCount == 13;
  }

  bool get _isRoundEnd {
    // TODO どう管理するか
    return false;
  }

  bool get _isGameEnd {
    return false; // TODO
  }

  Future<void> _updateGamePlayers() async {
    await _gameDoc.update({
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
    });
  }

  Future<void> _setTilesAtDatabase(List<AllTileKinds>? dealtsOther) async {
    Map<String, List<String>> myTiles = {
      'dealts': _dealtsMe.jsonValue,
      'hands': _handsMe.jsonValue,
      'trashes': _trashesMe.jsonValue,
    };
    // player_tiles 単位での更新は手間がかかるので、 collection にする
    await _gameDoc.collection('player_tiles').doc(_myUid).set(myTiles);
    if (dealtsOther is List<AllTileKinds>) {
      Map<String, List<String>> otherTiles = {
        'dealts': dealtsOther.map((e) => e.name).toList(),
        'hands': [],
        'trashes': [],
      };
      GamePlayer otherPlayer =
          _gamePlayers.firstWhere((gamePlayer) => gamePlayer.uid != _myUid);
      await _gameDoc
          .collection('player_tiles')
          .doc(otherPlayer.uid)
          .set(otherTiles);
    }
  }

  Future<void> deleteGame() async {
    QuerySnapshot playerTilesSnapshot =
        await _gameDoc.collection('player_tiles').get();
    for (QueryDocumentSnapshot element in playerTilesSnapshot.docs) {
      element.reference.delete();
    }
    await _gameDoc.delete();
  }

  Future<void> _gameEnd() async {
    if (_myUid == _hostUid) {
      await deleteGame();
    }
    onGameEnd();
  }

  void _fetchReachResult() {
    ReachMahjongState mahjongState = ReachMahjongState(
      doras: _doras.tiles,
      wind: _currentWind,
      round: _currentRound,
      isParent: _me.isParent,
    );
    _reachResult = fetchReachResult(_handsMe.tiles, mahjongState);
  }

  bool get _isReach => _trashesMe.tileCount > 0;

  bool get _isFirstTurnWin => _trashesMe.tileCount == 1;

  ReachState get _reachState {
    if (_reachResult.isEmpty) {
      return ReachState.none;
    }
    if (_reachResult.values.every((winResult) => winResult.hans >= 4)) {
      return ReachState.confirmed;
    }
    if (_reachResult.values.every((winResult) => winResult.hans < 4)) {
      return ReachState.notEnough;
    }
    return ReachState.undecided;
  }
}
