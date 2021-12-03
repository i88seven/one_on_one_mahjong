import 'package:one_on_one_mahjong/constants/all_tiles.dart';

class MahjongState {
  bool isReach;
  bool isFirstTurn;
  List<AllTileKinds> doras;
  int wind;
  int round;
  bool isParent;
  AllTileKinds winTile;

  MahjongState({
    required this.isReach,
    required this.isFirstTurn,
    required this.doras,
    required this.wind,
    required this.round,
    required this.isParent,
    required this.winTile,
  });

  AllTileKinds get prevalentWindTile {
    return wind == 1 ? AllTileKinds.j1 : AllTileKinds.j2;
  }

  AllTileKinds get seatWindTile {
    // 親なら自風は東、親でないなら自風は南 (タイマン特有の仕様)
    return isParent ? AllTileKinds.j1 : AllTileKinds.j2;
  }
}
