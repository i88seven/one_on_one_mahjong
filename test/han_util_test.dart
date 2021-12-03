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
      isReach: true,
      isFirstTurn: false,
      doras: [AllTileKinds.m1, AllTileKinds.j1],
      wind: wind ?? 1,
      round: round ?? 1,
      isParent: isParent ?? true,
      winTile: winTile);
}

void main() {
  group('fetchYakuman test', () {
    fetchYakumanTest(List<AllTileKinds> tiles, AllTileKinds winTile,
        Map<Yaku, bool> expected) {
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = fetchMahjongState(winTile);
      WinCandidate winCandidate = winCandidates[0];
      Map<Yaku, bool> actualYakumanMap =
          fetchYakuman(winCandidate, mahjongState, tiles);
      expect(actualYakumanMap.keys.length, expected.keys.length);
      for (Yaku yaku in actualYakumanMap.keys) {
        expect(actualYakumanMap[yaku], expected[yaku], reason: "on $yaku");
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
      Map<Yaku, bool> expected = {
        Yaku.fourConcealedTriples: false,
        Yaku.thirteenOrphans: false,
        Yaku.bigDragons: false,
        Yaku.fourWinds: false,
        Yaku.allHonors: false,
        Yaku.allTerminals: false,
        Yaku.allGreen: true,
        Yaku.nineGates: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.fourConcealedTriples: true,
        Yaku.thirteenOrphans: false,
        Yaku.bigDragons: false,
        Yaku.fourWinds: false,
        Yaku.allHonors: false,
        Yaku.allTerminals: true,
        Yaku.allGreen: false,
        Yaku.nineGates: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.fourConcealedTriples: true,
        Yaku.thirteenOrphans: false,
        Yaku.bigDragons: false,
        Yaku.fourWinds: true,
        Yaku.allHonors: true,
        Yaku.allTerminals: false,
        Yaku.allGreen: false,
        Yaku.nineGates: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.fourConcealedTriples: false,
        Yaku.thirteenOrphans: false,
        Yaku.bigDragons: false,
        Yaku.fourWinds: false,
        Yaku.allHonors: false,
        Yaku.allTerminals: false,
        Yaku.allGreen: false,
        Yaku.nineGates: false,
      };
      fetchYakumanTest(tiles, AllTileKinds.m2, expected);
    });
  });

  group('fetchYaku test', () {
    fetchYakuTest(List<AllTileKinds> tiles, AllTileKinds winTile,
        Map<Yaku, bool> expected) {
      List<WinCandidate> winCandidates = fetchWinCandidates(tiles);
      MahjongState mahjongState = fetchMahjongState(winTile);
      // TODO Candidate が複数ある時のテスト
      WinCandidate winCandidate = winCandidates[0];
      Map<Yaku, bool> actualYakumanMap =
          fetchYaku(winCandidate, mahjongState, tiles);
      expect(actualYakumanMap.keys.length, expected.keys.length);
      for (Yaku yaku in actualYakumanMap.keys) {
        expect(actualYakumanMap[yaku], expected[yaku], reason: "on $yaku");
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: true,
        Yaku.allRuns: true,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
      fetchYakuTest(tiles, AllTileKinds.s6, expected);
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: true,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: true,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: true,
        Yaku.fullFlush: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: true,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: true,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: true,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: true,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: true,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: true,
        Yaku.threeColorTriples: true,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: true,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: true,
      };
      fetchYakuTest(tiles, AllTileKinds.m9, expected);
    });
  });

  group('fetchSevenPairsYaku test', () {
    fetchSevenPairsYakuTest(List<AllTileKinds> tiles, AllTileKinds winTile,
        Map<Yaku, bool>? expected) {
      MahjongState mahjongState = fetchMahjongState(winTile);
      Map<Yaku, bool>? actualYakumanMap =
          fetchSevenPairsYaku(mahjongState, tiles);
      if (actualYakumanMap == null) {
        expect(actualYakumanMap, expected);
        return;
      }
      expect(actualYakumanMap.keys.length, expected!.keys.length);
      for (Yaku yaku in actualYakumanMap.keys) {
        expect(actualYakumanMap[yaku], expected[yaku], reason: "on $yaku");
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: true,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: true,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: true,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: true,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
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
      Map<Yaku, bool> expected = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: true,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: true,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: true,
      };
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
      fetchSevenPairsYakuTest(tiles, AllTileKinds.m3, null);
    });
  });

  group('sumHan test', () {
    test('AllRuns', () {
      Map<Yaku, bool> yakuMap = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: true,
        Yaku.allRuns: true,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
      expect(sumHan(yakuMap), 4);
    });

    test('TwoDoubleRuns', () {
      Map<Yaku, bool> yakuMap = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: true,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: true,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: true,
        Yaku.fullFlush: false,
      };
      expect(sumHan(yakuMap), 9);
    });

    test('pureOutsideHand', () {
      Map<Yaku, bool> yakuMap = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: true,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: false,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: true,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
      expect(sumHan(yakuMap), 7);
    });

    test('allTerminalsAndHonors', () {
      Map<Yaku, bool> yakuMap = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: true,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: true,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: true,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: true,
        Yaku.threeColorTriples: true,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: false,
      };
      expect(sumHan(yakuMap), 11);
    });

    test('fullFlush', () {
      Map<Yaku, bool> yakuMap = {
        Yaku.reach: true,
        Yaku.seatWind: false,
        Yaku.prevalentWind: false,
        Yaku.whiteDragon: false,
        Yaku.greenDragon: false,
        Yaku.redDragon: false,
        Yaku.allSimples: false,
        Yaku.allRuns: false,
        Yaku.concealedSelfDraw: true,
        Yaku.firstTurnWin: false,
        Yaku.doubleRun: false,
        Yaku.allTriples: false,
        Yaku.threeColorRuns: false,
        Yaku.sevenPairs: false,
        Yaku.fullStraight: false,
        Yaku.mixedOutsideHand: false,
        Yaku.threeConcealedTriples: true,
        Yaku.littleDragons: false,
        Yaku.allTerminalsAndHonors: false,
        Yaku.threeColorTriples: false,
        Yaku.halfFlush: false,
        Yaku.pureOutsideHand: false,
        Yaku.twoDoubleRuns: false,
        Yaku.fullFlush: true,
      };
      expect(sumHan(yakuMap), 10);
    });
  });
}
