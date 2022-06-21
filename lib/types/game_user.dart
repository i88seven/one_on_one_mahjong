class GameUser {
  String _uid;
  String _name;
  late bool _isPlayMusic;
  late bool _isAnonymously;

  GameUser(this._uid, this._name,
      {bool isPlayMusic = false, bool isAnonymously = false})
      : _isPlayMusic = isPlayMusic,
        _isAnonymously = isAnonymously;

  String get uid => _uid;
  String get name => _name;
  bool get isPlayMusic => _isPlayMusic;
  bool get isAnonymously => _isAnonymously;

  void updateFromJson(userJson) {
    _uid = userJson['uid'];
    _name = userJson['name'];
    _isPlayMusic = userJson['isPlayMusic'];
    if (userJson.containsKey('isAnonymously')) {
      _isAnonymously = userJson['isAnonymously'];
    }
  }

  Map<String, String> toJson() {
    return {
      'uid': _uid,
      'name': _name,
      'isPlayMusic': _isPlayMusic ? _isPlayMusic.toString() : '',
    };
  }
}
