import 'package:one_on_one_mahjong/constants/win_name.dart';
import 'package:one_on_one_mahjong/types/statistics/statistics_item.dart';

class WinNameStatistics implements StatisticsItem {
  Map<WinName, int> statistics = {};

  WinNameStatistics({
    int? mangan,
    int? haneman,
    int? baiman,
    int? sanbaiman,
    int? yakuman,
    int? kazoeYakuman,
  }) {
    statistics[WinName.mangan] = mangan ?? 0;
    statistics[WinName.haneman] = haneman ?? 0;
    statistics[WinName.baiman] = baiman ?? 0;
    statistics[WinName.sanbaiman] = sanbaiman ?? 0;
    statistics[WinName.yakuman] = yakuman ?? 0;
    statistics[WinName.kazoeYakuman] = kazoeYakuman ?? 0;
  }

  @override
  WinNameStatistics.fromJson(Map<String, int> json) {
    for (WinName winName in WinName.values) {
      statistics[winName] = int.parse(json[winName.name].toString());
    }
  }

  @override
  void count(value) {
    WinName winName = value;
    if (statistics[winName] != null) {
      statistics[winName] = statistics[winName]! + 1;
    }
  }

  @override
  Map<String, int> toMap() {
    Map<String, int> result = {};
    for (WinName winName in WinName.values) {
      result[winName.name] = statistics[winName] ?? 0;
    }
    return result;
  }

  Map<String, String> toNameMap() {
    Map<String, String> result = {};
    for (WinName winName in WinName.values) {
      result[winName.name] = (statistics[winName] ?? 0).toString();
    }
    return result;
  }
}
