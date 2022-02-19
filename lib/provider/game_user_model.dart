import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';

final gameUserProvider =
    ChangeNotifierProvider<GameUserModel>((ref) => GameUserModel());

class GameUserModel extends ChangeNotifier {
  GameUser gameUser = GameUser('', '');

  void updateFromJson(gameUserJson) {
    gameUser.updateFromJson(gameUserJson);
    notifyListeners();
  }
}
