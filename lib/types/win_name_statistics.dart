class WinNameStatistics {
  final String _prefix;
  final int _mangan;
  final int _haneman;
  final int _baiman;
  final int _sanbaiman;
  final int _yakuman;
  final int _kazoeYakuman;

  WinNameStatistics({
    required String prefix,
    int? mangan,
    int? haneman,
    int? baiman,
    int? sanbaiman,
    int? yakuman,
    int? kazoeYakuman,
  })  : _prefix = prefix,
        _mangan = mangan ?? 0,
        _haneman = haneman ?? 0,
        _baiman = baiman ?? 0,
        _sanbaiman = sanbaiman ?? 0,
        _yakuman = yakuman ?? 0,
        _kazoeYakuman = kazoeYakuman ?? 0;

  WinNameStatistics.fromJson(String prefix, Map<String, int> json)
      : _prefix = prefix,
        _mangan = json["${prefix}_mangan"] ?? 0,
        _haneman = json["${prefix}_haneman"] ?? 0,
        _baiman = json["${prefix}_baiman"] ?? 0,
        _sanbaiman = json["${prefix}_sanbaiman"] ?? 0,
        _yakuman = json["${prefix}_yakuman"] ?? 0,
        _kazoeYakuman = json["${prefix}_kazoeYakuman"] ?? 0;

  Map<String, int> toJson() {
    return {
      "${_prefix}_mangan": _mangan,
      "${_prefix}_haneman": _haneman,
      "${_prefix}_baiman": _baiman,
      "${_prefix}_sanbaiman": _sanbaiman,
      "${_prefix}_yakuman": _yakuman,
      "${_prefix}_kazoeYakuman": _kazoeYakuman,
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
