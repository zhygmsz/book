local UIAIPetStateBase = require("Logic/Presenter/UI/Main/AIPetMain/State/UIAIPetStateBase");
local UIAIPetStateRecord = class("UIAIPetStateRecord",UIAIPetStateBase);

function UIAIPetStateRecord:ctor(context)
    self.super.ctor(self, context);
    self._recordCom = context:GetComponent(AIPetUICOM.Record);
    self._boxCom = context:GetComponent(AIPetUICOM.BoxTip);
end

function UIAIPetStateRecord:StartRecord( )
    
    if self._timerIdx then GameTimer.DeleteTimer(self._timerIdx); self._timerIdx = nil; end
    
    local ret = AIPetMgr.StartRecord();--调用sdk开始录音；

    GameLog.Log("----------StartRecord  %s", ret);
    if not ret then
        self._context:EnterState(AIPetUISTATE.Work);
    end
end

function UIAIPetStateRecord:StopRecord()
    AIPetMgr.StopRecord();
    self._context:EnterState(AIPetUISTATE.Work);
end

function UIAIPetStateRecord:OnEnter()
    if not SystemInfo.IsMobilePlatform() or SystemInfo.IsEditor() then
        --TipsMgr.TipByKey("AIPet_Unavailable_for_PC");--
        --self._context:EnterState(AIPetUISTATE.Work);
        --return;
    end

    self._context:DisableCom(
        AIPetUICOM.Drag
    );
    self._context:EnableCom(
        AIPetUICOM.Animation,
        AIPetUICOM.Message,
        AIPetUICOM.Record
    );
    self._boxCom:SetUIActive(false);
    self._context:PlayAnimation(AIPetUIANIMATION.Listen);

    self._startTime = 0;
    self:StartRecord();
    UpdateBeat:Add(self.Update,self);
end

function UIAIPetStateRecord:Update()
    if self._startTime == 0 then return; end
    local timePassed = TimeUtils.SystemTimeStamp(true) - self._startTime;
    local fillAmount = 1 - timePassed/self._timeLimit;
    if fillAmount <=0 then
        self:StopRecord();
        return; 
    end
    self._recordCom:SetCountDown(self._token, fillAmount);
end

function UIAIPetStateRecord:OnExit()
    UpdateBeat:Remove(self.Update,self);
    if self._timerIdx then GameTimer.DeleteTimer(self._timerIdx); self._timerIdx = nil; end
    self._boxCom:SetUIActive(true);
    self._context:DisableCom(
        AIPetUICOM.Record
    );
end

function UIAIPetStateRecord:OnPress(pressed,id)
    
    if not pressed and id==1008 then
        AIPetMgr.StopRecord();
        self._context:EnterState(AIPetUISTATE.Work);
    end

    if (pressed) and id == 1008 then--语音权限提示可能会打断操作。点击重新开始
        self:StartRecord();
    end

    if id == 1004 then
        self._msgCom:OnPress();
    end
end

function UIAIPetStateRecord:OnDrag(delta,id)
    if id == 1004 then
        self._msgCom:OnDrag(delta,id);
    elseif id == 1008 then
        self._recordCom:DragForCancel(self._token);
    end
end

function UIAIPetStateRecord:OnDragStart(id)
    if id == 1004 then
        self._msgCom:OnDragStart(id);
    end
end

function UIAIPetStateRecord:OnDragEnd(id)
    if id == 1004 then
        self._msgCom:OnDragEnd(id);
    end
end

return UIAIPetStateRecord;
