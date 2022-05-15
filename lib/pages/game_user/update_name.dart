import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/game_user/update_name_input.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class UpdateGameUserNamePage extends ConsumerWidget {
  final String? _initialName;
  const UpdateGameUserNamePage({String? initialName, Key? key})
      : _initialName = initialName,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);

    Future<void> _updateName(String name) async {
      try {
        await gameUserModel.updateName(name);
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      } catch (e) {
        // TODO
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('名前の変更'),
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              GameUserNameInput(
                onSubmit: _updateName,
                initialName: _initialName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
