import 'package:one_on_one_mahjong/constants/win_name.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';

class WinResult {
  final List<Yaku> _yakuList;
  List<int> _hansOfDoras; // [ドラ, 裏ドラ, 赤ドラ]

  WinResult({
    required List<Yaku>? yakuList,
    List<int>? hansOfDoras,
  })  : _yakuList = yakuList ?? [Yaku.reach],
        _hansOfDoras = hansOfDoras ?? [0, 0, 0];

  void addFirstTurnWin() {
    _yakuList.insert(0, Yaku.firstTurnWin);
  }

  void addFinalTileWin() {
    _yakuList.insert(0, Yaku.finalTileWin);
  }

  void updateHansOfUraDora(int hansOfUraDora) {
    _hansOfDoras = [_hansOfDoras[0], hansOfUraDora, _hansOfDoras[2]];
  }

  int get hans => resultMap.fold(0, (int p, resultRow) => p + resultRow.hans);

  List<ResultRow> get resultMap {
    List<ResultRow> result = [];
    if (_hansOfDoras[0] > 0) {
      result.add(ResultRow(Yaku.dora, _hansOfDoras[0]));
    }
    if (_hansOfDoras[1] > 0) {
      result.add(ResultRow(Yaku.uraDora, _hansOfDoras[1]));
    }
    if (_hansOfDoras[2] > 0) {
      result.add(ResultRow(Yaku.redFive, _hansOfDoras[2]));
    }
    for (Yaku yaku in _yakuList) {
      result.add(ResultRow(yaku, hanMap[yaku] ?? 0));
    }
    return result;
  }

  int get yakumanCount =>
      yakumanList.where((yakuman) => _yakuList.contains(yakuman)).length;

  int get winPoints {
    if (yakumanCount >= 1) return 32000 * yakumanCount;
    if (hans >= 13) return 32000;
    if (hans >= 11) return 24000;
    if (hans >= 8) return 16000;
    if (hans >= 6) return 12000;
    if (hans >= 4) return 8000;
    return 0; // TODO エラー
  }

  WinName? get winName {
    if (yakumanCount >= 1) return WinName.yakuman;
    if (hans >= 13) return WinName.kazoeYakuman;
    if (hans >= 11) return WinName.sanbaiman;
    if (hans >= 8) return WinName.baiman;
    if (hans >= 6) return WinName.haneman;
    if (hans >= 4) return WinName.mangan;
    return null;
  }

  @override
  String toString() {
    return "_yakuList: $_yakuList\n_hansOfDoras: $_hansOfDoras";
  }

  toJson() {
    return {
      'yakuList': _yakuList.map((tile) => tile.name).toList(),
      'hansOfDoras': _hansOfDoras,
    };
  }
}

class ResultRow {
  final Yaku yaku;
  final int hans;
  ResultRow(this.yaku, this.hans);

  String get yakuName => nameMap[yaku] ?? '';

  @override
  String toString() {
    return yakumanList.contains(yaku) ? yakuName : "$yakuName : $hans翻";
  }
}
