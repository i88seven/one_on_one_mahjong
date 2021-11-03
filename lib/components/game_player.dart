import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:flame/palette.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GamePlayer {
  String uid;
  String name;
  late int _points;
  bool isMe;
  bool _isOnesTurn = false;
  TextComponent? _textObject;
  final SeventeenGame _game;

  GamePlayer(this._game, this.uid, this.name, this.isMe) {
    _points = 0;
    render();
  }

  void set(int points) {
    _points = points;
    render();
  }

  void updateTurn(bool isOnesTurn) {
    _isOnesTurn = isOnesTurn;
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
    if (isMe) {
      posY = _game.size.y - 30;
    } else {
      posY = 30.0;
    }
    _textObject = TextComponent(
      "$name: $_points",
      size: Vector2(100.0, isMe ? 24.0 : 12.0),
    );
    if (_game.isLoaded) {
      _game.add(_textObject!
        ..x = 0
        ..y = posY);
    }
  }

  bool get isGameOver => _points >= 40;

  int get points => _points;

  toJson() {
    return {
      'uid': uid,
      'name': name,
      'points': _points,
    };
  }
}
