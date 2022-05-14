import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';

// 表向きのカード描画
class FrontTile extends PositionComponent {
  final AllTileKinds tileKind;
  final TileState state;
  late Sprite _tileImage;

  FrontTile(Images gameImages, this.tileKind, this.state,
      {TileSizeType tileSizeType = TileSizeType.large}) {
    final image = gameImages.fromCache("${tileKind.name}.png");
    _tileImage = Sprite(image);
    size = tileSizeMap[tileSizeType]!;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    rendertile(canvas);
  }

  rendertile(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _tileImage.renderRect(canvas, rect);
  }
}
