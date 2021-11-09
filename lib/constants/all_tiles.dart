/*
  m: 萬子
  p: 筒子
  s: 索子
  j: 字牌
  東:j1, 南:j2, 西:j3, 北:j4, 白:j5, 發:j6, 中:j7
*/
const tileKind = ['m', 'p', 's', 'j'];
enum AllTileKinds {
  m1,
  m2,
  m3,
  m4,
  m5,
  m6,
  m7,
  m8,
  m9,
  mr,
  p1,
  p2,
  p3,
  p4,
  p5,
  p6,
  p7,
  p8,
  p9,
  pr,
  s1,
  s2,
  s3,
  s4,
  s5,
  s6,
  s7,
  s8,
  s9,
  sr,
  z1,
  z2,
  z3,
  z4,
  z5,
  z6,
  z7,
}

void sortTiles(List<AllTileKinds> tiles) {
  tiles.sort((a, b) => a.name.compareTo(b.name));
}

final Map<AllTileKinds, String> allTileKinds = Map.fromIterables(
    AllTileKinds.values,
    AllTileKinds.values
        .map((tileKind) => tileKind.toString().split('.').last)
        .toList());
final Map<AllTileKinds, String> simpleTileKinds = Map.from(allTileKinds)
  ..removeWhere((key, value) => value.endsWith('r'));
final Map<AllTileKinds, String> includeRedTileKinds = Map.from(allTileKinds)
  ..removeWhere((key, value) => [
        AllTileKinds.m5,
        AllTileKinds.p5,
        AllTileKinds.s5,
      ].contains(key));

List<AllTileKinds> allTiles = [
  ...simpleTileKinds.keys,
  ...simpleTileKinds.keys,
  ...simpleTileKinds.keys,
  ...includeRedTileKinds.keys,
];
