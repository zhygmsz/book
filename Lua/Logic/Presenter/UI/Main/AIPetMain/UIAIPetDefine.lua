AIPetUICOM = {
    Drag=1,--拖拽组件
    Animation=2,--动画组件
    BoxTip=3,--黑板气泡
    Message=4,--箭头气泡
    Notice=5,--棉花气泡
    Record=6,--录音
    Joke=7,--主动讲笑话
    AniRandom=8--播放随机动作
};

AIPetUISTATE = {};
AIPetUISTATE.Closed = 1;--玩家关闭，系统隐藏，未获得
AIPetUISTATE.Work = 3;--工作待机
AIPetUISTATE.Inactive = 4;--休眠
AIPetUISTATE.Record = 5;--聆听

AIPetUIANIMATION = {
    WorkIdle = 1, --工作待机
    InactiveIdle = 2,--休眠
    Drag = 3,--拖拽
    Listen = 4,--听
    Answer = 5,--回答
    AnswerFailed = 6,--无法回答
    Random = 10--随机动作
};