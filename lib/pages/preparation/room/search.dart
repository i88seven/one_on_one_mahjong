import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/room_id_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/wait.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';

class RoomSearchPage extends ConsumerStatefulWidget {
  const RoomSearchPage({Key? key}) : super(key: key);

  @override
  _RoomSearchPageState createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends ConsumerState<RoomSearchPage> {
  late GameUser _gameUser;
  String? _roomId;
  Member? _host;
  bool _hasResult = false;

  bool get _hasRoom {
    return _roomId != null && _host != null && _host?.uid != null;
  }

  @override
  void initState() {
    super.initState();
    final gameUserModel = ref.read(gameUserProvider);
    _gameUser = gameUserModel.gameUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('部屋を検索'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          RoomIdInput(
            onSubmit: _searchRoom,
            buttonText: '検索',
          ),
          if (_hasResult && !_hasRoom)
            ListView(
              children: [
                Text(
                  '見つかりませんでした',
                  style: TextStyle(fontSize: 18.0, color: Colors.yellow[300]),
                ),
              ],
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          if (_hasRoom)
            ListView(
              children: [
                Text(
                  "部屋ID: $_roomId",
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  "リーダー: ${_host?.name}",
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          if (_hasRoom)
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.center,
              child: ElevatedButton(
                child: const Text('入る'),
                onPressed: () async {
                  _participateGame(roomId: _roomId);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _searchRoom(String roomId) async {
    try {
      DocumentReference _roomRef =
          FirebaseFirestore.instance.collection('preparationRooms').doc(roomId);
      DocumentSnapshot snapshot = await _roomRef.get();
      if (!snapshot.exists) {
        setState(() {
          _roomId = null;
          _host = null;
          _hasResult = false;
        });
        return;
      }
      final roomData = snapshot.data()! as Map<String, dynamic>;
      setState(() {
        _roomId = snapshot.id;
        _host = Member(
          uid: roomData['hostUid'],
          name: roomData['hostName'],
        );
        _hasResult = true;
      });
    } catch (e) {
      // TODO
    }
  }

  void _participateGame({roomId}) async {
    try {
      DocumentReference _roomRef =
          FirebaseFirestore.instance.collection('preparationRooms').doc(roomId);
      DocumentReference memberDoc =
          _roomRef.collection('members').doc(_gameUser.uid);
      memberDoc.set({'name': _gameUser.name});

      bool? shouldDelete = await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => RoomWaitPage(
            roomId: roomId,
          ),
        ),
      );
      if (shouldDelete!) {
        await memberDoc.delete();
      } else {
        setState(() {
          _roomId = null;
          _host = null;
          _hasResult = true;
        });
      }
    } catch (e) {
      // TODO
    }
  }
}
