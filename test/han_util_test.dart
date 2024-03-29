import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/han_util.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/separate_tiles_util.dart';

MahjongState fetchMahjongState(
  AllTileKinds winTile, {
  int? wind,
  int? round,
  bool? isParent,
}) {
  return MahjongState(
      isFirstTurn: false,
      isFinalTile: false,
      wind: wind ?? 1,
      round: round ?? 1,
      isParent: isParent ?? true,
      winTile: winTile);
}

void main() {
  group('fetchYakuman test', () {
    fetchYakumanTest(
        List<AllTileKinds> tiles, AllTileKinds winTile, List<Yaku> expected) {
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = fetchMahjongState(winTile);
      WinCandidate winCandidate = winCandidates[0];
      List<Yaku> actualYakumanList =
          fetchYakuman(winCandidate, mahjongState, tiles);
      expect(actualYakumanList.length, expected.length);
      for (var i = 0; i < actualYakumanList.length; i++) {
        expect(actualYakumanList[i], expected[i], reason: "on $i");
      }
    }

    test('allGreen', () {
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
        AllTileKinds.j6,
      ];
      List<Yaku> expected = [
        Yaku.allGreen,
      ];
      fetchYakumanTest(tiles, AllTileKinds.s2, expected);
    });

    test('double yakuman', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.s1,
      ];
      List<Yaku> expected = [
        Yaku.fourConcealedTriples,
        Yaku.allTerminals,
      ];
      fetchYakumanTest(tiles, AllTileKinds.p9, expected);
    });

    test('triple yakuman', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j2,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j3,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j4,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j5,
      ];
      List<Yaku> expected = [
        Yaku.fourConcealedTriples,
        Yaku.fourWinds,
        Yaku.allHonors,
      ];
      fetchYakumanTest(tiles, AllTileKinds.j5, expected);
    });

    test('no yakuman', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p8,
        AllTileKinds.p8,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
      ];
      List<Yaku> expected = [];
      fetchYakumanTest(tiles, AllTileKinds.m2, expected);
    });
  });

  group('fetchYaku test', () {
    fetchYakuTest(
        List<AllTileKinds> tiles, AllTileKinds winTile, List<Yaku> expected) {
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = fetchMahjongState(winTile);
      // TODO Candidate が複数ある時のテスト
      WinCandidate winCandidate = winCandidates[0];
      List<Yaku> actualYakuList = fetchYaku(winCandidate, mahjongState, tiles);
      expect(actualYakuList.length, expected.length);
      for (var i = 0; i < actualYakuList.length; i++) {
        expect(actualYakuList[i], expected[i], reason: "on $i");
      }
    }

    test('AllRuns', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s6,
        AllTileKinds.s7,
        AllTileKinds.s8,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allSimples,
        Yaku.allRuns,
      ];
      fetchYakuTest(tiles, AllTileKinds.s6, expected);
    });

    test('FirstTurnWin', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s6,
        AllTileKinds.s7,
        AllTileKinds.s8,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allSimples,
        Yaku.allRuns,
        Yaku.firstTurnWin,
      ];
      AllTileKinds winTile = AllTileKinds.s6;
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = MahjongState(
          isFirstTurn: true,
          isFinalTile: false,
          wind: 1,
          round: 1,
          isParent: true,
          winTile: winTile);
      WinCandidate winCandidate = winCandidates[0];
      List<Yaku> actualYakuList = fetchYaku(winCandidate, mahjongState, tiles);
      expect(actualYakuList.length, expected.length);
      for (var i = 0; i < actualYakuList.length; i++) {
        expect(actualYakuList[i], expected[i], reason: "on $i");
      }
    });

    test('FinalTileWin', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s6,
        AllTileKinds.s7,
        AllTileKinds.s8,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allSimples,
        Yaku.allRuns,
        Yaku.finalTileWin,
      ];
      AllTileKinds winTile = AllTileKinds.s6;
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = MahjongState(
          isFirstTurn: false,
          isFinalTile: true,
          wind: 1,
          round: 1,
          isParent: true,
          winTile: winTile);
      WinCandidate winCandidate = winCandidates[0];
      List<Yaku> actualYakuList = fetchYaku(winCandidate, mahjongState, tiles);
      expect(actualYakuList.length, expected.length);
      for (var i = 0; i < actualYakuList.length; i++) {
        expect(actualYakuList[i], expected[i], reason: "on $i");
      }
    });

    test('TwoDoubleRuns', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m6,
        AllTileKinds.j2,
        AllTileKinds.j2,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allRuns,
        Yaku.halfFlush,
        Yaku.twoDoubleRuns,
      ];
      fetchYakuTest(tiles, AllTileKinds.m6, expected);
    });

    test('pureOutsideHand', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.s1,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.threeColorRuns,
        Yaku.pureOutsideHand,
      ];
      fetchYakuTest(tiles, AllTileKinds.s9, expected);
    });

    test('allTerminalsAndHonors', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.j2,
        AllTileKinds.j2,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.greenDragon,
        Yaku.allTriples,
        Yaku.threeConcealedTriples,
        Yaku.allTerminalsAndHonors,
        Yaku.threeColorTriples,
      ];
      fetchYakuTest(tiles, AllTileKinds.j6, expected);
    });

    test('fullFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.threeConcealedTriples,
        Yaku.fullFlush,
      ];
      fetchYakuTest(tiles, AllTileKinds.m9, expected);
    });
  });

  group('fetchSevenPairsYaku test', () {
    fetchSevenPairsYakuTest(
        List<AllTileKinds> tiles, AllTileKinds winTile, List<Yaku> expected) {
      MahjongState mahjongState = fetchMahjongState(winTile);
      List<Yaku> actualYakuList = fetchSevenPairsYaku(mahjongState, tiles);
      expect(actualYakuList.length, expected.length);
      for (var i = 0; i < actualYakuList.length; i++) {
        expect(actualYakuList[i], expected[i], reason: "on $i");
      }
    }

    test('allSimples', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s7,
        AllTileKinds.s7,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allSimples,
        Yaku.sevenPairs,
      ];
      fetchSevenPairsYakuTest(tiles, AllTileKinds.s7, expected);
    });

    test('allTerminalsAndHonors', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j4,
        AllTileKinds.j4,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.sevenPairs,
        Yaku.allTerminalsAndHonors,
      ];
      fetchSevenPairsYakuTest(tiles, AllTileKinds.s7, expected);
    });

    test('fullFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.m7,
        AllTileKinds.m8,
        AllTileKinds.m8,
      ];
      List<Yaku> expected = [
        Yaku.reach,
        Yaku.allSimples,
        Yaku.sevenPairs,
        Yaku.fullFlush,
      ];
      fetchSevenPairsYakuTest(tiles, AllTileKinds.m5, expected);
    });

    test('is not SevenPairs', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s7,
        AllTileKinds.s7,
      ];
      List<Yaku> expected = [];
      fetchSevenPairsYakuTest(tiles, AllTileKinds.m3, expected);
    });
  });

  group('fetchHansOfDora test', () {
    test('red tile', () {
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
      expect(fetchHansOfDora(hands, AllTileKinds.s4), 3);
    });

    test('red tile dora', () {
      List<AllTileKinds> hands = [
        AllTileKinds.mr,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j6,
      ];
      expect(fetchHansOfDora(hands, AllTileKinds.sr), 4);
    });

    test('honor', () {
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
      expect(fetchHansOfDora(hands, AllTileKinds.j4), 0);
    });
  });

  group('fetchHansOfRedFive test', () {
    test('red tile', () {
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
      expect(fetchHansOfRedFive(hands), 3);
    });

    test('zero', () {
      List<AllTileKinds> hands = [
        AllTileKinds.m1,
        AllTileKinds.p5,
        AllTileKinds.p1,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.s1,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j6,
      ];
      expect(fetchHansOfRedFive(hands), 0);
    });
  });
}
