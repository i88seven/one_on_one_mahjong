import 'package:one_on_one_mahjong/constants/all_tiles.dart';

abstract class PlayerTile {
  String uid = '';
  List<AllTileKinds> trashes = [];
  List<AllTileKinds> hands = [];
  List<AllTileKinds> candidates = [];
}
