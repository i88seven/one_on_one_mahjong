/*
  m: 萬子
  p: 筒子
  s: 索子
  j: 字牌
  東:j1, 南:j2, 西:j3, 北:j4, 白:j5, 發:j6, 中:j7
*/
const tileKind = ['m', 'p', 's', 'j'];
// TODO 赤ドラ
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
  p1,
  p2,
  p3,
  p4,
  p5,
  p6,
  p7,
  p8,
  p9,
  s1,
  s2,
  s3,
  s4,
  s5,
  s6,
  s7,
  s8,
  s9,
  j1,
  j2,
  j3,
  j4,
  j5,
  j6,
  j7
}
List<AllTileKinds> allTileKinds = AllTileKinds.values;
List<AllTileKinds> allTiles = [
  ...allTileKinds,
  ...allTileKinds,
  ...allTileKinds,
  ...allTileKinds
];
