import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class GameRoundResult extends PositionComponent {
  late final GameTextButton _button;
  final WinResult _winResult;

  GameRoundResult({
    required SeventeenGame game,
    required Vector2 screenSize,
    required WinResult winResult,
  }) : _winResult = winResult {
    size = screenSize;
    position = Vector2(0, 0);
    final okButton = GameTextButton(
      'OK',
      GameButtonKind.roundResultOk,
      position: Vector2(screenSize.x - 100, screenSize.y - 50),
      priority: 20,
    );
    _button = okButton;
    game.add(_button);
  }

  get button => _button;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFFC9FEF5));
    final _textRenderer = TextPaint(
        config: const TextPaintConfig(fontSize: 20.0, color: Colors.black54));
    _winResult.resultMap.asMap().forEach((int i, ResultRow resultRow) {
      _textRenderer.render(
        canvas,
        resultRow.toString(),
        Vector2(10 + (i > 7 ? size.x / 2 : 0), i * 28 + 40),
      );
    });
    final _winNameRenderer = TextPaint(
        config: const TextPaintConfig(fontSize: 50.0, color: Colors.black54));
    _winNameRenderer.render(
      canvas,
      _winResult.winName,
      Vector2(20, size.y - 70),
    );
  }
}
