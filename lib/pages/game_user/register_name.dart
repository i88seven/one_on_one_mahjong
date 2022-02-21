import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/pages/game_user/update_name_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/main.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';

class RegisterGameUserNamePage extends ConsumerWidget {
  final String? _initialName;
  const RegisterGameUserNamePage({String? initialName, Key? key})
      : _initialName = initialName,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);
    final gameUserStatisticsModel = ref.read(gameUserStatisticsProvider);

    Future<void> _registerName(String name) async {
      try {
        GameUser _gameUser = gameUserModel.gameUser;
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(_gameUser.uid);
        await userRef.update({
          'name': name,
          'updatedAt': Timestamp.now(),
        });
        gameUserModel.updateFromJson({..._gameUser.toJson(), 'name': name});

        await gameUserStatisticsModel.create(_gameUser.uid);

        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const PreparationMainPage(),
          ),
        );
      } catch (e) {
        // TODO
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('名前の変更'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          GameUserNameInput(
            onSubmit: _registerName,
            initialName: _initialName,
          ),
        ],
      ),
    );
  }
}
