import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class OtherDeals {
  final SeventeenGame _game;
  List<BackTile> _tileObjects = [];
  int _tileCount = 0;

  OtherDeals(this._game);

  void initialize(int tileCount) {
    _tileCount = tileCount;
    _render();
  }

  void select() {
    _tileCount -= 1;
    _render();
  }

  void _render() {
    _game.removeAll(_tileObjects);
    _tileObjects = [];

    for (int index = 0; index < _tileCount; index++) {
      double tileWidth = smallTileSize.width;
      double tileAreaWidth = _game.screenSize.x - tileWidth * 2;
      tileAreaWidth = (tileAreaWidth ~/ tileWidth) * tileWidth;
      double x = tileWidth * index;
      int tileRowCount = x ~/ tileAreaWidth;
      x -= (tileAreaWidth - 1) * tileRowCount;
      BackTile tileObject = BackTile(_game.gameImages, isSmall: true);
      _game.add(tileObject
        ..x = x + tileWidth * 0.7
        ..y = 150 + tileRowCount * tileSize.height * 1.3);
      _tileObjects.add(tileObject);
    }
  }
}
