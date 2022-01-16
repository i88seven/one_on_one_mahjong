import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/constants/game_player_status.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class GamePlayer {
  String uid;
  String name;
  late int _points;
  GamePlayerStatus status;
  WinResult? winResult;
  final bool _isMe;
  TextComponent? _textObject;
  final SeventeenGame _game;
  bool _isParent;

  GamePlayer(this._game, this.uid, this.name, this.status, this._isMe,
      this._isParent) {
    _points = 25000;
    render();
  }

  GamePlayer.fromJson(SeventeenGame game, bool isMe, Map<String, dynamic> json)
      : _game = game,
        uid = json['uid'],
        name = json['name'],
        _points = json['points'] ?? 0,
        status =
            EnumToString.fromString(GamePlayerStatus.values, json['status']) ??
                GamePlayerStatus.ready,
        _isMe = isMe,
        _isParent = json['isParent'] ?? false {
    if (json['yakuList'] != null && json['hansOfDoras'] != null) {
      List<Yaku> yakuList = [];
      for (String yakuString in json['yakuList']) {
        yakuList.add(EnumToString.fromString(Yaku.values, yakuString)!);
      }
      List<int> hansOfDoras = [];
      for (int hansString in json['hansOfDoras']) {
        hansOfDoras.add(hansString);
      }
      winResult = WinResult(yakuList: yakuList, hansOfDoras: hansOfDoras);
    }
    render();
  }

  void initOnRound(String parentUid) {
    winResult = null;
    status = GamePlayerStatus.selectHands;
    _isParent = uid == parentUid;
  }

  void setStatus(GamePlayerStatus status) {
    this.status = status;
    render();
  }

  void addPoints(int points) {
    _points += points;
    render();
  }

  void render() {
    String text = "$name: $_points";
    if (_textObject != null) {
      _textObject!.text = text;
      return;
    }
    double posY;
    if (_isMe) {
      posY = _game.screenSize.y - 30;
    } else {
      posY = 30.0;
    }
    final textRenderer =
        TextPaint(config: const TextPaintConfig(color: Colors.white));
    _textObject = TextComponent(
      text,
      textRenderer: textRenderer,
      size: Vector2(100.0, _isMe ? 24.0 : 12.0),
    );
    _game.add(_textObject!
      ..x = 10
      ..y = posY);
  }

  void remove() {
    if (_textObject != null) {
      _textObject!.text = '';
      _game.remove(_textObject!);
    }
  }

  int get points => _points;
  bool get isParent => _isParent;

  Map<String, dynamic> toJson() {
    final json = {
      'uid': uid,
      'name': name,
      'status': status.name,
      'points': _points,
      'isParent': _isParent,
    };
    if (winResult != null) {
      return {...json, ...winResult!.toJson()};
    }
    return json;
  }
}
