local UIAIPetStateBase = require("Logic/Presenter/UI/Main/AIPetMain/State/UIAIPetStateBase");
local UIAIPetStateWork = class("UIAIPetStateWork",UIAIPetStateBase);

function UIAIPetStateWork:ctor(context)
    self.super.ctor(self, context);
    self._boxCom = context:GetComponent(AIPetUICOM.BoxTip);
    self._msgCom = context:GetComponent(AIPetUICOM.Message);
    self._dragCom = context:GetComponent(AIPetUICOM.Drag);
    self._timerIdx = nil;
end

function UIAIPetStateWork:OnEnter()
    self._context:EnableCom(
        AIPetUICOM.Drag,
        AIPetUICOM.Animation,
        AIPetUICOM.BoxTip,
        AIPetUICOM.Message,
        AIPetUICOM.Joke,
        AIPetUICOM.AniRandom
    );
    self._context:DisableCom(
        AIPetUICOM.Record,
        AIPetUICOM.Notice
    );
    self._context:PlayAnimation(AIPetUIANIMATION.WorkIdle,true);
end

function UIAIPetStateWork:OnExit()
    self._context:DisableCom(
        AIPetUICOM.Message,
        AIPetUICOM.Joke,
        AIPetUICOM.AniRandom
    );
    self._timerIdx = nil;
end

function UIAIPetStateWork:OnClick(id)
    if id == 1008 then
        MapMgr.RequestEnterMap(4, 99);--进入宠物的窝
        TipsMgr.TipByFormat("进入宠物的窝");
    elseif id == 1006 then
        self._boxCom:OnClick1();
    elseif id == 1007 then
        self._boxCom:OnClick2();
    elseif id == 1004 then
        self._msgCom:OnClick();
    end
end

function UIAIPetStateWork:Change2Record()
    self._context:EnterState(AIPetUISTATE.Record);
end

function UIAIPetStateWork:OnPress(pressed,id)
    if pressed and id==1008 then
        --开启录音
        GameLog.Log("PrepareRecord");
        self._timerIdx = GameTimer.AddTimer(0.5,1,self.Change2Record,self);
    end
    if (not pressed) and id == 1008 then
        if not self._timerIdx then return; end
        GameTimer.DeleteTimer(self._timerIdx);
        self._timerIdx = nil;
    end

    if id == 1004 then
        self._msgCom:OnPress();
    end
end

function UIAIPetStateWork:DeleteRecordTimer( )
    if not self._timerIdx then return; end
    GameTimer.DeleteTimer(self._timerIdx);
    self._timerIdx = nil;
end

function UIAIPetStateWork:OnDrag(delta,id)
    if id == 1004 then
        self._msgCom:OnDrag(delta,id);
    elseif id == 1008 then
        self:DeleteRecordTimer();
    end
end
function UIAIPetStateWork:OnDragStart(id)
    if id == 1004 then
        self._msgCom:OnDragStart(id);
    end
end
function UIAIPetStateWork:OnDragEnd(id)
    if id == 1004 then
        self._msgCom:OnDragEnd(id);
    end
end


return UIAIPetStateWork;

