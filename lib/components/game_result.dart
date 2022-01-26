import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GameResult extends PositionComponent {
  final List<GamePlayer> _gamePlayers;
  late GameTextButton _endButton;

  GameResult({
    required SeventeenGame game,
    required Vector2 screenSize,
    required List<GamePlayer> gamePlayers,
  }) : _gamePlayers = gamePlayers {
    size = screenSize;
    position = Vector2(0, 0);
    _endButton = GameTextButton(
      '終了',
      GameButtonKind.gameEnd,
      position: Vector2(240, screenSize.y / 2 + 20),
      priority: 20,
    );
    game.add(_endButton);
  }

  get button => _endButton;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFFC9FEF5));

    final _textRenderer = TextPaint(
        config: const TextPaintConfig(fontSize: 20.0, color: Colors.black54));
    _gamePlayers.sort((a, b) => b.points - a.points);
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      final _text = "${gamePlayer.name} : ${gamePlayer.points}";
      _textRenderer.render(
        canvas,
        _text,
        Vector2(30, (index * 50 + 50).toDouble()),
      );
    });
  }
}
