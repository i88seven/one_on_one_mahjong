import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

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

  group('canExtractChow test', () {
    test('canExtractChow red', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m4,
        AllTileKinds.mr,
        AllTileKinds.p1,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.pr,
        AllTileKinds.p6,
        AllTileKinds.p7,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s5,
      ];
      Map<AllTileKinds, bool> expectTiles = {
        AllTileKinds.m4: false,
        AllTileKinds.mr: false,
        AllTileKinds.p1: false,
        AllTileKinds.p3: true,
        AllTileKinds.p4: true,
        AllTileKinds.pr: true,
        AllTileKinds.p6: false,
        AllTileKinds.p7: false,
        AllTileKinds.p9: false,
        AllTileKinds.s1: true,
        AllTileKinds.s2: true,
        AllTileKinds.s3: true,
        AllTileKinds.s4: false,
        AllTileKinds.s5: false,
      };
      for (AllTileKinds expectTile in expectTiles.keys) {
        expect(canExtractChow(hands, expectTile), expectTiles[expectTile],
            reason: "for tile:${expectTile.name}");
      }
    });

    test('canExtractChow twoDoubleRun', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.mr,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
      ];
      Map<AllTileKinds, bool> expectTiles = {
        AllTileKinds.m3: true,
        AllTileKinds.m4: false,
        AllTileKinds.m5: false,
        AllTileKinds.mr: false,
        AllTileKinds.p1: true,
        AllTileKinds.p2: true,
        AllTileKinds.p3: false,
        AllTileKinds.p4: false,
      };
      for (AllTileKinds expectTile in expectTiles.keys) {
        expect(canExtractChow(hands, expectTile), expectTiles[expectTile],
            reason: "for tile:${expectTile.name}");
      }
    });
  });

  group('fetchPungCandidate test', () {
    test('fetchPungCandidate', () {
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
      final candidates = fetchPungCandidate(hands);
      List<AllTileKinds> expectTiles = [
        AllTileKinds.s5,
        AllTileKinds.s7,
      ];
      expect(candidates.length, expectTiles.length);
      for (AllTileKinds candidate in candidates) {
        expect(expectTiles.contains(candidate), true,
            reason: "for tile:${candidate.name}");
      }
    });
  });

  group('fetchChowCandidate test', () {
    test('fetchChowCandidate', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.p7,
        AllTileKinds.p8,
        AllTileKinds.p8,
        AllTileKinds.p9,
        AllTileKinds.sr,
        AllTileKinds.s6,
        AllTileKinds.s7,
      ];
      final candidates = fetchChowCandidate(hands);
      List<AllTileKinds> expectTiles = [
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p7,
        AllTileKinds.s5,
      ];
      expect(candidates.length, expectTiles.length);
      for (AllTileKinds candidate in candidates) {
        expect(expectTiles.contains(candidate), true,
            reason: "for tile:${candidate.name}");
      }
    });
  });

  group('fetchSeparatedTilesCandidates test', () {
    fetchSeparatedTilesCandidatesTest(List<AllTileKinds> hands,
        List<List<Map<String, AllTileKinds>>> expectCandidates) {
      final actualCandidates = fetchSeparatedTilesCandidates(hands);

      expect(actualCandidates.length, expectCandidates.length);
      for (List<Map<String, AllTileKinds>> expectCandidate
          in expectCandidates) {
        expect(isSeparatedTilesFound(actualCandidates, expectCandidate), true,
            reason: "expect: $expectCandidate is not found");
      }
    }

    test('fetchSeparatedTilesCandidates test1', () {
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
        AllTileKinds.p8,
      ];
      List<List<Map<String, AllTileKinds>>> expectCandidates = [
        [
          {'head': AllTileKinds.p8},
          {'pung': AllTileKinds.p3},
          {'chow': AllTileKinds.p2},
          {'chow': AllTileKinds.p4},
          {'chow': AllTileKinds.p4},
        ]
      ];
      fetchSeparatedTilesCandidatesTest(hands, expectCandidates);
    });

    test('fetchSeparatedTilesCandidates test2', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
      ];
      List<List<Map<String, AllTileKinds>>> expectCandidates = [
        [
          {'head': AllTileKinds.p2},
          {'pung': AllTileKinds.p1},
          {'chow': AllTileKinds.p1},
          {'chow': AllTileKinds.p2},
          {'chow': AllTileKinds.p3},
        ]
      ];
      fetchSeparatedTilesCandidatesTest(hands, expectCandidates);
    });
  });
}
