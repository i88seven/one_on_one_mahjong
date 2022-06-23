import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/components/drawn_image_component.dart';
import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/utils/flame_renderer.dart';

class GameDrawnRoundResult extends PositionComponent {
  final Images _gameImages;
  late final GameTextButton _button;
  final List<AllTileKinds> _trashesOther;
  final List<AllTileKinds> _handsOther;
  final List<AllTileKinds> _trashesMe;
  final List<AllTileKinds> _handsMe;
  final List<AllTileKinds> _doras;
  final String _meName;
  final String _otherName;
  final String _gameRoundName;

  GameDrawnRoundResult({
    required SeventeenGame game,
    required Vector2 screenSize,
    required List<AllTileKinds> trashesOther,
    required List<AllTileKinds> handsOther,
    required List<AllTileKinds> trashesMe,
    required List<AllTileKinds> handsMe,
    required List<AllTileKinds> doras,
    required String meName,
    required String otherName,
    required String gameRoundName,
  })  : _trashesOther = trashesOther,
        _handsOther = handsOther,
        _trashesMe = trashesMe,
        _handsMe = handsMe,
        _doras = doras,
        _meName = meName,
        _otherName = otherName,
        _gameRoundName = gameRoundName,
        _gameImages = game.gameImages {
    size = screenSize;
    position = Vector2(0, 0);
    final okButton = GameTextButton(
      'OK',
      GameButtonKind.roundResultOk,
      position: Vector2(screenSize.x - 152, screenSize.y - 72),
      priority: 20,
    );
    _button = okButton;
    add(_button);
    DrawnImageComponent drawnImageComponent = DrawnImageComponent(_gameImages);
    add(drawnImageComponent
      ..x = 70
      ..y = size.y - 160);
  }

  get button => _button;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderResultBackgroud(canvas, size);

    // ドラ
    for (var i = 0; i < 4; i++) {
      PositionComponent tile;
      if (i == 1) {
        tile = FrontTile(_gameImages, _doras[0], TileState.result);
      } else if (i == 2) {
        tile = FrontTile(_gameImages, _doras[1], TileState.result);
      } else {
        tile = BackTile(_gameImages);
      }
      add(tile
        ..x = size.x / 2 + tileSize.x * (i + 0.5)
        ..y = size.y / 2 - 76);
    }

    const trashTilesCountOfRow = 9;
    _trashesOther.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.result);
      if (index < trashTilesCountOfRow) {
        add(tileObject
          ..x =
              size.x / 2 + tileSize.x * (index - trashTilesCountOfRow * 0.5)
          ..y = 108 + tileSize.y);
      } else {
        add(tileObject
          ..x =
              size.x / 2 + tileSize.x * (index - trashTilesCountOfRow * 1.5)
          ..y = 120 + tileSize.y * 2);
      }
    });

    _trashesMe.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.result);
      if (index < trashTilesCountOfRow) {
        add(tileObject
          ..x =
              size.x / 2 + tileSize.x * (index - trashTilesCountOfRow * 0.5)
          ..y = size.y / 2 - 26);
      } else {
        add(tileObject
          ..x =
              size.x / 2 + tileSize.x * (index - trashTilesCountOfRow * 1.5)
          ..y = size.y / 2 - 14 + tileSize.y);
      }
    });

    // 相手の手配
    _handsOther.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.result);
      add(tileObject
        ..x = size.x / 2 + tileSize.x * (index - 6.5)
        ..y = 96);
    });

    _handsMe.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.result);
      add(tileObject
        ..x = size.x / 2 + tileSize.x * (index - 6.5)
        ..y = size.y / 2 + 4 + tileSize.y * 2);
    });

    final _nameRenderer = TextPaint(
        style: const TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 24.0,
        color: AppColor.gameDialogText,
      ),
    );
    _nameRenderer.render(
      canvas,
      _meName,
      Vector2(size.x / 2, size.y / 2 + 20 + tileSize.y * 3),
      anchor: Anchor.topCenter,
    );
    _nameRenderer.render(
      canvas,
      _otherName,
      Vector2(size.x / 2, 56),
      anchor: Anchor.topCenter,
    );
    _nameRenderer.render(canvas, _gameRoundName, Vector2(80, size.y / 2 - 70));

    final _drawnCaptionRenderer = TextPaint(
        style: const TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: AppColor.gameDialogText,
      ),
    );
    _drawnCaptionRenderer.render(
      canvas,
      '流局',
      Vector2(size.x - 124, size.y - 136),
      anchor: Anchor.topCenter,
    );
  }
}
