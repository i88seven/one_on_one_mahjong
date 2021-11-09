import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:one_on_one_mahjong/components/game_player.dart';

class GamePlayerResult extends PositionComponent {
  final GamePlayer _gamePlayer;

  GamePlayerResult(this._gamePlayer);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
    );
    final textSpan = TextSpan(
      text: "${_gamePlayer.name} : ${_gamePlayer.points}",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );
    const offset = Offset(24, 4);
    textPainter.paint(canvas, offset);
  }
}
