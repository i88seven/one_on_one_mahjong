import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localstorage/localstorage.dart';
import 'package:one_on_one_mahjong/components/preparation_background.dart';
import 'package:one_on_one_mahjong/config/theme.dart';
import 'package:one_on_one_mahjong/constants/yaku.dart';
import 'package:one_on_one_mahjong/pages/game_user/setting.dart';
import 'package:one_on_one_mahjong/pages/login/login_page.dart';
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
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');

  void updateUserSetting() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SettingPage(
            initialName: _gameUser.name,
            initialIsPlayMusic: _gameUser.isPlayMusic);
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
              width: (MediaQuery.of(context).size.width - 48) * 0.5,
              alignment: Alignment.centerLeft,
              child: Text(textList[i * 2]),
            ),
            textList.length > i * 2 + 1
                ? Container(
                    width: (MediaQuery.of(context).size.width - 48) * 0.5,
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
    Future(() async {
      await _storage.ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー管理'),
      ),
      body: Stack(
        children: [
          const PreparationBackground(),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("名前 : ${_gameUser.name}"),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('設定'),
                      onPressed: updateUserSetting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              !_gameUser.isAnonymously
                  ? ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                initiallyExpanded: true,
                childrenPadding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                title: const Text(
                  '対戦集計',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: AppColor.primaryColorMain,
                iconColor: AppColor.primaryColorMain,
                children: convertToStatisticsRow([
                  "総対戦数 : ${_gameUserStatistics.totalGame} 回",
                  "通信切断 : ${_gameUserStatistics.disconnectionGame} 回 (${_gameUserStatistics.disconnectionRate} %)",
                  "勝ち : ${_gameUserStatistics.winGame} 回 (${_gameUserStatistics.winRate} %)",
                  "負け : ${_gameUserStatistics.loseGame} 回 (${_gameUserStatistics.loseRate} %)",
                  "引き分け : ${_gameUserStatistics.drawGame} 回 (${_gameUserStatistics.drawRate} %)",
                ]),
                    )
                  : Container(),
              !_gameUser.isAnonymously
                  ? ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                initiallyExpanded: true,
                childrenPadding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                title: const Text(
                  '局集計',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: AppColor.primaryColorMain,
                iconColor: AppColor.primaryColorMain,
                children: convertToStatisticsRow([
                  "総局数 : ${_gameUserStatistics.totalRound} 局",
                  "流局 : ${_gameUserStatistics.drawnRound} 局",
                  "勝ち : ${_gameUserStatistics.winRound} 局",
                  "負け : ${_gameUserStatistics.loseRound} 局",
                  "満貫 : ${_gameUserStatistics.winName['mangan']} 回",
                  "跳満 : ${_gameUserStatistics.winName['haneman']} 回",
                  "倍満 : ${_gameUserStatistics.winName['baiman']} 回",
                  "三倍満 : ${_gameUserStatistics.winName['sanbaiman']} 回",
                  "役満 : ${_gameUserStatistics.winName['yakuman']} 回",
                  "数え役満 : ${_gameUserStatistics.winName['kazoeYakuman']} 回",
                  "平均勝ち点数 : ${_gameUserStatistics.winPointAverage} 点",
                  "平均負け点数 : ${_gameUserStatistics.losePointAverage} 点",
                  "平均勝ち歩数 : ${_gameUserStatistics.winStepAverage} 歩",
                  "平均負け歩数 : ${_gameUserStatistics.loseStepAverage} 歩",
                ]),
                    )
                  : Container(),
              !_gameUser.isAnonymously
                  ? ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                initiallyExpanded: false,
                childrenPadding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                title: const Text(
                  '役集計',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: AppColor.primaryColorMain,
                iconColor: AppColor.primaryColorMain,
                children: convertToStatisticsRow([
                  "勝ち局数 : ${_gameUserStatistics.winRound} 局",
                  "",
                  ...Yaku.values.fold<List<String>>([], (currentList, yaku) {
                    currentList.add(
                        "${nameMap[yaku]} : ${_gameUserStatistics.winYaku[yaku.name]} 回");
                    switch (yaku) {
                      case Yaku.dora:
                        currentList.add(
                            "ドラ合計 : ${_gameUserStatistics.winYaku['doraAll']} 翻");
                        break;
                      case Yaku.uraDora:
                        currentList.add(
                            "裏ドラ合計 : ${_gameUserStatistics.winYaku['uraDoraAll']} 翻");
                        break;
                      case Yaku.redFive:
                        currentList.add(
                            "赤ドラ合計 : ${_gameUserStatistics.winYaku['redFiveAll']} 翻");
                        break;
                      default:
                      // NOP
                    }
                    return currentList;
                  }),
                ]),
                    )
                  : Container(),
              const SizedBox(height: 52),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('ログアウト'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        _storage.deleteItem('myName');
                        _storage.deleteItem('isPlayMusic');
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                            return const LoginPage();
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
