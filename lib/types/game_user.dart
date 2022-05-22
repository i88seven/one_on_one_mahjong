class GameUser {
  String _uid;
  String _name;
  late bool _isPlayMusic;

  GameUser(this._uid, this._name, {bool isPlayMusic = false})
      : _isPlayMusic = isPlayMusic;

  String get uid => _uid;
  String get name => _name;
  bool get isPlayMusic => _isPlayMusic;

  void updateFromJson(userJson) {
    _uid = userJson['uid'];
    _name = userJson['name'];
    _isPlayMusic = userJson['isPlayMusic'];
  }

  Map<String, String> toJson() {
    return {
      'uid': _uid,
      'name': _name,
      'isPlayMusic': _isPlayMusic ? _isPlayMusic.toString() : '',
    };
  }
}
