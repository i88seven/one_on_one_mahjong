import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
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
  String _errorMessage = '';

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
      body: Stack(
        children: [
          const PreparationBackground(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                RoomIdInput(
                  onSubmit: _searchRoom,
                  buttonText: '検索',
                ),
                if (_errorMessage != '' && !_hasRoom)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 15.0,
                          color: AppColor.errorColor,
                        ),
                      ),
                    ],
                  ),
                if (_hasRoom)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        "部屋ID : $_roomId",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "リーダー : ${_host?.name}",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                if (_hasRoom)
                  Container(
                    padding: const EdgeInsets.only(top: 32.0),
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
          ),
        ],
      ),
    );
  }

  void _searchRoom(String roomId) async {
    try {
      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('preparationRooms').doc(roomId);
      DocumentSnapshot snapshot = await roomRef.get();
      if (!snapshot.exists) {
        setState(() {
          _roomId = null;
          _host = null;
          _errorMessage = '見つかりませんでした';
        });
        return;
      }
      final membersSnapshot = await roomRef.collection('members').get();
      if (membersSnapshot.docs.length > 1) {
        setState(() {
          _roomId = null;
          _host = null;
          _errorMessage = '部屋に空きがありません';
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
        _errorMessage = '';
      });
    } catch (e) {
      // TODO
    }
  }

  void _participateGame({roomId}) async {
    try {
      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('preparationRooms').doc(roomId);
      final membersSnapshot = await roomRef.collection('members').get();
      if (membersSnapshot.docs.length > 1) {
        setState(() {
          _roomId = null;
          _host = null;
          _errorMessage = '部屋に空きがありません';
        });
        return;
      }
      DocumentReference memberDoc =
          roomRef.collection('members').doc(_gameUser.uid);
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
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _roomId = null;
        _host = null;
        _errorMessage = e.toString();
      });
    }
  }
}
