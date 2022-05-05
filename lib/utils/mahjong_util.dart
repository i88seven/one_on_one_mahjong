import 'package:collection/collection.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';
import 'package:one_on_one_mahjong/utils/han_util.dart';
import 'package:one_on_one_mahjong/utils/mahjong_state.dart';
import 'package:one_on_one_mahjong/utils/separate_tiles_util.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';
import 'package:one_on_one_mahjong/utils/yaku_util.dart';

AllTileKinds? fetchSevenPairsReachTile(List<AllTileKinds> tiles) {
  if (tiles.length != 13) {
    return null;
  }
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  AllTileKinds? singleTile;
  for (AllTileKinds tile in tileKindCount.keys) {
    if (tileKindCount[tile]! > 2) {
      return null;
    }
    if (tileKindCount[tile]! == 2) {
      continue;
    }
    if (singleTile != null) {
      return null;
    }
    singleTile = tile;
  }
  return singleTile;
}

List<AllTileKinds> fetchThirteenOrphansTiles(List<AllTileKinds> tiles) {
  if (tiles.length != 13) {
    return [];
  }
  AllTileKinds? zeroTile = terminalsAndHonors.firstWhereOrNull(
      (AllTileKinds terminalsAndHonor) => !tiles.contains(terminalsAndHonor));
  if (zeroTile == null) {
    return terminalsAndHonors;
  }
  if (isThirteenOrphans([...tiles, zeroTile])) {
    return [zeroTile];
  }
  return [];
}

/// utils の main となる関数
Map<AllTileKinds, WinResult> fetchReachResult(
    List<AllTileKinds> tiles, ReachMahjongState reachMahjongState) {
  Map<AllTileKinds, WinResult> result = {};

  // 国士無双
  final thirteenOrphansTiles = fetchThirteenOrphansTiles(tiles);
  if (thirteenOrphansTiles.isNotEmpty) {
    for (AllTileKinds thirteenOrphansTile in thirteenOrphansTiles) {
      result[thirteenOrphansTile] = WinResult(yakuList: [Yaku.thirteenOrphans]);
    }
    return result;
  }

  // 七対子
  AllTileKinds? sevenPairsReachTile = fetchSevenPairsReachTile(tiles);
  if (sevenPairsReachTile != null) {
    MahjongState mahjongState = MahjongState.fromReach(
        reachMahjongState: reachMahjongState,
        isFirstTurn: false,
        isFinalTile: false,
        winTile: sevenPairsReachTile);
    final sevenPairsYaku =
        fetchSevenPairsYaku(mahjongState, [...tiles, sevenPairsReachTile]);

    final hansOfDora = fetchHansOfDora(
        [...tiles, sevenPairsReachTile], reachMahjongState.dora);
    final hansOfRedFive = fetchHansOfRedFive(tiles);
    result[sevenPairsReachTile] = WinResult(
      yakuList: sevenPairsYaku,
      hansOfDoras: [hansOfDora, 0, hansOfRedFive],
    );
    // 七対子をアガっても二盃口などの上位役の可能性がある
  }

  Map<AllTileKinds, List<WinCandidate>> reachTiles = searchReachTiles(tiles);
  reachTiles.forEach((AllTileKinds winTile, List<WinCandidate> winCandidates) {
    MahjongState mahjongState = MahjongState.fromReach(
        reachMahjongState: reachMahjongState,
        isFirstTurn: false,
        isFinalTile: false,
        winTile: winTile);
    for (WinCandidate winCandidate in winCandidates) {
      List<Yaku> yakumanList =
          fetchYakuman(winCandidate, mahjongState, [...tiles, winTile]);
      if (yakumanList.isNotEmpty) {
        WinResult temporaryWinResult = WinResult(yakuList: yakumanList);
        if (result[winTile] == null ||
            temporaryWinResult.yakumanCount > result[winTile]!.yakumanCount) {
          result[winTile] = temporaryWinResult;
        }
        continue; // 他の高い役満があるかもしれない e.g. 緑一色 + 四暗刻
      }

      if (result[winTile] != null && result[winTile]!.yakumanCount > 0) {
        continue;
      }
      List<Yaku> yakuList =
          fetchYaku(winCandidate, mahjongState, [...tiles, winTile]);
      if (yakuList.isNotEmpty) {
        final hansOfDora =
            fetchHansOfDora([...tiles, winTile], reachMahjongState.dora);
        final hansOfRedFive = fetchHansOfRedFive(tiles);
        WinResult temporaryWinResult = WinResult(
          yakuList: yakuList,
          hansOfDoras: [hansOfDora, 0, hansOfRedFive],
        );
        if (result[winTile] == null ||
            temporaryWinResult.hans > result[winTile]!.hans) {
          result[winTile] = temporaryWinResult;
        }
      }
    }
  });
  return result;
}
