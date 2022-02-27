import 'package:one_on_one_mahjong/types/statistics/statistics_item.dart';

class WinNameStatistics implements StatisticsItem {
  int _mangan;
  int _haneman;
  int _baiman;
  int _sanbaiman;
  int _yakuman;
  int _kazoeYakuman;

  WinNameStatistics({
    int? mangan,
    int? haneman,
    int? baiman,
    int? sanbaiman,
    int? yakuman,
    int? kazoeYakuman,
  })  : _mangan = mangan ?? 0,
        _haneman = haneman ?? 0,
        _baiman = baiman ?? 0,
        _sanbaiman = sanbaiman ?? 0,
        _yakuman = yakuman ?? 0,
        _kazoeYakuman = kazoeYakuman ?? 0;

  @override
  WinNameStatistics.fromJson(Map<String, int> json)
      : _mangan = int.parse(json['mangan'].toString()),
        _haneman = int.parse(json['haneman'].toString()),
        _baiman = int.parse(json['baiman'].toString()),
        _sanbaiman = int.parse(json['sanbaiman'].toString()),
        _yakuman = int.parse(json['yakuman'].toString()),
        _kazoeYakuman = int.parse(json['kazoeYakuman'].toString());

  @override
  void count(value) {
    // TODO switch 使わない形にしたい
    String winName = value;
    switch (winName) {
      case '満貫':
        _mangan++;
        break;
      case '跳満':
        _haneman++;
        break;
      case '倍満':
        _baiman++;
        break;
      case '三倍満':
        _sanbaiman++;
        break;
      case '数え役満':
        _kazoeYakuman++;
        break;
      case 'エラー':
        break;
      default:
        _yakuman++;
    }
  }

  @override
  Map<String, int> toMap() {
    return {
      'mangan': _mangan,
      'haneman': _haneman,
      'baiman': _baiman,
      'sanbaiman': _sanbaiman,
      'yakuman': _yakuman,
      'kazoeYakuman': _kazoeYakuman,
    };
  }

  Map<String, String> toNameMap() {
    return {
      '満貫': _mangan.toString(),
      '跳満': _haneman.toString(),
      '倍満': _baiman.toString(),
      '三倍満': _sanbaiman.toString(),
      '役満': _yakuman.toString(),
      '数え役満': _kazoeYakuman.toString(),
    };
  }
}
