import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Dealts {
  List<AllTileKinds> _tiles = [];
  List<FrontTile> _tileObjects = [];
  final SeventeenGame _game;

  Dealts(this._game);

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    sortTiles(_tiles);
    _render();
  }

  void select(AllTileKinds tileKind) {
    _tiles.remove(tileKind);
    _render();
  }

  void unselect(AllTileKinds tileKind) {
    _tiles.add(tileKind);
    sortTiles(_tiles);
    _render();
  }

  void discard(FrontTile tile) {
    _game.remove(tile);
    _tiles.remove(tile.tileKind);
    _tileObjects.remove(tile);
  }

  void _render() {
    _game.removeAll(_tileObjects);
    _tileObjects = [];
    double tileAreaWidth = _game.screenSize.x - paddingX * 2;
    tileAreaWidth = (tileAreaWidth ~/ tileSize.x) * tileSize.x;
    _tiles.asMap().forEach((index, tile) {
      double x = tileSize.x * index;
      int tileRowCount = x ~/ tileAreaWidth;
      x -= tileAreaWidth * tileRowCount;
      FrontTile tileObject = FrontTile(_game.gameImages, tile, TileState.dealt);
      _game.add(tileObject
        ..x = x + paddingX
        ..y = _game.screenSize.y - 264 + tileRowCount * (tileSize.y + 12));
      _tileObjects.add(tileObject);
    });
  }

  int get tileCount {
    return _tiles.length;
  }

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
