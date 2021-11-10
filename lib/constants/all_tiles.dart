/*
  m: 萬子
  p: 筒子
  s: 索子
  z: 字牌 ※アルファベット順でソートできるので、字牌は z
  東:z1, 南:z2, 西:z3, 北:z4, 白:z5, 發:z6, 中:z7
*/
const tileKind = ['m', 'p', 's', 'z'];
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
