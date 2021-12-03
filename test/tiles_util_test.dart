import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';

void main() {
  group('convertRedTiles test', () {
    test('convertRedTiles', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.mr,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final convertedTiles = convertRedTiles(hands);
      List<AllTileKinds> expectTiles = [
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      expect(convertedTiles.length, expectTiles.length);
      for (AllTileKinds convertedTile in convertedTiles) {
        expect(expectTiles.contains(convertedTile), true,
            reason: "for tile:${convertedTile.name}");
      }
    });
  });

  test('addTileNumber', () {
    Map<AllTileKinds, AllTileKinds?> expectTilesMap = {
      AllTileKinds.m1: AllTileKinds.m2,
      AllTileKinds.m4: AllTileKinds.m5,
      AllTileKinds.m5: AllTileKinds.m6,
      AllTileKinds.mr: AllTileKinds.m6,
      AllTileKinds.m6: AllTileKinds.m7,
      AllTileKinds.m9: null,
      AllTileKinds.p1: AllTileKinds.p2,
      AllTileKinds.p4: AllTileKinds.p5,
      AllTileKinds.p5: AllTileKinds.p6,
      AllTileKinds.pr: AllTileKinds.p6,
      AllTileKinds.p6: AllTileKinds.p7,
      AllTileKinds.p9: null,
      AllTileKinds.s1: AllTileKinds.s2,
      AllTileKinds.s4: AllTileKinds.s5,
      AllTileKinds.s5: AllTileKinds.s6,
      AllTileKinds.sr: AllTileKinds.s6,
      AllTileKinds.s6: AllTileKinds.s7,
      AllTileKinds.s9: null,
      AllTileKinds.j1: null,
      AllTileKinds.j4: null,
      AllTileKinds.j5: null,
      AllTileKinds.j7: null,
    };
    for (AllTileKinds baseTile in expectTilesMap.keys) {
      expect(addTileNumber(baseTile), expectTilesMap[baseTile],
          reason: "for tile:${baseTile.name}");
    }
  });

  group('fetchWinTileTypes test', () {
    test('fetchWinTileTypes error', () {
      List<AllTileKinds> hands = [
        AllTileKinds.mr,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j6,
      ];
      final winTileTypes = fetchWinTileTypes(hands);
      expect(winTileTypes.isEmpty, true);
    });

    test('fetchWinTileTypes 1', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      final winTileTypes = fetchWinTileTypes(hands);
      expect(winTileTypes.length, 1);
      expect(winTileTypes.first, 'p');
    });

    test('fetchWinTileTypes 2', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      final winTileTypes = fetchWinTileTypes(hands);
      expect(winTileTypes.length, 2);
      expect(winTileTypes.contains('m'), true);
      expect(winTileTypes.contains('p'), true);
    });
  });

  group('fetchTileTypeCount test', () {
    test('fetchTileTypeCount', () {
      List<AllTileKinds> hands = [
        AllTileKinds.mr,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j6,
      ];
      final tileTypeCount = fetchTileTypeCount(hands);
      Map<String, int> expectCount = {'m': 1, 'p': 2, 's': 7, 'j': 3};
      for (String tileType in tileTypeCount.keys) {
        expect(tileTypeCount[tileType], expectCount[tileType],
            reason: "for tileType:$tileType");
      }
    });

    test('fetchTileTypeCount with 0', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.p6,
        AllTileKinds.p6,
        AllTileKinds.p8,
      ];
      final tileTypeCount = fetchTileTypeCount(hands);
      Map<String, int> expectCount = {'p': 13};
      for (String tileType in tileTypeCount.keys) {
        expect(tileTypeCount[tileType], expectCount[tileType],
            reason: "for tileType:$tileType");
      }
    });
  });

  group('fetchTileKindCount test', () {
    test('fetchTileKindCount', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j6,
      ];
      final actualTileKindCount = fetchTileKindCount(hands);
      Map<AllTileKinds, int> expectCount = {
        AllTileKinds.p5: 3,
        AllTileKinds.s5: 3,
        AllTileKinds.s7: 4,
        AllTileKinds.j5: 2,
        AllTileKinds.j6: 1,
      };
      expect(actualTileKindCount.length, expectCount.length);
      for (AllTileKinds tileKind in actualTileKindCount.keys) {
        expect(actualTileKindCount[tileKind], expectCount[tileKind],
            reason: "for tileKind:$tileKind");
      }
    });
  });
}
