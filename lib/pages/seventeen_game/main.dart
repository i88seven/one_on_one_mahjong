import 'dart:ui';
import 'dart:async';

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
  final List<Member> _members = [];
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
  String _hostUid = '';
  bool _isParent = false;
  int _currentOrder = 0; // 0:親, 1:子
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this.screenSize, this.onGameEnd) {
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
    await _storage.ready;
    _myUid = _storage.getItem('myUid');
    DocumentReference roomDoc =
        _firestoreReference.collection('preparationRooms').doc(_roomId);
    DocumentSnapshot roomSnapshot = await roomDoc.get();
    final roomData = roomSnapshot.data()! as Map<String, dynamic>;
    _hostUid = roomData['hostUid'];
    _gameDoc = _firestoreReference.collection('games').doc(_hostUid);
    // await _gameDoc.delete();
    _streams.add(_gameDoc.snapshots().listen(_onChangeGame));
    final membersSnapshot = await roomDoc.collection('members').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> membersDoc =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            membersSnapshot.docs);
    for (QueryDocumentSnapshot<Map<String, dynamic>> memberDoc in membersDoc) {
      final memberData = memberDoc.data();
      Member member = Member(
        uid: memberDoc.id,
        name: memberData['name'],
      );
      _members.add(member);
    }
    _members.asMap().forEach((index, member) {
      if (member.uid == _myUid) {
        _currentOrder = index;
      }
    });
    for (var member in _members) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
      await _gameDoc.collection('player_tiles').doc(member.uid).set({
        'dealts': [],
        'candidates': [],
        'trashs': [],
        'hands': [],
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
      'hostId': _hostUid,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
    });
  }

  Future<void> initializeSlave({hostUid = String}) async {
    await _storage.ready;
    _myUid = _storage.getItem('myUid');
    _hostUid = hostUid;
    _gameDoc = _firestoreReference.collection('games').doc(_hostUid);
    _streams.add(_gameDoc.snapshots().listen(_onChangeGame));

    DocumentSnapshot gameSnapshot = await _gameDoc.get();

    final gameData = gameSnapshot.data()! as Map<String, dynamic>;
    final players = gameData['players'];
    for (var gamePlayerJson in players) {
      GamePlayer gamePlayer = GamePlayer.fromJson(
          this, gamePlayerJson['uid'] == _myUid, gamePlayerJson);
      _gamePlayers.add(gamePlayer);

      Member member = Member(uid: gamePlayer.uid, name: gamePlayer.name);
      _members.add(member);
    }
    // TODO _isParent;
  }

  @override
  Future<void>? onLoad() async {
    List<String> allTileImageName =
        allTileKinds.values.map((tileName) => "$tileName.png").toList();
    await gameImages.loadAll([
      'tile-back.png',
      ...allTileImageName,
    ]);
    await super.onLoad();
    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.render();
    }
    OtherHands otherHands = OtherHands(this);
    otherHands.initialize();
    if (_myUid == _hostUid) {
      await _deal();
    }
  }

  Future<void> _onChangeGame(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return;
    }
    // if (data == 'cards') {
    //   List<List<dynamic>> playersTiles =
    //       List<List<dynamic>>.from(data.players);

    //   // hands の initialize の前に trash を initialize する
    //   _trashesMe.initialize(
    //     List<AllTileKinds>.from(e.snapshot.value['trashes'] ?? []),
    //   );

    //   playersTiles.asMap().forEach((i, playerTiles) {
    //     if (i == _currentOrder) {
    //       _handsMe.initialize(List<AllTileKinds>.from(playerTiles));
    //       return;
    //     }
    //   });

    //   if (_isRoundEnd) {
    //     await _processRoundEnd();
    //     return;
    //   }
    //   return;
    // }
    // if (e.snapshot.key == 'current') {
    //   _currentOrder = e.snapshot.value;
    //   for (var gamePlayer in _gamePlayers) {
    //     gamePlayer.updateTurn((_currentOrder == 1) ^ _isParent);
    //     gamePlayer.render();
    //   }
    //   return;
    // }
    // if (e.snapshot.key == 'players') {
    //   e.snapshot.value.asMap().forEach((index, gamePlayer) {
    //     if (_gamePlayers.isNotEmpty) {
    //       _gamePlayers[index].set(gamePlayer['points']);
    // TODO render
    //     }
    //   });
    //   if (_isGameEnd) {
    //     _processGameEnd();
    //     return;
    //   }
    //   if (_isRoundEnd) {
    //     await _processRoundEnd();
    //   }
    //   return;
    // }
  }

  Future<void> _onChangeOtherTiles(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? data = snapshot.data();
    print({'data': data});
    if (data == null) {
      return;
    }
  }

  Future<void> _deal() async {
    List<AllTileKinds> stocks = [...allTiles];
    stocks.shuffle();
    _dealtsMe.initialize(stocks.sublist(0, 34));
    stocks.removeRange(0, 34);
    List<AllTileKinds> dealtsOther = stocks.sublist(0, 34);
    _dealtsOther.initialize(dealtsOther.length);
    stocks.removeRange(0, 34);
    _doras.initialize(stocks.sublist(0, 2));
    stocks.removeRange(0, 2);

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

    // await _gameDoc.set({'current': (_currentOrder + 1) % 2});

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
      'dealts': _dealtsMe.tiles.map((e) => e.name).toList(),
      'candidates': _candidatesMe.tiles.map((e) => e.name).toList(),
      'trashs': _trashesMe.tiles.map((e) => e.name).toList(),
      'hands': _handsMe.tiles.map((e) => e.name).toList(),
    };
    await _gameDoc.collection('player_tiles').doc(_myUid).set(myTiles);
    if (dealtsOther is List<AllTileKinds>) {
      Map<String, List<String>> otherTiles = {
        'dealts': dealtsOther.map((e) => e.name).toList(),
        'candidates': [],
        'trashs': [],
        'hands': [],
      };
      Member otherMember =
          _members.firstWhere((member) => member.uid != _myUid);
      await _gameDoc
          .collection('player_tiles')
          .doc(otherMember.uid)
          .set(otherTiles);
    }
  }

  Future<void> _gameEnd() async {
    if (_myUid == _hostUid) {
      QuerySnapshot playerTilesSnapshot =
          await _gameDoc.collection('player_tiles').get();
      for (QueryDocumentSnapshot element in playerTilesSnapshot.docs) {
        element.reference.delete();
      }
      await _gameDoc.delete();
    }
    onGameEnd();
  }
}
