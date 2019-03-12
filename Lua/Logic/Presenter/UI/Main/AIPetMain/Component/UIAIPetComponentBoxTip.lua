local UIAIPetComponentBoxTip = class("UIAIPetComponentBoxTip");
function UIAIPetComponentBoxTip:ctor(ui, context, uiRootPath)
    self._context = context;
    local path = uiRootPath.."/BirthPos/DragRoot/BoxTip";
    self._comGo = ui:Find(path).gameObject;
    self._contentLabel = ui:FindComponent("UILabel", path.."/SpriteBg/LabelInfo");
    self._btnGrid = ui:FindComponent("UIGrid", path.."/SpriteBg/Grid");
    self._btn1Label = ui:FindComponent("UILabel", path.."/SpriteBg/Grid/Btn1/Name");
    self._btn2Label = ui:FindComponent("UILabel", path.."/SpriteBg/Grid/Btn2/Name");
    self._btn2Go = ui:Find(path.."/SpriteBg/Grid/Btn2").gameObject;
    self._enabled = false;
end

function UIAIPetComponentBoxTip:OnTipOver()
    GameTimer.DeleteTimer(self._timeIndexer);
    self._timeIndexer = nil;
    AIPetMgr.SetTipRead(self._tip);
    self._tip = nil;
    self:TryShowTip();
end

function UIAIPetComponentBoxTip:TryShowTip()
    self._tip = AIPetMgr.GetOneTip();
    if not self._tip then
        self._comGo:SetActive(false);
        return;
    end
    local tip = self._tip;
    self._comGo:SetActive(true);
    self._contentLabel.text = tip:GetContent();
    local btnCount = tip:GetCallCount();
    self._btn2Go:SetActive(btnCount == 2);
    self._btnGrid:Reposition();
    self._btn1Label.text = tip:GetBtn1Str();
    self._btn2Label.text = tip:GetBtn2Str();
    local dur = ConfigData.GetIntValue("AIPet_Box_Tip_Time_Interval") or 10;--黑板气泡存活时间 单位秒
    self._timeIndexer = GameTimer.AddTimer(dur,1,self.OnClick1,self);
end

function UIAIPetComponentBoxTip:OnEnable()
    if self._enabled then return; end
    self:TryShowTip();
    GameEvent.Reg(EVT.AIPET, EVT.AIPET_CONFIRM,self.OnNewTip, self);
    GameEvent.Reg(EVT.AIPET, EVT.AIPET_QUESTIONNAIRE,self.OnNewTip, self);
end

--新tip需要排队
function UIAIPetComponentBoxTip:OnNewTip()
    if self._tip then return; end
    self:TryShowTip();
end

--关闭只影响计时，不影响显示；
function UIAIPetComponentBoxTip:OnDisable()
    self._comGo:SetActive(false);
    if self._timeIndexer then
        GameTimer.DeleteTimer(self._timeIndexer);
        self._timeIndexer = nil;
    end
    GameEvent.UnReg(EVT.AIPET, EVT.AIPET_CONFIRM,self.OnNewTip, self);
    GameEvent.UnReg(EVT.AIPET, EVT.AIPET_QUESTIONNAIRE,self.OnNewTip, self);
end

function UIAIPetComponentBoxTip:SetUIActive(state)
    self._comGo:SetActive(state);
end

function UIAIPetComponentBoxTip:OnClick1()
    GameUtils.TryInvokeCallback(self._tip:GetBtn1Call(), self._tip:GetCaller());
    self:OnTipOver();
end
function UIAIPetComponentBoxTip:OnClick2()
    GameUtils.TryInvokeCallback(self._tip:GetBtn2Call(), self._tip:GetCaller());
    self:OnTipOver();
end

return UIAIPetComponentBoxTip;

