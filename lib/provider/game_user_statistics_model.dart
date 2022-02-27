import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/types/statistics/game_user_statistics.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

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
    final statisticsSnapshot = await statisticsRef.get();
    final statisticsData = statisticsSnapshot.data() as Map<String, dynamic>;
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
      ...gameUserStatistics.toMap(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    notifyListeners();
  }

  Future<void> countOnGameStart({required String uid}) async {
    DocumentReference statisticsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('statistics')
        .doc(uid);
    gameUserStatistics.countOnGameStart();
    await statisticsRef.update({
      ...gameUserStatistics.toMap(),
      'updatedAt': Timestamp.now(),
    });
    notifyListeners();
  }

  Future<void> countOnGameEnd({
    required String uid,
    required int pointDiff,
  }) async {
    DocumentReference statisticsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('statistics')
        .doc(uid);
    gameUserStatistics.countOnGameEnd(pointDiff: pointDiff);
    await statisticsRef.update({
      ...gameUserStatistics.toMap(),
      'updatedAt': Timestamp.now(),
    });
    notifyListeners();
  }

  Future<void> countOnRoundEnd({
    required String uid,
    required bool isParent,
    required bool isWinner,
    required WinResult? winResult,
    required int step,
    required List<int> doraTrashes,
  }) async {
    DocumentReference statisticsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('statistics')
        .doc(uid);
    gameUserStatistics.countOnRoundEnd(
      isParent: isParent,
      isWinner: isWinner,
      winResult: winResult,
      step: step,
      doraTrashes: doraTrashes,
    );
    await statisticsRef.update({
      ...gameUserStatistics.toMap(),
      'updatedAt': Timestamp.now(),
    });
    notifyListeners();
  }
}
