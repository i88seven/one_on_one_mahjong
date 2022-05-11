import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameResultComponent extends PositionComponent {
  late Sprite _gameResultImage;

  GameResultComponent(Images gameImages, int winPoints, double componentWidth) {
    size = Vector2(componentWidth, componentWidth);
    final resultName = winPoints > 0
        ? 'win'
        : winPoints < 0
            ? 'lose'
            : 'draw';
    final image = gameImages.fromCache('$resultName.png');
    _gameResultImage = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _gameResultImage.renderRect(canvas, rect);
  }
}
