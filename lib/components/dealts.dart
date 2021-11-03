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
    this.tiles.sort();
    _render();
  }

  void select(AllTileKinds tileKind) {
    tiles.remove(tileKind);
    _render();
  }

  void unselect(AllTileKinds tileKind) {
    tiles.add(tileKind);
    tiles.sort();
    _render();
  }

  void _render() {
    for (var tileObject in _tileObjects) {
      _game.remove(tileObject);
    }
    _tileObjects = [];
    tiles.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(tile, TileState.dealt);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = index * tileSize.width
        ..y = _game.size.y - tileSize.height - 300);
      _tileObjects.add(tileObject);
    });
  }
}
