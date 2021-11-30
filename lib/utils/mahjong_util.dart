import 'dart:convert';
import 'package:flutter/foundation.dart';

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

bool canExtractChow(List<AllTileKinds> tiles, AllTileKinds baseTile) {
  if (baseTile.name.startsWith('j')) {
    return false;
  }
  if (baseTile.name.endsWith('8') || baseTile.name.endsWith('9')) {
    return false;
  }
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  AllTileKinds? nextTile;
  for (var i = 0; i < 2; i++) {
    nextTile = addTileNumber(nextTile ?? baseTile);
    if (nextTile == null || !tileKindCount.keys.contains(nextTile)) {
      return false;
    }
  }
  return true;
}

int compareSeparatedTile(
    Map<String, AllTileKinds> a, Map<String, AllTileKinds> b) {
  if (a.keys.toList()[0] == 'head') {
    return -1;
  }
  if (b.keys.toList()[0] == 'head') {
    return 1;
  }
  if (a.keys.toList()[0] == 'pung' && b.keys.toList()[0] == 'chow') {
    return -1;
  }
  if (a.keys.toList()[0] == 'chow' && b.keys.toList()[0] == 'pung') {
    return 1;
  }
  return AllTileKinds.values.indexOf(a.values.toList()[0]) -
      AllTileKinds.values.indexOf(b.values.toList()[0]);
}

bool isSeparatedTilesFound(
  List<List<Map<String, AllTileKinds>>> separatedTilesCandidates,
  List<Map<String, AllTileKinds>> targetSeparatedTiles,
) {
  if (separatedTilesCandidates.isEmpty || targetSeparatedTiles.isEmpty) {
    return false;
  }
  for (List<Map<String, AllTileKinds>> separatedTilesCandidate
      in separatedTilesCandidates) {
    bool result = true;
    for (var i = 0; i < targetSeparatedTiles.length; i++) {
      if (!mapEquals(separatedTilesCandidate[i], targetSeparatedTiles[i])) {
        result = false;
        break;
      }
    }
    if (result) {
      return true;
    }
  }
  return false;
}

void fetchSetRecursively(
  List<AllTileKinds> tiles,
  List<List<Map<String, AllTileKinds>>> separatedTilesCandidates,
  List<Map<String, AllTileKinds>> currentSeparatedMaps,
) {
  if (tiles.length <= 2) {
    if (tiles[0] == tiles[1]) {
      separatedTilesCandidates.add([
        {'head': tiles[0]},
        ...currentSeparatedMaps
      ]);
    }
    return;
  }
  List<AllTileKinds> pungCandidate = fetchPungCandidate(tiles)
      .where((tile) =>
          currentSeparatedMaps.isEmpty ||
          compareSeparatedTile({'pung': tile}, currentSeparatedMaps.last) >= 0)
      .toList();
  List<AllTileKinds> chowCandidate = fetchChowCandidate(tiles)
      .where((tile) =>
          currentSeparatedMaps.isEmpty ||
          compareSeparatedTile({'chow': tile}, currentSeparatedMaps.last) >= 0)
      .toList();
  for (AllTileKinds pung in pungCandidate) {
    List<AllTileKinds> pungRemainderTiles = [...tiles];
    for (var i = 0; i < 3; i++) {
      pungRemainderTiles.remove(pung);
    }
    fetchSetRecursively(pungRemainderTiles, separatedTilesCandidates, [
      ...currentSeparatedMaps,
      {'pung': pung}
    ]);
  }
  for (AllTileKinds chow in chowCandidate) {
    List<AllTileKinds> chowRemainderTiles = [...tiles];
    chowRemainderTiles.remove(chow);
    chowRemainderTiles.remove(addTileNumber(chow));
    chowRemainderTiles.remove(addTileNumber(addTileNumber(chow)));
    fetchSetRecursively(chowRemainderTiles, separatedTilesCandidates, [
      ...currentSeparatedMaps,
      {'chow': chow}
    ]);
  }
}

List<AllTileKinds> fetchPungCandidate(List<AllTileKinds> tiles) {
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  tileKindCount.removeWhere((key, value) => value < 3);
  return tileKindCount.keys.toList();
}

List<AllTileKinds> fetchChowCandidate(List<AllTileKinds> tiles) {
  Map<AllTileKinds, int> tileKindCount = fetchTileKindCount(tiles);
  List<AllTileKinds> result = [];
  for (AllTileKinds tileKind in tileKindCount.keys) {
    if (canExtractChow(tileKindCount.keys.toList(), tileKind)) {
      result.add(tileKind);
    }
  }
  return result;
}

List<List<Map<String, AllTileKinds>>> fetchSeparatedTilesCandidates(
    List<AllTileKinds> tiles) {
  List<List<Map<String, AllTileKinds>>> separatedTilesCandidates = [];
  fetchSetRecursively(convertRedTiles(tiles), separatedTilesCandidates, []);
  return separatedTilesCandidates;
}

/// Search tiles to win for given [tiles].
Map<AllTileKinds, List<List<Map<String, AllTileKinds>>>> searchReachTiles(
    List<AllTileKinds> tiles) {
  List<String> winTileTypes = fetchWinTileTypes(tiles);
  if (winTileTypes.isEmpty) {
    return {};
  }
  Map<AllTileKinds, List<List<Map<String, AllTileKinds>>>> result = {};
  for (AllTileKinds simpleTile in simpleTileKinds.keys) {
    for (String winTileType in winTileTypes) {
      if (simpleTile.name.startsWith(winTileType)) {
        List<List<Map<String, AllTileKinds>>> separatedTilesCandidates =
            fetchSeparatedTilesCandidates([...tiles, simpleTile]);
        if (separatedTilesCandidates.isNotEmpty) {
          result[simpleTile] = separatedTilesCandidates;
        }
      }
    }
  }
  return result;
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
