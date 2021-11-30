import 'package:one_on_one_mahjong/constants/all_tiles.dart';

enum SeparateType {
  head,
  pung,
  chow,
}

class SeparatedTile {
  SeparateType type;
  AllTileKinds baseTile;
  SeparatedTile({
    required this.type,
    required this.baseTile,
  });

  @override
  String toString() {
    return "$type: $baseTile";
  }
}

typedef WinCandidate = List<SeparatedTile>;
