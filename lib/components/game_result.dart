import 'package:one_on_one_mahjong/components/game_end_button.dart';
import 'package:one_on_one_mahjong/components/game_player.dart';
import 'package:one_on_one_mahjong/components/game_player_result.dart';
import 'package:one_on_one_mahjong/pages/seventeen_game/main.dart';

class GameResult {
  final SeventeenGame _game;
  final List<GamePlayer> _gamePlayers;
  // GameResultBackground _background;
  late GameEndButton _endButton;
  List<GamePlayerResult> _gamePlayerResults = [];

  GameResult(this._game, this._gamePlayers);

  void render() {
    // _background = GameResultBackground()
    //   ..width = _game.screenSize.width
    //   ..height = _game.screenSize.height;
    // _game.add(_background);

    _endButton = GameEndButton()
      ..x = _game.screenSize.x / 2 - 40
      ..y = _game.screenSize.y - 110;
    _game.add(_endButton);

    _gamePlayers.sort((a, b) => b.points - a.points);
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      GamePlayerResult gamePlayerResult = GamePlayerResult(gamePlayer)
        ..x = 30
        ..y = (index * 50 + 50).toDouble()
        ..width = _game.screenSize.x - 60;
      _game.add(gamePlayerResult);
      _gamePlayerResults.add(gamePlayerResult);
    });
  }

  void remove() {
    // _game.markToRemove(_background);
    _game.remove(_endButton);
    for (var gamePlayerResult in _gamePlayerResults) {
      _game.remove(gamePlayerResult);
    }
  }
}
