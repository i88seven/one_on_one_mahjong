import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import 'package:one_on_one_mahjong/constants/game_status.dart';
import 'package:one_on_one_mahjong/constants/reach_state.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/constants/win_name.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/utils/firestore_accessor.dart';
import 'package:one_on_one_mahjong/utils/han_util.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';

const maxTrashCount = 17;

class SeventeenGame extends FlameGame with TapDetector {
  late FirestoreAccessor _firestoreAccessor;
  late final InterstitialAd _interstitialAd;
  GameUserStatisticsModel gameUserStatisticsModel;
  Images gameImages = Images();
  final AudioCache _audioCache = AudioCache();
  AudioPlayer? _prepareBgmPlayer;
  AudioPlayer? _battleBgmPlayer;
  final String _myUid;
  final String _roomId;
  bool _isTapping = false;
  Vector2 screenSize;
  final List<GamePlayer> _gamePlayers = []; // 0 が host
  late GameRound _gameRound;
  late Dealts _dealtsMe;
  late OtherDeals _dealtsOther;
  late Doras _doras;
  late Hands _handsMe;
  late OtherHands _handsOther;
  late Trashes _trashesMe;
  late Trashes _trashesOther;
  late GameResult? _gameResult;
  GameRoundResult? _gameRoundResult;
  GameStatus _gameStatus = GameStatus.init;
  final String _hostUid;
  GameTextButton? _fixHandsButton;
  GameDialog? _gameDialog;
  int _currentOrder = 0; // 0:親, 1:子
  bool _isFuriten = false;
  Map<AllTileKinds, WinResult> _reachResult = {};
  Function onGameEnd;

  static const playerCount = 2;

  SeventeenGame(this._roomId, this._myUid, this._hostUid, this.screenSize,
      this.onGameEnd, this.gameUserStatisticsModel) {
    _dealtsMe = Dealts(this);
    _dealtsOther = OtherDeals(game: this);
    _doras = Doras(game: this);
    _handsMe = Hands(game: this);
    _handsOther = OtherHands(this);
    _trashesMe = Trashes(this, true);
    _trashesOther = Trashes(this, false);
    // this.add(GameBackground(this));
  }

  Future<void> initializeHost() async {
    await _firestoreAccessor.deleteGame();
    List<Member> members = await _firestoreAccessor.getRoomMembers();
    members.sort((a, b) => a.uid == _hostUid ? -1 : 1);
    int parentIndex = Random().nextInt(2);
    String parentUid = members[parentIndex].uid;
    for (Member member in members) {
      GamePlayer gamePlayer = GamePlayer(
        game: this,
        uid: member.uid,
        name: member.name,
        status: GamePlayerStatus.selectHands,
        isMe: member.uid == _myUid,
        isParent: member.uid == parentUid,
      );
      _gamePlayers.add(gamePlayer);
      await _firestoreAccessor.initializePlayerTiles(member.uid);
    }
    await _firestoreAccessor.initializeGame(_hostUid, _gameRound, _gamePlayers);
    await _deal();
    await _firestoreAccessor.notifyStartToGame();
  }

  Future<void> initializeClient() async {
    final gameSnapshot = await _firestoreAccessor.getGameSnapshot();
    final gameData = gameSnapshot.data()!;
    final hostPlayerJson = gameData['player-host'];
    final clientPlayerJson = gameData['player-client'];
    GamePlayer hostPlayer = GamePlayer.fromJson(
        this, hostPlayerJson['uid'] == _myUid, hostPlayerJson);
    _gamePlayers.add(hostPlayer);
    _initializeOtherTiles();

    GamePlayer clientPlayer = GamePlayer.fromJson(
        this, clientPlayerJson['uid'] == _myUid, clientPlayerJson);
    _gamePlayers.add(clientPlayer);
    _firestoreAccessor.deleteRoomOnStartGame();
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    List<String> allTileImages =
        allTileKinds.values.map((tileName) => "$tileName.png").toList();
    List<String> allWinNameImages =
        WinName.values.map((winName) => "${winName.name}.png").toList();
    await gameImages.loadAll([
      'tile-back.png',
      ...allTileImages,
      ...allWinNameImages,
      'win.png',
      'lose.png',
      'draw.png',
    ]);
    String adUnitId = dotenv.env['AD_UNIT_ID'] ?? '';
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            // TODO catch
            print('InterstitialAd failed to load: $error');
          },
        ));
    if (_canPlayBgm) {
      _prepareBgmPlayer =
          await _audioCache.loop('audio/prepare_bgm.wav', volume: 0.8);
    }

    _gameRound = GameRound(this, 1, 1);
    _firestoreAccessor = FirestoreAccessor(roomId: _roomId, hostUid: _hostUid);
    if (_myUid == _hostUid) {
      await initializeHost();
    } else {
      await initializeClient();
    }
    addAll(_gamePlayers);
    add(_dealtsOther);
    add(_doras);
    add(_handsMe);
    _firestoreAccessor.listenOnChangeGame(_onChangeGame);
    await gameUserStatisticsModel.countOnGameStart(uid: _myUid);
    _handsOther.initialize();
  }

  @override
  void onRemove() {
    super.onRemove();
    _prepareBgmPlayer?.stop().then((value) => _prepareBgmPlayer?.dispose());
    _battleBgmPlayer?.stop().then((value) => _battleBgmPlayer?.dispose());
    _audioCache.clearAll();
  }

  Future<void> _onChangeGame(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic>? gameData = snapshot.data();
    if (gameData == null) {
      return;
    }

    await updatePlayers(gameData);

    if (gameData['gameStatus'] != null &&
        _gameStatus.name != gameData['gameStatus']) {
      await _onChangeGameStatus(gameData);
    }

    if (gameData['current'] != null && _currentOrder != gameData['current']) {
      _currentOrder = gameData['current'];
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.setCurrentOrder(_currentOrder);
      });
      final tilesSnapshot =
          await _firestoreAccessor.getTilesSnapshot(_other.uid);
      await _onChangeTrashesOther(tilesSnapshot.data());
    }
  }

  Future<void> _onChangeGameStatus(Map<String, dynamic> gameData) async {
    if (_gameStatus == GameStatus.trash && gameData['gameStatus'] == 'dealt') {
      return;
    }
    _gameStatus =
        EnumToString.fromString(GameStatus.values, gameData['gameStatus']) ??
            GameStatus.init;
    if (_gameStatus == GameStatus.newRound &&
        gameData['wind'] != null &&
        gameData['round'] != null) {
      _isFuriten = false;
      _reachResult = {};
      _gameRound.setRound(wind: gameData['wind'], round: gameData['round']);
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.setCurrentOrder(_currentOrder);
      });
      _initializeOtherTiles();
    }

    if (_gameStatus == GameStatus.dealt && gameData['doras'] != null) {
      _initializeOtherTiles();
      if (_myUid == _hostUid) {
        return;
      }
      final dorasJson = gameData['doras'];
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
      final myTilesSnapshot = await _firestoreAccessor.getTilesSnapshot(_myUid);
      _initializeMyTiles(myTilesSnapshot.data());
    }

    if (_gameStatus == GameStatus.trash) {
      _gamePlayers.asMap().forEach((index, gamePlayer) {
        gamePlayer.setCurrentOrder(_currentOrder);
      });
      if (_canPlayBgm) {
        await _prepareBgmPlayer?.stop();
        _battleBgmPlayer = await _audioCache.loop('audio/battle_bgm.wav');
      }
      _dealtsOther.initialize(21);
    }

    if (_gameStatus == GameStatus.ron) {
      final winner = _gamePlayers
          .firstWhereOrNull((gamePlayer) => gamePlayer.winResult != null);
      AllTileKinds targetTile = winner?.uid == _me.uid
          ? _trashesOther.tiles.last
          : _trashesMe.tiles.last;
      List<AllTileKinds> winnerHands = winner != null
          ? await _firestoreAccessor.fetchWinnerHands(winner.uid)
          : [];
      if (winner != null && _gameRoundResult == null) {
        _gameRoundResult = GameRoundResult(
            game: this,
            screenSize: screenSize,
            winResult: winner.winResult!,
            tiles: winnerHands,
            winTile: targetTile,
            doras: _doras.tiles);
        add(_gameRoundResult!);
        if (_canPlayBgm) {
          await _battleBgmPlayer?.stop();
          _prepareBgmPlayer =
              await _audioCache.loop('audio/prepare_bgm.wav', volume: 0.8);
        }
      }
    }

    if (_gameStatus == GameStatus.drawnRound) {
      if (_hostUid == _myUid) {
        _gamePlayers.asMap().forEach((index, gamePlayer) {
          gamePlayer.setStatus(GamePlayerStatus.waitRound);
        });
        await _firestoreAccessor.updateGamePlayers(_gamePlayers);
      }
      await gameUserStatisticsModel.countOnRoundEnd(
        uid: _myUid,
        isParent: _me.isParent,
        isWinner: true,
        winResult: null,
        step: maxTrashCount,
        doraTrashes: _doraTrashes,
      );
      return;
    }

    if (_gameStatus == GameStatus.gameResult) {
      await _processGameEnd();
      return;
    }
  }

  Future<void> updatePlayers(Map<String, dynamic> gameData) async {
    final hostPlayerJson = gameData['player-host'];
    final clientPlayerJson = gameData['player-client'];
    if (!mapEquals(hostPlayerJson, _gamePlayers[0].toJson()) ||
        !mapEquals(clientPlayerJson, _gamePlayers[1].toJson())) {
      _gamePlayers[0].updateFromJson(hostPlayerJson);
      _gamePlayers[1].updateFromJson(clientPlayerJson);
    }

    if (_gamePlayers[0].points != gameData['points-host']) {
      _gamePlayers[0].setPoints(gameData['points-host']);
    }
    if (_gamePlayers[1].points != gameData['points-client']) {
      _gamePlayers[1].setPoints(gameData['points-client']);
    }

    if (_gamePlayers.every(
            (gamePlayer) => gamePlayer.status == GamePlayerStatus.fixedHands) &&
        _myUid == _hostUid) {
      for (GamePlayer gamePlayer in _gamePlayers) {
        gamePlayer.setStatus(GamePlayerStatus.selectTrash);
      }
      await _firestoreAccessor.updateGameOnStartTrash(_gamePlayers);
    }

    if (_gamePlayers.every(
        (gamePlayer) => gamePlayer.status == GamePlayerStatus.waitRound)) {
      await _processNewRound();
    }
  }

  void _initializeMyTiles(Map<String, dynamic>? myTilesData) {
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

  void _initializeOtherTiles() {
    _handsOther.initialize();
    _dealtsOther.initialize(34);
    _trashesOther.initialize([]);
  }

  Future<void> _onChangeTrashesOther(
      Map<String, dynamic>? otherTilesData) async {
    if (otherTilesData == null) {
      return;
    }

    final trashesJson = otherTilesData['trashes'];
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
          _reachResult.containsKey(convertRedTile(targetTile))) {
        // リーチの段階では裏ドラはカウントされていないので、ドラの判定し直し
        final winResult = _reachResult[convertRedTile(targetTile)]!;
        if (winResult.yakumanCount == 0) {
          final winTiles = [..._handsMe.tiles, targetTile];
          final hansOfUraDora = fetchHansOfDora(winTiles, _doras.tiles[1]);
          final hansOfRedFive = fetchHansOfRedFive(winTiles);
          winResult.updateHansOfDoras(hansOfUraDora, hansOfRedFive);
          if (_isFinalTileWin) winResult.addFinalTileWin();
          if (_isFirstTurnWin) winResult.addFirstTurnWin();
        }
        if (winResult.hans >= 4 || winResult.yakumanCount >= 1) {
          // ロン!!!
          _me.setWinResult(winResult);
          _gamePlayers.asMap().forEach((index, gamePlayer) {
            gamePlayer.setStatus(GamePlayerStatus.roundResult);
          });
          await _firestoreAccessor.updateGameOnRon(_gamePlayers);
          return;
        } else {
          _isFuriten = true;
        }
      }
      final dealtsJson = otherTilesData['dealts'];
      if (dealtsJson is List<dynamic>) {
        _dealtsOther.initialize(dealtsJson.length);
      }
        await _firestoreAccessor.updateGameOnDrawnRound();
      if (_isDrawnRound) {
      }
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
    _trashesMe.initialize([]);

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
    GamePlayer? winPlayer = _gamePlayers
        .firstWhereOrNull((gamePlayer) => gamePlayer.winResult != null);
    if (winPlayer == null) {
      // TODO エラー検知
      print({'error': _gamePlayers.map((gamePlayer) => gamePlayer.toJson())});
      return;
    }
    WinResult winResult = winPlayer.winResult!;
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      if (gamePlayer.winResult != null) {
        gamePlayer.addPoints(winResult.winPoints);
      } else {
        gamePlayer.addPoints(winResult.winPoints * -1);
      }
    });
    await _firestoreAccessor.updateGameRound(_gamePlayers);
  }

  Future<void> _processNewRound() async {
    if (_myUid != _hostUid) {
      return;
    }
    if (_gameRound.isFinalGame && _gameStatus != GameStatus.drawnRound) {
      await _firestoreAccessor.updateGameOnGameEnd();
      return;
    }

    for (GamePlayer gamePlayer in _gamePlayers) {
      gamePlayer.initOnRound(_gameStatus != GameStatus.drawnRound);
    }
    if (_gameStatus != GameStatus.drawnRound) {
      _gameRound.setNewRound();
    }
    await _firestoreAccessor.updateGameOnNewRound(_gameRound, _gamePlayers);

    await _deal();
  }

  Future<void> _processGameEnd() async {
    _gameResult = GameResult(
      game: this,
      screenSize: screenSize,
      gamePlayers: _gamePlayers,
      myPoints: _me.points,
    );
    add(_gameResult!);
    await gameUserStatisticsModel.countOnGameEnd(
      uid: _myUid,
      pointDiff: _me.points - _other.points,
    );
    await _firestoreAccessor.cancelStream();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    screenSize = canvasSize;
  }

  @override
  Future<void> onTapUp(info) async {
    if (_gameStatus == GameStatus.gameResult) {
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

    if (_isTapping || _me.status == GamePlayerStatus.waitRound) {
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
                _myUid == _hostUid, _me);
            break;
          }
          if (c.kind == GameButtonKind.fixHands && _gameDialog == null) {
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
        final winner = _gamePlayers
            .firstWhereOrNull((gamePlayer) => gamePlayer.winResult != null);
        final isWinner = winner?.uid == _me.uid;
        await gameUserStatisticsModel.countOnRoundEnd(
          uid: _myUid,
          isParent: _me.isParent,
          isWinner: isWinner,
          winResult: winner?.winResult,
          step: _trashesMe.tileCount,
          doraTrashes: _doraTrashes,
        );
        remove(_gameRoundResult!.button);
        remove(_gameRoundResult!);
        _gameRoundResult = null;
        _me.setStatus(GamePlayerStatus.waitRound);
        if (_myUid == _hostUid) {
          await _processRoundEnd();
        } else {
          await _firestoreAccessor.updateTargetPlayer(_myUid == _hostUid, _me);
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
      if (c is FrontTile && _gameDialog == null && !_isDrawnRound) {
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
          position: Vector2(screenSize.x - 140, screenSize.y - 150));
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

    if (_reachResult.containsKey(convertRedTile(tile.tileKind))) {
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

  bool get _canFixHands {
    return _me.status == GamePlayerStatus.selectHands &&
        _handsMe.tileCount == 13;
  }

  List<int> get _doraTrashes {
    int doraTrash = fetchHansOfDora(_trashesMe.tiles, _doras.tiles[0]);
    int uraDoraTrash = fetchHansOfDora(_trashesMe.tiles, _doras.tiles[1]);
    int redFiveTrash = fetchHansOfRedFive(_trashesMe.tiles);
    return [doraTrash, uraDoraTrash, redFiveTrash];
  }

  Future<void> _gameEnd() async {
    if (_myUid == _hostUid) {
      await _firestoreAccessor.deleteGame();
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
    _interstitialAd.show();
    onGameEnd();
  }

  void _fetchReachResult() {
    ReachMahjongState mahjongState = ReachMahjongState(
      dora: _doras.tiles[0],
      wind: _gameRound.wind,
      round: _gameRound.round,
      isParent: _me.isParent,
    );
    _reachResult = fetchReachResult(_handsMe.tiles, mahjongState);
  }

  bool get _isDrawnRound =>
      _trashesOther.tileCount == maxTrashCount &&
      _trashesMe.tileCount == maxTrashCount &&
      _currentOrder == 0 &&
      _me.isParent;
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

  // Android では BGM を流すと大量のログが流れるので開発中は BGM を OFF
  bool get _canPlayBgm {
    return dotenv.env['MODE'] != 'dev' || !Platform.isAndroid;
  }
}
