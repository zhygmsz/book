local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatTableBase")
local PanelChatPrivate = class("PanelChatPrivate",Base);
local WrapUIChatPrivateLeft = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatPrivateLeft");
local WrapUIChatPrivateRight = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatPrivateRight");
local WrapUIChatSystemNotice = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatSystemNotice");
local WrapUIChatLabelNotice = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatLabelNotice");
local WrapUIChatTime = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatTime");

function PanelChatPrivate:ctor(ui,path,basicPath,inputPath,input)
    self.super.ctor(self,ui,path,basicPath,inputPath);
    --(ui,path,count,wrapUIs,baseEvent,eventSpan,context)
    local wrapUIs = {WrapUIChatPrivateLeft,WrapUIChatPrivateRight,WrapUIChatSystemNotice,WrapUIChatTime,WrapUIChatLabelNotice};
    self._wrapTable = BaseWrapTableEx.new(ui,path.."/ScrollView",10,wrapUIs,1000,5,self);
    self._wrapTable:RegisterData("PrivateTextOtherData","WrapUIChatPrivateLeft");
    self._wrapTable:RegisterData("PrivateVoiceOtherData","WrapUIChatPrivateLeft");
    self._wrapTable:RegisterData("PrivateTextSelfData","WrapUIChatPrivateRight");
    self._wrapTable:RegisterData("PrivateVoiceSelfData","WrapUIChatPrivateRight");
    self._wrapTable:RegisterData("FriendChatDataChatTime","WrapUIChatTime");
    self._wrapTable:RegisterData("FriendChatDataSystemNotice","WrapUIChatSystemNotice");
    self._wrapTable:RegisterData("FriendChatDataLabelNotice","WrapUIChatLabelNotice");
    
    self._input = input;
    self._labelHeat = ui:FindComponent("UILabel",basicPath.."/Private/LabelChatHot");
    self._labelIntimacy = ui:FindComponent("UILabel",basicPath.."/Private/LabelIntimacy/Label");
    self._goAddFriend = ui:Find(basicPath.."/Private/ButtonAdd").gameObject;
    self._goUnreqiuredLove = ui:Find(basicPath.."/Private/UnreqiuredLove").gameObject;
    self._labelRelation = ui:FindComponent("UILabel",basicPath.."/Private/LabelRelation");
    self._eventID = nil;
end

function PanelChatPrivate:OnEnable(player)
    self.super.OnEnable(self,player);
    self._player = player;

    self._basicGo:SetActive(true);
    self._basicPrivateGo:SetActive(true);
    self._input:SetTarget(player,false);

    self:RefreshRelationUI();

    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_RELATION_CHANGE,self.OnFriendRelation,self);     --改变好友基本数据；
    
end

function PanelChatPrivate:OnDisable()
    self.super.OnDisable(self);
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_RELATION_CHANGE,self.OnFriendRelation,self);     --改变好友基本数据；
end



function PanelChatPrivate:OnClick(id)
    if not self._rootGo.activeSelf then
        return;
    end
    if id >=1000 and id < 2000 then
        self._wrapTable:OnClick(id);
    elseif id == 42 then
        TipsMgr.TipByKey("friend_chat_hot");--聊天热度
    elseif id == 41 then
        --添加好友
        FriendMgr.RequestAskAddFriend(self._chatter);
    elseif id == 40 then --清空聊天记录
        local function ConfirmDelete()
            self.super.OnClearMsg(self);
        end
        TipsMgr.TipConfirmByKey("friend_delete_%s_msg_record",ConfirmDelete,nil,self._chatter:GetName());--删除聊天记录的确认窗口
    end
end

function PanelChatPrivate:OnFriendRelation(player)
    if player ~= self._player then return; end
    self:RefreshRelationUI()
end

function PanelChatPrivate:RefreshRelationUI()
    local player = self._player;
    if player:IsFriend() or player:IsFollow() then
        self._goAddFriend:SetActive(false);
        self._goUnreqiuredLove:SetActive(player:IsUnrequitedLover());
        
        if player:IsHusbandWife() then
            self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_husband_wide");--夫妻
        elseif (player:IsMaster() or player:IsApprentice()) then
            self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_master_apprentice");--师徒
        elseif player:IsBrothers() then
            self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_brothers");--结义
        elseif player:IsUnrequitedLover() then
            self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_unrequited_lover");--暗恋
        else
            self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_normal_friend");--普通好友
        end
    else
        self._goAddFriend:SetActive(true);
        self._goUnreqiuredLove:SetActive(false);
        self._labelRelation.text = WordData.GetWordStringByKey("friend_relation_stranger");--陌生人
    end
    self._labelIntimacy.text = player:GetIntimacy();
    --self._labelHeat.text = player:GetHeat();
end

return PanelChatPrivate;
