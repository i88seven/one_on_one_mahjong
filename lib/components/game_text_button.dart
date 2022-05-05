import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';

class GameTextButton extends PositionComponent {
  static Vector2 padding = Vector2(8, 4);
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
    final textRenderer =
        TextPaint(
        config: const TextPaintConfig(color: AppColor.gameDialogText));
    final textWidth = textRenderer.measureTextWidth(_text);
    final textHeight = textRenderer.measureTextHeight(_text);
    size = Vector2(textWidth + padding.x * 2, textHeight + padding.y * 2);
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = AppColor.primaryGameButton);
    textRenderer.render(canvas, _text, padding);
  }
}
