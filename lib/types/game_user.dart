class GameUser {
  String _uid;
  String _name;

  GameUser(this._uid, this._name);

  String get uid => _uid;
  String get name => _name;

  void updateFromJson(userJson) {
    _uid = userJson['uid'];
    _name = userJson['name'];
  }

  Map<String, String> toJson() {
    return {
      'uid': _uid,
      'name': _name,
    };
  }
}
