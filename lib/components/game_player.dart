import 'package:enum_to_string/enum_to_string.dart';
import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/image_component.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/game_player_status.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class GamePlayer extends PositionComponent {
  final String _uid;
  final String _name;
  int _points = 25000;
  GamePlayerStatus _status;
  WinResult? _winResult;
  final bool _isMe;
  int _currentOrder = 0;
  bool _isParent;
  late Sprite _parentImage;
  late Sprite _childImage;
  ImageComponent? imageComponent;

  GamePlayer(
      {required SeventeenGame game,
      required Images gameImages,
      required String uid,
      required String name,
      required GamePlayerStatus status,
      required bool isMe,
      required bool isParent})
      : _uid = uid,
        _name = name,
        _status = status,
        _isMe = isMe,
        _isParent = isParent {
    final double _posY = _isMe ? game.screenSize.y - 74.0 : 26.0;
    position = Vector2(0, _posY);
    size = Vector2(game.screenSize.x, 48.0);
    _parentImage = Sprite(gameImages.fromCache('parent.png'));
    _childImage = Sprite(gameImages.fromCache('child.png'));
    _rerenderImage();
  }

  GamePlayer.fromJson(SeventeenGame game, Images gameImages, bool isMe,
      Map<String, dynamic> json)
      : _uid = json['uid'],
        _name = json['name'],
        _status =
            EnumToString.fromString(GamePlayerStatus.values, json['status']) ??
                GamePlayerStatus.ready,
        _isMe = isMe,
        _isParent = json['isParent'] ?? false {
    final double _posY = _isMe ? game.screenSize.y - 74.0 : 26.0;
    position = Vector2(0, _posY);
    size = Vector2(game.screenSize.x, 48.0);
    _parentImage = Sprite(gameImages.fromCache('parent.png'));
    _childImage = Sprite(gameImages.fromCache('child.png'));
    updateFromJson(json);
    _rerenderImage();
  }

  void updateFromJson(json) {
    bool isParentOld = _isParent;
    _status =
        EnumToString.fromString(GamePlayerStatus.values, json['status']) ??
            GamePlayerStatus.ready;
    _isParent = json['isParent'] ?? false;
    if (json['yakuList'] != null && json['hansOfDoras'] != null) {
      List<Yaku> yakuList = [];
      for (String yakuString in json['yakuList']) {
        yakuList.add(EnumToString.fromString(Yaku.values, yakuString)!);
      }
      List<int> hansOfDoras = [];
      for (int hansString in json['hansOfDoras']) {
        hansOfDoras.add(hansString);
      }
      _winResult = WinResult(yakuList: yakuList, hansOfDoras: hansOfDoras);
    } else {
      _winResult = null;
    }
    if (isParentOld != _isParent) {
      _rerenderImage();
    }
  }

  String get uid => _uid;
  String get name => _name;
  int get points => _points;
  GamePlayerStatus get status => _status;
  WinResult? get winResult => _winResult;
  bool get isMe => _isMe;
  bool get isParent => _isParent;
  String get _text => "$_name : $_points";
  bool get _isMyTurn {
    if (_status != GamePlayerStatus.selectTrash) {
      return false;
    }
    return (_currentOrder == 0 && _isParent) ||
        (_currentOrder == 1 && !_isParent);
  }

  void setWinResult(WinResult winResult) {
    _winResult = winResult;
  }

  void initOnRound(bool shouldParentChange) {
    _winResult = null;
    _status = GamePlayerStatus.selectHands;
    if (shouldParentChange) {
      _isParent = !_isParent;
      _rerenderImage();
    }
  }

  void setStatus(GamePlayerStatus status) {
    _status = status;
  }

  void setCurrentOrder(int currentOrder) {
    _currentOrder = currentOrder;
  }

  void addPoints(int points) {
    _points += points;
  }

  void setPoints(int points) {
    _points = points;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textColor = _isMyTurn ? AppColor.primaryColorMain : Colors.white;
    final textRenderer =
        TextPaint(
      style: TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 24.0,
        color: textColor,
      ),
    );
    textRenderer.render(
      canvas,
      _text,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }

  void _rerenderImage() {
    if (imageComponent != null) {
      remove(imageComponent!);
    }
    imageComponent =
        ImageComponent.fromSprite(_isParent ? _parentImage : _childImage);
    add(imageComponent!
      ..size = Vector2(48, 48)
      ..x = _isMe ? 14 : size.x - 62);
  }

  Map<String, dynamic> toJson() {
    final json = {
      'uid': _uid,
      'name': _name,
      'status': _status.name,
      'isParent': _isParent,
    };
    if (_winResult != null) {
      return {...json, ..._winResult!.toJson()};
    }
    return json;
  }
}
