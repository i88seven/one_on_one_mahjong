import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_result_component.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/utils/flame_renderer.dart';

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
      position: Vector2(screenSize.x - 152, screenSize.y - 72),
      priority: 20,
    );
    game.add(_endButton);

    GameResultComponent gameResultComponent = GameResultComponent(
      _gameImages,
      _myPoints - 25000,
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
    renderResultBackgroud(canvas, size);

    final _textRenderer = TextPaint(
        config: const TextPaintConfig(
            fontSize: 24.0, color: AppColor.gameDialogText));
    _gamePlayers.sort((a, b) => b.points - a.points);
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      final _text = "${gamePlayer.name} : ${gamePlayer.points}";
      _textRenderer.render(
        canvas,
        _text,
        Vector2(size.x / 2, size.y - 220 + index * 46),
        anchor: Anchor.topCenter,
      );
    });
  }
}
