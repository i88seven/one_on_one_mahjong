import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Candidates {
  List<AllTileKinds> tiles = [];
  final SeventeenGame _game;

  Candidates(this._game);

  void initialize(List<AllTileKinds> tiles) {
    this.tiles = tiles;
    this.tiles.sort();
    _render();
  }

  void discard(FrontTile tile) {
    _game.remove(tile);
    tiles.remove(tile.tileKind);
    _render();
  }

  void _render() {
    tiles.asMap().forEach((index, tile) {
      FrontTile tileObject =
          FrontTile(_game.gameImages, tile, TileState.candidate);
      _game.add(tileObject
        ..width = index < tiles.length - 1 ? tileSize.width / 2 : tileSize.width
        ..height = tileSize.height
        ..x = index * tileSize.width
        ..y = _game.screenSize.y - tileSize.height - 42);
    });
  }
}
