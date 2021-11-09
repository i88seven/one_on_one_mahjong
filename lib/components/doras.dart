import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Doras {
  List<AllTileKinds> tiles = [];
  final SeventeenGame _game;

  Doras(this._game);

  void initialize(List<AllTileKinds> tiles) {
    this.tiles = tiles;
    _render();
  }

  void _render() {
    FrontTile dora = FrontTile(_game.gameImages, tiles[0], TileState.dora);
    _game.add(dora
      ..width = tileSize.width
      ..height = tileSize.height
      ..x = 200
      ..y = _game.screenSize.y - tileSize.height - 300);
    FrontTile uraDora = FrontTile(_game.gameImages, tiles[1], TileState.dora);
    _game.add(uraDora
      ..width = tileSize.width
      ..height = tileSize.height
      ..x = 200 + tileSize.width
      ..y = _game.screenSize.y - tileSize.height - 300);
  }
}
