enum ReachState {
  none, // テンパイになっていない
  notEnough, // テンパイにはなっているが翻が足りない
  confirmed, // アガリ牌によっては満貫
  undecided, // 満貫確定
}

Map<ReachState, String> reachStateTextMap = {
  ReachState.none: 'テンパイになっていません',
  ReachState.notEnough: '満貫になりません',
  ReachState.undecided: '満貫にならない場合があります',
  ReachState.confirmed: '満貫確定',
};
