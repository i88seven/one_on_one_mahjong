import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/types/game_user_statistics.dart';

final gameUserStatisticsProvider =
    ChangeNotifierProvider<GameUserStatisticsModel>(
        (ref) => GameUserStatisticsModel());

class GameUserStatisticsModel extends ChangeNotifier {
  GameUserStatistics gameUserStatistics = GameUserStatistics('');

  Future<void> login(String uid) async {
    DocumentReference statisticsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('statistics')
        .doc(uid);
    final statisticsData = await statisticsRef.get() as Map<String, int>;
    gameUserStatistics = GameUserStatistics.fromJson(uid, statisticsData);
    notifyListeners();
  }

  Future<void> create(String uid) async {
    DocumentReference statisticsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('statistics')
        .doc(uid);
    gameUserStatistics = GameUserStatistics(uid);
    await statisticsRef.set({
      ...gameUserStatistics.toJson(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    notifyListeners();
  }
}
