abstract class StatisticsItem {
  StatisticsItem.fromJson(Map<String, int> json);

  void count(value);

  Map<String, int> toMap();
}
