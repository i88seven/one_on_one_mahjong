import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:one_on_one_mahjong/types/statistics/game_user_statistics.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  late GameUserModel _gameUserModel;
  late GameUserStatistics _gameUserStatistics;
  final LocalStorage _storage = LocalStorage('one_one_one_mahjong');

  void updateUserSetting() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SettingPage(
            initialName: _gameUserModel.gameUser.name,
            initialIsPlayMusic: _gameUserModel.gameUser.isPlayMusic);
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
            if (textList.length > i * 2 + 1)
              Container(
                    width: (MediaQuery.of(context).size.width - 48) * 0.5,
                    alignment: Alignment.centerLeft,
                    child: Text(textList[i * 2 + 1]),
              ),
          ],
        ),
      );
    }
    return result;
  }

  void showUserDeleteDialog() async {
    showDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('??????????????????'),
          content: const Text('??????????????????????????????????????????????????????????????????????????????????????????\n????????????????????????'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('???????????????'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                await _gameUserModel.delete();
                await FirebaseAuth.instance.currentUser?.delete();
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
              child: const Text('??????'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _gameUserModel = ref.read(gameUserProvider);
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
        title: const Text('??????????????????'),
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
                  Text("?????? : ${_gameUserModel.gameUser.name}"),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('??????'),
                      onPressed: updateUserSetting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_gameUserModel.gameUser.isAnonymously)
                ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      initiallyExpanded: true,
                      childrenPadding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      title: const Text(
                        '????????????',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: AppColor.primaryColorMain,
                      iconColor: AppColor.primaryColorMain,
                      children: convertToStatisticsRow([
                        "???????????? : ${_gameUserStatistics.totalGame} ???",
                        "???????????? : ${_gameUserStatistics.disconnectionGame} ??? (${_gameUserStatistics.disconnectionRate} %)",
                        "?????? : ${_gameUserStatistics.winGame} ??? (${_gameUserStatistics.winRate} %)",
                        "?????? : ${_gameUserStatistics.loseGame} ??? (${_gameUserStatistics.loseRate} %)",
                        "???????????? : ${_gameUserStatistics.drawGame} ??? (${_gameUserStatistics.drawRate} %)",
                      ]),
                ),
              if (!_gameUserModel.gameUser.isAnonymously)
                ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      initiallyExpanded: true,
                      childrenPadding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      title: const Text(
                        '?????????',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: AppColor.primaryColorMain,
                      iconColor: AppColor.primaryColorMain,
                      children: convertToStatisticsRow([
                        "????????? : ${_gameUserStatistics.totalRound} ???",
                        "?????? : ${_gameUserStatistics.drawnRound} ???",
                        "?????? : ${_gameUserStatistics.winRound} ???",
                        "?????? : ${_gameUserStatistics.loseRound} ???",
                        "?????? : ${_gameUserStatistics.winName['mangan']} ???",
                        "?????? : ${_gameUserStatistics.winName['haneman']} ???",
                        "?????? : ${_gameUserStatistics.winName['baiman']} ???",
                        "????????? : ${_gameUserStatistics.winName['sanbaiman']} ???",
                        "?????? : ${_gameUserStatistics.winName['yakuman']} ???",
                        "???????????? : ${_gameUserStatistics.winName['kazoeYakuman']} ???",
                        "?????????????????? : ${_gameUserStatistics.winPointAverage} ???",
                        "?????????????????? : ${_gameUserStatistics.losePointAverage} ???",
                        "?????????????????? : ${_gameUserStatistics.winStepAverage} ???",
                        "?????????????????? : ${_gameUserStatistics.loseStepAverage} ???",
                      ]),
                ),
              if (!_gameUserModel.gameUser.isAnonymously)
                ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      initiallyExpanded: false,
                      childrenPadding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      title: const Text(
                        '?????????',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: AppColor.primaryColorMain,
                      iconColor: AppColor.primaryColorMain,
                      children: convertToStatisticsRow([
                        "???????????? : ${_gameUserStatistics.winRound} ???",
                        "",
                        ...Yaku.values.fold<List<String>>([],
                            (currentList, yaku) {
                          currentList.add(
                              "${nameMap[yaku]} : ${_gameUserStatistics.winYaku[yaku.name]} ???");
                          switch (yaku) {
                            case Yaku.dora:
                              currentList.add(
                                  "???????????? : ${_gameUserStatistics.winYaku['doraAll']} ???");
                              break;
                            case Yaku.uraDora:
                              currentList.add(
                                  "??????????????? : ${_gameUserStatistics.winYaku['uraDoraAll']} ???");
                              break;
                            case Yaku.redFive:
                              currentList.add(
                                  "??????????????? : ${_gameUserStatistics.winYaku['redFiveAll']} ???");
                              break;
                            default:
                            // NOP
                          }
                          return currentList;
                        }),
                      ]),
                ),
              const SizedBox(height: 52),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('???????????????'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        _storage.deleteItem('myName');
                        _storage.deleteItem('isPlayMusic');
                        _gameUserModel.logout();
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
              if (!_gameUserModel.gameUser.isAnonymously)
                Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Container(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.warning),
                                label: const Text('??????????????????'),
                                onPressed: showUserDeleteDialog,
                              ),
                            )),
                      ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
