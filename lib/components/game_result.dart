import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result_component.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GameResult extends PositionComponent {
  final Images _gameImages;
  final List<GamePlayer> _gamePlayers;
  final int _myPoints;
  late GameTextButton _endButton;

  GameResult({
    required SeventeenGame game,
    required Vector2 screenSize,
    required List<GamePlayer> gamePlayers,
    required int myPoints,
  })  : _gamePlayers = gamePlayers,
        _gameImages = game.gameImages,
        _myPoints = myPoints {
    size = screenSize;
    position = Vector2(0, 0);
    _endButton = GameTextButton(
      '終了',
      GameButtonKind.gameEnd,
      position: Vector2(240, screenSize.x + 110),
      priority: 20,
    );
    game.add(_endButton);

    GameResultComponent gameResultComponent = GameResultComponent(
      _gameImages,
      _myPoints >= 25000, // TODO 引き分け
      size.x - 60,
    );
    add(gameResultComponent
      ..x = 30
      ..y = 50);
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
        Vector2(30, (index * 50 + size.x + 10).toDouble()),
      );
    });
  }
}
