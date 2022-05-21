import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/image_component.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/utils/flame_renderer.dart';

class GameBackground extends PositionComponent {
  late Sprite _backgroundImage;

  GameBackground({required SeventeenGame game, required Images gameImages}) {
    size = game.screenSize;
    _backgroundImage = Sprite(gameImages.fromCache('gameBackground.png'));

    final imageComponent = ImageComponent.fromSprite(_backgroundImage);
    game.add(imageComponent..size = size);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderGameBackgroud(canvas, size);
  }
}
