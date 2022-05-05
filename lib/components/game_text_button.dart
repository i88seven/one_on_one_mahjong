import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';

class GameTextButton extends PositionComponent {
  final String _text;
  final GameButtonKind _kind;

  GameTextButton(
    this._text,
    this._kind, {
    Vector2? position,
    int? priority,
  }) : super(position: position, priority: priority);

  get kind => _kind;

  @override
  void render(Canvas canvas) {
    final textRenderer = TextPaint(
      config: const TextPaintConfig(
        fontSize: 16,
        color: AppColor.gameDialogText,
      ),
    );
    final textWidth = textRenderer.measureTextWidth(_text);
    final textHeight = textRenderer.measureTextHeight(_text);
    size = Vector2(120, 40);
    Vector2 padding =
        Vector2((size.x - textWidth) / 2, (size.y - textHeight) / 2);
    super.render(canvas);
    final BorderRadius borderRadius = BorderRadius.circular(10);
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, Paint()..color = AppColor.primaryGameButton);
    textRenderer.render(canvas, _text, padding);
  }
}
