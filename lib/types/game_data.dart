import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/types/player_data.dart';
import 'package:one_on_one_mahjong/types/player_tile.dart';

abstract class GameData {
  String hostId = '';
  List<PlayerTile> playerTiles = [];
  List<PlayerData> players = [];
  int wind = 1; // 東:1, 南:2, 西:3, 北:4
  List<AllTileKinds> doras = [];
}
