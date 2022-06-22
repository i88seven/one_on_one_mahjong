enum ReachState {
  none, // テンパイになっていない
  notEnough, // テンパイにはなっているが翻が足りない
  confirmed, // 満貫確定
  undecided, // アガリ牌によっては満貫
}

Map<ReachState, String> reachStateTextMap = {
  ReachState.none: 'テンパイになっていません',
  ReachState.notEnough: '満貫になりません',
  ReachState.undecided: '満貫にならない場合があります',
  ReachState.confirmed: '満貫確定',
};
