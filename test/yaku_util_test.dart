import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/yaku_util.dart';

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
  /* 自風 */
  group('isSeatWind test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result =
          isSeatWind(winCandidate, fetchMahjongState(AllTileKinds.p1));
      expect(result, true);
    });
    test('success south', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isSeatWind(
          winCandidate, fetchMahjongState(AllTileKinds.p1, isParent: false));
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result =
          isSeatWind(winCandidate, fetchMahjongState(AllTileKinds.p1));
      expect(result, false);
    });
  });

  /* 場風 */
  group('isPrevalentWind test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result =
          isPrevalentWind(winCandidate, fetchMahjongState(AllTileKinds.p1));
      expect(result, true);
    });
    test('success south', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isPrevalentWind(
          winCandidate, fetchMahjongState(AllTileKinds.p1, wind: 2));
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result =
          isPrevalentWind(winCandidate, fetchMahjongState(AllTileKinds.p1));
      expect(result, false);
    });
  });

  /* 白 */
  group('isWhiteDragon test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isWhiteDragon(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isWhiteDragon(winCandidate);
      expect(result, false);
    });
  });

  /* 發 */
  group('isGreenDragon test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isGreenDragon(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isGreenDragon(winCandidate);
      expect(result, false);
    });
  });

  /* 中 */
  group('isRedDragon test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isRedDragon(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isRedDragon(winCandidate);
      expect(result, false);
    });
  });

  /* 断ヤオ九 */
  group('isAllSimples test', () {
    test('success true', () {
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
      final result = isAllSimples(tiles);
      expect(result, true);
    });
    test('success false 1', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j3,
        AllTileKinds.j3,
      ];
      final result = isAllSimples(tiles);
      expect(result, false);
    });
    test('success false 2', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      final result = isAllSimples(tiles);
      expect(result, false);
    });
  });

  /* 平和 */
  group('isAllRuns test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s6));
      expect(result, true);
    });
    test('success true double run', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.m2));
      expect(result, true);
    });
    test('success true contain head', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.m2));
      expect(result, true);
    });
    test('success true edge wait ', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s7));
      expect(result, true);
    });
    test('success false contain pung ', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s6));
      expect(result, false);
    });
    test('success false closed wait ', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s7));
      expect(result, false);
    });
    test('success false edge wait ', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s7));
      expect(result, false);
    });
    test('success false single wait', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.s2));
      expect(result, false);
    });
    test('success false seat', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result = isAllRuns(
          winCandidate, fetchMahjongState(AllTileKinds.s6, isParent: false));
      expect(result, false);
    });
    test('success false dragon', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s6),
      ];
      final result = isAllRuns(
          winCandidate, fetchMahjongState(AllTileKinds.s6, isParent: false));
      expect(result, false);
    });
    test('success false double run middle', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s2),
      ];
      final result =
          isAllRuns(winCandidate, fetchMahjongState(AllTileKinds.m3));
      expect(result, false);
    });
  });

  /* 一盃口 */
  group('isDoubleRun test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
      ];
      final result = isDoubleRun(winCandidate);
      expect(result, true);
    });
    test('success true two double runs', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
      ];
      final result = isDoubleRun(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m6),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
      ];
      final result = isDoubleRun(winCandidate);
      expect(result, false);
    });
  });

  /* 対々和 */
  group('isAllTriples test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p2),
      ];
      final result = isAllTriples(winCandidate);
      expect(result, true);
    });
    test('success true four concealed triples', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
      ];
      final result = isAllTriples(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
      ];
      final result = isAllTriples(winCandidate);
      expect(result, false);
    });
  });

  /* 三色同刻 */
  group('isThreeColorRuns test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeColors(winCandidate, SeparateType.pung);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeColors(winCandidate, SeparateType.pung);
      expect(result, false);
    });
  });

  /* 三色同順 */
  group('isThreeColorTriples test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeColors(winCandidate, SeparateType.chow);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeColors(winCandidate, SeparateType.chow);
      expect(result, false);
    });
  });

  /* 七対子 */
  group('isSevenPairs test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.p8,
        AllTileKinds.p8,
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.j1,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j2,
      ];
      final result = isSevenPairs(tiles);
      expect(result, true);
    });
    test('success true two double runs', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.j2,
        AllTileKinds.j2,
      ];
      final result = isSevenPairs(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.s2,
        AllTileKinds.s2,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.s7,
        AllTileKinds.s7,
        AllTileKinds.j3,
        AllTileKinds.j3,
      ];
      final result = isSevenPairs(tiles);
      expect(result, false);
    });
    test('success false 4 tiles', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.p2,
        AllTileKinds.p2,
        AllTileKinds.p3,
        AllTileKinds.p3,
        AllTileKinds.p4,
        AllTileKinds.p4,
        AllTileKinds.j2,
        AllTileKinds.j2,
      ];
      final result = isSevenPairs(tiles);
      expect(result, false);
    });
  });

  /* 一気通貫 */
  group('isFullStraight test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
      ];
      final result = isFullStraight(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result = isFullStraight(winCandidate);
      expect(result, false);
    });
  });

  /* 混全帯么九 */
  group('isMixedOutsideHand test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result = isMixedOutsideHand(winCandidate);
      expect(result, true);
    });
    test('success true AllTerminalsAndHonors', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
      ];
      final result = isMixedOutsideHand(winCandidate);
      expect(result, true);
    });
    test('success true FourWinds', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
      ];
      final result = isMixedOutsideHand(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result = isMixedOutsideHand(winCandidate);
      expect(result, false);
    });
  });

  /* 三暗刻 */
  group('isThreeConcealedTriples test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
      ];
      final result = isThreeConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m9));
      expect(result, true);
    });
    test('success true pung', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.p3));
      expect(result, true);
    });
    test('success true FourConcealedTriples', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
      ];
      final result = isThreeConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m3));
      expect(result, true);
    });
    test('success true 4 tiles', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m2),
      ];
      final result = isThreeConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m4));
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
      ];
      final result = isThreeConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m5));
      expect(result, false);
    });
  });

  /* 小三元 */
  group('isLittleDragons test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
      ];
      final result = isLittleDragons(winCandidate);
      expect(result, true);
    });
    test('success true BigDragons', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
      ];
      final result = isLittleDragons(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
      ];
      final result = isLittleDragons(winCandidate);
      expect(result, false);
    });
  });

  /* 混老頭 */
  group('isAllTerminalsAndHonors test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isAllTerminalsAndHonors(tiles);
      expect(result, true);
    });
    test('success true seven pairs', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.j2,
        AllTileKinds.j2,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isAllTerminalsAndHonors(tiles);
      expect(result, true);
    });
    test('success true AllTerminals', () {
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
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      final result = isAllTerminalsAndHonors(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isAllTerminalsAndHonors(tiles);
      expect(result, false);
    });
  });

  /* 混一色 */
  group('isHalfFlush test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isHalfFlush(tiles);
      expect(result, true);
    });
    test('success true seven pairs', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.j2,
        AllTileKinds.j2,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isHalfFlush(tiles);
      expect(result, true);
    });
    test('success true FullFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      final result = isHalfFlush(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isHalfFlush(tiles);
      expect(result, false);
    });
  });

  /* 純全帯么九 */
  group('isPureOutsideHand test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.s9),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
      ];
      final result = isPureOutsideHand(winCandidate);
      expect(result, true);
    });
    test('success true AllTerminals', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s9),
      ];
      final result = isPureOutsideHand(winCandidate);
      expect(result, true);
    });
    test('success false MixedOutsideHand', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s7),
      ];
      final result = isPureOutsideHand(winCandidate);
      expect(result, false);
    });
  });

  /* ニ盃口 */
  group('isTwoDoubleRuns test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
      ];
      final result = isTwoDoubleRuns(winCandidate);
      expect(result, true);
    });
    test('success true 4 chows', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m3),
      ];
      final result = isTwoDoubleRuns(winCandidate);
      expect(result, true);
    });
    test('success false DoubleRun', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m4),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p2),
      ];
      final result = isTwoDoubleRuns(winCandidate);
      expect(result, false);
    });
  });

  /* 清一色 */
  group('isFullFlush test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      final result = isFullFlush(tiles);
      expect(result, true);
    });
    test('success true seven pairs', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m4,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m7,
        AllTileKinds.m7,
        AllTileKinds.m8,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      final result = isFullFlush(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isFullFlush(tiles);
      expect(result, false);
    });
    test('success false HalfFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isFullFlush(tiles);
      expect(result, false);
    });
  });

  /* 四暗刻 */
  group('isFourConcealedTriples test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
      ];
      final result = isFourConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m3));
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.p3),
      ];
      final result = isFourConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.m9));
      expect(result, false);
    });
    test('success false pung', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m9),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.p3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.s3),
      ];
      final result = isFourConcealedTriples(
          winCandidate, fetchMahjongState(AllTileKinds.p3));
      expect(result, false);
    });
  });

  /* 国士無双 */
  group('isThirteenOrphans test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      final result = isThirteenOrphans(tiles);
      expect(result, true);
    });

    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      final result = isThirteenOrphans(tiles);
      expect(result, false);
    });

    test('error single', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.s1,
        AllTileKinds.s2,
        AllTileKinds.s9,
        AllTileKinds.j1,
        AllTileKinds.j2,
        AllTileKinds.j3,
        AllTileKinds.j4,
        AllTileKinds.j5,
        AllTileKinds.j6,
        AllTileKinds.j7,
      ];
      final result = isThirteenOrphans(tiles);
      expect(result, false);
    });
  });

  /* 大三元 */
  group('isBigDragons test', () {
    test('success true', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
      ];
      final result = isBigDragons(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
      ];
      final result = isBigDragons(winCandidate);
      expect(result, false);
    });
    test('success false LittleDragon', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j7),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.s1),
        SeparatedTile(type: SeparateType.chow, baseTile: AllTileKinds.m7),
      ];
      final result = isBigDragons(winCandidate);
      expect(result, false);
    });
  });

  /* 四喜和 */
  group('isFourWinds test', () {
    test('success true BigFourWinds', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
      ];
      final result = isFourWinds(winCandidate);
      expect(result, true);
    });
    test('success true LittleFourWinds', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
      ];
      final result = isFourWinds(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
      ];
      final result = isFourWinds(winCandidate);
      expect(result, false);
    });
  });

  /* 字一色 */
  group('isAllHonors test', () {
    test('success true BigFourWinds', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
      ];
      final result = isAllHonors(winCandidate);
      expect(result, true);
    });
    test('success true LittleFourWinds', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.j1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j4),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
      ];
      final result = isAllHonors(winCandidate);
      expect(result, true);
    });
    test('success false', () {
      WinCandidate winCandidate = [
        SeparatedTile(type: SeparateType.head, baseTile: AllTileKinds.m1),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j2),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j3),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j5),
        SeparatedTile(type: SeparateType.pung, baseTile: AllTileKinds.j6),
      ];
      final result = isAllHonors(winCandidate);
      expect(result, false);
    });
  });

  /* 清老頭 */
  group('isAllTerminals test', () {
    test('success true', () {
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
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      final result = isAllTerminals(tiles);
      expect(result, true);
    });
    test('success false HalfFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p9,
        AllTileKinds.p9,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      final result = isAllTerminals(tiles);
      expect(result, false);
    });
    test('success false HalfFlush', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.p1,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j5,
        AllTileKinds.j7,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final result = isAllTerminals(tiles);
      expect(result, false);
    });
  });

  /* 緑一色 */
  group('isAllGreen test', () {
    test('success true', () {
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
      final result = isAllGreen(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s4,
        AllTileKinds.s5,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s6,
        AllTileKinds.s8,
        AllTileKinds.s8,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j6,
      ];
      final result = isAllGreen(tiles);
      expect(result, false);
    });
  });

  /* 九蓮宝燈 */
  group('isNineGates test', () {
    test('success true', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.s1,
        AllTileKinds.s2,
        AllTileKinds.s3,
        AllTileKinds.s4,
        AllTileKinds.s5,
        AllTileKinds.s6,
        AllTileKinds.s7,
        AllTileKinds.s8,
        AllTileKinds.s8,
        AllTileKinds.s9,
        AllTileKinds.s9,
        AllTileKinds.s9,
      ];
      final result = isNineGates(tiles);
      expect(result, true);
    });
    test('success true 2', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      final result = isNineGates(tiles);
      expect(result, true);
    });
    test('success false', () {
      List<AllTileKinds> tiles = [
        AllTileKinds.m1,
        AllTileKinds.m1,
        AllTileKinds.m2,
        AllTileKinds.m2,
        AllTileKinds.m3,
        AllTileKinds.m3,
        AllTileKinds.m4,
        AllTileKinds.m5,
        AllTileKinds.m6,
        AllTileKinds.m7,
        AllTileKinds.m8,
        AllTileKinds.m9,
        AllTileKinds.m9,
        AllTileKinds.m9,
      ];
      final result = isNineGates(tiles);
      expect(result, false);
    });
  });
}
