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

void sortSeparatedTiles(List<Map<String, AllTileKinds>> separatedTiles) {
  separatedTiles.sort((a, b) {
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
  });
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
      currentSeparatedMaps.add({'head': tiles[0]});
      sortSeparatedTiles(currentSeparatedMaps);
      if (!isSeparatedTilesFound(
          separatedTilesCandidates, currentSeparatedMaps)) {
        separatedTilesCandidates.add(currentSeparatedMaps);
      }
    }
    return;
  }
  List<AllTileKinds> pungCandidate = fetchPungCandidate(tiles);
  List<AllTileKinds> chowCandidate = fetchChowCandidate(tiles);
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

List<List<Map<String, AllTileKinds>>> fetchSeparatedTilesCandidates(
    List<AllTileKinds> tiles) {
  List<List<Map<String, AllTileKinds>>> separatedTilesCandidates = [];
  fetchSetRecursively(convertRedTiles(tiles), separatedTilesCandidates, []);
  return separatedTilesCandidates;
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
