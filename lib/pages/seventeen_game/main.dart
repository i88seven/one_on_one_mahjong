import 'dart:ui';
import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/assets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_on_one_mahjong/components/candidates.dart';
import 'package:one_on_one_mahjong/components/dealts.dart';
import 'package:one_on_one_mahjong/components/doras.dart';
import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/components/game_end_button.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result.dart';
import 'package:one_on_one_mahjong/components/game_start_button.dart';

import 'package:one_on_one_mahjong/components/hands.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/other_hands.dart';
import 'package:one_on_one_mahjong/components/trashes.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/types/game_data.dart';
import 'package:one_on_one_mahjong/types/player_tile.dart';

class SeventeenGame extends FlameGame with TapDetector {
  Images gameImages = Images();
  late String _myUid;
  final String _roomId;
  bool _isReadyGame = false;
  bool _isTapping = false;
  final List<Member> _members = [];
  final List<GamePlayer> _gamePlayers = [];
  late Dealts _dealtsMe;
  late Dealts _dealtsOther;
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
  late GameStartButton _gameStartButton;
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this.onGameEnd) {
    _myUid = 'user123'; // TODO
    _gameResult = GameResult(this, _gamePlayers);
    _dealtsMe = Dealts(this);
    _dealtsOther = Dealts(this);
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
    _members.asMap().forEach((index, member) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });
    await _gameDoc.set({
      'hostId': _hostUid,
      'players': _gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList()
    });
    for (GamePlayer gamePlayer in _gamePlayers) {
      _gameDoc
          .collection('players')
          .doc(gamePlayer.uid)
          .set({'name': gamePlayer.name});
    }
  }

  Future<void> initializeSlave({hostUid = String}) async {
    _hostUid = hostUid;
    _gameDoc = _firestoreReference.collection('games').doc(_hostUid);
    _streams.add(_gameDoc.snapshots().listen(_onChangeGame));

    QuerySnapshot playersSnapshot = await _gameDoc.collection('players').get();
    final _members = playersSnapshot.docs.map((QueryDocumentSnapshot doc) {
      final memberData = doc.data()! as Map<String, dynamic>;
      Member member = Member(uid: doc.id, name: memberData['name']);
      return member;
    }).toList();
    // TODO _isParent;
    _members.asMap().forEach((index, member) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });
  }

  @override
  Future<void>? onLoad() async {
    await gameImages.loadAll(['tile.png', 'tile-back.png']);
    await super.onLoad();
    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.render();
    }
    OtherHands otherHands = OtherHands(this);
    otherHands.initialize();
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
    //   }
    //   return;
    // }
    // if (e.snapshot.key == 'players') {
    //   e.snapshot.value.asMap().forEach((index, gamePlayer) {
    //     if (_gamePlayers.isNotEmpty) {
    //       _gamePlayers[index].set(gamePlayer['points']);
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

  Future<void> _deal() async {
    List<AllTileKinds> stocks = [...allTiles];
    stocks.shuffle();
    _candidatesMe.initialize(stocks.sublist(0, 34));
    stocks.removeRange(0, 34);
    _candidatesOther.initialize(stocks.sublist(0, 34));
    stocks.removeRange(0, 34);
    _doras.initialize(stocks.sublist(0, 2));
    stocks.removeRange(0, 2);

    await _setTilesAtDatabase();
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
  Future<void> onTapUp(info) async {
    if (!_isReadyGame) {
      for (final t in children) {
        if (t is GameStartButton &&
            t.toRect().contains(info.eventPosition.global.toOffset())) {
          _isReadyGame = true;
          remove(_gameStartButton);
          if (_myUid == _hostUid) {
            await _deal();
          }
        }
      }
      return;
    }

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
    _handsMe.discard(tile.tileKind);
    _trashesMe.add(tile.tileKind);
    await _setTilesAtDatabase();

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

  Future<void> _setTilesAtDatabase() async {
    Map<String, List<AllTileKinds>> myTiles = {
      'candidates': _candidatesMe.tiles,
      'trashs': _trashesMe.tiles,
      'hands': _handsMe.tiles,
    };
    await _gameDoc.update(myTiles);
  }

  Future<void> _gameEnd() async {
    if (_myUid == _hostUid) {
      await _gameDoc.delete();
    }
    onGameEnd();
  }
}
