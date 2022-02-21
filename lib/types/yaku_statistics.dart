import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class YakuStatistics {
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

  YakuStatistics.fromJson(Map<String, dynamic> json)
      : _yakuMap = Map.fromIterables(
            Yaku.values, Yaku.values.map((yaku) => json[yaku.name] ?? 0)),
        _doraAll = json['doraAll'] ?? 0,
        _uraDoraAll = json['uraDoraAll'] ?? 0,
        _redFiveAll = json['redFiveAll'] ?? 0;

  void count({required WinResult winResult}) {
    _yakuMap = Map.fromIterables(
        Yaku.values,
        Yaku.values.map((yaku) =>
            (_yakuMap[yaku] ?? 0) +
            (winResult.yakuList.contains(yaku) ? 1 : 0)));
    _doraAll = _doraAll + winResult.hansOfDoras[0];
    _uraDoraAll = _uraDoraAll + winResult.hansOfDoras[1];
    _redFiveAll = _redFiveAll + winResult.hansOfDoras[2];
  }

  Map<String, int> toJson() {
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
