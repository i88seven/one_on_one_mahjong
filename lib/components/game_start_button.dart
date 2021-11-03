import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameStartButton extends PositionComponent {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height),
        Paint()..color = const Color(0xFF39C23F));
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    const textSpan = TextSpan(
      text: 'Start!!',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 100,
    );
    const offset = Offset(10, 4);
    textPainter.paint(canvas, offset);
  }

  @override
  void onMount() {
    width = 112;
    height = 50;
  }
}
