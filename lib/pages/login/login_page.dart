import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/pages/game_user/register_name.dart';
import 'package:one_on_one_mahjong/pages/login/login_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/main.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.watch(gameUserProvider);
    final gameUserStatisticsModel = ref.watch(gameUserStatisticsProvider);

    Future<void> _onCreate(String uid) async {
      await gameUserModel.create(uid);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return const RegisterGameUserNamePage();
        }),
      );
    }

    Future<void> _onLogin(String uid) async {
      await gameUserModel.login(uid);
      await gameUserStatisticsModel.login(uid);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<bool>(
          builder: (context) => const PreparationMainPage(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: LoginInput(
          onCreate: _onCreate,
          onLogin: _onLogin,
        ),
      ),
    );
  }
}
