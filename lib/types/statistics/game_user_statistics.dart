import 'package:one_on_one_mahjong/types/statistics/int_statistics.dart';
import 'package:one_on_one_mahjong/types/statistics/stated_statistics.dart';
import 'package:one_on_one_mahjong/types/statistics/statistics_kind.dart';
import 'package:one_on_one_mahjong/types/statistics/win_name_statistics.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/types/statistics/yaku_statistics.dart';

class GameUserStatistics {
  final String _uid;
  int _totalGame = 0;
  int _winGame = 0;
  int _loseGame = 0;
  int _drawGame = 0;

  int _totalRound = 0;
  StatedStatistics _winName = StatedStatistics(WinNameStatistics());
  int _parentDrawnRound = 0;
  int _childDrawnRound = 0;
  StatedStatistics _yaku = StatedStatistics(YakuStatistics());
  StatedStatistics _pointAll = StatedStatistics(IntStatistics());
  StatedStatistics _stepAll = StatedStatistics(IntStatistics());
  List<int> _doraTrashAll = [0, 0, 0]; // [ドラ, 裏ドラ, 赤ドラ]

  GameUserStatistics(this._uid);

  GameUserStatistics.fromJson(String uid, Map<String, dynamic> json)
      : _uid = uid,
        _totalGame = int.parse(json['totalGame'].toString()),
        _winGame = int.parse(json['winGame'].toString()),
        _loseGame = int.parse(json['loseGame'].toString()),
        _drawGame = int.parse(json['drawGame'].toString()),
        _totalRound = int.parse(json['totalRound'].toString()),
        _winName = StatedStatistics.fromJson(
            json['winName'], WinNameStatistics.fromJson),
        _parentDrawnRound = int.parse(json['parentDrawnRound'].toString()),
        _childDrawnRound = int.parse(json['childDrawnRound'].toString()),
        _yaku =
            StatedStatistics.fromJson(json['yaku'], YakuStatistics.fromJson),
        _pointAll =
            StatedStatistics.fromJson(json['pointAll'], IntStatistics.fromJson),
        _stepAll =
            StatedStatistics.fromJson(json['stepAll'], IntStatistics.fromJson),
        _doraTrashAll = [
          int.parse(json['doraTrashAll'][0].toString()),
          int.parse(json['doraTrashAll'][1].toString()),
          int.parse(json['doraTrashAll'][2].toString())
        ];

  int get totalGame => _totalGame;
  int get winGame => _winGame;
  int get loseGame => _loseGame;
  int get drawGame => _drawGame;
  int get disconnectionGame => _totalGame - _winGame - _loseGame - _drawGame;
  int get winRate => (_winGame / _totalGame * 100).floor();
  int get loseRate => (_loseGame / _totalGame * 100).floor();
  int get drawRate => (_drawGame / _totalGame * 100).floor();
  int get disconnectionRate => (disconnectionGame / _totalGame * 100).floor();

  int get totalRound => _totalRound;
  int get drawnRound => _parentDrawnRound + _childDrawnRound;
  int get winRound =>
      _winName.toMapWin().values.reduce((sum, value) => sum + value);
  int get loseRound =>
      _winName.toMapLose().values.reduce((sum, value) => sum + value);
  Map<String, int> get winName => _winName.toMapWin();
  Map<String, int> get loseName => _winName.toMapLose();
  Map<String, int> get winYaku => _yaku.toMapWin();
  int get winPointAll =>
      _pointAll.toMapWin().values.reduce((sum, value) => sum + value);
  int get losePointAll =>
      _pointAll.toMapLose().values.reduce((sum, value) => sum + value);
  int get winPointAverage => (winPointAll / winRound).floor();
  int get losePointAverage => (losePointAll / loseRound).floor();
  int get winStepAll =>
      _stepAll.toMapWin().values.reduce((sum, value) => sum + value);
  int get loseStepAll =>
      _stepAll.toMapLose().values.reduce((sum, value) => sum + value);
  double get winStepAverage => (winStepAll / winRound * 100).floor() / 100;
  double get loseStepAverage => (loseStepAll / loseRound * 100).floor() / 100;

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
    StatisticsKind? statisticsKind;
    if (isParent) {
      if (isWinner && winResult != null) {
        statisticsKind = StatisticsKind.parentWin;
      } else if (!isWinner && winResult != null) {
        statisticsKind = StatisticsKind.parentLose;
      } else if (winResult == null) {
        _parentDrawnRound++;
      }
    } else {
      if (isWinner && winResult != null) {
        statisticsKind = StatisticsKind.childWin;
      } else if (!isWinner && winResult != null) {
        statisticsKind = StatisticsKind.childLose;
      } else if (winResult == null) {
        _childDrawnRound++;
      }
    }
    if (statisticsKind != null && winResult != null) {
      _winName.count(statisticsKind, winResult.winName);
      _yaku.count(statisticsKind, winResult);
      _pointAll.count(statisticsKind, winResult.winPoints);
      _stepAll.count(statisticsKind, step);
    }
    _doraTrashAll = [
      _doraTrashAll[0] + doraTrashes[0],
      _doraTrashAll[1] + doraTrashes[1],
      _doraTrashAll[2] + doraTrashes[2],
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': _uid,
      'totalGame': _totalGame,
      'winGame': _winGame,
      'loseGame': _loseGame,
      'drawGame': _drawGame,
      'totalRound': _totalRound,
      'winName': _winName.toMap(),
      'parentDrawnRound': _parentDrawnRound,
      'childDrawnRound': _childDrawnRound,
      'yaku': _yaku.toMap(),
      'pointAll': _pointAll.toMap(),
      'stepAll': _stepAll.toMap(),
      'doraTrashAll': _doraTrashAll,
    };
  }
}
