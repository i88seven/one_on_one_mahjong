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
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result.dart';
import 'package:one_on_one_mahjong/components/game_round.dart';
import 'package:one_on_one_mahjong/components/game_round_result.dart';
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

const maxTrashCount = 17;

class SeventeenGame extends FlameGame with TapDetector {
  Images gameImages = Images();
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');
  late String _myUid;
  final String _roomId;
  bool _isTapping = false;
  Vector2 screenSize;
  final List<GamePlayer> _gamePlayers = [];
  late GameRound _gameRound;
  late Dealts _dealtsMe;
  late OtherDeals _dealtsOther;
  late Doras _doras;
  late Hands _handsMe;
  late OtherHands _handsOther;
  late Trashes _trashesMe;
  late Trashes _trashesOther;
  late GameResult? _gameResult;
  late GameRoundResult? _gameRoundResult;
  final FirebaseFirestore _firestoreReference = FirebaseFirestore.instance;
  late DocumentReference<Map<String, dynamic>> _gameDoc;
  final List<StreamSubscription> _streams = [];
  final String _hostUid;
  GameTextButton? _fixHandsButton;
  GameDialog? _gameDialog;
  int _currentOrder = 0; // 0:親, 1:子
  bool _isFuriten = false;
  Map<AllTileKinds, WinResult> _reachResult = {};
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this._hostUid, this.screenSize, this.onGameEnd) {
    _dealtsMe = Dealts(this);
    _dealtsOther = OtherDeals(this);
    _doras = Doras(this);
    _handsMe = Hands(this);
    _handsOther = OtherHands(this);
    _trashesMe = Trashes(this, true);
    _trashesOther = Trashes(this, false);
    // this.add(GameBackground(this));
    _gameRoundResult = null;
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
    _gameRound = GameRound(this, 1, 1);
    await _gameDoc.set({
      'hostUid': _hostUid,
      'current': 0,
      'wind': _gameRound.wind,
      'round': _gameRound.round,
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

    _gameRound = GameRound(this, 1, 1);
    final gameSnapshot = await _gameDoc.get();
    await _onChangeGame(gameSnapshot);

    for (GamePlayer gamePlayer in _gamePlayers) {
      if (gamePlayer.uid != _myUid) {
        final otherTilesDoc =
            _gameDoc.collection('player_tiles').doc(gamePlayer.uid);
        _streams.add(otherTilesDoc.snapshots().listen(_onChangeOtherTiles));
        final tilesSnapshot = await otherTilesDoc.get();
        await _onChangeOtherTiles(tilesSnapshot);
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

    if (gameData['wind'] != null) {
      _gameRound.setRound(wind: gameData['wind']);
      if (gameData['wind'] == 5) {
        _processGameEnd();
        return;
      }
    }
    if (gameData['round'] != null) {
      _gameRound.setRound(round: gameData['round']);
    }

    final playersJson = gameData['players'];
    if (_gamePlayers.isEmpty ||
        !mapEquals(playersJson[0], _gamePlayers[0].toJson()) ||
        !mapEquals(playersJson[1], _gamePlayers[1].toJson())) {
      GamePlayerStatus oldMyStatus =
          _gamePlayers.isNotEmpty ? _me.status : GamePlayerStatus.ready;
      GamePlayerStatus oldOtherStatus =
          _gamePlayers.isNotEmpty ? _other.status : GamePlayerStatus.ready;
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.remove();
      });
      _gamePlayers.clear();
      for (var playerJson in playersJson) {
        GamePlayer gamePlayer =
            GamePlayer.fromJson(this, playerJson['uid'] == _myUid, playerJson);
        _gamePlayers.add(gamePlayer);
      }
      if (_me.status == GamePlayerStatus.roundResult &&
          _gameRoundResult == null) {
        final winner = _gamePlayers
            .firstWhere((gamePlayer) => gamePlayer.winResult != null);
        _gameRoundResult = GameRoundResult(
            game: this, screenSize: screenSize, winResult: winner.winResult!);
        add(_gameRoundResult!);
      }
      if (_gamePlayers.every(
          (gamePlayer) => gamePlayer.status == GamePlayerStatus.waitRound)) {
        await _processNewRound(isDrawnGame: false);
      }
      if (oldMyStatus == GamePlayerStatus.waitRound &&
          _me.status == GamePlayerStatus.selectHands) {
        final tilesSnapshot =
            await _gameDoc.collection('player_tiles').doc(_myUid).get();
        await _initializeMyTiles(tilesSnapshot);
      }
    }

    if (_isDrawnGame) {
      await _processRoundEnd();
      return;
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
        if (_isFinalTileWin) winResult.addFinalTileWin();
        if (_isFirstTurnWin) winResult.addFirstTurnWin();
        if (winResult.hans >= 4 || winResult.yakumanCount >= 1) {
          // ロン!!!
          _me.winResult = winResult;
          _gamePlayers.asMap().forEach((index, gamePlayer) {
            gamePlayer.setStatus(GamePlayerStatus.roundResult);
          });
          await _updateGamePlayers();
          if (_gameRoundResult == null) {
            _gameRoundResult = GameRoundResult(
                game: this, screenSize: screenSize, winResult: winResult);
            add(_gameRoundResult!);
          }
          return;
        } else {
          _isFuriten = true;
        }
      }
      if (_myUid == _hostUid && _isDrawnGame) {
        await _processRoundEnd();
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

    _gamePlayers.asMap().forEach((index, gamePlayer) {
      gamePlayer.setStatus(GamePlayerStatus.selectHands);
    });
    await _setTilesAtDatabase(dealtsOther);
    await _gameDoc.update({
      'doras': _doras.jsonValue,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
    });
  }

  Future<void> _processRoundEnd() async {
    if (_myUid != _hostUid) {
      return;
    }
    if (_isDrawnGame) {
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.setStatus(GamePlayerStatus.waitRound);
      });
      await _updateGamePlayers();
      await _processNewRound(isDrawnGame: true);
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
    });
    await _updateGamePlayers();
  }

  Future<void> _processNewRound({required bool isDrawnGame}) async {
    _isFuriten = false;
    _reachResult = {};
    _trashesMe.initialize([]);
    _trashesOther.initialize([]);
    _handsMe.initialize([]);
    if (_myUid != _hostUid) {
      return;
    }
    if (_gameRound.isFinalGame && !isDrawnGame) {
      await _gameDoc.update({
        'wind': 5,
        'round': 1,
      });
      _processGameEnd();
      return;
    }
    await _initOnRoundMaster(isDrawnGame: isDrawnGame);
    await _deal();
    await _initOnRoundSlave();
  }

  Future<void> _initOnRoundMaster({required bool isDrawnGame}) async {
    _currentOrder = 0;
    _gamePlayers.sort((a, b) => 1);
    String parentUid = _gamePlayers.first.uid;
    _me.initOnRound(parentUid);
    if (!isDrawnGame) {
      _gameRound.setNewRound();
    }
    await _gameDoc.update({
      'current': _currentOrder,
      'wind': _gameRound.wind,
      'round': _gameRound.round,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList(),
    });
  }

  Future<void> _initOnRoundSlave() async {
    String parentUid = _gamePlayers.first.uid;
    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.initOnRound(parentUid);
    }
    await _updateGamePlayers();
  }

  void _processGameEnd() {
    _gameResult = GameResult(
        game: this, screenSize: screenSize, gamePlayers: _gamePlayers);
    add(_gameResult!);
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
    if (_gameRound.isGameEnded) {
      for (final t in children) {
        if (t is GameTextButton &&
            t.toRect().contains(info.eventPosition.global.toOffset()) &&
            t.kind == GameButtonKind.gameEnd) {
          remove(_gameResult!.button);
          remove(_gameResult!);
          _gameResult = null;
          await _gameEnd();
          break;
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
      if (_canFixHands) {
        if (c is GameTextButton &&
            c.toRect().contains(info.eventPosition.global.toOffset())) {
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
            await _updateGamePlayers();
            break;
          }
          if (c.kind == GameButtonKind.fixHands) {
            _fetchReachResult();
            _gameDialog = GameDialog(
                game: this, screenSize: screenSize, reachState: _reachState);
            add(_gameDialog!);
            break;
          }
        }
      }
      if (c is GameTextButton &&
          c.toRect().contains(info.eventPosition.global.toOffset())) {
        if (c.kind == GameButtonKind.roundResultOk) {
          remove(_gameRoundResult!.button);
          remove(_gameRoundResult!);
          _gameRoundResult = null;
          _me.setStatus(GamePlayerStatus.waitRound);
          await _updateGamePlayers();
          await _processRoundEnd();
          break;
        }
      }
      if (c is FrontTile) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == TileState.dealt &&
              _me.status == GamePlayerStatus.selectHands) {
            bool success = _selectTile(c);
            if (success) {
              break;
            }
          }
          if (c.state == TileState.hand &&
              _me.status == GamePlayerStatus.selectHands) {
            bool success = _unselectTile(c);
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
    }
    _isTapping = false;
  }

  bool _selectTile(FrontTile tile) {
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

  bool _unselectTile(FrontTile tile) {
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

    if (_reachResult.containsKey(tile.tileKind)) {
      _isFuriten = true;
    }
    _gameDoc.update({'current': (_currentOrder + 1) % 2});

    return true;
  }

  GamePlayer get _me {
    return _gamePlayers.firstWhere((gamePlayer) => gamePlayer.uid == _myUid);
  }

  GamePlayer get _other {
    return _gamePlayers.firstWhere((gamePlayer) => gamePlayer.uid != _myUid);
  }

  bool get _isDrawnGame {
    return _trashesMe.tileCount == _trashesOther.tileCount &&
        _trashesMe.tileCount == maxTrashCount &&
        _gamePlayers.every(
            (gamePlayer) => gamePlayer.status == GamePlayerStatus.selectTrash);
  }

  bool get _canFixHands {
    return _me.status == GamePlayerStatus.selectHands &&
        _handsMe.tileCount == 13;
  }

  bool get _isRoundEnd {
    return _me.status == GamePlayerStatus.waitRound;
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
      wind: _gameRound.wind,
      round: _gameRound.round,
      isParent: _me.isParent,
    );
    _reachResult = fetchReachResult(_handsMe.tiles, mahjongState);
  }

  bool get _isFirstTurnWin => _trashesOther.tileCount == 1;
  bool get _isFinalTileWin =>
      _trashesMe.tileCount == _trashesOther.tileCount &&
      _trashesOther.tileCount == maxTrashCount;

  ReachState get _reachState {
    if (_reachResult.isEmpty) {
      return ReachState.none;
    }
    if (_reachResult.values.every(
        (winResult) => winResult.hans >= 4 || winResult.yakumanCount > 0)) {
      return ReachState.confirmed;
    }
    if (_reachResult.values.every(
        (winResult) => winResult.hans < 4 && winResult.yakumanCount == 0)) {
      return ReachState.notEnough;
    }
    return ReachState.undecided;
  }
}
