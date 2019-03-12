module("UI_Friend_QunInfo",package.seeall)
require("Logic/Presenter/UI/Friend/UI_Friend_QunAddPlayer");
 
local WrapUIFriendQunMemberInfo = require("Logic/Presenter/UI/Friend/QunInfo/WrapUIFriendQunMemberInfo");
local mQun;
local mPlayerList;
local mBasicPanel = {};
local mFriendPanel = {};

local function OnMemberAdd(qun,member)
    if qun == mQun then
        mFriendPanel:AddMember(member);
        mBasicPanel:UpdateCount();
    end
end
local function OnMemberDelete(qun,member)
    if qun == mQun then
        mFriendPanel:RemoveMember(member);
        mBasicPanel:UpdateCount();
    end
end
local function OnAdminChange(qun,member)
    if qun == mQun then
        mFriendPanel:AdminChange();
    end
end
local function OnQunInfoUpdated(qun)
    if qun == mQun then
        mBasicPanel:UpdateName();
        mBasicPanel:UpdateCount();
    end
end

local function OnQunRemove(qun)
    if qun == mQun then
        UIMgr.UnShowUI(AllUI.UI_Friend_QunInfo);
    end
end

local function DismissQun()
    ChatMgr.RequestDestoryCligroup(mQun);
end

local function QuitQun()
    ChatMgr.RequestLeaveCligroup(mQun);
end

function ShowQunInfo(qun)
    mQun = qun;
    UIMgr.ShowUI(AllUI.UI_Friend_QunInfo);
end

function OnCreate(ui)
    mBasicPanel:Init(ui);
    mFriendPanel:Init(ui);
end

function OnEnable(ui)
    mBasicPanel:OnEnable();
    mFriendPanel:OnEnable();

    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN, OnQunRemove);--退出群或者解散群
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD, OnMemberAdd);--群成员变化
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE, OnMemberDelete);--群成员变化
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO, OnQunInfoUpdated);--群基本信息变化
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_ADMIN,OnAdminChange);--群管理员变化

end

function OnDisable(ui)
    mQun = nil;
    mFriendPanel:OnDisable();
     
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN, OnQunRemove);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD, OnMemberAdd);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE, OnMemberDelete);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO, OnQunInfoUpdated);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_ADMIN,OnAdminChange);
end

function OnClick(go, id)
    mBasicPanel:OnClick(id);
    mFriendPanel:OnClick(id);
end

function mBasicPanel:Init(ui)
    self._nameLabel = ui:FindComponent("UILabel","Offset/Top/LabelName");
    local limitCount = ConfigData.GetIntValue("friend_qun_name_limit") or 6;--好友群名长度
    self._nameInput = UICommonLuaInput.new(ui:FindComponent("LuaUIInput","Offset/Top/InputName"),limitCount);
    --local okButtonLabel = ui:FindComponent("UILabel","Offset/Top/ButtonOK/Name");
    self._renameGo = ui:Find("Offset/Top/ButtonOK").gameObject;
    self._renameInputCollider = ui:FindComponent("BoxCollider","Offset/Top/InputName")

    self._memberCountLabel  = ui:FindComponent("UILabel","Offset/Bottom/LabelCount");
    self._quitOrDismissLabel = ui:FindComponent("UILabel","Offset/Bottom/ButtonDismiss/Name");
    self._quitOrDismissEvent = ui:FindComponent("UIEvent","Offset/Bottom/ButtonDismiss");

end

function mBasicPanel:OnEnable()
    if mQun:IsMyQun() then
        self._renameGo:SetActive(true);
        self._renameInputCollider.enabled = true;
        
        self._quitOrDismissLabel.text = WordData.GetWordStringByKey("friend_qun_button_dismiss");--解散群组按钮
        self._quitOrDismissEvent.id = 3;
    else
        self._renameGo:SetActive(false);
        self._renameInputCollider.enabled = false;
        self._quitOrDismissLabel.text = WordData.GetWordStringByKey("friend_qun_button_quit");--退出群组按钮
        self._quitOrDismissEvent.id = 4;
    end
    self:UpdateName();
    self:UpdateCount();
end

function mBasicPanel:OnClick(id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_QunInfo);
    elseif id == 1 then
        if self._nameInput:CheckValid() then
            local name = self._nameInput:GetValue();
            ChatMgr.RequestChangeCligroupName( mQun,name );
        end
    elseif id == 2 then
        UI_Friend_QunAddPlayer.ShowQun(mQun);
        UIMgr.UnShowUI(AllUI.UI_Friend_QunInfo);
    elseif id == 3 then
        TipsMgr.TipConfirmByKey("friend_qun_dismiss_ensure",DismissQun,nil,mQun:GetName());--群组信息，解散群确认
    elseif id == 4 then
        TipsMgr.TipConfirmByKey("friend_qun_quit_ensure",QuitQun,nil,mQun:GetName());--群组信息，退出群确认
    elseif id == 5 then
        TipsMgr.TipByFormat("Share My Qun");--
    end
end

function mBasicPanel:UpdateName()
    self._nameInput:SetInitText(mQun:GetName());
end
function mBasicPanel:UpdateCount()
    local currentCount,maxCount = mQun:GetCurrentMaxCapacity();
    self._memberCountLabel.text = string.format("%s/%s",currentCount, maxCount);
end


local function SortFunc(a,b)
    if mQun:IsOwner(a) then
        return true;
    elseif mQun:IsOwner(b) then
        return false;
    elseif mQun:IsAdmin(a) then
        return true;
    elseif mQun:IsAdmin(b) then
        return false;
    elseif a:IsSelf() then
        return true;
    elseif b:IsSelf() then
        return false;
    elseif a:IsOnline() then
        return true;
    elseif b:IsOnline() then 
        return false;
    end
    return false;
end


function mFriendPanel:Init(ui)
    local path = "Offset/Center/ScrollView";

    self._wrapTable = BaseWrapContentEx.new(ui,path,6,WrapUIFriendQunMemberInfo,1,self);
    self._wrapTable:SetUIEvent(200,5,{self.OnAddAdmin,self.OnRemoveAdmin,self.OnDeleteMember},self);

end

function mFriendPanel:OnEnable()
    self._wrapDatas = mQun:GetAllMembers();
    table.sort(self._wrapDatas,SortFunc);
    self._wrapTable:ResetWithData(self._wrapDatas);
end

function mFriendPanel:OnDisable()
    self._wrapTable:ReleaseData();
end

function mFriendPanel:OnClick(id)
    if id >= 200 then
        self._wrapTable:OnClick(id);
    end
end

function mFriendPanel:OnAddAdmin(player)
    ChatMgr.RequestSetCligroupAdmin(mQun,player,true);
end

function mFriendPanel:OnRemoveAdmin(player)
    ChatMgr.RequestSetCligroupAdmin(mQun,player,false);
end


function mFriendPanel:OnDeleteMember(player)
    local function DeleteMember()
        ChatMgr.RequestLeaveCligroup(mQun, player);
    end
    TipsMgr.TipConfirmByKey("friend_qun_delete_memeber",DeleteMember,nil,mQun:GetName(),player:GetRemark());--群组信息，删除成员确认
    
end

function mFriendPanel:AddMember(player)
    self._wrapDatas[#self._wrapDatas+1] = player;
    table.sort(self._wrapDatas,SortFunc);
    self._wrapTable:ResetWithPosition(self._wrapDatas);
end
function mFriendPanel:RemoveMember(player)
    for i=1,#self._wrapDatas do
        if self._wrapDatas[i] == player then
            table.remove(self._wrapDatas,i);
        end
    end
    self._wrapTable:ResetWithPosition(self._wrapDatas);
end
function mFriendPanel:AdminChange()
    table.sort(self._wrapDatas,SortFunc);
    self._wrapTable:ResetWithPosition(self._wrapDatas);
end

function mFriendPanel:GetQun()
    return mQun;
end
