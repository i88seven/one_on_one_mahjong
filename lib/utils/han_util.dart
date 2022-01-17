import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';
import 'package:one_on_one_mahjong/utils/yaku_util.dart';

List<Yaku> fetchYakuman(WinCandidate winCandidate, MahjongState mahjongState,
    List<AllTileKinds> tiles) {
  List<Yaku> yakuList = [];
  if (isFourConcealedTriples(winCandidate, mahjongState)) {
    yakuList.add(Yaku.fourConcealedTriples);
  }
  // Yaku.thirteenOrphans: 国士無双は別で判定する
  if (isBigDragons(winCandidate)) yakuList.add(Yaku.bigDragons);
  if (isFourWinds(winCandidate)) yakuList.add(Yaku.fourWinds);
  if (isAllHonors(winCandidate)) yakuList.add(Yaku.allHonors);
  if (isAllTerminals(tiles)) yakuList.add(Yaku.allTerminals);
  if (isAllGreen(tiles)) yakuList.add(Yaku.allGreen);
  if (isNineGates(tiles)) yakuList.add(Yaku.nineGates);
  return yakuList;
}

List<Yaku> fetchYaku(WinCandidate winCandidate, MahjongState mahjongState,
    List<AllTileKinds> tiles) {
  List<Yaku> yakuList = [Yaku.reach];
  if (isSeatWind(winCandidate, mahjongState)) yakuList.add(Yaku.seatWind);
  if (isPrevalentWind(winCandidate, mahjongState)) {
    yakuList.add(Yaku.prevalentWind);
  }
  if (isWhiteDragon(winCandidate)) yakuList.add(Yaku.whiteDragon);
  if (isGreenDragon(winCandidate)) yakuList.add(Yaku.greenDragon);
  if (isRedDragon(winCandidate)) yakuList.add(Yaku.redDragon);
  if (isAllSimples(tiles)) yakuList.add(Yaku.allSimples);
  if (isAllRuns(winCandidate, mahjongState)) yakuList.add(Yaku.allRuns);
  if (mahjongState.isFirstTurn) yakuList.add(Yaku.firstTurnWin);
  if (isDoubleRun(winCandidate)) yakuList.add(Yaku.doubleRun);
  if (isAllTriples(winCandidate)) yakuList.add(Yaku.allTriples);
  if (isThreeColors(winCandidate, SeparateType.chow)) {
    yakuList.add(Yaku.threeColorRuns);
  }
  // Yaku.sevenPairs: 七対子は別で判定する
  if (isFullStraight(winCandidate)) yakuList.add(Yaku.fullStraight);
  if (isMixedOutsideHand(winCandidate)) yakuList.add(Yaku.mixedOutsideHand);
  if (isThreeConcealedTriples(winCandidate, mahjongState)) {
    yakuList.add(Yaku.threeConcealedTriples);
  }
  if (isLittleDragons(winCandidate)) yakuList.add(Yaku.littleDragons);
  if (isAllTerminalsAndHonors(tiles)) yakuList.add(Yaku.allTerminalsAndHonors);
  if (isThreeColors(winCandidate, SeparateType.pung)) {
    yakuList.add(Yaku.threeColorTriples);
  }
  if (isHalfFlush(tiles)) yakuList.add(Yaku.halfFlush);
  if (isPureOutsideHand(winCandidate)) yakuList.add(Yaku.pureOutsideHand);
  if (isTwoDoubleRuns(winCandidate)) yakuList.add(Yaku.twoDoubleRuns);
  if (isFullFlush(tiles)) yakuList.add(Yaku.fullFlush);

  conflicts.forEach((upperYaku, lowerYaku) {
    if (yakuList.contains(upperYaku) && yakuList.contains(lowerYaku)) {
      yakuList.remove(lowerYaku);
    }
  });
  return yakuList;
}

List<Yaku> fetchSevenPairsYaku(
    MahjongState mahjongState, List<AllTileKinds> tiles) {
  List<Yaku> yakuList = [];
  if (!isSevenPairs(tiles)) {
    return yakuList;
  }
  yakuList.add(Yaku.reach);
  if (isAllSimples(tiles)) yakuList.add(Yaku.allSimples);
  if (mahjongState.isFirstTurn) yakuList.add(Yaku.firstTurnWin);
  yakuList.add(Yaku.sevenPairs);
  if (isAllTerminalsAndHonors(tiles)) yakuList.add(Yaku.allTerminalsAndHonors);
  if (isHalfFlush(tiles)) yakuList.add(Yaku.halfFlush);
  if (isFullFlush(tiles)) yakuList.add(Yaku.fullFlush);

  conflicts.forEach((upperYaku, lowerYaku) {
    if (yakuList.contains(upperYaku) && yakuList.contains(lowerYaku)) {
      yakuList.remove(lowerYaku);
    }
  });
  return yakuList;
}

int fetchHansOfDora(List<AllTileKinds> tiles, AllTileKinds dora) {
  AllTileKinds doraValue = getDoraValue(dora);
  return convertRedTiles(tiles).where((tile) => tile == doraValue).length;
}

int fetchHansOfRedFive(List<AllTileKinds> tiles) {
  return tiles.where((tile) => redFives.contains(tile)).length;
}
