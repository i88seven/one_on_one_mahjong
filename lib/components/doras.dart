import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'back_tile.dart';
import 'front_tile.dart';

class Doras extends PositionComponent {
  final Images _gameImages;
  List<AllTileKinds> _tiles = [];
  final List<PositionComponent> _tileObjects = [];

  Doras({required SeventeenGame game}) : _gameImages = game.gameImages {
    position = Vector2(200, game.screenSize.y - tileSize.y - 300);
  }

  List<AllTileKinds> get tiles => _tiles;

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    _render();
  }

  void _render() {
    removeAll(_tileObjects);
    FrontTile dora = FrontTile(_gameImages, _tiles[0], TileState.dora);
    for (var i = 0; i < 4; i++) {
      BackTile backTile = BackTile(_gameImages);
      _tileObjects.add(i == 1 ? dora : backTile);
      add(i == 1 ? dora : backTile
        ..x = tileSize.x * i);
    }
  }

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
