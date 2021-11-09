import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Hands {
  List<AllTileKinds> tiles = [];
  List<FrontTile> _tileObjects = [];
  final SeventeenGame _game;

  Hands(this._game);

  void initialize(List<AllTileKinds> tiles) {
    this.tiles = tiles;
    sortTiles(this.tiles);
    _render();
  }

  void add(AllTileKinds tileKind) {
    tiles.add(tileKind);
    sortTiles(tiles);
    _render();
  }

  void discard(AllTileKinds tileKind) {
    tiles.remove(tileKind);
    _render();
  }

  void _render() {
    for (var tileObject in _tileObjects) {
      _game.remove(tileObject);
    }
    _tileObjects = [];
    tiles.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_game.gameImages, tile, TileState.hand);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = index * tileSize.width
        ..y = _game.screenSize.y - tileSize.height - 42);
      _tileObjects.add(tileObject);
    });
  }
}
