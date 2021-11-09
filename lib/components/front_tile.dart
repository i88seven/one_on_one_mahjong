import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';

// 表向きのカード描画
class FrontTile extends PositionComponent {
  final Images _gameImages;
  final AllTileKinds tileKind;
  double time = 0;
  final TileState state;
  int lightIntensity = 0;
  late Sprite _tileImage;

  FrontTile(this._gameImages, this.tileKind, this.state) {
    final image = _gameImages.fromCache('tile.png');
    _tileImage = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    rendertile(canvas);
  }

  rendertile(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, tileSize.width, tileSize.height);
    _tileImage.renderRect(canvas, rect);
  }
}
