import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';

class RoomWaitPage extends StatefulWidget {
  final String roomId;

  const RoomWaitPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomWaitPageState();
}

class _RoomWaitPageState extends State<RoomWaitPage> {
  late GameUserStatisticsModel _gameUserStatisticsModel;
  late DocumentReference _roomDoc;
  late StreamSubscription _changeSubscription;
  late StreamSubscription _changeMember;
  late String myUid;
  late bool _isPlayMusic;
  List<Member> _memberList = [];
  Member? _hostMember;

  int get _memberCount {
    return _memberList.length;
  }

  bool get _isHost {
    return _hostMember != null && myUid == _hostMember!.uid;
  }

  @override
  void initState() {
    _memberList = [];
    _roomDoc = FirebaseFirestore.instance
        .collection('preparationRooms')
        .doc(widget.roomId);
    _changeSubscription = _roomDoc.snapshots().listen(_onChangeRoom);
    _roomDoc.get().then((DocumentSnapshot roomSnapshot) {
      final roomData = roomSnapshot.data()! as Map<String, dynamic>;
      CollectionReference membersCollection = _roomDoc.collection('members');
      _changeMember = membersCollection.snapshots().listen(_onChangeMember);
      _hostMember = Member(
        uid: roomData['hostUid'],
        name: roomData['hostName'],
      );
    });

    super.initState();
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
      child: Consumer(builder: (context, ref, child) {
        final gameUserModel = ref.watch(gameUserProvider);
        myUid = gameUserModel.gameUser.uid;
        _isPlayMusic = gameUserModel.gameUser.isPlayMusic;
        _gameUserStatisticsModel = ref.read(gameUserStatisticsProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text("${widget.roomId} 待機中..."),
          ),
          body: Stack(
            children: [
              const PreparationBackground(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  child: SizedBox(
                    height: _isHost ? 200 : 146,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          ListView.builder(
                            itemExtent: 30,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, index) {
                              String namePrefix =
                                  myUid == _memberList[index].uid
                                      ? 'あなたの名前 : '
                                      : '相手の名前 : ';
                              return ListTile(
                                title:
                                    Text(namePrefix + _memberList[index].name),
                              );
                            },
                            itemCount: _memberCount,
                          ),
                          if (_isHost)
                            Container(
                              padding: const EdgeInsets.only(top: 24.0),
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
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _changeSubscription.cancel();
    _changeMember.cancel();
    super.dispose();
  }

  Future<void> _onChangeRoom(DocumentSnapshot snapshot) async {
    if (_isHost) {
      return;
    }
    if (!snapshot.exists) {
      Navigator.of(context).pop(false);
      return;
    }
    final roomData = snapshot.data()! as Map<String, dynamic>;
    if (roomData['status'] == 'start') {
      await _startGame();
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

  Future<void> _startGame() async {
    try {
      Size screenSize = MediaQuery.of(context).size;
      final game = SeventeenGame(
        widget.roomId,
        myUid,
        _isPlayMusic,
        _hostMember!.uid,
        Vector2(screenSize.width, screenSize.height),
        _onGameEnd,
        _gameUserStatisticsModel,
      );
      await _changeSubscription.cancel();
      await _changeMember.cancel();
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
