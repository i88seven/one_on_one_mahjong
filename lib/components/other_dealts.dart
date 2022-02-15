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
    position = Vector2(0, 150);
    double tileWidth = smallTileSize.width;
    double tileAreaWidth = game.screenSize.x - tileWidth * 2;
    tileAreaWidth = (tileAreaWidth ~/ tileWidth) * tileWidth;
    size = Vector2(tileAreaWidth, smallTileSize.height * 2.3);
  }

  void initialize(int tileCount) {
    _tileCount = tileCount;
    _rerender();
  }

  void _rerender() {
    removeAll(_tileObjects);
    _tileObjects = [];

    for (int index = 0; index < _tileCount; index++) {
      double tileWidth = smallTileSize.width;
      double x = tileWidth * index;
      int tileRowCount = x ~/ size.x;
      x -= (size.x - 1) * tileRowCount;
      BackTile tileObject = BackTile(_gameImages, isSmall: true);
      add(tileObject
        ..x = x + tileWidth * 0.7
        ..y = tileRowCount * tileSize.height * 1.3);
      _tileObjects.add(tileObject);
    }
  }
}
