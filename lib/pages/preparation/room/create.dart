import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/room_id_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/wait.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class RoomCreatePage extends ConsumerWidget {
  const RoomCreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUserModel = ref.read(gameUserProvider);
    final _myUid = gameUserModel.gameUser.uid;
    final _myName = gameUserModel.gameUser.name;

    void _createRoom(String roomId) async {
      try {
        // TODO すでに存在していて、自分以外が作っていたらエラー
        DocumentReference _roomRef = FirebaseFirestore.instance
            .collection('preparationRooms')
            .doc(roomId);
        _roomRef.set({
          'hostUid': _myUid,
          'hostName': _myName,
          'status': 'wait',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
        _roomRef.collection('members').doc(_myUid).set({'name': _myName});

        bool? shouldDelete = await Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => RoomWaitPage(
              roomId: roomId,
            ),
          ),
        );
        if (shouldDelete!) {
          QuerySnapshot membersSnapshot =
              await _roomRef.collection('members').get();
          for (QueryDocumentSnapshot element in membersSnapshot.docs) {
            element.reference.delete();
          }
          _roomRef.delete();
        }
      } catch (e) {
        // TODO
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('部屋の作成'),
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: RoomIdInput(
                  onSubmit: _createRoom,
                  buttonText: '作成',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
