import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:one_on_one_mahjong/components/dealts.dart';
import 'package:one_on_one_mahjong/components/doras.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_round.dart';
import 'package:one_on_one_mahjong/components/hands.dart';
import 'package:one_on_one_mahjong/components/member.dart';
import 'package:one_on_one_mahjong/components/trashes.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';

class FirestoreAccessor {
  late final DocumentReference<Map<String, dynamic>> _roomDoc;
  late final DocumentReference<Map<String, dynamic>> _gameDoc;
  final List<StreamSubscription> _streams = [];
  final FirebaseFirestore _firestoreReference = FirebaseFirestore.instance;

  FirestoreAccessor({
    required String roomId,
    required String hostUid,
  }) {
    _roomDoc = _firestoreReference.collection('preparationRooms').doc(roomId);
    _gameDoc = _firestoreReference.collection('games').doc(hostUid);
  }

  void listenOnChangeGame(onChangeGame) {
    _streams.add(_gameDoc.snapshots().listen(onChangeGame));
  }

  Future<void> cancelStream() async {
    for (StreamSubscription stream in _streams) {
      await stream.cancel();
    }
  }

  // Room

  Future<void> notifyStartToGame() async {
    await _roomDoc.update({
      'status': 'start',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteRoomOnStartGame() async {
    QuerySnapshot membersSnapshot = await _roomDoc.collection('members').get();
    for (QueryDocumentSnapshot element in membersSnapshot.docs) {
      element.reference.delete();
    }
    _roomDoc.delete();
  }

  // Game

  Future<List<Member>> getRoomMembers() async {
    final membersSnapshot = await _roomDoc.collection('members').get();
    final List<Member> members = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> membersDoc =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            membersSnapshot.docs);
    for (QueryDocumentSnapshot<Map<String, dynamic>> memberDoc in membersDoc) {
      final memberData = memberDoc.data();
      Member member = Member(
        uid: memberDoc.id,
        name: memberData['name'],
      );
      members.add(member);
    }
    return members;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGameSnapshot() async {
    return await _gameDoc.get();
  }

  Future<void> initializeGame(
      String hostUid, GameRound gameRound, List<GamePlayer> gamePlayers) async {
    await _gameDoc.set({
      'hostUid': hostUid,
      'current': 0,
      'wind': gameRound.wind,
      'round': gameRound.round,
      'player-0': gamePlayers[0].toJson(),
      'player-1': gamePlayers[1].toJson(),
    });
  }

  Future<void> updateGameAsDeal(
      Doras doras, List<GamePlayer> gamePlayers) async {
    await _gameDoc.update({
      'doras': doras.jsonValue,
      'player-0': gamePlayers[0].toJson(),
      'player-1': gamePlayers[1].toJson(),
    });
  }

  Future<void> updateGameOnNewRound(int currentOrder, GameRound gameRound,
      List<GamePlayer> gamePlayers) async {
    await _gameDoc.update({
      'current': currentOrder,
      'wind': gameRound.wind,
      'round': gameRound.round,
      'player-0': gamePlayers[0].toJson(),
      'player-1': gamePlayers[1].toJson(),
    });
  }

  Future<void> updateCurrentOrder(int currentOrder) async {
    await _gameDoc.update({
      'current': (currentOrder + 1) % 2,
    });
  }

  Future<void> updateGamePlayers(List<GamePlayer> gamePlayers) async {
    await _gameDoc.update({
      'player-0': gamePlayers[0].toJson(),
      'player-1': gamePlayers[1].toJson(),
    });
  }

  Future<void> updateTargetPlayer(
      int playerIndex, GamePlayer gamePlayer) async {
    await _gameDoc.update({
      "player-$playerIndex": gamePlayer.toJson(),
    });
  }

  Future<void> deleteGame() async {
    QuerySnapshot playerTilesSnapshot =
        await _gameDoc.collection('player_tiles').get();
    for (QueryDocumentSnapshot element in playerTilesSnapshot.docs) {
      element.reference.delete();
    }
    await _gameDoc.delete();
  }

  // PlayerTiles

  void listenPlayerTilesDoc(String uid, dynamic onChangeOtherTiles) async {
    _streams.add(_gameDoc
        .collection('player_tiles')
        .doc(uid)
        .snapshots()
        .listen(onChangeOtherTiles));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTilesSnapshot(
      String uid) async {
    return await _gameDoc.collection('player_tiles').doc(uid).get();
  }

  Future<void> initializePlayerTiles(String uid) async {
    await _gameDoc.collection('player_tiles').doc(uid).set({
      'dealts': [],
      'hands': [],
      'trashes': [],
    });
  }

  Future<List<AllTileKinds>> fetchOtherHands(String otherUid) async {
    final tilesSnapshot =
        await _gameDoc.collection('player_tiles').doc(otherUid).get();
    Map<String, dynamic>? myTilesData = tilesSnapshot.data();
    if (myTilesData == null) {
      return [];
    }

    final handsJson = myTilesData['hands'] as List<dynamic>?;
    if (handsJson is List<dynamic>) {
      return handsJson
          .map((tileString) =>
              EnumToString.fromString(AllTileKinds.values, tileString) ??
              AllTileKinds.m1)
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchTilesData(String uid) async {
    final tilesSnapshot =
        await _gameDoc.collection('player_tiles').doc(uid).get();
    return tilesSnapshot.data();
  }

  Future<void> setTiles({
    required Dealts dealtsMe,
    required Hands handsMe,
    required Trashes trashesMe,
    required String myUid,
    List<AllTileKinds>? dealtsOther,
    required List<GamePlayer> gamePlayers,
  }) async {
    Map<String, List<String>> myTiles = {
      'dealts': dealtsMe.jsonValue,
      'hands': handsMe.jsonValue,
      'trashes': trashesMe.jsonValue,
    };
    // player_tiles 単位での更新は手間がかかるので、 collection にする
    await _gameDoc.collection('player_tiles').doc(myUid).set(myTiles);

    if (dealtsOther is List<AllTileKinds>) {
      Map<String, List<String>> otherTiles = {
        'dealts': dealtsOther.map((e) => e.name).toList(),
        'hands': [],
        'trashes': [],
      };
      GamePlayer? otherPlayer =
          gamePlayers.firstWhereOrNull((gamePlayer) => gamePlayer.uid != myUid);
      if (otherPlayer != null) {
        await _gameDoc
            .collection('player_tiles')
            .doc(otherPlayer.uid)
            .set(otherTiles);
      }
    }
  }
}
