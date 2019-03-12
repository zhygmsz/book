local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatTableBase")
local PanelChatQun = class("PanelChatQun",Base);
local WrapUIChatQunLeft = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatQunLeft");
local WrapUIChatQunRight = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatQunRight");
local WrapUIChatSystemNotice = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatSystemNotice");
local WrapUIChatLabelNotice = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatLabelNotice");
local WrapUIChatTime = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatTime");
require("Logic/Presenter/UI/Friend/UI_Friend_QunApply");

function PanelChatQun:ctor(ui,path,basicPath,inputPath,input)
    self.super.ctor(self,ui,path,basicPath,inputPath);
    --(ui,path,count,wrapUIs,baseEvent,eventSpan,context)
    local wrapUIs = {WrapUIChatQunLeft,WrapUIChatQunRight,WrapUIChatSystemNotice,WrapUIChatTime,WrapUIChatLabelNotice};
    self._wrapTable = BaseWrapTableEx.new(ui,path.."/ScrollView",10,wrapUIs,1000,2,self);
    self._wrapTable:RegisterData("QunTextOtherData","WrapUIChatQunLeft");
    self._wrapTable:RegisterData("QunVoiceOtherData","WrapUIChatQunLeft");
    self._wrapTable:RegisterData("QunTextSelfData","WrapUIChatQunRight");
    self._wrapTable:RegisterData("QunVoiceSelfData","WrapUIChatQunRight");
    self._wrapTable:RegisterData("FriendChatDataChatTime","WrapUIChatTime");
    self._wrapTable:RegisterData("FriendChatDataSystemNotice","WrapUIChatSystemNotice");
    self._wrapTable:RegisterData("FriendChatDataLabelNotice","WrapUIChatLabelNotice");

    self._applyListGo = ui:Find(basicPath.."/Qun/ButtonApply").gameObject;
    self._input = input;
    self._blockChatGo = ui:Find(basicPath.."/Qun/ToggleBlock/Active").gameObject;
    self._lockScreenGo = ui:Find(basicPath.."/Qun/ToggleLock/Active").gameObject;

end

function PanelChatQun:OnEnable(chat)
    self.super.OnEnable(self,chat);

    self._basicGo:SetActive(true);
    self._basicQunGo:SetActive(true);
    self._input:SetTarget(chat,true);

    self._applyListGo:SetActive(chat:IsMyQun() or chat:IsAdminByID(UserData.PlayerID));
    self:SetToggleBlockValue(self._chatter:GetChatBlock());
    self:SetToggleLockValue(self._chatter:GetChatBlock());
end


function PanelChatQun:OnClick(id)
    if not self._rootGo.activeInHierarchy then
        return;
    end
    if id >=1000 and id < 2000 then
        self._wrapTable:OnClick(id);
    elseif id == 44 then -- 打开申请列表
        UI_Friend_QunApply.ShowApplyList(self._chatter);
    elseif id == 43 then -- 锁屏
        self:SetToggleLockValue(not self._toggleLockScreen);
    elseif id == 42 then -- 屏蔽消息提醒
        self:SetToggleBlockValue(not self._toggleBlock);

    elseif id == 40 then -- 清空聊天记录
        local function ConfirmDelete()
            self.super.OnClearMsg(self);
        end
        TipsMgr.TipConfirmByKey("friend_delete_%s_qun_msg_record",ConfirmDelete,nil,self._chatter:GetName());--删除群聊记录的确认窗口
    end
end

function PanelChatQun:SetToggleBlockValue(value)
    self._toggleBlock = value;
    self._blockChatGo:SetActive(value);
    self._chatter:SetChatBlock(value);
end
function PanelChatQun:SetToggleLockValue(value)
    self._toggleLockScreen = value;
    self._lockScreenGo:SetActive(value);
end

return PanelChatQun;

