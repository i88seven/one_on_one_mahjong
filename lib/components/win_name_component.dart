import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/constants/win_name.dart';

class WinNameComponent extends PositionComponent {
  final Images _gameImages;
  final WinName winName;
  late Sprite _winNameImage;

  WinNameComponent(this._gameImages, this.winName) {
    size = Vector2(84, 84);
    final image = _gameImages.fromCache("${winName.name}.png");
    _winNameImage = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _winNameImage.renderRect(canvas, rect);
  }
}
