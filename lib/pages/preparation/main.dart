import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/pages/game_user/update_name.dart';
import 'package:one_on_one_mahjong/pages/login/login_page.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/create.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/search.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class PreparationMainPage extends ConsumerWidget {
  const PreparationMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);
    final _myName = gameUserModel.gameUser.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマン麻雀'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO アカウント画面を作成
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return UpdateGameUserNamePage(initialName: _myName);
                }),
              );
            },
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("あなたの名前 : $_myName"),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: const Text('部屋を立てる'),
                    onPressed: () async {
                      _createRoom(context);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: const Text('部屋を探す'),
                    onPressed: () async {
                      _searchRoom(context);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _createRoom(context) async {
    try {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RoomCreatePage()),
      );
    } catch (e) {}
  }

  void _searchRoom(context) async {
    try {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RoomSearchPage()),
      );
    } catch (e) {}
  }
}
