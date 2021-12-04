import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';

// 裏向きのカード描画
class BackTile extends PositionComponent {
  late Sprite _tileImage;
  final Images _gameImages;
  bool _isSmall = false;

  BackTile(this._gameImages, {isSmall}) {
    final image = _gameImages.fromCache('tile-back.png');
    _tileImage = Sprite(image);
    _isSmall = isSmall ?? false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderTile(canvas);
  }

  _renderTile(Canvas c) {
    Rect rect = Rect.fromLTWH(
        0,
        0,
        _isSmall ? smallTileSize.width : tileSize.width,
        _isSmall ? smallTileSize.height : tileSize.height);
    _tileImage.renderRect(c, rect);
  }
}
