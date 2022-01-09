import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'mahjong_state.dart';
import 'tiles_util.dart';

/* 自風 */
bool isSeatWind(WinCandidate winCandidate, MahjongState mahjongState) {
  return winCandidate.any((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile == mahjongState.seatWindTile);
}

/* 場風 */
bool isPrevalentWind(WinCandidate winCandidate, MahjongState mahjongState) {
  return winCandidate.any((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile == mahjongState.prevalentWindTile);
}

/* 白 */
bool isWhiteDragon(WinCandidate winCandidate) {
  return winCandidate.any((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile == AllTileKinds.j5);
}

/* 發 */
bool isGreenDragon(WinCandidate winCandidate) {
  return winCandidate.any((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile == AllTileKinds.j6);
}

/* 中 */
bool isRedDragon(WinCandidate winCandidate) {
  return winCandidate.any((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile == AllTileKinds.j7);
}

/* 断ヤオ九 */
bool isAllSimples(List<AllTileKinds> tiles) {
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  return tileKindCount.keys.every((tile) => !terminalsAndHonors.contains(tile));
}

/* 平和 */
bool isAllRuns(WinCandidate winCandidate, MahjongState mahjongState) {
  bool hasPung = winCandidate
      .any((separatedTile) => separatedTile.type == SeparateType.pung);
  if (hasPung) {
    // 4面子すべてが順子でないと平和にならない
    return false;
  }

  List<AllTileKinds> valueTiles = [
    mahjongState.seatWindTile,
    mahjongState.prevalentWindTile,
    AllTileKinds.j5,
    AllTileKinds.j6,
    AllTileKinds.j7,
  ];
  AllTileKinds headTile = winCandidate
      .firstWhere((separatedTile) => separatedTile.type == SeparateType.head)
      .baseTile;
  if (valueTiles.contains(headTile)) {
    // 場風・自風・役牌が雀頭の時は平和にならない
    return false;
  }

  List<AllTileKinds> sideTiles = [];
  for (SeparatedTile separatedTile in winCandidate) {
    if (separatedTile.type == SeparateType.head) {
      continue;
    }
    AllTileKinds higherSideTile =
        addTileNumber(addTileNumber(separatedTile.baseTile))!;
    if (!terminals.contains(higherSideTile)) {
      sideTiles.add(separatedTile.baseTile);
    }
    if (!terminals.contains(separatedTile.baseTile)) {
      sideTiles.add(higherSideTile);
    }
  }
  if (!sideTiles.contains(mahjongState.winTile)) {
    // 両面待ちでない場合は平和にならない
    return false;
  }

  return true;
}

/* 一盃口 */
bool isDoubleRun(WinCandidate winCandidate) {
  List<AllTileKinds> chowTiles = [];
  for (SeparatedTile separatedTile in winCandidate) {
    if (separatedTile.type == SeparateType.chow) {
      chowTiles.add(separatedTile.baseTile);
    }
  }
  return chowTiles.length != chowTiles.toSet().length;
}

/* 対々和 */
bool isAllTriples(WinCandidate winCandidate) {
  bool hasChow = winCandidate
      .any((separatedTile) => separatedTile.type == SeparateType.chow);
  return !hasChow;
}

/* separateType == pung: 三色同刻 , separateType == chow: 三色同順 */
bool isThreeColors(WinCandidate winCandidate, SeparateType separateType) {
  List<String> separateTypeTileNames = [];
  for (SeparatedTile separatedTile in winCandidate) {
    if (separatedTile.type == separateType) {
      separateTypeTileNames.add(separatedTile.baseTile.name);
    }
  }
  if (separateTypeTileNames.length < 3) {
    return false;
  }
  for (int i = 2; i < separateTypeTileNames.length; i++) {
    String number = separateTypeTileNames[i].substring(1);
    bool result = ['m', 'p', 's']
        .every((tileType) => separateTypeTileNames.contains(tileType + number));
    if (result) {
      return true;
    }
  }
  return false;
}

/* 七対子 */
bool isSevenPairs(List<AllTileKinds> tiles) {
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  return tileKindCount.values.every((count) => count == 2);
}

/* 一気通貫 */
bool isFullStraight(WinCandidate winCandidate) {
  List<String> chowTileNames = [];
  for (SeparatedTile separatedTile in winCandidate) {
    if (separatedTile.type == SeparateType.chow) {
      chowTileNames.add(separatedTile.baseTile.name);
    }
  }
  if (chowTileNames.length < 3) {
    return false;
  }
  for (int i = 2; i < chowTileNames.length; i++) {
    String tileType = chowTileNames[i].substring(0, 1);
    bool result = ['1', '4', '7']
        .every((number) => chowTileNames.contains(tileType + number));
    if (result) {
      return true;
    }
  }
  return false;
}

/* 混全帯么九 */
bool isMixedOutsideHand(WinCandidate winCandidate) {
  return winCandidate.every((separatedTile) {
    if (terminalsAndHonors.contains(separatedTile.baseTile)) {
      return true;
    }
    if (separatedTile.type == SeparateType.chow) {
      if (separatedTile.baseTile.name.endsWith('7')) {
        return true;
      }
    }
    return false;
  });
}

/* 三暗刻 */
bool isThreeConcealedTriples(
    WinCandidate winCandidate, MahjongState mahjongState) {
  bool isWinTileInChow = winCandidate
      .where((separatedTile) => separatedTile.type == SeparateType.chow)
      .any((separatedTile) => [
            separatedTile.baseTile,
            addTileNumber(separatedTile.baseTile),
            addTileNumber(addTileNumber(separatedTile.baseTile))
          ].contains(mahjongState.winTile));
  final concealedTriples = winCandidate.where((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      (isWinTileInChow || separatedTile.baseTile != mahjongState.winTile));
  return concealedTriples.length >= 3;
}

/* 小三元 */
bool isLittleDragons(WinCandidate winCandidate) {
  const List<AllTileKinds> dragonTiles = [
    AllTileKinds.j5,
    AllTileKinds.j6,
    AllTileKinds.j7,
  ];
  return dragonTiles.every((dragonTile) => winCandidate
      .map((separatedTile) => separatedTile.baseTile)
      .contains(dragonTile));
}

/* 混老頭 */
bool isAllTerminalsAndHonors(List<AllTileKinds> tiles) {
  return tiles.every((tile) => terminalsAndHonors.contains(tile));
}

/* 混一色 */
bool isHalfFlush(List<AllTileKinds> tiles) {
  final tileTypeCount = fetchTileTypeCount(tiles);
  return tileTypeCount.keys.where((tileType) => tileType != 'j').length == 1;
}

/* 純全帯么九 */
bool isPureOutsideHand(WinCandidate winCandidate) {
  return winCandidate.every((separatedTile) {
    if (terminals.contains(separatedTile.baseTile)) {
      return true;
    }
    if (separatedTile.type == SeparateType.chow) {
      if (separatedTile.baseTile.name.endsWith('7')) {
        return true;
      }
    }
    return false;
  });
}

/* ニ盃口 */
bool isTwoDoubleRuns(WinCandidate winCandidate) {
  List<AllTileKinds> chowTiles = [];
  for (SeparatedTile separatedTile in winCandidate) {
    if (separatedTile.type == SeparateType.chow) {
      chowTiles.add(separatedTile.baseTile);
    }
  }
  if (chowTiles.length != 4) {
    return false;
  }
  final chowTileKindCount = fetchTileKindCount(chowTiles);
  return chowTileKindCount.values.every((count) => count == 2 || count == 4);
}

/* 清一色 */
bool isFullFlush(List<AllTileKinds> tiles) {
  final tileTypeCount = fetchTileTypeCount(tiles);
  return tileTypeCount.values.length == 1 && tileTypeCount.keys.first != 'j';
}

/* 四暗刻 */
bool isFourConcealedTriples(
    WinCandidate winCandidate, MahjongState mahjongState) {
  final concealedTriples = winCandidate.where((separatedTile) =>
      separatedTile.type == SeparateType.pung &&
      separatedTile.baseTile != mahjongState.winTile);
  return concealedTriples.length == 4;
}

/* 国士無双 */
bool isThirteenOrphans(List<AllTileKinds> tiles) {
  // TODO 単騎待ちどうする
  return terminalsAndHonors
          .every((terminalsAndHonor) => tiles.contains(terminalsAndHonor)) &&
      tiles.every((tile) => terminalsAndHonors.contains(tile));
}

/* 大三元 */
bool isBigDragons(WinCandidate winCandidate) {
  const List<AllTileKinds> dragonTiles = [
    AllTileKinds.j5,
    AllTileKinds.j6,
    AllTileKinds.j7,
  ];
  return dragonTiles.every((dragonTile) => winCandidate
      .where((separatedTile) => separatedTile.type == SeparateType.pung)
      .map((separatedTile) => separatedTile.baseTile)
      .contains(dragonTile));
}

/* 四喜和 */
bool isFourWinds(WinCandidate winCandidate) {
  const List<AllTileKinds> windTiles = [
    AllTileKinds.j1,
    AllTileKinds.j2,
    AllTileKinds.j3,
    AllTileKinds.j4,
  ];
  return windTiles.every((windTile) => winCandidate
      .map((separatedTile) => separatedTile.baseTile)
      .contains(windTile));
}

/* 字一色 */
bool isAllHonors(WinCandidate winCandidate) {
  return winCandidate
      .every((separatedTile) => honors.contains(separatedTile.baseTile));
}

/* 清老頭 */
bool isAllTerminals(List<AllTileKinds> tiles) {
  return tiles.every((tile) => terminals.contains(tile));
}

/* 緑一色 */
bool isAllGreen(List<AllTileKinds> tiles) {
  const List<AllTileKinds> greenTiles = [
    AllTileKinds.s2,
    AllTileKinds.s3,
    AllTileKinds.s4,
    AllTileKinds.s6,
    AllTileKinds.s8,
    AllTileKinds.j6,
  ];
  return tiles.every((tile) => greenTiles.contains(tile));
}

/* 九蓮宝燈 */
bool isNineGates(List<AllTileKinds> tiles) {
  if (!isFullFlush(tiles)) {
    return false;
  }
  final tileKindCount = fetchTileKindCount(tiles);
  return tileKindCount.keys.every((tile) {
    if (tile.name.endsWith('1') || tile.name.endsWith('9')) {
      return tileKindCount[tile]! >= 3;
    }
    return tileKindCount[tile]! >= 1;
  });
}
