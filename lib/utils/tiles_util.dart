import 'package:one_on_one_mahjong/constants/all_tiles.dart';

List<AllTileKinds> convertRedTiles(List<AllTileKinds> tiles) {
  return tiles.map((tile) {
    if (tile == AllTileKinds.mr) {
      return AllTileKinds.m5;
    }
    if (tile == AllTileKinds.pr) {
      return AllTileKinds.p5;
    }
    if (tile == AllTileKinds.sr) {
      return AllTileKinds.s5;
    }
    return tile;
  }).toList();
}

AllTileKinds? addTileNumber(AllTileKinds? tile) {
  if (tile == null) {
    return null;
  }
  Map<AllTileKinds, AllTileKinds> specialTileMap = {
    AllTileKinds.m5: AllTileKinds.m6,
    AllTileKinds.p5: AllTileKinds.p6,
    AllTileKinds.s5: AllTileKinds.s6,
  };
  if (specialTileMap.keys.contains(tile)) {
    return specialTileMap[tile];
  }
  if (tile.name.startsWith('j')) {
    return null;
  }
  if (tile.name.endsWith('9')) {
    return null;
  }
  int tileIndex = AllTileKinds.values.indexOf(tile);
  return AllTileKinds.values[tileIndex + 1];
}

List<String> fetchWinTileTypes(List<AllTileKinds> tiles) {
  if (tiles.length != 13) {
    return [];
  }
  Map<String, int> tileTypeCount = fetchTileTypeCount(tiles);
  List<String> count1Tiles = [];
  List<String> count2Tiles = [];
  for (String tileType in tileTypeCount.keys) {
    int countBy3 = tileTypeCount[tileType]! % 3;
    switch (countBy3) {
      case 1:
        count1Tiles.add(tileType);
        break;
      case 2:
        count2Tiles.add(tileType);
        break;
      default:
    }
  }
  if (count1Tiles.length == 1 && count2Tiles.isEmpty) {
    return count1Tiles;
  }
  if (count2Tiles.length == 2 && count1Tiles.isEmpty) {
    return count2Tiles;
  }
  return [];
}

Map<String, int> fetchTileTypeCount(List<AllTileKinds> tiles) {
  Map<String, int> tileTypeCount = {};
  for (AllTileKinds tile in tiles) {
    String tileType = tile.name[0];

    if (tileTypeCount[tileType] == null) {
      tileTypeCount[tileType] = 1;
      continue;
    }
    tileTypeCount[tileType] = tileTypeCount[tileType]! + 1;
  }
  return tileTypeCount;
}

Map<AllTileKinds, int> fetchTileKindCount(List<AllTileKinds> tiles) {
  List<AllTileKinds> convertedTiles = convertRedTiles(tiles);
  Map<AllTileKinds, int> tileKindCount = {};
  for (AllTileKinds tile in convertedTiles) {
    if (tileKindCount[tile] == null) {
      tileKindCount[tile] = 1;
      continue;
    }
    tileKindCount[tile] = tileKindCount[tile]! + 1;
  }
  return tileKindCount;
}
