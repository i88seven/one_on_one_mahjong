import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Hands {
  List<AllTileKinds> _tiles = [];
  List<FrontTile> _tileObjects = [];
  final SeventeenGame _game;

  Hands(this._game);

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    sortTiles(_tiles);
    _render();
  }

  void add(AllTileKinds tileKind) {
    _tiles.add(tileKind);
    sortTiles(_tiles);
    _render();
  }

  void discard(AllTileKinds tileKind) {
    _tiles.remove(tileKind);
    _render();
  }

  void _render() {
    _game.removeAll(_tileObjects);
    _tileObjects = [];
    _tiles.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_game.gameImages, tile, TileState.hand);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = (index + 1) * tileSize.width
        ..y = _game.screenSize.y - tileSize.height - 42);
      _tileObjects.add(tileObject);
    });
  }

  int get tileCount {
    return _tiles.length;
  }

  List<AllTileKinds> get tiles => _tiles;

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
