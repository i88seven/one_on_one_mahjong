import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/game_user/setting_input.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class SettingPage extends ConsumerWidget {
  final String? _initialName;
  final bool? _initialIsPlayMusic;
  const SettingPage({String? initialName, bool? initialIsPlayMusic, Key? key})
      : _initialName = initialName,
        _initialIsPlayMusic = initialIsPlayMusic,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);

    Future<void> _updateSetting(String name, bool isPlayMusic) async {
      try {
        await gameUserModel.update(name, isPlayMusic);
        if (gameUserModel.gameUser.isAnonymously) {
          LocalStorage storage = LocalStorage('one_one_one_mahjong');
          await storage.ready;
          storage.setItem('myName', name);
          storage.setItem('isPlayMusic', isPlayMusic);
        }
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      } catch (e) {
        // TODO
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定変更'),
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SettingInput(
                onSubmit: _updateSetting,
                initialName: _initialName,
                initialIsPlayMusic: _initialIsPlayMusic,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
