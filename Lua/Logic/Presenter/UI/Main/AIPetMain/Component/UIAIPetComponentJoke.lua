local UIAIPetComponentJoke = class("UIAIPetComponentJoke");

function UIAIPetComponentJoke:ctor(ui)
    self._enabled = false;
end

function UIAIPetComponentJoke:OnReceiveNewMessage(dialog)
    self._sendTime = TimeUtils.SystemTimeStamp(true) + AIPetMgr.GetChatFrequenceTime();
end

function UIAIPetComponentJoke:OnFrequenceChange(level)
    local timeLimit = AIPetMgr.GetChatFrequenceTime();
    if timeLimit == self._timeLimit then return; end
    self._timeLimit = timeLimit;
    self._sendTime = TimeUtils.SystemTimeStamp(true) + timeLimit;
    if timeLimit <= 0 then 
        UpdateBeat:Remove(self.Update,self);
    end
end

function UIAIPetComponentJoke:OnEnable()
    if self._enabled then return; end
    local timeLimit = AIPetMgr.GetChatFrequenceTime();
    self._timeLimit = timeLimit;
    self._sendTime = TimeUtils.SystemTimeStamp(true) + timeLimit;
    if timeLimit > 0 then 
        UpdateBeat:Add(self.Update,self); 
    end
    GameEvent.Reg(EVT.AIPET, EVT.DIALOG_PLAYER,self.OnReceiveNewMessage,self);
    GameEvent.Reg(EVT.AIPET, EVT.DIALOG_AIPET,self.OnReceiveNewMessage,self);
    GameEvent.Reg(EVT.AIPET, EVT.AIPET_JOKE_FREQUENCE,self.OnFrequenceChange,self);
end

function UIAIPetComponentJoke:Update()
    if not self._sendTime then return; end

    local time = TimeUtils.SystemTimeStamp(true);
    if time > self._sendTime then
        self._sendTime = self._timeLimit + time;
        local catalyzer = "讲个笑话"--WordData.GetWordStringByKey("AIPet_Joke");--
        AIPetMgr.CallFairyText(catalyzer,true);
    end
end

function UIAIPetComponentJoke:OnDisable()
    self._sendTime = nil;
    UpdateBeat:Remove(self.Update,self);
    GameEvent.UnReg(EVT.AIPET, EVT.DIALOG_PLAYER,self.OnReceiveNewMessage,self);
    GameEvent.UnReg(EVT.AIPET, EVT.DIALOG_AIPET,self.OnReceiveNewMessage,self);
    GameEvent.UnReg(EVT.AIPET, EVT.AIPET_JOKE_FREQUENCE,self.OnFrequenceChange,self);
end

return UIAIPetComponentJoke;