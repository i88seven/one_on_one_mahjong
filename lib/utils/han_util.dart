import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/yaku_util.dart';

Map<Yaku, bool> fetchYakuman(WinCandidate winCandidate,
    MahjongState mahjongState, List<AllTileKinds> tiles) {
  return {
    Yaku.fourConcealedTriples:
        isFourConcealedTriples(winCandidate, mahjongState),
    Yaku.thirteenOrphans: false, // 国士無双は別で判定する
    Yaku.bigDragons: isBigDragons(winCandidate),
    Yaku.fourWinds: isFourWinds(winCandidate),
    Yaku.allHonors: isAllHonors(winCandidate),
    Yaku.allTerminals: isAllTerminals(tiles),
    Yaku.allGreen: isAllGreen(tiles),
    Yaku.nineGates: isNineGates(tiles),
  };
}

Map<Yaku, bool> fetchYaku(WinCandidate winCandidate, MahjongState mahjongState,
    List<AllTileKinds> tiles) {
  Map<Yaku, bool> result = {
    Yaku.reach: mahjongState.isReach,
    Yaku.seatWind: isSeatWind(winCandidate, mahjongState),
    Yaku.prevalentWind: isPrevalentWind(winCandidate, mahjongState),
    Yaku.whiteDragon: isWhiteDragon(winCandidate),
    Yaku.greenDragon: isGreenDragon(winCandidate),
    Yaku.redDragon: isRedDragon(winCandidate),
    Yaku.allSimples: isAllSimples(tiles),
    Yaku.allRuns: isAllRuns(winCandidate, mahjongState),
    Yaku.concealedSelfDraw: true,
    Yaku.firstTurnWin: mahjongState.isFirstTurn,
    Yaku.doubleRun: isDoubleRun(winCandidate),
    Yaku.allTriples: isAllTriples(winCandidate),
    Yaku.threeColorRuns: isThreeColors(winCandidate, SeparateType.chow),
    Yaku.sevenPairs: false, // 七対子は別で判定する
    Yaku.fullStraight: isFullStraight(winCandidate),
    Yaku.mixedOutsideHand: isMixedOutsideHand(winCandidate),
    Yaku.threeConcealedTriples:
        isThreeConcealedTriples(winCandidate, mahjongState),
    Yaku.littleDragons: isLittleDragons(winCandidate),
    Yaku.allTerminalsAndHonors: isAllTerminalsAndHonors(tiles),
    Yaku.threeColorTriples: isThreeColors(winCandidate, SeparateType.pung),
    Yaku.halfFlush: isHalfFlush(tiles),
    Yaku.pureOutsideHand: isPureOutsideHand(winCandidate),
    Yaku.twoDoubleRuns: isTwoDoubleRuns(winCandidate),
    Yaku.fullFlush: isFullFlush(tiles),
  };
  conflicts.forEach((upperYaku, lowerYaku) {
    if (result[upperYaku]!) {
      result[lowerYaku] = false;
    }
  });
  return result;
}

Map<Yaku, bool>? fetchSevenPairsYaku(
    MahjongState mahjongState, List<AllTileKinds> tiles) {
  if (!isSevenPairs(tiles)) {
    return null;
  }
  Map<Yaku, bool> result = {
    Yaku.reach: mahjongState.isReach,
    Yaku.seatWind: false,
    Yaku.prevalentWind: false,
    Yaku.whiteDragon: false,
    Yaku.greenDragon: false,
    Yaku.redDragon: false,
    Yaku.allSimples: isAllSimples(tiles),
    Yaku.allRuns: false,
    Yaku.concealedSelfDraw: true,
    Yaku.firstTurnWin: mahjongState.isFirstTurn,
    Yaku.doubleRun: false,
    Yaku.allTriples: false,
    Yaku.threeColorRuns: false,
    Yaku.sevenPairs: true,
    Yaku.fullStraight: false,
    Yaku.mixedOutsideHand: false,
    Yaku.threeConcealedTriples: false,
    Yaku.littleDragons: false,
    Yaku.allTerminalsAndHonors: isAllTerminalsAndHonors(tiles),
    Yaku.threeColorTriples: false,
    Yaku.halfFlush: isHalfFlush(tiles),
    Yaku.pureOutsideHand: false,
    Yaku.twoDoubleRuns: false,
    Yaku.fullFlush: isFullFlush(tiles),
  };
  conflicts.forEach((upperYaku, lowerYaku) {
    if (result[upperYaku]!) {
      result[lowerYaku] = false;
    }
  });
  return result;
}

int sumHan(Map<Yaku, bool> winYakuMap) {
  Map<Yaku, bool> targetYakuMap = {...winYakuMap};
  targetYakuMap.removeWhere((yaku, isWin) => !isWin);
  return targetYakuMap.keys
      .fold(0, (previous, yaku) => previous + hanMap[yaku]!);
}
