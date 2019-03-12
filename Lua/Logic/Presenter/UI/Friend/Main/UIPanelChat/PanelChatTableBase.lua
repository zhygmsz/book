local UIPanelChatBase = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/UIPanelChatBase")
local PanelChatTableBase = class("PanelChatTableBase",UIPanelChatBase);
function PanelChatTableBase:OnMessageChange(chatter)
    if self._chatter ~= chatter then
        return;
    end
    local wrapDatas = self._chatter:GetRecordCom():GetAllMsg();
    self._wrapTable:ResetWrapContent(wrapDatas,true);
end
function PanelChatTableBase:OnMessageClear(chatter)
    if self._chatter ~= chatter then
        return;
    end
    local wrapDatas = table.emptyTable;
    self._wrapTable:ResetWrapContent(wrapDatas,true);
end
function PanelChatTableBase:OnVoicePlayStart(voiceData)
    self._wrapTable:UpdateWithPosition();--刷新一遍UI
end
--正常结束的情况下，需要连播下一条未读语音
function PanelChatTableBase:OnVoicePlayEnd(voiceData,normalEnd)
    if not normalEnd then return; end
    self._chatter:GetRecordCom():PlayNextUnplayedVoice(voiceData);
end

function PanelChatTableBase:ctor(ui,path,basicPath,inputPath)
    UIPanelChatBase.ctor(self,ui,path,basicPath,inputPath);
    self._basicPrivateGo = ui:Find(basicPath.."/Private").gameObject;
    self._basicQunGo = ui:Find(basicPath.."/Qun").gameObject;
    self._basicNPCGo = ui:Find(basicPath.."/NPC").gameObject;
    self._nameGo = ui:Find(basicPath.."/LabelName").gameObject;--名字
end

function PanelChatTableBase:OnEnable(chat)
    UIPanelChatBase.OnEnable(self);

    self._nameGo:SetActive(false);
    self._basicPrivateGo:SetActive(false);
    self._basicQunGo:SetActive(false);
    self._basicNPCGo:SetActive(false);

    self._chatter = chat;
    local wrapDatas = self._chatter:GetRecordCom():GetAllMsg();
    self._wrapTable:ResetWrapContent(wrapDatas,true);

    self._inputGo:SetActive(true);

    GameEvent.Reg(EVT.SPEECH, EVT.SPEECH_VOICE_START,self.OnVoicePlayStart,self);
    GameEvent.Reg(EVT.SPEECH, EVT.SPEECH_VOICE_STOP,self.OnVoicePlayEnd,self);
    GameEvent.Reg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_MESSAGE,self.OnMessageChange,self);
    GameEvent.Reg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_CLEAR_MESSAGE,self.OnMessageClear,self);
end

function PanelChatTableBase:OnDisable()
    UIPanelChatBase.OnDisable(self);
    GameEvent.Reg(EVT.SPEECH, EVT.SPEECH_VOICE_START,self.OnVoicePlayStart,self);
    GameEvent.Reg(EVT.SPEECH, EVT.SPEECH_VOICE_STOP,self.OnVoicePlayEnd,self);
    GameEvent.UnReg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_MESSAGE,self.OnMessageChange,self);
    GameEvent.UnReg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_CLEAR_MESSAGE,self.OnMessageClear,self);
end

function PanelChatTableBase:OnClick(id)
    GameLog.Log("%s OnClick",self.__cname);
end

function PanelChatTableBase:OnClearMsg()
    self._chatter:GetRecordCom():ClearMemory(true);
end


function PanelChatTableBase:OnUpdateMemberInfo(player)
    if self._chatter == player then
        self._wrapTable:UpdateWithPosition();
    end
end

return PanelChatTableBase;


