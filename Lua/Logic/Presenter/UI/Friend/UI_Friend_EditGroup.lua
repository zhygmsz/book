
module("UI_Friend_EditGroup",package.seeall);
local WrapUIFriendGroupMember = require("Logic/Presenter/UI/Friend/EditGroup/WrapUIFriendGroupMember");

local mBasicInfo = {};

local mAllFriendTable;
local mWrapDatas;
local mSelectedData;

local mNewCount;
local mFriendsInThisGroup;
local mGroup ;

local function SendModifyGroup()    
    local newName = mBasicInfo.nameInput:GetValue();
    
    if mGroup:GetName() ~= newName then
        if not mBasicInfo.nameInput:CheckValid() then return; end
        if FriendMgr.CheckRepeatName(newName) then TipsMgr.TipByKey("friend_group_name_repeat");return; end--分组名称不能重名
        FriendMgr.RequestModifyFriendGroupName(mGroup,newName);
    end

    for i,player in ipairs(mFriendsInThisGroup) do
        if not mSelectedData[player] then
            FriendMgr.RequestMoveOutFromCustomGroup(player);
        else
            mSelectedData[player] = nil;
        end
    end
    for player,selected in pairs(mSelectedData) do
        if selected then
            FriendMgr.RequestSetFriend2Group(player, mGroup);
        end
    end
    UIMgr.UnShowUI(AllUI.UI_Friend_EditGroup);
end

local function UpdateCount()

    mBasicInfo.newFriendLabel.text = string.format("%s:%s",WordData.GetWordStringByKey("friend_group_new_count"),mNewCount);--好友分组，新加好友
    local containedCount = 0;
    for i, friend in ipairs(mFriendsInThisGroup) do
        if mSelectedData[friend] then
            containedCount  = containedCount +1;
        end
    end
    mBasicInfo.friendContainedLabel.text = string.format("%s:%s",WordData.GetWordStringByKey("friend_in_group_count"),containedCount);--好友分组，分组中好友
end

local function DeleteGroup()
    FriendMgr.RequestDeleteGroup(mGroup);
    UIMgr.UnShowUI(AllUI.UI_Friend_EditGroup);
end

local function OnPlayerClick(player,wrapUI)
    mSelectedData[player] = not mSelectedData[player];
    wrapUI:OnRefresh();
    if not mGroup:ContainMember(player) then
        if mSelectedData[player] then
            mNewCount = mNewCount + 1;
        else
            mNewCount = mNewCount - 1;
        end
    end
    UpdateCount();
end

function IsPlayerInGroup(player)
    return player:GetFriendAttr():GetGroup() == mGroup ;
end

function IsPlayerSelected(player)
    return mSelectedData[player];
end

function ShowGroup(group)
    GameLog.Log("UI_Friend_EditGroup");
    mGroup = group or FriendMgr.GetOneUnuseGroupFriend();
    if not mGroup then return; end
    UIMgr.ShowUI(AllUI.UI_Friend_EditGroup);
end

function OnCreate(ui)
    local path = "Offset/Bg/BasicInfo";
    mBasicInfo.friendContainedLabel = ui:FindComponent("UILabel",path.."/LabelNotice1");
    mBasicInfo.newFriendLabel = ui:FindComponent("UILabel",path.."/LabelNotice2");
    local limitCount = ConfigData.GetIntValue("friend_group_name_limit") or 6;--好友分组名长度
    mBasicInfo.nameInput = UICommonLuaInput.new(ui:FindComponent("LuaUIInput",path.."/Input/Input"),limitCount);
    mBasicInfo.nameLabel = ui:FindComponent("UILabel",path.."/Input/Label");
    local ensureEvent = ui:FindComponent("UIEvent",path.."/ButtonGridBottom/ButtonEnsure");
    local deleteEvent = ui:FindComponent("UIEvent",path.."/ButtonGridBottom/ButtonDelete");
    mBasicInfo.deleteGo = ui:Find(path.."/ButtonGridBottom/ButtonDelete").gameObject;
    mBasicInfo.titleLabel = ui:FindComponent("UILabel","Bg (4)/Title");
    ensureEvent.id = 11;
    deleteEvent.id = 12;

    path = "Offset/Bg/DragAreaFriend/Scroll View";
    mAllFriendTable = BaseWrapContentEx.new(ui,path,12,WrapUIFriendGroupMember,2,UI_Friend_EditGroup);
    mAllFriendTable:SetUIEvent(200,1,{OnPlayerClick});

    mBasicInfo.nameInput:SetInvalidChars(WordData.GetWordStringByKey("friend_editgroup_invaid_chars"));--"%s, ,%d"模式匹配非法字符
end

function OnEnable(ui)
    mFriendsInThisGroup = mGroup:GetAllMembers();

    mNewCount = 0;
    local inUse = mGroup:IsInUse();
    if inUse then
        mBasicInfo.nameInput:SetInitText(mGroup:GetName());
        mBasicInfo.titleLabel.text = WordData.GetWordStringByKey("friend_edit_group");--编辑分组
        mBasicInfo.deleteGo:SetActive(true);
    else
        mBasicInfo.nameInput:SetInitText("");
        mBasicInfo.nameInput:SetValue(FriendMgr.GetDefaultGroupName());
        mBasicInfo.titleLabel.text = WordData.GetWordStringByKey("friend_new_group");--新建分组
        mBasicInfo.deleteGo:SetActive(false);
    end

    mSelectedData = {};
    mWrapDatas = FriendMgr.GetAllFriendsUngrouped();
   
    for i,v in ipairs(mFriendsInThisGroup) do
        table.insert(mWrapDatas, v);
        mSelectedData[v] = true;
    end
    mAllFriendTable:ResetWithData(mWrapDatas);
    UpdateCount();
end

function OnDisable(ui)
    mNewCount = nil;
    mGroup = nil;
    mSelectedData = nil;
    mWrapDatas = nil;
    mFriendsInThisGroup = nil;

    mAllFriendTable:ReleaseData();
end

function OnClick(go,id)
    GameLog.Log("Button %s On Click %s",go.name, id);
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_EditGroup);
    elseif id == 11 then
        SendModifyGroup();
        
    elseif id == 12 then
        TipsMgr.TipConfirmByStr(string.format("friend_group_delete_ensure",mGroup:GetName()),DeleteGroup,nil);--删除分组确认
    elseif id >= 200 then
        mAllFriendTable:OnClick(id);
    end
end


