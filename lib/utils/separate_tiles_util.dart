import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/types/mahjong_types.dart';
import 'package:one_on_one_mahjong/utils/tiles_util.dart';

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

int compareSeparatedTile(SeparatedTile a, SeparatedTile b) {
  if (a.type != b.type) {
    return a.type.index - b.type.index;
  }
  return a.baseTile.index - b.baseTile.index;
}

bool isWinCandidateFound(
  List<WinCandidate> winCandidates,
  WinCandidate targetWinCandidate,
) {
  if (winCandidates.isEmpty || targetWinCandidate.isEmpty) {
    return false;
  }
  for (WinCandidate winCandidate in winCandidates) {
    bool result = true;
    for (var i = 0; i < targetWinCandidate.length; i++) {
      if (compareSeparatedTile(winCandidate[i], targetWinCandidate[i]) != 0) {
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
  List<WinCandidate> winCandidates,
  WinCandidate currentWinCandidate,
) {
  if (tiles.length <= 2) {
    if (tiles[0] == tiles[1]) {
      winCandidates.add([
        SeparatedTile(type: SeparateType.head, baseTile: tiles[0]),
        ...currentWinCandidate
      ]);
    }
    return;
  }
  List<AllTileKinds> pungCandidate = fetchPungCandidate(tiles)
      .where((tile) =>
          currentWinCandidate.isEmpty ||
          compareSeparatedTile(
                  SeparatedTile(type: SeparateType.pung, baseTile: tile),
                  currentWinCandidate.last) >=
              0)
      .toList();
  List<AllTileKinds> chowCandidate = fetchChowCandidate(tiles)
      .where((tile) =>
          currentWinCandidate.isEmpty ||
          compareSeparatedTile(
                  SeparatedTile(type: SeparateType.chow, baseTile: tile),
                  currentWinCandidate.last) >=
              0)
      .toList();
  for (AllTileKinds pung in pungCandidate) {
    List<AllTileKinds> pungRemainderTiles = [...tiles];
    for (var i = 0; i < 3; i++) {
      pungRemainderTiles.remove(pung);
    }
    fetchSetRecursively(pungRemainderTiles, winCandidates, [
      ...currentWinCandidate,
      SeparatedTile(type: SeparateType.pung, baseTile: pung)
    ]);
  }
  for (AllTileKinds chow in chowCandidate) {
    List<AllTileKinds> chowRemainderTiles = [...tiles];
    chowRemainderTiles.remove(chow);
    chowRemainderTiles.remove(addTileNumber(chow));
    chowRemainderTiles.remove(addTileNumber(addTileNumber(chow)));
    fetchSetRecursively(chowRemainderTiles, winCandidates, [
      ...currentWinCandidate,
      SeparatedTile(type: SeparateType.chow, baseTile: chow)
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

List<WinCandidate> fetchWinCandidates(List<AllTileKinds> tiles) {
  List<WinCandidate> winCandidates = [];
  fetchSetRecursively(convertRedTiles(tiles), winCandidates, []);
  return winCandidates;
}

/// Search tiles to win for given [tiles].
Map<AllTileKinds, List<WinCandidate>> searchReachTiles(
    List<AllTileKinds> tiles) {
  List<String> winTileTypes = fetchWinTileTypes(tiles);
  if (winTileTypes.isEmpty) {
    return {};
  }
  Map<AllTileKinds, List<WinCandidate>> result = {};
  for (AllTileKinds simpleTile in simpleTileKinds.keys) {
    for (String winTileType in winTileTypes) {
      if (simpleTile.name.startsWith(winTileType)) {
        List<WinCandidate> winCandidates =
            fetchWinCandidates([...tiles, simpleTile]);
        if (winCandidates.isNotEmpty) {
          result[simpleTile] = winCandidates;
        }
      }
    }
  }
  return result;
}
