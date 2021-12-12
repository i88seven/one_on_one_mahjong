import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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
  final bool _isParent;

  GamePlayer(this._game, this.uid, this.name, this.status, this._isMe,
      this._isParent) {
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
        _isMe = isMe,
        _isParent = json['isParent'] ?? false;

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
    final textRenderer =
        TextPaint(config: const TextPaintConfig(color: Colors.white));
    _textObject = TextComponent(
      "$name: $_points",
      textRenderer: textRenderer,
      size: Vector2(100.0, _isMe ? 24.0 : 12.0),
    );
    _game.add(_textObject!
      ..x = 0
      ..y = posY);
  }

  int get points => _points;
  bool get isParent => _isParent;

  toJson() {
    return {
      'uid': uid,
      'name': name,
      'status': status.name,
      'points': _points,
      'isParent': _isParent,
    };
  }
}
