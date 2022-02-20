import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/pages/login/login_input.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.watch(gameUserProvider);

    Future<void> _onSubmit(Map<String, dynamic> gameUserJson) async {
      gameUserModel.updateFromJson(gameUserJson);
    }

    return Scaffold(
      body: Center(
        child: LoginInput(
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}
