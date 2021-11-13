import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FixHandsButton extends PositionComponent {
  static Vector2 buttonSize = Vector2(88.0, 50.0);

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
      text: '確定',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 80,
    );
    const offset = Offset(16, 10);
    textPainter.paint(canvas, offset);
  }

  @override
  void onMount() {
    width = buttonSize.x;
    height = buttonSize.y;
  }
}
