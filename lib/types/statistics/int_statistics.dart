import 'package:one_on_one_mahjong/types/statistics/statistics_item.dart';

class IntStatistics implements StatisticsItem {
  int _value;

  IntStatistics({
    int? value,
  }) : _value = value ?? 0;

  @override
  IntStatistics.fromJson(Map<String, int> json) : _value = json['value']!;

  @override
  void count(value) {
    _value += value as int;
  }

  @override
  Map<String, int> toMap() {
    return {'value': _value};
  }
}
