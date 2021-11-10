import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class OtherHands {
  final SeventeenGame _game;

  OtherHands(this._game);

  void initialize() {
    _render();
  }

  void _render() {
    double padding = (_game.screenSize.x - tileSize.width) / 13;
    for (int i = 0; i < 13; i++) {
      BackTile tileObject = BackTile(_game.gameImages);
      _game.add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = padding * i
        ..y = 80.0);
    }
  }
}
