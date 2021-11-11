import 'dart:ui';
import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/assets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/candidates.dart';
import 'package:one_on_one_mahjong/components/dealts.dart';
import 'package:one_on_one_mahjong/components/doras.dart';
import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/components/game_end_button.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result.dart';

import 'package:one_on_one_mahjong/components/hands.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/other_dealts.dart';
import 'package:one_on_one_mahjong/components/other_hands.dart';
import 'package:one_on_one_mahjong/components/trashes.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';

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
  late Candidates _candidatesMe;
  late Candidates _candidatesOther;
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
  bool _isParent = false;
  int _currentOrder = 0; // 0:親, 1:子
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this._hostUid, this.screenSize, this.onGameEnd) {
    _gameResult = GameResult(this, _gamePlayers);
    _dealtsMe = Dealts(this);
    _dealtsOther = OtherDeals(this);
    _candidatesMe = Candidates(this);
    _candidatesOther = Candidates(this);
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
    for (var member in members) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
      await _gameDoc.collection('player_tiles').doc(member.uid).set({
        'candidates': [],
        'dealts': [],
        'hands': [],
        'trashs': [],
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
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
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
        final tilesDoc =
            _gameDoc.collection('player_tiles').doc(gamePlayer.uid);
        _streams.add(tilesDoc.snapshots().listen(_onChangeOtherTiles));
        final tiesSnapshot = await tilesDoc.get();
        await _onChangeOtherTiles(tiesSnapshot);
      } else {
        final tilesSnapshot =
            await _gameDoc.collection('player_tiles').doc(gamePlayer.uid).get();
        await _initializeMyTiles(tilesSnapshot);
      }
    }

    // TODO _isParent;
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

    _gamePlayers.clear();
    final players = gameData['players'];
    for (var gamePlayerJson in players) {
      GamePlayer gamePlayer = GamePlayer.fromJson(
          this, gamePlayerJson['uid'] == _myUid, gamePlayerJson);
      _gamePlayers.add(gamePlayer);
    }

    final dorasJson = gameData['doras'] as List<dynamic>?;
    if (dorasJson is List<dynamic>) {
      List<AllTileKinds> doras = dorasJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _doras.initialize(doras);
    }
  }

  Future<void> _onChangeOtherTiles(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? otherTilesData = snapshot.data();
    if (otherTilesData == null) {
      return;
    }

    final candidatesJson = otherTilesData['candidates'] as List<dynamic>?;
    if (candidatesJson is List<dynamic>) {
      List<AllTileKinds> candidates = candidatesJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _candidatesOther.initialize(candidates);
      // TODO candidatesOther は隠す
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
      _trashesOther.initialize(trashes);
    }
  }

  Future<void> _initializeMyTiles(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? myTilesData = snapshot.data();
    if (myTilesData == null) {
      return;
    }

    final candidatesJson = myTilesData['candidates'] as List<dynamic>?;
    if (candidatesJson is List<dynamic>) {
      List<AllTileKinds> candidates = candidatesJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
      _candidatesMe.initialize(candidates);
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

    await _gameDoc.update({'doras': _doras.tiles.map((e) => e.name).toList()});
    await _setTilesAtDatabase(dealtsOther);
  }

  Future<void> _processRoundEnd() async {
    if (_myUid == _hostUid) {
      await _processRoundEndHost();
    }
  }

  Future<void> _processRoundEndHost() async {
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      int points = 10000; // TODO 得点計算
      gamePlayer.addPoints(points);
      gamePlayer.render();
    });
    // _isGameEnd の状態を一旦 False にしないと何度も得点が加算される
    Map<String, List<dynamic>> playerStatus = {
      'player_status':
          _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList(),
    };
    await _gameDoc.update(playerStatus);

    if (_isGameEnd) {
      _processGameEnd();
      return;
    }
    await _deal();
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

    if (_isTapping || _currentOrder != _currentOrder || _isRoundEnd) {
      return;
    }
    _isTapping = true;

    final touchArea = Rect.fromCenter(
      center: info.eventPosition.global.toOffset(),
      width: 2,
      height: 2,
    );

    for (final t in children) {
      if (t is FrontTile) {
        if (t.toRect().overlaps(touchArea)) {
          if (t.state == TileState.candidate) {
            bool success = await _discard(t);
            if (success) {
              break;
            }
          }
        }
      }
    }
    _isTapping = false;
  }

  Future<bool> _discard(FrontTile tile) async {
    _candidatesMe.discard(tile);
    _trashesMe.add(tile.tileKind);
    await _setTilesAtDatabase(null);

    // await _gameDoc.update({'current': (_currentOrder + 1) % 2});

    return true;
  }

  bool get _isRoundEnd {
    // TODO どう管理するか
    return false;
  }

  bool get _isGameEnd {
    return _gamePlayers.indexWhere((gamePlayer) => gamePlayer.isGameOver) >= 0;
  }

  Future<void> _setTilesAtDatabase(List<AllTileKinds>? dealtsOther) async {
    Map<String, List<String>> myTiles = {
      'candidates': _candidatesMe.tiles.map((e) => e.name).toList(),
      'dealts': _dealtsMe.tiles.map((e) => e.name).toList(),
      'hands': _handsMe.tiles.map((e) => e.name).toList(),
      'trashs': _trashesMe.tiles.map((e) => e.name).toList(),
    };
    // player_tiles 単位での更新は手間がかかるので、 collection にする
    await _gameDoc.collection('player_tiles').doc(_myUid).set(myTiles);
    if (dealtsOther is List<AllTileKinds>) {
      Map<String, List<String>> otherTiles = {
        'candidates': [],
        'dealts': dealtsOther.map((e) => e.name).toList(),
        'hands': [],
        'trashs': [],
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
}
