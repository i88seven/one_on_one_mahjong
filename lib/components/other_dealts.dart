import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class OtherDeals {
  final SeventeenGame _game;
  List<BackTile> _tileObjects = [];
  int tileCount = 0;

  OtherDeals(this._game);

  void initialize(int _tileCount) {
    tileCount = _tileCount;
    _render();
  }

  void select() {
    tileCount -= 1;
    _render();
  }

  void _render() {
    _game.removeAll(_tileObjects);
    _tileObjects = [];

    for (int index = 0; index < tileCount; index++) {
      double tileAreaWidth = _game.screenSize.x - tileSize.width * 2;
      double x = tileSize.width * index;
      int tileRowCount = x ~/ tileAreaWidth;
      x -= (tileAreaWidth - 1) * tileRowCount;
      BackTile tileObject = BackTile(_game.gameImages);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = x + tileSize.width * 0.7
        ..y = 150 + tileRowCount * tileSize.height * 1.3);
      _tileObjects.add(tileObject);
    }
  }
}
