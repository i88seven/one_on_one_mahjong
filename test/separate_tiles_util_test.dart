import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/separate_tiles_util.dart';

void main() {
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

  group('compareSeparatedTile test', () {
    test('compareSeparatedTile Bamboos', () {
      WinCandidate baseList = [
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s8),
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s2),
      ];
      WinCandidate expectList = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s4),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s8),
      ];
      baseList.sort(compareSeparatedTile);
      expect(baseList.length, expectList.length);
      for (int i = 0; i < expectList.length; i++) {
        expect(baseList[i].type, expectList[i].type,
            reason: "actual: ${baseList[i]}, expect: ${expectList[i]}");
        expect(baseList[i].baseTile, expectList[i].baseTile,
            reason: "actual: ${baseList[i]}, expect: ${expectList[i]}");
      }
    });

    test('compareSeparatedTile mix', () {
      WinCandidate baseList = [
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p8),
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
      ];
      WinCandidate expectList = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p8),
      ];
      baseList.sort(compareSeparatedTile);
      expect(baseList.length, expectList.length);
      for (int i = 0; i < expectList.length; i++) {
        expect(baseList[i].type, expectList[i].type,
            reason: "actual: ${baseList[i]}, expect: ${expectList[i]}");
        expect(baseList[i].baseTile, expectList[i].baseTile,
            reason: "actual: ${baseList[i]}, expect: ${expectList[i]}");
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

  group('fetchWinCandidates test', () {
    fetchWinCandidatesTest(
        List<AllTileKinds> hands, List<WinCandidate> expectWinCandidates) {
      final actualWinCandidates = fetchWinCandidates(hands);

      expect(actualWinCandidates.length, expectWinCandidates.length);
      for (WinCandidate expectWinCandidate in expectWinCandidates) {
        expect(
            isWinCandidateFound(actualWinCandidates, expectWinCandidate), true,
            reason: "expect: $expectWinCandidate is not found");
      }
    }

    test('fetchWinCandidates test1', () {
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
      List<WinCandidate> expectWinCandidates = [
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p8),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
        ]
      ];
      fetchWinCandidatesTest(hands, expectWinCandidates);
    });

    test('fetchWinCandidates test2', () {
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
      List<WinCandidate> expectWinCandidates = [
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
        ]
      ];
      fetchWinCandidatesTest(hands, expectWinCandidates);
    });

    test('fetchWinCandidates empty', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j1,
      ];
      List<WinCandidate> expectWinCandidates = [];
      fetchWinCandidatesTest(hands, expectWinCandidates);
    });

    test('fetchWinCandidates some pattern test', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.p5,
      ];
      List<WinCandidate> expectWinCandidates = [
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p5),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p4),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
        ],
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p5),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        ],
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p5),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p4),
        ],
        [
          SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p1),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
          SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
        ],
      ];
      fetchWinCandidatesTest(hands, expectWinCandidates);
    });
  });

  group('reach test', () {
    reachTest(List<AllTileKinds> hands,
        Map<AllTileKinds, List<WinCandidate>> expectTiles) {
      final reachTiles = searchReachTiles(hands);

      expect(reachTiles.length, expectTiles.length);
      for (AllTileKinds reachTile in reachTiles.keys) {
        expect(reachTiles[reachTile]!.length, expectTiles[reachTile]!.length);
        for (WinCandidate expectWinCandidate in expectTiles[reachTile]!) {
          expect(
              isWinCandidateFound(reachTiles[reachTile]!, expectWinCandidate),
              true,
              reason: "expect: $expectWinCandidate is not found");
        }
      }
    }

    test('reach test', () {
      List<AllTileKinds> hands = [
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.p6,
        AllTileKinds.p6,
        AllTileKinds.p7,
        AllTileKinds.p7,
      ];
      Map<AllTileKinds, List<WinCandidate>> expectTiles = {
        AllTileKinds.p1: [
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
          ],
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p4),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
          ],
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p7),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
          ],
        ],
        AllTileKinds.p4: [
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p4),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
          ],
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p7),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
          ],
        ],
        AllTileKinds.p7: [
          [
            SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p7),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p4),
            SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p5),
          ],
        ],
      };
      reachTest(hands, expectTiles);
    });
  });
}
