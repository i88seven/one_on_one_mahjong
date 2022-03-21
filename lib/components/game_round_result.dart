import 'package:flame/assets.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:one_on_one_mahjong/components/back_tile.dart';
import 'package:one_on_one_mahjong/components/front_tile.dart';
import 'package:one_on_one_mahjong/components/game_text_button.dart';
import 'package:one_on_one_mahjong/components/win_name_component.dart';
import 'package:one_on_one_mahjong/constants/all_tiles.dart';
import 'package:one_on_one_mahjong/constants/game_button_kind.dart';
import 'package:one_on_one_mahjong/constants/tile_size.dart';
import 'package:one_on_one_mahjong/constants/tile_state.dart';
import 'package:one_on_one_mahjong/constants/win_name.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';
import 'package:one_on_one_mahjong/types/win_result.dart';

class GameRoundResult extends PositionComponent {
  final Images _gameImages;
  late final GameTextButton _button;
  final WinResult _winResult;
  final List<AllTileKinds> _tiles;
  final AllTileKinds _winTile;
  final List<AllTileKinds> _doras;

  GameRoundResult({
    required SeventeenGame game,
    required Vector2 screenSize,
    required WinResult winResult,
    required List<AllTileKinds> tiles,
    required AllTileKinds winTile,
    required List<AllTileKinds> doras,
  })  : _winResult = winResult,
        _tiles = tiles,
        _winTile = winTile,
        _doras = doras,
        _gameImages = game.gameImages {
    size = screenSize;
    position = Vector2(0, 0);
    final okButton = GameTextButton(
      'OK',
      GameButtonKind.roundResultOk,
      position: Vector2(screenSize.x - 100, screenSize.y - 50),
      priority: 20,
    );
    _button = okButton;
    add(_button);
  }

  get button => _button;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFFC9FEF5));
    final _textRenderer = TextPaint(
        config: const TextPaintConfig(fontSize: 20.0, color: Colors.black54));
    _winResult.resultMap.asMap().forEach((int i, ResultRow resultRow) {
      add(TextComponent(resultRow.toString(),
          textRenderer: _textRenderer,
          position: Vector2(
              10 + (i > 7 ? size.x / 2 : 0), (i > 7 ? i - 8 : i) * 28 + 40)));
    });

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
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = 200 + tileSize.width * i
        ..y = size.y - tileSize.height - 170);
    }

    _tiles.asMap().forEach((index, tile) {
      FrontTile tileObject = FrontTile(_gameImages, tile, TileState.result);
      add(tileObject
        ..width = tileSize.width
        ..height = tileSize.height
        ..x = (index + 0.5) * tileSize.width
        ..y = size.y - tileSize.height - 120);
    });

    FrontTile tileObject = FrontTile(_gameImages, _winTile, TileState.result);
    add(tileObject
      ..width = tileSize.width
      ..height = tileSize.height
      ..x = 13.5 * tileSize.width + 5
      ..y = size.y - tileSize.height - 120);

    WinNameComponent winNameComponent =
        WinNameComponent(_gameImages, _winResult.winName!);
    add(winNameComponent
      ..x = 20
      ..y = size.y - 104);
    final _winNameRenderer = TextPaint(
        config: const TextPaintConfig(fontSize: 50.0, color: Colors.black54));
    add(TextComponent(
      captionMap[_winResult.winName] ?? 'エラー',
      textRenderer: _winNameRenderer,
      position: Vector2(120, size.y - 70),
    ));
  }
}
