import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

void main() {
  group('fetchSevenPairsReachTile test', () {
    test('scuccess', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s4,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s8,
        AllTileKinds.s8,
        AllTileKinds.j1,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      AllTileKinds expected = AllTileKinds.j1;
      AllTileKinds? actual = fetchSevenPairsReachTile(tiles);
      expect(actual, expected);
    });

    test('short', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s4,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s8,
        AllTileKinds.s8,
        AllTileKinds.j1,
        AllTileKinds.j6,
      ];
      AllTileKinds? actual = fetchSevenPairsReachTile(tiles);
      expect(actual, null);
    });

    test('three tiles', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s4,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s8,
        AllTileKinds.s8,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      AllTileKinds? actual = fetchSevenPairsReachTile(tiles);
      expect(actual, null);
    });

    test('single tile', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s4,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s7,
        AllTileKinds.s8,
        AllTileKinds.s9,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      AllTileKinds? actual = fetchSevenPairsReachTile(tiles);
      expect(actual, null);
    });
  });
}
