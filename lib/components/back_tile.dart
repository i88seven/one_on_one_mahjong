import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';

// 裏向きのカード描画
class BackTile extends PositionComponent {
  late Sprite _tileImage;

  BackTile() {
    Images().load("tile-back.png").then((image) {
      _tileImage = Sprite(image);
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    renderTile(canvas);
  }

  renderTile(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, tileSize.width, tileSize.height);
    _tileImage.renderRect(c, rect);
  }

  @override
  void onMount() {
    width = tileSize.width;
    height = tileSize.height;
  }
}
