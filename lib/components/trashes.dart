import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class Trashes {
  List<AllTileKinds> tiles = [];
  final SeventeenGame _game;
  final bool _isMe;

  Trashes(this._game, this._isMe);

  void initialize(List<AllTileKinds> tiles) {
    this.tiles = tiles;
  }

  void add(AllTileKinds tileKind) {
    tiles.add(tileKind);
    _render(tileKind, tiles.length);
  }

  void _render(AllTileKinds tileKind, int length) {
    _game.add(FrontTile(tileKind, TileState.trash)
      ..x = tileSize.width * length
      ..y = _isMe ? 250 : 550);
  }
}
