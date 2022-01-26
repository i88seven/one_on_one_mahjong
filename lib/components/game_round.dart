import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GameRound {
  int _wind; // 東:1, 南:2, 西:3, 北:4
  int _round; // 局
  TextComponent? _textObject;
  final SeventeenGame _game;

  static const windMap = ['', '東', '南', '西', '北', '北'];
  static const roundMap = ['', '一', '二', '二'];

  GameRound(this._game, this._wind, this._round) {
    render();
  }

  int get wind => _wind;
  int get round => _round;
  bool get isFinalGame => _wind == 4 && _round == 2;
  bool get isGameEnded => _wind > 4;

  void setRound({int? wind, int? round}) {
    if (wind != null) {
      _wind = wind;
    }
    if (round != null) {
      _round = round;
    }
    render();
  }

  void setNewRound() {
    if (_round == 1) {
      _round = 2;
    } else {
      _wind = _wind + 1;
      _round = 1;
    }
    render();
  }

  void render() {
    String text = "${windMap[_wind]}${roundMap[_round]}局";
    if (_textObject != null) {
      _textObject!.text = text;
      return;
    }
    final textRenderer =
        TextPaint(config: const TextPaintConfig(color: Colors.white));
    _textObject = TextComponent(
      text,
      textRenderer: textRenderer,
      size: Vector2(60.0, 12.0),
    );
    _game.add(_textObject!
      ..x = tileSize.width * 0.7
      ..y = _game.screenSize.y - 330);
  }

  void remove() {
    if (_textObject != null) {
      _textObject!.text = '';
      _game.remove(_textObject!);
    }
  }
}
