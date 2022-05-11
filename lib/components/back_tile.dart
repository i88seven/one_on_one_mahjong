import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';

// 裏向きのカード描画
class BackTile extends PositionComponent {
  late Sprite _tileImage;
  bool _isSmall = false;

  BackTile(Images gameImages, {isSmall}) {
    final image = gameImages.fromCache('tile-back.png');
    _tileImage = Sprite(image);
    _isSmall = isSmall ?? false;
    size = _isSmall ? smallTileSize : tileSize;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderTile(canvas);
  }

  _renderTile(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _tileImage.renderRect(c, rect);
  }
}
