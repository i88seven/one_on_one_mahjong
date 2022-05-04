import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/game_user/detail_page.dart';
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const UserDetailPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text("あなたの名前 : $_myName"),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text('部屋を立てる'),
                      onPressed: () async {
                        _createRoom(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text('部屋を探す'),
                      onPressed: () async {
                        _searchRoom(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
