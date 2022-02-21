import 'package:one_on_one_mahjong/types/win_name_statistics.dart';
import 'package:one_on_one_mahjong/types/yaku_statistics.dart';

class GameUserStatistics {
  final String _uid;
  int _totalGame = 0;
  int _winGame = 0;
  int _loseGame = 0;
  int _drawGame = 0;

  int _totalRound = 0;
  WinNameStatistics _parentWinRound = WinNameStatistics(prefix: 'parentWin');
  WinNameStatistics _childWinRound = WinNameStatistics(prefix: 'childWin');
  WinNameStatistics _parentLoseRound = WinNameStatistics(prefix: 'parentLose');
  WinNameStatistics _childLoseRound = WinNameStatistics(prefix: 'childLose');
  int _parentDrawnRound = 0;
  int _childDrawnRound = 0;
  YakuStatistics _winYaku = YakuStatistics(prefix: 'win');
  YakuStatistics _loseYaku = YakuStatistics(prefix: 'lose');
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

  GameUserStatistics.fromJson(String uid, Map<String, int> json)
      : _uid = uid,
        _totalGame = json['totalGame'] ?? 0,
        _winGame = json['winGame'] ?? 0,
        _loseGame = json['loseGame'] ?? 0,
        _drawGame = json['drawGame'] ?? 0,
        _totalRound = json['totalRound'] ?? 0,
        _parentWinRound = WinNameStatistics.fromJson('parentWin', json),
        _childWinRound = WinNameStatistics.fromJson('childWin', json),
        _parentLoseRound = WinNameStatistics.fromJson('parentLose', json),
        _childLoseRound = WinNameStatistics.fromJson('childLose', json),
        _parentDrawnRound = json['parentDrawnRound'] ?? 0,
        _childDrawnRound = json['childDrawnRound'] ?? 0,
        _winYaku = YakuStatistics.fromJson('win', json),
        _loseYaku = YakuStatistics.fromJson('lose', json),
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

  Map<String, dynamic> toJson() {
    return {
      'uid': _uid,
      'totalGame': _totalGame,
      'winGame': _winGame,
      'loseGame': _loseGame,
      'drawGame': _drawGame,
      'totalRound': _totalRound,
      ..._parentWinRound.toJson(),
      ..._childWinRound.toJson(),
      ..._parentLoseRound.toJson(),
      ..._childLoseRound.toJson(),
      'parentDrawnRound': _parentDrawnRound,
      'childDrawnRound': _childDrawnRound,
      ..._winYaku.toJson(),
      ..._loseYaku.toJson(),
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
