local UIAIPetComponentNotice = class("UIAIPetComponentNotice");

function UIAIPetComponentNotice:ctor(ui,context,rootPath)
    local path = rootPath.."/BirthPos/DragRoot/NoticeTip";
    self._comGo = ui:Find(path).gameObject;
    self._label = ui:FindComponent("UILabel", path.."/SpriteLeft/LabelInfo");
    -- self._timeLimit = ConfigData.GetIntValue("AIPet_Notice_Life") or 20;--通知存活时间
    -- self._timeClose = nil;
    self._enabled = false;
end

function UIAIPetComponentNotice:TryDisplay()
    local count = AIPetMgr.GetUnReadTipsCount();
    if count <=0 then
        self._comGo:SetActive(false);
        return;
    end
    self._comGo:SetActive(true);
    if count == 1 then
        local content = WordData.GetWordStringByKey("AIPet_Tip_Notice_1");--...
        self._label.text = content;
    elseif count <= 9 then
        self._label.text = count;
    else
        self._label.text = WordData.GetWordStringByKey("AIPet_Tip_Notice_9+");--9+
    end
end

function UIAIPetComponentNotice:OnEnable()
    if self._enabled then return; end
    --self._timeClose = nil;
    self:TryDisplay();
    GameEvent.Reg(EVT.AIPET, EVT.AIPET_CONFIRM,self.TryDisplay,self);
    GameEvent.Reg(EVT.AIPET, EVT.AIPET_QUESTIONNAIRE,self.TryDisplay,self);
    --UpdateBeat:Add(self.Update,self);
end

function UIAIPetComponentNotice:OnDisable()
    --self._timeClose = nil;
    self._comGo:SetActive(false);

    GameEvent.UnReg(EVT.AIPET, EVT.AIPET_CONFIRM,self.TryDisplay,self);
    GameEvent.UnReg(EVT.AIPET, EVT.AIPET_QUESTIONNAIRE,self.TryDisplay,self);
    --UpdateBeat:Remove(self.Update,self);
end

-- function UIAIPetComponentNotice:Update()
--     local time = TimeUtils.SystemTimeStamp();
--     if self._timeClose and time > self._timeClose then
--         GameLog.Log("---------Close Notice");
--         self._timeClose = nil;
--         self._leftContainer.Close();
--     end
-- end

return UIAIPetComponentNotice;