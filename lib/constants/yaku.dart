enum Yaku {
  dora,
  uraDora,
  redFive,
  /* 1翻 */
  /* 立直 */
  reach,
  /* 自風 */
  seatWind,
  /* 場風 */
  prevalentWind,
  /* 白 */
  whiteDragon,
  /* 發 */
  greenDragon,
  /* 中 */
  redDragon,
  /* 断ヤオ九 */
  allSimples,
  /* 平和 */
  allRuns,
  /* 門前自摸 */
  concealedSelfDraw,
  /* 一発 */
  firstTurnWin,
  /* 河底撈魚 */
  finalTileWin,
  /* 一盃口 */
  doubleRun,

  /* 2翻 */
  /* 対々和 */
  allTriples,
  /* 三色同順 */
  threeColorRuns,
  /* 七対子 */
  sevenPairs,
  /* 一気通貫 */
  fullStraight,
  /* 混全帯么九 */
  mixedOutsideHand,
  /* 三暗刻 */
  threeConcealedTriples,
  /* 小三元 */
  littleDragons,
  /* 混老頭 */
  allTerminalsAndHonors,
  /* 三色同刻 */
  threeColorTriples,

  /* 3翻 */
  /* 混一色 */
  halfFlush,
  /* 純全帯么九 */
  pureOutsideHand,
  /* ニ盃口 */
  twoDoubleRuns,

  /* 6翻 */
  /* 清一色 */
  fullFlush,

  /* 役満 */
  /* 四暗刻 */
  fourConcealedTriples,
  /* 国士無双 */
  thirteenOrphans,
  /* 大三元 */
  bigDragons,
  /* 四喜和 */
  fourWinds,
  /* 字一色 */
  allHonors,
  /* 清老頭 */
  allTerminals,
  /* 緑一色 */
  allGreen,
  /* 九蓮宝燈 */
  nineGates,
}

final Map<Yaku, int> hanMap = {
  /* 立直 */
  Yaku.reach: 1,
  /* 自風 */
  Yaku.seatWind: 1,
  /* 場風 */
  Yaku.prevalentWind: 1,
  /* 白 */
  Yaku.whiteDragon: 1,
  /* 發 */
  Yaku.greenDragon: 1,
  /* 中 */
  Yaku.redDragon: 1,
  /* 断ヤオ九 */
  Yaku.allSimples: 1,
  /* 平和 */
  Yaku.allRuns: 1,
  /* 門前自摸 */
  Yaku.concealedSelfDraw: 1,
  /* 一発 */
  Yaku.firstTurnWin: 1,
  /* 河底撈魚 */
  Yaku.finalTileWin: 1,
  /* 一盃口 */
  Yaku.doubleRun: 1,
  /* 対々和 */
  Yaku.allTriples: 2,
  /* 三色同順 */
  Yaku.threeColorRuns: 2,
  /* 七対子 */
  Yaku.sevenPairs: 2,
  /* 一気通貫 */
  Yaku.fullStraight: 2,
  /* 混全帯么九 */
  Yaku.mixedOutsideHand: 2,
  /* 三暗刻 */
  Yaku.threeConcealedTriples: 2,
  /* 小三元 */
  Yaku.littleDragons: 2,
  /* 混老頭 */
  Yaku.allTerminalsAndHonors: 2,
  /* 三色同刻 */
  Yaku.threeColorTriples: 2,
  /* 混一色 */
  Yaku.halfFlush: 3,
  /* 純全帯么九 */
  Yaku.pureOutsideHand: 3,
  /* ニ盃口 */
  Yaku.twoDoubleRuns: 3,
  /* 清一色 */
  Yaku.fullFlush: 6,
};

List<Yaku> yakumanList = [
  /* 四暗刻 */
  Yaku.fourConcealedTriples,
  /* 国士無双 */
  Yaku.thirteenOrphans,
  /* 大三元 */
  Yaku.bigDragons,
  /* 四喜和 */
  Yaku.fourWinds,
  /* 字一色 */
  Yaku.allHonors,
  /* 清老頭 */
  Yaku.allTerminals,
  /* 緑一色 */
  Yaku.allGreen,
  /* 九蓮宝燈 */
  Yaku.nineGates,
];

/// key は value の上位役 := key の役が成り立っているとき、 value の役は成り立たない
final Map<Yaku, Yaku> conflicts = {
  Yaku.twoDoubleRuns: Yaku.doubleRun, // ニ盃口 : 一盃口
  Yaku.pureOutsideHand: Yaku.mixedOutsideHand, // 純全帯么九 : 混全帯么九
  Yaku.allTerminalsAndHonors: Yaku.mixedOutsideHand, // 混老頭 : 混全帯么九
  Yaku.fullFlush: Yaku.halfFlush, // 清一色 : 混一色
};

final Map<Yaku, String> nameMap = {
  Yaku.dora: 'ドラ',
  Yaku.uraDora: '裏ドラ',
  Yaku.redFive: '赤ドラ',
  Yaku.reach: '立直',
  Yaku.seatWind: '自風',
  Yaku.prevalentWind: '場風',
  Yaku.whiteDragon: '白',
  Yaku.greenDragon: '發',
  Yaku.redDragon: '中',
  Yaku.allSimples: '断ヤオ九',
  Yaku.allRuns: '平和',
  Yaku.concealedSelfDraw: '門前自摸',
  Yaku.firstTurnWin: '一発',
  Yaku.finalTileWin: '河底撈魚',
  Yaku.doubleRun: '一盃口',
  Yaku.allTriples: '対々和',
  Yaku.threeColorRuns: '三色同順',
  Yaku.sevenPairs: '七対子',
  Yaku.fullStraight: '一気通貫',
  Yaku.mixedOutsideHand: '混全帯么九',
  Yaku.threeConcealedTriples: '三暗刻',
  Yaku.littleDragons: '小三元',
  Yaku.allTerminalsAndHonors: '混老頭',
  Yaku.threeColorTriples: '三色同刻',
  Yaku.halfFlush: '混一色',
  Yaku.pureOutsideHand: '純全帯么九',
  Yaku.twoDoubleRuns: 'ニ盃口',
  Yaku.fullFlush: '清一色',
  Yaku.fourConcealedTriples: '四暗刻',
  Yaku.thirteenOrphans: '国士無双',
  Yaku.bigDragons: '大三元',
  Yaku.fourWinds: '四喜和',
  Yaku.allHonors: '字一色',
  Yaku.allTerminals: '清老頭',
  Yaku.allGreen: '緑一色',
  Yaku.nineGates: '九蓮宝燈',
};
