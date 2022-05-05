import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

ReachMahjongState fetchReachMahjongState({
  AllTileKinds? dora,
  int? wind,
  int? round,
  bool? isParent,
}) {
  return ReachMahjongState(
    dora: dora ?? AllTileKinds.m1,
    wind: wind ?? 1,
    round: round ?? 1,
    isParent: isParent ?? true,
  );
}

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

  group('fetchReachResult test', () {
    fetchReachResultTest(
      List<AllTileKinds> tiles,
      ReachMahjongState reachMahjongState,
      Map<AllTileKinds, WinResult> expected,
    ) {
      Map<AllTileKinds, WinResult> actual =
          fetchReachResult(tiles, reachMahjongState);
      expect(actual.keys.length, expected.keys.length);
      for (AllTileKinds tile in actual.keys) {
        for (int i = 0; i < actual[tile]!.resultMap.length; i++) {
          expect(actual[tile]!.resultMap[i].toString(),
              expected[tile]!.resultMap[i].toString(),
              reason: "on $tile");
        }
        expect(actual[tile]!.resultMap.length, expected[tile]!.resultMap.length,
            reason: 'resultMap.length');
        expect(actual[tile]!.yakumanCount, expected[tile]!.yakumanCount,
            reason: "yakumanCount");
        expect(actual[tile]!.hans, expected[tile]!.hans, reason: "hans");
      }
    }

    group('yakuman test', () {
      test('ThirteenOrphans', () {
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
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.m1: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.m9: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.p1: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.p9: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.s1: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.s9: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j1: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j2: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j3: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j4: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j5: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j6: WinResult(yakuList: [Yaku.thirteenOrphans]),
          AllTileKinds.j7: WinResult(yakuList: [Yaku.thirteenOrphans]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });

      test('AllGreen', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.s2,
          AllTileKinds.s2,
          AllTileKinds.s3,
          AllTileKinds.s3,
          AllTileKinds.s4,
          AllTileKinds.s4,
          AllTileKinds.s6,
          AllTileKinds.s6,
          AllTileKinds.s6,
          AllTileKinds.s8,
          AllTileKinds.s8,
          AllTileKinds.j6,
          AllTileKinds.j6,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.s8: WinResult(yakuList: [Yaku.allGreen]),
          AllTileKinds.j6: WinResult(yakuList: [Yaku.allGreen]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });

      test('FourConcealedTriples', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.p3,
          AllTileKinds.p3,
          AllTileKinds.p3,
          AllTileKinds.p5,
          AllTileKinds.s3,
          AllTileKinds.s3,
          AllTileKinds.s3,
          AllTileKinds.s5,
          AllTileKinds.s5,
          AllTileKinds.sr,
          AllTileKinds.s7,
          AllTileKinds.s7,
          AllTileKinds.s7,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.p4: WinResult(
            yakuList: [Yaku.reach, Yaku.allSimples, Yaku.threeConcealedTriples],
            hansOfDoras: [0, 0, 1],
          ),
          AllTileKinds.p5: WinResult(yakuList: [Yaku.fourConcealedTriples]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });

      test('FourConcealedTriples with runs', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.p3,
          AllTileKinds.p3,
          AllTileKinds.p3,
          AllTileKinds.p5,
          AllTileKinds.s5,
          AllTileKinds.s5,
          AllTileKinds.sr,
          AllTileKinds.s6,
          AllTileKinds.s6,
          AllTileKinds.s6,
          AllTileKinds.s7,
          AllTileKinds.s7,
          AllTileKinds.s7,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.p4: WinResult(
            yakuList: [Yaku.reach, Yaku.allSimples, Yaku.threeConcealedTriples],
            hansOfDoras: [0, 0, 1],
          ),
          AllTileKinds.p5: WinResult(yakuList: [Yaku.fourConcealedTriples]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });
      // TODO 他の役満のテスト
    });

    group('yaku test', () {
      test('SevenPairs', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.p2,
          AllTileKinds.p2,
          AllTileKinds.p3,
          AllTileKinds.p3,
          AllTileKinds.p4,
          AllTileKinds.p8,
          AllTileKinds.p8,
          AllTileKinds.s2,
          AllTileKinds.s2,
          AllTileKinds.j1,
          AllTileKinds.j1,
          AllTileKinds.j2,
          AllTileKinds.j2,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.p4: WinResult(
              yakuList: [Yaku.reach, Yaku.sevenPairs], hansOfDoras: [0, 0, 0]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });

      test('SeatWind', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.p1,
          AllTileKinds.p1,
          AllTileKinds.p5,
          AllTileKinds.p5,
          AllTileKinds.pr,
          AllTileKinds.s1,
          AllTileKinds.s2,
          AllTileKinds.s3,
          AllTileKinds.s9,
          AllTileKinds.s9,
          AllTileKinds.s9,
          AllTileKinds.j1,
          AllTileKinds.j1,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.p1: WinResult(yakuList: [
            Yaku.reach,
          ], hansOfDoras: [
            0,
            0,
            1
          ]),
          AllTileKinds.j1: WinResult(yakuList: [
            Yaku.reach,
            Yaku.seatWind,
            Yaku.prevalentWind,
          ], hansOfDoras: [
            0,
            0,
            1
          ]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });

      test('FullFlush', () {
        List<AllTileKinds> tiles = [
          AllTileKinds.m2,
          AllTileKinds.m3,
          AllTileKinds.m4,
          AllTileKinds.m4,
          AllTileKinds.m4,
          AllTileKinds.m5,
          AllTileKinds.m5,
          AllTileKinds.mr,
          AllTileKinds.m7,
          AllTileKinds.m7,
          AllTileKinds.m8,
          AllTileKinds.m8,
          AllTileKinds.m8,
        ];
        Map<AllTileKinds, WinResult> expected = {
          AllTileKinds.m1: WinResult(yakuList: [
            Yaku.reach,
            Yaku.threeConcealedTriples,
            Yaku.fullFlush
          ], hansOfDoras: [
            1,
            0,
            1
          ]),
          AllTileKinds.m4: WinResult(yakuList: [
            Yaku.reach,
            Yaku.allSimples,
            Yaku.threeConcealedTriples,
            Yaku.fullFlush
          ], hansOfDoras: [
            1,
            0,
            1
          ]),
          AllTileKinds.m7: WinResult(
              yakuList: [Yaku.reach, Yaku.allSimples, Yaku.fullFlush],
              hansOfDoras: [1, 0, 1]),
        };
        ReachMahjongState reachMahjongState = fetchReachMahjongState();
        fetchReachResultTest(tiles, reachMahjongState, expected);
      });
      // TODO 他の役のテスト
    });
  });
}
