import 'package:one_on_one_mahjong/types/win_name_statistics.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/types/yaku_statistics.dart';

class GameUserStatistics {
  final String _uid;
  int _totalGame = 0;
  int _winGame = 0;
  int _loseGame = 0;
  int _drawGame = 0;

  int _totalRound = 0;
  WinNameStatistics _parentWinRound = WinNameStatistics();
  WinNameStatistics _childWinRound = WinNameStatistics();
  WinNameStatistics _parentLoseRound = WinNameStatistics();
  WinNameStatistics _childLoseRound = WinNameStatistics();
  int _parentDrawnRound = 0;
  int _childDrawnRound = 0;
  YakuStatistics _winYaku = YakuStatistics();
  YakuStatistics _loseYaku = YakuStatistics();
  int _parentWinPointAll = 0;
  int _childWinPointAll = 0;
  int _parentLosePointAll = 0;
  int _childLosePointAll = 0;
  int _parentWinStepAll = 0;
  int _childWinStepAll = 0;
  int _parentLoseStepAll = 0;
  int _childLoseStepAll = 0;
  int _doraTrashAll = 0;
  int _uraDoraTrashAll = 0;
  int _redFiveTrashAll = 0;

  GameUserStatistics(this._uid);

  GameUserStatistics.fromJson(String uid, Map<String, dynamic> json)
      : _uid = uid,
        _totalGame = json['totalGame'] ?? 0,
        _winGame = json['winGame'] ?? 0,
        _loseGame = json['loseGame'] ?? 0,
        _drawGame = json['drawGame'] ?? 0,
        _totalRound = json['totalRound'] ?? 0,
        _parentWinRound = WinNameStatistics.fromJson(json['parentWin']),
        _childWinRound = WinNameStatistics.fromJson(json['childWin']),
        _parentLoseRound = WinNameStatistics.fromJson(json['parentLose']),
        _childLoseRound = WinNameStatistics.fromJson(json['childLose']),
        _parentDrawnRound = json['parentDrawnRound'] ?? 0,
        _childDrawnRound = json['childDrawnRound'] ?? 0,
        _winYaku = YakuStatistics.fromJson(json['winYaku']),
        _loseYaku = YakuStatistics.fromJson(json['loseYaku']),
        _parentWinPointAll = json['parentWinPointAll'] ?? 0,
        _childWinPointAll = json['childWinPointAll'] ?? 0,
        _parentLosePointAll = json['parentLosePointAll'] ?? 0,
        _childLosePointAll = json['childLosePointAll'] ?? 0,
        _parentWinStepAll = json['parentWinStepAll'] ?? 0,
        _childWinStepAll = json['childWinStepAll'] ?? 0,
        _parentLoseStepAll = json['parentLoseStepAll'] ?? 0,
        _childLoseStepAll = json['childLoseStepAll'] ?? 0,
        _doraTrashAll = json['doraTrashAll'] ?? 0,
        _uraDoraTrashAll = json['uraDoraTrashAll'] ?? 0,
        _redFiveTrashAll = json['redFiveTrashAll'] ?? 0;

  int get disconnectionGame => _totalGame - _winGame - _loseGame - _drawGame;

  void countOnGameStart() {
    _totalGame++;
  }

  /// Count as statistics data.
  ///
  /// Consider as win if pointDiff > 0.
  /// Consider as lose if pointDiff < 0.
  /// Consider as draw if pointDiff == 0.
  void countOnGameEnd({required int pointDiff}) {
    if (pointDiff > 0) {
      _winGame++;
    } else if (pointDiff < 0) {
      _loseGame++;
    } else {
      _drawGame++;
    }
  }

  void countOnRoundEnd({
    required bool isParent,
    required bool isWinner,
    required WinResult? winResult,
    required int step,
    required List<int> doraTrashes,
  }) {
    _totalRound++;
    if (isParent) {
      if (isWinner && winResult != null) {
        _parentWinRound.count(winName: winResult.winName);
        _parentWinPointAll += winResult.winPoints;
        _parentWinStepAll += step;
      } else if (!isWinner && winResult != null) {
        _parentLoseRound.count(winName: winResult.winName);
        _parentLosePointAll += winResult.winPoints;
        _parentLoseStepAll += step;
      } else if (winResult == null) {
        _parentDrawnRound++;
      }
    } else {
      if (isWinner && winResult != null) {
        _childWinRound.count(winName: winResult.winName);
        _childWinPointAll += winResult.winPoints;
        _childWinStepAll += step;
      } else if (!isWinner && winResult != null) {
        _childLoseRound.count(winName: winResult.winName);
        _childLosePointAll += winResult.winPoints;
        _childLoseStepAll += step;
      } else if (winResult == null) {
        _childDrawnRound++;
      }
    }
    if (isWinner && winResult != null) {
      _winYaku.count(winResult: winResult);
    } else if (!isWinner && winResult != null) {
      _loseYaku.count(winResult: winResult);
    }
    _doraTrashAll += doraTrashes[0];
    _uraDoraTrashAll += doraTrashes[1];
    _redFiveTrashAll += doraTrashes[2];
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': _uid,
      'totalGame': _totalGame,
      'winGame': _winGame,
      'loseGame': _loseGame,
      'drawGame': _drawGame,
      'totalRound': _totalRound,
      'parentWin': _parentWinRound.toJson(),
      'childWin': _childWinRound.toJson(),
      'parentLose': _parentLoseRound.toJson(),
      'childLose': _childLoseRound.toJson(),
      'parentDrawnRound': _parentDrawnRound,
      'childDrawnRound': _childDrawnRound,
      'winYaku': _winYaku.toJson(),
      'loseYaku': _loseYaku.toJson(),
      'parentWinPointAll': _parentWinPointAll,
      'childWinPointAll': _childWinPointAll,
      'parentLosePointAll': _parentLosePointAll,
      'childLosePointAll': _childLosePointAll,
      'parentWinStepAll': _parentWinStepAll,
      'childWinStepAll': _childWinStepAll,
      'parentLoseStepAll': _parentLoseStepAll,
      'childLoseStepAll': _childLoseStepAll,
      'doraTrashAll': _doraTrashAll,
      'uraDoraTrashAll': _uraDoraTrashAll,
      'redFiveTrashAll': _redFiveTrashAll,
    };
  }
}
