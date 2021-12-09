enum ReachState {
  none, // リーチになっていない
  notEnough, // リーチにはなっているが翻が足りない
  confirmed, // アガリ牌によっては満貫
  undecided, // 満貫確定
}

Map<ReachState, String> reachStateTextMap = {
  ReachState.none: 'リーチになっていません',
  ReachState.notEnough: '満貫になりません',
  ReachState.undecided: '満貫にならない場合があります',
  ReachState.confirmed: '満貫確定',
};
