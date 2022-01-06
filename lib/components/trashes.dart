import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class Trashes {
  List<AllTileKinds> _tiles = [];
  List<FrontTile> _tileObjects = [];
  final SeventeenGame _game;
  final bool _isMe;

  Trashes(this._game, this._isMe);

  void initialize(List<AllTileKinds> tiles) {
    _tiles = tiles;
    _renderAll();
  }

  void add(AllTileKinds tileKind) {
    _tiles.add(tileKind);
    _render(tileKind);
  }

  void _render(AllTileKinds tileKind) {
    FrontTile tileObject =
        FrontTile(_game.gameImages, tileKind, TileState.trash);
    _game.add(tileObject
      ..x = tileSize.width * tileCount
      ..y = _isMe ? _game.screenSize.y - tileSize.height * 3 - 42 : 250);
    _tileObjects.add(tileObject);
  }

  void _renderAll() {
    _game.removeAll(_tileObjects);
    _tileObjects = [];
    for (AllTileKinds tile in _tiles) {
      _render(tile);
    }
  }

  int get tileCount {
    return _tiles.length;
  }

  List<String> get jsonValue {
    return _tiles.map((e) => e.name).toList();
  }
}
