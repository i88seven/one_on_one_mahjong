import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';

final gameUserProvider =
    ChangeNotifierProvider<GameUserModel>((ref) => GameUserModel());

class GameUserModel extends ChangeNotifier {
  GameUser gameUser = GameUser('', '');

  Future<void> create(String uid) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.set({
      'name': '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    gameUser.updateFromJson({'uid': uid, 'name': ''});
    notifyListeners();
  }

  Future<void> login(String uid) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final userData = await userRef.get();
    gameUser.updateFromJson({'uid': uid, 'name': userData['name']});
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(gameUser.uid);
    await userRef.update({
      'name': name,
      'updatedAt': Timestamp.now(),
    });
    gameUser.updateFromJson({...gameUser.toJson(), 'name': name});
    notifyListeners();
  }
}
