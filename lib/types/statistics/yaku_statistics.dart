import 'package:collection/collection.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/statistics/statistics_item.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class YakuStatistics implements StatisticsItem {
  Map<Yaku, int> _yakuMap;
  int _doraAll;
  int _uraDoraAll;
  int _redFiveAll;

  YakuStatistics({
    Map<Yaku, int>? yakuMap,
    int? doraAll,
    int? uraDoraAll,
    int? redFiveAll,
  })  : _yakuMap = yakuMap ??
            Map.fromIterables(Yaku.values, List.filled(Yaku.values.length, 0)),
        _doraAll = doraAll ?? 0,
        _uraDoraAll = uraDoraAll ?? 0,
        _redFiveAll = redFiveAll ?? 0;

  @override
  YakuStatistics.fromJson(Map<String, int> json)
      : _yakuMap = Map.fromIterables(Yaku.values,
            Yaku.values.map((yaku) => int.parse(json[yaku.name].toString()))),
        _doraAll = int.parse(json['doraAll'].toString()),
        _uraDoraAll = int.parse(json['uraDoraAll'].toString()),
        _redFiveAll = int.parse(json['redFiveAll'].toString());

  @override
  void count(value) {
    WinResult winResult = value;
    _yakuMap = Map.fromIterables(
        Yaku.values,
        Yaku.values.map((yaku) =>
            (_yakuMap[yaku] ?? 0) +
            (winResult.resultMap.map((result) => result.yaku).contains(yaku)
                ? 1
                : 0)));
    List<int> countedDoras =
        [Yaku.dora, Yaku.uraDora, Yaku.redFive].map((yaku) {
      final doraResult =
          winResult.resultMap.firstWhereOrNull((result) => result.yaku == yaku);
      return doraResult != null ? doraResult.hans : 0;
    }).toList();
    _doraAll += countedDoras[0];
    _uraDoraAll += countedDoras[1];
    _redFiveAll += countedDoras[2];
  }

  @override
  Map<String, int> toMap() {
    return {
      ...Map.fromIterables(Yaku.values.map((yaku) => yaku.name),
          Yaku.values.map((yaku) => _yakuMap[yaku] ?? 0)),
      'doraAll': _doraAll,
      'uraDoraAll': _uraDoraAll,
      'redFiveAll': _redFiveAll,
    };
  }

  Map<String, String> toNameMap() {
    Map<String, String> yakuNameMap = {};
    nameMap.forEach((key, value) {
      yakuNameMap[value] = _yakuMap[key].toString();
    });
    return {
      ...yakuNameMap,
      'ドラ合計': _doraAll.toString(),
      '裏ドラ合計': _uraDoraAll.toString(),
      '赤ドラ合計': _redFiveAll.toString(),
    };
  }
}
