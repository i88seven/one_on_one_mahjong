import 'package:one_on_one_mahjong/constants/yaku.dart';

class WinResult {
  final List<Yaku> _yakuList;
  final List<int> _hansOfDoras; // [ドラ, 裏ドラ, 赤ドラ]

  WinResult({
    required yakuList,
    hansOfDoras,
  })  : _yakuList = yakuList ?? [],
        _hansOfDoras = hansOfDoras ?? [0, 0, 0];

  void addReach() {
    _yakuList.insert(0, Yaku.reach);
  }

  void addFirstTurnWin() {
    _yakuList.insert(0, Yaku.firstTurnWin);
  }

  int get hans {
    return resultMap.fold(0, (int p, resultRow) => p + resultRow.hans);
  }

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
    return "$yaku : $hans";
  }
}
