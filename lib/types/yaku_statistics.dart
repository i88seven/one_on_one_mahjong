import 'package:one_on_one_mahjong/constants/yaku.dart';

class YakuStatistics {
  final String _prefix;
  final Map<Yaku, int> _yakuMap;
  final int _doraAll;
  final int _uraDoraAll;
  final int _redFiveAll;

  YakuStatistics({
    required String prefix,
    Map<Yaku, int>? yakuMap,
    int? doraAll,
    int? uraDoraAll,
    int? redFiveAll,
  })  : _prefix = prefix,
        _yakuMap = yakuMap ??
            Map.fromIterables(Yaku.values, List.filled(Yaku.values.length, 0)),
        _doraAll = doraAll ?? 0,
        _uraDoraAll = uraDoraAll ?? 0,
        _redFiveAll = redFiveAll ?? 0;

  YakuStatistics.fromJson(String prefix, Map<String, int> json)
      : _prefix = prefix,
        _yakuMap = Map.fromIterables(Yaku.values,
            Yaku.values.map((yaku) => json["${prefix}_${yaku.name}"] ?? 0)),
        _doraAll = json["${prefix}_doraAll"] ?? 0,
        _uraDoraAll = json["${prefix}_uraDoraAll"] ?? 0,
        _redFiveAll = json["${prefix}_redFiveAll"] ?? 0;

  Map<String, int> toJson() {
    return {
      ...Map.fromIterables(Yaku.values.map((yaku) => "${_prefix}_${yaku.name}"),
          Yaku.values.map((yaku) => _yakuMap[yaku] ?? 0)),
      "${_prefix}_doraAll": _doraAll,
      "${_prefix}_uraDoraAll": _uraDoraAll,
      "${_prefix}_redFiveAll": _redFiveAll,
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
