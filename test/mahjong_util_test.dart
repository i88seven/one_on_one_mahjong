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

  group('fetchThirteenOrphansTiles test', () {
    test('thirteen reach', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s9,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      List<AllTileKinds> expected = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s9,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      List<AllTileKinds> actual = fetchThirteenOrphansTiles(tiles);
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i], reason: "on $i");
      }
    });

    test('single reach', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      List<AllTileKinds> expected = [AllTileKinds.s9];
      List<AllTileKinds> actual = fetchThirteenOrphansTiles(tiles);
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i], reason: "on $i");
      }
    });

    test('other tile', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.sr,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      List<AllTileKinds> expected = [];
      List<AllTileKinds> actual = fetchThirteenOrphansTiles(tiles);
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i], reason: "on $i");
      }
    });

    test('too much', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      List<AllTileKinds> expected = [];
      List<AllTileKinds> actual = fetchThirteenOrphansTiles(tiles);
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i], expected[i], reason: "on $i");
      }
    });
  });
}
