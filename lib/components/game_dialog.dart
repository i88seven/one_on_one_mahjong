import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/constants/reach_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GameDialog extends PositionComponent {
  List<GameTextButton> _buttons = [];
  final ReachState _reachState;

  GameDialog({
    required SeventeenGame game,
    required Vector2 screenSize,
    required ReachState reachState,
  }) : _reachState = reachState {
    size = Vector2(300, 160);
    position = Vector2(
      screenSize.x / 2 - size.x / 2,
      screenSize.y / 2 - size.y / 2,
    );
    final cancelButton = GameTextButton(
      'キャンセル',
      GameButtonKind.dialogCancel,
      position: Vector2(50, screenSize.y / 2 + 20),
      priority: 20,
    );
    final okButton = GameTextButton(
      '確定',
      GameButtonKind.dialogOk,
      position: Vector2(200, screenSize.y / 2 + 20),
      priority: 20,
    );
    _buttons = [cancelButton, okButton];
    game.addAll(_buttons);
  }

  get buttons => _buttons;

  get _text => reachStateTextMap[_reachState] ?? '';

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = AppColor.gameDialogBackground);
    final _textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 20.0,
        color: AppColor.gameDialogText,
      ),
    );
    final textWidth = _textRenderer.measureTextWidth(_text);
    _textRenderer.render(
      canvas,
      _text,
      Vector2((size.x - textWidth) / 2, 30),
    );
  }
}
