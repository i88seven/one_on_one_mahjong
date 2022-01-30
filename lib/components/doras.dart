import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'back_tile.dart';
import 'front_tile.dart';

class Doras {
  List<AllTileKinds> _tiles = [];
  final List<PositionComponent> _tileObjects = [];
  final SeventeenGame _game;

  Doras(this._game);

  List<AllTileKinds> get tiles => _tiles;

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    _render();
  }

  void _render() {
    if (_tileObjects.isNotEmpty) {
      _game.removeAll(_tileObjects);
    }
    FrontTile dora = FrontTile(_game.gameImages, _tiles[0], TileState.dora);
    for (var i = 0; i < 4; i++) {
      BackTile backTile = BackTile(_game.gameImages);
      _tileObjects.add(i == 1 ? dora : backTile);
      _game.add(i == 1 ? dora : backTile
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = 200 + tileSize.width * i
        ..y = _game.screenSize.y - tileSize.height - 300);
    }
  }

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
