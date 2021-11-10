import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Dealts {
  List<AllTileKinds> tiles = [];
  List<FrontTile> _tileObjects = [];
  final SeventeenGame _game;

  Dealts(this._game);

  void initialize(List<AllTileKinds> tiles) {
    this.tiles = tiles;
    sortTiles(this.tiles);
    _render();
  }

  void select(AllTileKinds tileKind) {
    tiles.remove(tileKind);
    _render();
  }

  void unselect(AllTileKinds tileKind) {
    tiles.add(tileKind);
    sortTiles(tiles);
    _render();
  }

  void _render() {
    for (var tileObject in _tileObjects) {
      _game.remove(tileObject);
    }
    _tileObjects = [];
    tiles.asMap().forEach((index, tile) {
      double tileAreaWidth = _game.screenSize.x - tileSize.width * 2;
      double x = tileSize.width * index;
      int tileRowCount = x ~/ tileAreaWidth;
      x -= tileAreaWidth * tileRowCount;
      FrontTile tileObject = FrontTile(_game.gameImages, tile, TileState.dealt);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = x + tileSize.width * 0.7
        ..y = _game.screenSize.y - 280 + tileRowCount * tileSize.height * 1.3);
      _tileObjects.add(tileObject);
    });
  }
}
