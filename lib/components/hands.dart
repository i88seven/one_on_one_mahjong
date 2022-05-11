import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'front_tile.dart';

class Hands extends PositionComponent {
  final Images _gameImages;
  List<AllTileKinds> _tiles = [];
  List<FrontTile> _tileObjects = [];

  Hands({required SeventeenGame game}) : _gameImages = game.gameImages {
    position = Vector2(tileSize.x, game.screenSize.y - tileSize.y - 84);
  }

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    sortTiles(_tiles);
    _rerender();
  }

  void _rerender() {
    removeAll(_tileObjects);
    _tileObjects = [];
    _tiles.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.hand);
      add(tileObject..x = index * tileSize.x);
      _tileObjects.add(tileObject);
    });
  }

  void addTile(AllTileKinds tileKind) {
    _tiles.add(tileKind);
    sortTiles(_tiles);
    _rerender();
  }

  void discard(AllTileKinds tileKind) {
    _tiles.remove(tileKind);
    _rerender();
  }

  int get tileCount {
    return _tiles.length;
  }

  List<AllTileKinds> get tiles => _tiles;

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
