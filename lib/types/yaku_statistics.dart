import 'package:one_on_one_mahjong/constants/yaku.dart';

class YakuStatistics {
  final Map<Yaku, int> _yakuMap;
  final int _doraAll;
  final int _uraDoraAll;
  final int _redFiveAll;

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
