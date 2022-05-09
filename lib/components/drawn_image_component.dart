import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DrawnImageComponent extends PositionComponent {
  final Images _gameImages;
  late Sprite _winNameImage;

  DrawnImageComponent(this._gameImages) {
    size = Vector2(84, 84);
    final image = _gameImages.fromCache("drawnRound.png");
    _winNameImage = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _winNameImage.renderRect(canvas, rect);
  }
}
