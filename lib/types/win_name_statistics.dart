class WinNameStatistics {
  final int _mangan;
  final int _haneman;
  final int _baiman;
  final int _sanbaiman;
  final int _yakuman;
  final int _kazoeYakuman;

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

  WinNameStatistics.fromJson(Map<String, int> json)
      : _mangan = json['mangan'] ?? 0,
        _haneman = json['haneman'] ?? 0,
        _baiman = json['baiman'] ?? 0,
        _sanbaiman = json['sanbaiman'] ?? 0,
        _yakuman = json['yakuman'] ?? 0,
        _kazoeYakuman = json['kazoeYakuman'] ?? 0;

  Map<String, int> toJson() {
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
