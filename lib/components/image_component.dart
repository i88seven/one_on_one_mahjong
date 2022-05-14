import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ImageComponent extends PositionComponent {
  late Sprite _imageSprite;

  ImageComponent(Images gameImages, String fileName) {
    final image = gameImages.fromCache(fileName);
    _imageSprite = Sprite(image);
  }

  ImageComponent.fromSprite(this._imageSprite);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _imageSprite.renderRect(canvas, rect);
  }
}
