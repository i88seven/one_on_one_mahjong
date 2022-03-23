import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameResultComponent extends PositionComponent {
  final Images _gameImages;
  late Sprite _gameResultImage;

  GameResultComponent(this._gameImages, bool isWin, double componentWidth) {
    size = Vector2(componentWidth, componentWidth);
    final image = _gameImages.fromCache(isWin ? 'win.png' : 'lose.png');
    _gameResultImage = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _gameResultImage.renderRect(canvas, rect);
  }
}
