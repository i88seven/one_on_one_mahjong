import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_on_one_mahjong/pages/game_user/update_name.dart';
import 'package:one_on_one_mahjong/provider/game_user_model.dart';
import 'package:one_on_one_mahjong/provider/game_user_statistics_model.dart';
import 'package:one_on_one_mahjong/types/game_user.dart';
import 'package:one_on_one_mahjong/types/statistics/game_user_statistics.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  late GameUser _gameUser;
  late GameUserStatistics _gameUserStatistics;

  void updateUserName() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return UpdateGameUserNamePage(initialName: _gameUser.name);
      }),
    );
  }

  List<Widget> convertToStatisticsRow(List<String> textList) {
    int rows = (textList.length / 2).ceil();
    List<Widget> result = [];
    for (var i = 0; i < rows; i++) {
      result.add(
        Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 16) * 0.5,
              alignment: Alignment.centerLeft,
              child: Text(textList[i * 2]),
            ),
            textList.length > i * 2 + 1
                ? Container(
                    width: (MediaQuery.of(context).size.width - 16) * 0.5,
                    alignment: Alignment.centerLeft,
                    child: Text(textList[i * 2 + 1]),
                  )
                : Container(),
          ],
        ),
      );
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    final gameUserModel = ref.read(gameUserProvider);
    _gameUser = gameUserModel.gameUser;
    final gameUserStatisticsModel = ref.read(gameUserStatisticsProvider);
    _gameUserStatistics = gameUserStatisticsModel.gameUserStatistics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー管理'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("名前 : ${_gameUser.name}"),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: const Text('名前の変更'),
                  onPressed: updateUserName,
                ),
              ),
            ],
          ),
          ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            initiallyExpanded: true,
            title: const Text('対戦集計'),
            children: convertToStatisticsRow([
              "総対戦数 : ${_gameUserStatistics.toMap()['totalGame']} 回",
              "引き分け数 : ${_gameUserStatistics.toMap()['drawGame']} 回",
              "勝ち数 : ${_gameUserStatistics.toMap()['winGame']} 回",
              "負け数 : ${_gameUserStatistics.toMap()['loseGame']} 回",
            ]),
          ),
          ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            initiallyExpanded: true,
            title: const Text('局集計'),
            children: convertToStatisticsRow([
              "総局数 : ${_gameUserStatistics.toMap()['totalRound']} 回",
              "引き分け数 : ${_gameUserStatistics.summedUpMap['drawnRound']} 回",
              "勝ち数 : ${_gameUserStatistics.summedUpMap['winRound']} 回",
              "負け数 : ${_gameUserStatistics.summedUpMap['loseRound']} 回",
              "満貫 : ${_gameUserStatistics.summedUpMap['winName']['win']['mangan']} 回",
              "跳満 : ${_gameUserStatistics.summedUpMap['winName']['win']['haneman']} 回",
              "倍満 : ${_gameUserStatistics.summedUpMap['winName']['win']['baiman']} 回",
              "三倍満 : ${_gameUserStatistics.summedUpMap['winName']['win']['sanbaiman']} 回",
              "役満 : ${_gameUserStatistics.summedUpMap['winName']['win']['yakuman']} 回",
              "数え役満 : ${_gameUserStatistics.summedUpMap['winName']['win']['kazoeYakuman']} 回",
            ]),
          ),
        ],
      ),
    );
  }
}
