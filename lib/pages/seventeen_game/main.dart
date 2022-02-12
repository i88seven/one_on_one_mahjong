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
import 'package:one_on_one_mahjong/utils/firestore_accessor.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

const maxTrashCount = 17;

class SeventeenGame extends FlameGame with TapDetector {
  late FirestoreAccessor _firestoreAccessor;
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
    _handsMe = Hands(game: this);
    _handsOther = OtherHands(this);
    _trashesMe = Trashes(this, true);
    _trashesOther = Trashes(this, false);
    // this.add(GameBackground(this));
    _gameRoundResult = null;
  }

  Future<void> initializeHost() async {
    _gameRound = GameRound(this, 1, 1);
    _firestoreAccessor = FirestoreAccessor(roomId: _roomId, hostUid: _hostUid);
    await _firestoreAccessor.deleteGame();
    List<Member> members = await _firestoreAccessor.getRoomMembers();
    members.asMap().forEach((index, member) {
      if (member.uid == _myUid) {
        _currentOrder = index;
      }
    });
    List<String> memberUids = members.map((member) => member.uid).toList();
    // memberUids の index == 0 が親になる
    memberUids.shuffle();
    String parentUid = memberUids.first;
    for (String memberUid in memberUids) {
      Member member = members.firstWhere((member) => member.uid == memberUid);
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        GamePlayerStatus.selectHands,
        member.uid == _myUid,
        member.uid == parentUid,
      );
      _gamePlayers.add(gamePlayer);
      await _firestoreAccessor.initializePlayerTiles(member.uid);
      if (member.uid != _myUid) {
        _firestoreAccessor.listenPlayerTilesDoc(
            member.uid, _onChangeOtherTiles);
      }
    }
    await _firestoreAccessor.initializeGame(_hostUid, _gameRound, _gamePlayers);
    await _deal();
    await _firestoreAccessor.notifyStartToGame();
    add(_handsMe);
    _firestoreAccessor.listenOnChangeGame(_onChangeGame);
  }

  Future<void> initializeSlave() async {
    _gameRound = GameRound(this, 1, 1);
    _firestoreAccessor = FirestoreAccessor(roomId: _roomId, hostUid: _hostUid);
    final gameSnapshot = await _firestoreAccessor.getGameSnapshot();
    await _onChangeGame(gameSnapshot);

    for (GamePlayer gamePlayer in _gamePlayers) {
      if (gamePlayer.uid != _myUid) {
        _firestoreAccessor.listenPlayerTilesDoc(
            gamePlayer.uid, _onChangeOtherTiles);
        final tilesSnapshot =
            await _firestoreAccessor.getTilesSnapshot(gamePlayer.uid);
        await _onChangeOtherTiles(tilesSnapshot);
      } else {
        final tilesSnapshot =
            await _firestoreAccessor.fetchTilesData(gamePlayer.uid);
        await _initializeMyTiles(tilesSnapshot);
      }
    }
    _firestoreAccessor.deleteRoomOnStartGame();
    add(_handsMe);
    _firestoreAccessor.listenOnChangeGame(_onChangeGame);
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
        await _processGameEnd();
        return;
      }
    }
    if (gameData['round'] != null) {
      _gameRound.setRound(round: gameData['round']);
    }

    final parentPlayerJson = gameData['player-0'];
    final childPlayerJson = gameData['player-1'];
    if (_gamePlayers.isEmpty) {
      if (parentPlayerJson != null && childPlayerJson != null) {
        GamePlayer parentPlayer = GamePlayer.fromJson(
            this, parentPlayerJson['uid'] == _myUid, parentPlayerJson);
        _gamePlayers.add(parentPlayer);
        GamePlayer childPlayer = GamePlayer.fromJson(
            this, childPlayerJson['uid'] == _myUid, childPlayerJson);
        _gamePlayers.add(childPlayer);
      }
    } else if (!mapEquals(parentPlayerJson, _gamePlayers[0].toJson()) ||
        !mapEquals(childPlayerJson, _gamePlayers[1].toJson())) {
      GamePlayerStatus oldMyStatus = _me.status;
      GamePlayerStatus oldOtherStatus = _other.status;
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        // TODO update に変更
        gamePlayer.remove();
      });
      _gamePlayers.clear();
      GamePlayer parentPlayer = GamePlayer.fromJson(
          this, parentPlayerJson['uid'] == _myUid, parentPlayerJson);
      _gamePlayers.add(parentPlayer);
      GamePlayer childPlayer = GamePlayer.fromJson(
          this, childPlayerJson['uid'] == _myUid, childPlayerJson);
      _gamePlayers.add(childPlayer);
      if (_me.status == GamePlayerStatus.roundResult &&
          _gameRoundResult == null) {
        final winner = _gamePlayers
            .firstWhere((gamePlayer) => gamePlayer.winResult != null);
        AllTileKinds targetTile = winner.uid == _me.uid
            ? _trashesOther.tiles.last
            : _trashesMe.tiles.last;
        List<AllTileKinds> winnerHands =
            await _firestoreAccessor.fetchOtherHands(winner.uid);
        if (_gameRoundResult == null) {
          _gameRoundResult = GameRoundResult(
              game: this,
              screenSize: screenSize,
              winResult: winner.winResult!,
              tiles: winnerHands,
              winTile: targetTile,
              doras: _doras.tiles);
          add(_gameRoundResult!);
        }
      }
      if (_gamePlayers.every(
          (gamePlayer) => gamePlayer.status == GamePlayerStatus.waitRound)) {
        await _processNewRound(isDrawnGame: false);
      }
      if (oldMyStatus == GamePlayerStatus.waitRound &&
          _me.status == GamePlayerStatus.selectHands) {
        final tilesSnapshot = await _firestoreAccessor.fetchTilesData(_myUid);
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
      await _firestoreAccessor.updateGamePlayers(_gamePlayers);
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
        if (winResult.yakumanCount == 0) {
          if (_isFinalTileWin) winResult.addFinalTileWin();
          if (_isFirstTurnWin) winResult.addFirstTurnWin();
        }
        if (winResult.hans >= 4 || winResult.yakumanCount >= 1) {
          // ロン!!!
          _me.winResult = winResult;
          _gamePlayers.asMap().forEach((index, gamePlayer) {
            gamePlayer.setStatus(GamePlayerStatus.roundResult);
          });
          await _firestoreAccessor.updateGamePlayers(_gamePlayers);
          if (_gameRoundResult == null) {
            _gameRoundResult = GameRoundResult(
                game: this,
                screenSize: screenSize,
                winResult: winResult,
                tiles: _handsMe.tiles,
                winTile: targetTile,
                doras: _doras.tiles);
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

  Future<void> _initializeMyTiles(Map<String, dynamic>? myTilesData) async {
    print({'_initializeMyTiles': myTilesData});
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
    _handsMe.initialize([]);

    _gamePlayers.asMap().forEach((index, gamePlayer) {
      gamePlayer.setStatus(GamePlayerStatus.selectHands);
    });
    await _firestoreAccessor.setTiles(
      dealtsMe: _dealtsMe,
      handsMe: _handsMe,
      trashesMe: _trashesMe,
      myUid: _myUid,
      dealtsOther: dealtsOther,
      gamePlayers: _gamePlayers,
    );
    await _firestoreAccessor.updateGameAsDeal(_doras, _gamePlayers);
  }

  Future<void> _processRoundEnd() async {
    if (_myUid != _hostUid) {
      return;
    }
    if (_isDrawnGame) {
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.setStatus(GamePlayerStatus.waitRound);
      });
      await _firestoreAccessor.updateGamePlayers(_gamePlayers);
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
    await _firestoreAccessor.updateGamePlayers(_gamePlayers);
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
      _currentOrder = 0;
      _gameRound.setRound(wind: 5, round: 1);
      await _firestoreAccessor.updateGameOnNewRound(
          _currentOrder, _gameRound, _gamePlayers);
      await _processGameEnd();
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
    await _firestoreAccessor.updateGameOnNewRound(
        _currentOrder, _gameRound, _gamePlayers);
  }

  Future<void> _initOnRoundSlave() async {
    String parentUid = _gamePlayers.first.uid;
    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.initOnRound(parentUid);
    }
    await _firestoreAccessor.updateGamePlayers(_gamePlayers);
  }

  Future<void> _processGameEnd() async {
    _gameResult = GameResult(
        game: this, screenSize: screenSize, gamePlayers: _gamePlayers);
    add(_gameResult!);
    await _firestoreAccessor.cancelStream();
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
            _gameDialog = null;
            break;
          }
          if (c.kind == GameButtonKind.dialogOk) {
            removeAll(_gameDialog!.buttons);
            remove(_gameDialog!);
            _gameDialog = null;
            remove(_fixHandsButton!);
            await _firestoreAccessor.setTiles(
              dealtsMe: _dealtsMe,
              handsMe: _handsMe,
              trashesMe: _trashesMe,
              myUid: _myUid,
              gamePlayers: _gamePlayers,
            );
            _me.setStatus(GamePlayerStatus.fixedHands);
            await _firestoreAccessor.updateTargetPlayer(
                _me.isParent ? 0 : 1, _me);
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
      if (c is GameRoundResult &&
          c.button.toRect().contains(info.eventPosition.global.toOffset())) {
        remove(_gameRoundResult!.button);
        remove(_gameRoundResult!);
        _gameRoundResult = null;
        _me.setStatus(GamePlayerStatus.waitRound);
        await _firestoreAccessor.updateTargetPlayer(_me.isParent ? 0 : 1, _me);
        await _processRoundEnd();
        if (_gamePlayers.every(
            (gamePlayer) => gamePlayer.status == GamePlayerStatus.waitRound)) {
          await _processNewRound(isDrawnGame: false);
        }
        break;
      }
      if (c is Hands) {
        for (final tile in c.children) {
          if (tile is FrontTile && _gameDialog == null) {
            if (tile.toRect().shift(Offset(c.x, c.y)).overlaps(touchArea)) {
              if (tile.state == TileState.hand &&
                  _me.status == GamePlayerStatus.selectHands) {
                bool success = _unselectTile(tile);
                if (success) {
                  break;
                }
              }
            }
          }
        }
      }
      if (c is FrontTile && _gameDialog == null) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == TileState.dealt &&
              _me.status == GamePlayerStatus.selectHands) {
            bool success = _selectTile(c);
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
    _handsMe.addTile(tile.tileKind);
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
    await _firestoreAccessor.setTiles(
      dealtsMe: _dealtsMe,
      handsMe: _handsMe,
      trashesMe: _trashesMe,
      myUid: _myUid,
      gamePlayers: _gamePlayers,
    );

    if (_reachResult.containsKey(tile.tileKind)) {
      _isFuriten = true;
    }
    await _firestoreAccessor.updateCurrentOrder(_currentOrder);

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
        _gamePlayers.every((gamePlayer) =>
            gamePlayer.status == GamePlayerStatus.selectTrash) &&
        _currentOrder == 0;
  }

  bool get _canFixHands {
    return _me.status == GamePlayerStatus.selectHands &&
        _handsMe.tileCount == 13;
  }

  bool get _isRoundEnd {
    return _me.status == GamePlayerStatus.waitRound;
  }

  Future<void> _gameEnd() async {
    if (_myUid == _hostUid) {
      await _firestoreAccessor.deleteGame();
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
