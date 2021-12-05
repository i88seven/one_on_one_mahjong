import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';

class GameDialog extends PositionComponent {
  List<GameTextButton> _buttons = [];

  GameDialog({required Vector2 screenSize}) {
    size = Vector2(300, 160);
    position =
        Vector2(screenSize.x / 2 - size.x / 2, screenSize.y / 2 - size.y / 2);
    final cancelButton = GameTextButton('キャンセル', GameButtonKind.dialogCancel,
        position: Vector2(70, screenSize.y / 2 + 20), priority: 20);
    final okButton = GameTextButton('確定', GameButtonKind.dialogOk,
        position: Vector2(240, screenSize.y / 2 + 20), priority: 20);
    _buttons = [cancelButton, okButton];
  }

  get buttons => _buttons;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFFC9FEF5));
  }
}
