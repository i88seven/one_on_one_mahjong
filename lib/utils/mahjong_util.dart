import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';
import 'package:one_on_one_mahjong/utils/yaku_util.dart';

AllTileKinds? fetchSevenPairsReachTile(List<AllTileKinds> tiles) {
  if (tiles.length != 13) {
    return null;
  }
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  AllTileKinds? singleTile;
  for (AllTileKinds tile in tileKindCount.keys) {
    if (tileKindCount[tile]! > 2) {
      return null;
    }
    if (tileKindCount[tile]! == 2) {
      continue;
    }
    if (singleTile != null) {
      return null;
    }
    singleTile = tile;
  }
  return singleTile;
}
