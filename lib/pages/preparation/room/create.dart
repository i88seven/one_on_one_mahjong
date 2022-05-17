import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/room_id_input.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/wait.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';

class RoomCreatePage extends ConsumerStatefulWidget {
  const RoomCreatePage({Key? key}) : super(key: key);

  @override
  _RoomCreatePageState createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends ConsumerState<RoomCreatePage> {
  late String _myUid;
  late String _myName;
  bool _hasResult = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final gameUserModel = ref.read(gameUserProvider);
    _myUid = gameUserModel.gameUser.uid;
    _myName = gameUserModel.gameUser.name;
  }

  @override
  Widget build(BuildContext context) {
    bool _canCreateRoom(DocumentSnapshot roomSnapshot) {
      if (!roomSnapshot.exists) {
        return true;
      }
      final roomData = roomSnapshot.data()! as Map<String, dynamic>;
      if (roomData['hostUid'] == _myUid) {
        return true;
      }
      final createdAt = roomData['createdAt'];
      // 作ってから2時間以上経っていたら上書きできる
      if (createdAt is Timestamp &&
          DateTime.now().difference(createdAt.toDate()).inHours > 2) {
        return true;
      }
      return false;
    }

    void _createRoom(String roomId) async {
      try {
        DocumentReference _roomRef = FirebaseFirestore.instance
            .collection('preparationRooms')
            .doc(roomId);
        DocumentSnapshot snapshot = await _roomRef.get();
        if (!_canCreateRoom(snapshot)) {
          setState(() {
            _hasResult = true;
            _hasError = false;
          });
          return;
        }
        setState(() {
          _hasResult = false;
          _hasError = false;
        });
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
        setState(() {
          _hasResult = false;
          _hasError = true;
        });
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
              if (_hasResult)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'すでに使われているIDです。\n別のIDを指定してください。',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: AppColor.errorColor,
                    ),
                  ),
                ),
              if (_hasError)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'エラーが発生しました。',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: AppColor.errorColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
