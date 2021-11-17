import 'package:flutter_test/flutter_test.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/utils/mahjong_util.dart';

void main() {
  group('convertRedTiles test', () {
    test('convertRedTiles', () {
      List<AllTileKinds> _hands = [
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.mr,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.pr,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.sr,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      final convertedTiles = convertRedTiles(_hands);
      List<AllTileKinds> expectTiles = [
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.m5,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.p5,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.s5,
        AllTileKinds.j6,
        AllTileKinds.j6,
        AllTileKinds.j7,
        AllTileKinds.j7,
      ];
      expect(convertedTiles.length, expectTiles.length);
      for (AllTileKinds convertedTile in convertedTiles) {
        expect(expectTiles.contains(convertedTile), true);
      }
    });
  });
}
