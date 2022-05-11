import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class OtherDeals extends PositionComponent {
  final Images _gameImages;
  List<BackTile> _tileObjects = [];
  int _tileCount = 0;

  OtherDeals({required SeventeenGame game}) : _gameImages = game.gameImages {
    double tileWidth = smallTileSize.x;
    double tileAreaWidth = game.screenSize.x - paddingX * 2;
    tileAreaWidth = (tileAreaWidth ~/ tileWidth) * tileWidth;
    position = Vector2(paddingX, 132);
    size = Vector2(tileAreaWidth, smallTileSize.y * 2 + 12);
  }

  void initialize(int tileCount) {
    if (_tileCount != tileCount) {
      _tileCount = tileCount;
      _rerender();
    }
  }

  void _rerender() {
    removeAll(_tileObjects);
    _tileObjects = [];

    for (int index = 0; index < _tileCount; index++) {
      double tileWidth = smallTileSize.x;
      double x = tileWidth * index;
      int tileRowCount = x ~/ size.x;
      x -= size.x * tileRowCount;
      BackTile tileObject = BackTile(_gameImages, isSmall: true);
      add(tileObject
        ..x = x
        ..y = tileRowCount * (tileSize.y + 12));
      _tileObjects.add(tileObject);
    }
  }
}
