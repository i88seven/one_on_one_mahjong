import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/game_user/setting_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/main.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';

// login page からのみ呼ばれる
class RegisterGameUserNamePage extends ConsumerWidget {
  final String? _initialName;
  const RegisterGameUserNamePage({String? initialName, Key? key})
      : _initialName = initialName,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);
    final gameUserStatisticsModel = ref.read(gameUserStatisticsProvider);

    Future<void> _registerName(String name, bool isPlayMusic) async {
      try {
        GameUser gameUser = gameUserModel.gameUser;
        gameUserModel.update(name, isPlayMusic);
        if (gameUser.isAnonymously) {
          LocalStorage storage = LocalStorage('one_one_one_mahjong');
          await storage.ready;
          storage.setItem('myName', name);
          storage.setItem('isPlayMusic', isPlayMusic);
        }
        if (!gameUser.isAnonymously) {
          await gameUserStatisticsModel.create(gameUser.uid);
        }
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
        title: const Text('ユーザー設定'),
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SettingInput(
                onSubmit: _registerName,
                initialName: _initialName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
