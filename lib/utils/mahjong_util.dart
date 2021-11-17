import 'package:one_on_one_mahjong/constants/all_tiles.dart';

List<AllTileKinds> convertRedTiles(List<AllTileKinds> tiles) {
  return tiles.map((tile) {
    if (tile == AllTileKinds.mr) {
      return AllTileKinds.m5;
    }
    if (tile == AllTileKinds.pr) {
      return AllTileKinds.p5;
    }
    if (tile == AllTileKinds.sr) {
      return AllTileKinds.s5;
    }
    return tile;
  }).toList();
}
