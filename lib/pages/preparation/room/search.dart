import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/pages/preparation/room/wait.dart';

class RoomSearchPage extends StatefulWidget {
  final String title = '部屋を検索';
  final String myName;

  const RoomSearchPage({Key? key, required this.myName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomSearchPageState();
}

class _RoomSearchPageState extends State<RoomSearchPage> {
  late CollectionReference _roomRef;
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomIdController = TextEditingController();
  String _myUid = '';
  String? _roomId;
  Member? _host;
  bool _isNoResult = false;

  bool get _hasRoom {
    return _roomId != null && _host != null && _host?.uid != null;
  }

  @override
  void initState() {
    _roomRef = FirebaseFirestore.instance.collection('preparationRooms');
    super.initState();

    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
      _roomIdController.text = _storage.getItem('searchRoomId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _roomIdController,
                        decoration: const InputDecoration(labelText: '部屋ID'),
                        maxLength: 10,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return '入力してください';
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: const Text('検索'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _searchRoom();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isNoResult)
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
        );
      }),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _searchRoom() async {
    try {
      DocumentSnapshot snapshot =
          await _roomRef.doc(_roomIdController.text).get();
      if (!snapshot.exists) {
        setState(() {
          _roomId = null;
          _host = null;
          _isNoResult = true;
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
        _isNoResult = false;
      });
    } catch (e) {
      // TODO
    }
  }

  void _participateGame({roomId}) async {
    try {
      DocumentReference memberDoc =
          _roomRef.doc(roomId).collection('members').doc(_myUid);
      memberDoc.set({'name': widget.myName});
      _storage.setItem('searchRoomId', _roomIdController.text);

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
          _isNoResult = false;
        });
      }
    } catch (e) {
      // TODO
    }
  }
}
