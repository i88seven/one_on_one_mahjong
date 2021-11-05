import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class RoomWaitPage extends StatefulWidget {
  String title = '待機中...';
  final String roomId;

  RoomWaitPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomWaitPageState();
}

class _RoomWaitPageState extends State<RoomWaitPage> {
  late DocumentReference _roomDoc;
  late StreamSubscription _changeSubscription;
  late StreamSubscription _changeMember;
  List<Member> _memberList = [];
  Member? _hostMember;
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');
  String _myUid = '';

  int get _memberCount {
    return _memberList.length;
  }

  bool get _isHost {
    return _hostMember != null && _myUid == _hostMember!.uid;
  }

  @override
  void initState() {
    super.initState();

    widget.title = "${widget.roomId} 待機中...";
    _memberList = [];
    _roomDoc = FirebaseFirestore.instance
        .collection('preparationRooms')
        .doc(widget.roomId);
    _changeSubscription = _roomDoc.snapshots().listen(_onChangeRoom);
    _roomDoc.get().then((DocumentSnapshot roomSnapshot) {
      final roomData = roomSnapshot.data()! as Map<String, dynamic>;
      CollectionReference _membersCollection = _roomDoc.collection('members');
      _changeMember = _membersCollection.snapshots().listen(_onChangeMember);
      _hostMember = Member(
        uid: roomData['hostUid'],
        name: roomData['hostName'],
      );
    });

    super.initState();
    Future(() async {
      await _storage.ready;
      _myUid = _storage.getItem('myUid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _changeSubscription.cancel();
        _changeMember.cancel();
        Navigator.of(context).pop(true);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(builder: (BuildContext context) {
          return ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, index) {
                  return ListTile(
                    title: Text(_memberList[index].name),
                  );
                },
                itemCount: _memberCount,
              ),
              if (_isHost)
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: const Text('始める'),
                    onPressed: () async {
                      if (_memberCount < 2) {
                        return;
                      }
                      _startGame();
                    },
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _changeSubscription.cancel();
    _changeMember.cancel();
    super.dispose();
  }

  void _onChangeRoom(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      Navigator.of(context).pop(false);
      return;
    }
  }

  void _onChangeMember(QuerySnapshot snapshot) {
    List<Member> memberList = snapshot.docs.map((QueryDocumentSnapshot doc) {
      final memberData = doc.data()! as Map<String, dynamic>;
      Member member = Member(uid: doc.id, name: memberData['name']);
      return member;
    }).toList();
    setState(() {
      _memberList = memberList;
    });
  }

  void _startGame() async {
    try {
      Flame.images.loadAll(<String>[
        'tile.png',
        'tile-back.png',
      ]);
      final game = SeventeenGame(widget.roomId, _onGameEnd);
      if (_isHost) {
        await game.initializeHost();
        // TODO room の情報を介して game が始まったことを Slave に伝える
      } else {
        await game.initializeSlave(hostUid: _hostMember!.uid);
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameWidget(game: game),
        ),
      );
    } catch (e) {
      // TODO
    }
  }

  void _onGameEnd() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}
