import 'package:one_on_one_mahjong/types/statistics/statistics_kind.dart';
import 'package:one_on_one_mahjong/types/statistics/statistics_item.dart';

class StatedStatistics {
  Map<StatisticsKind, StatisticsItem> statistics;

  StatedStatistics(StatisticsItem initialiValue)
      : statistics = {
          StatisticsKind.parentWin: initialiValue,
          StatisticsKind.childWin: initialiValue,
          StatisticsKind.parentLose: initialiValue,
          StatisticsKind.childLose: initialiValue,
        };

  StatedStatistics.fromJson(Map<String, dynamic> json,
      StatisticsItem Function(Map<String, int> json) fromJson)
      : statistics = {
          StatisticsKind.parentWin: fromJson(
              Map<String, int>.from(json[StatisticsKind.parentWin.name])),
          StatisticsKind.childWin: fromJson(
              Map<String, int>.from(json[StatisticsKind.childWin.name])),
          StatisticsKind.parentLose: fromJson(
              Map<String, int>.from(json[StatisticsKind.parentLose.name])),
          StatisticsKind.childLose: fromJson(
              Map<String, int>.from(json[StatisticsKind.childLose.name])),
        };

  void count(StatisticsKind statisticsKind, value) {
    StatisticsItem? base = statistics[statisticsKind];
    base!.count(value);
  }

  Map<String, Map<String, int>> toMap() {
    return Map.fromIterables(
      StatisticsKind.values.map((kind) => kind.name),
      StatisticsKind.values.map((kind) => statistics[kind]!.toMap()),
    );
  }

  Map<String, int> toMapWin() {
    Map<String, int> summedUpMap = {};
    statistics[StatisticsKind.parentWin]!.toMap().entries.forEach((entry) {
      summedUpMap[entry.key] = (summedUpMap[entry.key] ?? 0) + entry.value;
    });
    statistics[StatisticsKind.childWin]!.toMap().entries.forEach((entry) {
      summedUpMap[entry.key] = (summedUpMap[entry.key] ?? 0) + entry.value;
    });
    return summedUpMap;
  }

  Map<String, int> toMapLose() {
    Map<String, int> summedUpMap = {};
    statistics[StatisticsKind.parentLose]!.toMap().entries.forEach((entry) {
      summedUpMap[entry.key] = (summedUpMap[entry.key] ?? 0) + entry.value;
    });
    statistics[StatisticsKind.childLose]!.toMap().entries.forEach((entry) {
      summedUpMap[entry.key] = (summedUpMap[entry.key] ?? 0) + entry.value;
    });
    return summedUpMap;
  }
}
