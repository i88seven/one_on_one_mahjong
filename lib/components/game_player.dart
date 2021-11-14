import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/game_player_status.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GamePlayer {
  String uid;
  String name;
  late int _points;
  GamePlayerStatus status;
  final bool _isMe;
  TextComponent? _textObject;
  final SeventeenGame _game;

  GamePlayer(this._game, this.uid, this.name, this.status, this._isMe) {
    _points = 0;
  }

  GamePlayer.fromJson(SeventeenGame game, bool isMe, Map<String, dynamic> json)
      : _game = game,
        uid = json['uid'],
        name = json['name'],
        _points = json['points'] ?? 0,
        status =
            EnumToString.fromString(GamePlayerStatus.values, json['status']) ??
                GamePlayerStatus.ready,
        _isMe = isMe;

  void setStatus(GamePlayerStatus status) {
    this.status = status;
    render();
  }

  void setPoint(int points) {
    _points = points;
    render();
  }

  void addPoints(int points) {
    _points += points;
    render();
  }

  void render() {
    if (_textObject != null) {
      _game.remove(_textObject!);
    }
    double posY;
    if (_isMe) {
      posY = _game.screenSize.y - 30;
    } else {
      posY = 30.0;
    }
    _textObject = TextComponent(
      "$name: $_points",
      size: Vector2(100.0, _isMe ? 24.0 : 12.0),
    );
    if (_game.isLoaded) {
      _game.add(_textObject!
        ..x = 0
        ..y = posY);
    }
  }

  int get points => _points;

  toJson() {
    return {
      'uid': uid,
      'name': name,
      'status': status.name,
      'points': _points,
    };
  }
}
