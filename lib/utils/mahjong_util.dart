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

// firstWhere の orElse で null が返せない問題を無理矢理解消している
// https://github.com/dart-lang/sdk/issues/42947
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

List<AllTileKinds> fetchThirteenOrphansTiles(List<AllTileKinds> tiles) {
  if (tiles.length != 13) {
    return [];
  }
  AllTileKinds? zeroTile = terminalsAndHonors.firstWhereOrNull(
      (AllTileKinds terminalsAndHonor) => !tiles.contains(terminalsAndHonor));
  if (zeroTile == null) {
    return terminalsAndHonors;
  }
  if (isThirteenOrphans([...tiles, zeroTile])) {
    return [zeroTile];
  }
  return [];
}
