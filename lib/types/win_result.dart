import 'package:one_on_one_mahjong/constants/yaku.dart';

class WinResult {
  final List<Yaku> _yakuList;
  final List<int> _hansOfDoras; // [ドラ, 裏ドラ, 赤ドラ]

  WinResult({
    required yakuList,
    hansOfDoras,
  })  : _yakuList = yakuList ?? [],
        _hansOfDoras = hansOfDoras ?? [0, 0, 0];

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

  @override
  String toString() {
    return "_yakuList: $_yakuList\n_hansOfDoras: $_hansOfDoras";
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