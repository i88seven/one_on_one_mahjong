import 'package:enum_to_string/enum_to_string.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';

class MahjongState {
  bool isFirstTurn;
  bool isFinalTile;
  int wind;
  int round;
  bool isParent;
  AllTileKinds winTile;

  MahjongState({
    required this.isFirstTurn,
    required this.isFinalTile,
    required this.wind,
    required this.round,
    required this.isParent,
    required this.winTile,
  });

  MahjongState.fromReach({
    required ReachMahjongState reachMahjongState,
    required this.isFirstTurn,
    required this.isFinalTile,
    required this.winTile,
  })  : wind = reachMahjongState.wind,
        round = reachMahjongState.round,
        isParent = reachMahjongState.isParent;

  AllTileKinds get prevalentWindTile {
    return wind == 1 ? AllTileKinds.j1 : AllTileKinds.j2;
  }

  AllTileKinds get seatWindTile {
    // 親なら自風は東、親でないなら自風は南 (タイマン特有の仕様)
    return isParent ? AllTileKinds.j1 : AllTileKinds.j2;
  }
}

class ReachMahjongState {
  AllTileKinds dora;
  int wind;
  int round;
  bool isParent;

  ReachMahjongState({
    required this.dora,
    required this.wind,
    required this.round,
    required this.isParent,
  });

  AllTileKinds get prevalentWindTile {
    AllTileKinds? tile = EnumToString.fromString(AllTileKinds.values, "j$wind");
    return tile ?? AllTileKinds.j1;
  }

  AllTileKinds get seatWindTile {
    // 親なら自風は東、親でないなら自風は南 (タイマン特有の仕様)
    return isParent ? AllTileKinds.j1 : AllTileKinds.j2;
  }
}
