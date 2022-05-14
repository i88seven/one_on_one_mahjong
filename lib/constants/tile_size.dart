import 'package:flame/components.dart';

enum TileSizeType {
  large,
  middle,
  small,
}

Vector2 tileSize = Vector2(24, 36);
Vector2 middleTileSize = Vector2(24 * 17 / 19, 36 * 17 / 19);
Vector2 smallTileSize = Vector2(24 * 15 / 19, 36 * 15 / 19);
Map<TileSizeType, Vector2> tileSizeMap = {
  TileSizeType.large: tileSize,
  TileSizeType.middle: middleTileSize,
  TileSizeType.small: smallTileSize,
};

double paddingX = 16.0;
