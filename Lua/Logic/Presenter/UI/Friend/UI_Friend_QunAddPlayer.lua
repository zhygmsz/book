module("UI_Friend_QunAddPlayer",package.seeall)

local mQun;
local mSelctedFriends;
local mSelectedCount;
local mSelectedGroup;
local mSelectedGroupAll;

local mAllFriends;

local mGroupList;
local mWrapTable;

local mGroupMemberTable;

local mBasicPanel;
local mPanelNoneGo;
local mPanelFriendGo;

local mToggleGroup;
local mToggleSelectAll;
local function SetToggleSelectAll(value)
    if value ~= mToggleSelectAll then
        mBasicPanel.allSelectGo:SetActive(value);
        mToggleSelectAll = value;
    end
end

local function SetSelectedFriend(friend, value)
    mSelctedFriends[friend] = value;
    if not value then
        SetToggleSelectAll(false);
    end
end

--按照设置显示分组或者不显示分组
local function ShowTableAsSetting()
    if #mAllFriends == 0 then return; end
    if mToggleGroup then
        mWrapTable:ResetAll(mGroupList);
    else
        mWrapTable:ResetAll(mAllFriends);
    end
end

local function UpdateSelectCount()
    mBasicPanel.askCountLabel.text = tostring(mSelectedCount);
end

local function SearchPlayer()
    local inputStr = mBasicPanel.searchInput.value;
    if (not inputStr) or (inputStr == "") then
        ShowTableAsSetting();
    else
        local dataList = {};
        for i, friend in ipairs(mAllFriends) do
            if friend:FullfillSearch(inputStr) then
                table.insert(dataList,friend);
            end
        end
        mWrapTable:ResetAll(dataList);
    end
end

local function FriendCondition(mem)
    if not mem:IsFriend() then return false; end
    if mQun:IsMember(mem) then return false; end
    return tonumber(mem:GetLevel()) >= 0;--(ConfigData.GetIntValue("friend_qun_add_condition_level") or 0); --群邀请好友等级限制
end

local function InitGroupMemberTable(groups)
    mGroupMemberTable = {};
    for i,group in ipairs(groups) do
        mGroupMemberTable[group] = group:GetAllMembersWithCondition(FriendCondition);
    end
end

--初始化带Group的WrapTable
local function InitTableWithGroup()
    local groups = FriendMgr.GetGroupFriends();
    mGroupList = groups;
    local myFriendG = groups[1];
    table.remove(groups,1);

    table.insert(groups,myFriendG);
    
    InitGroupMemberTable(groups);

    if not mSelectedGroup then
        mWrapTable:ResetAll(mGroupList);
        return;
    end

    local showIndex = nil;
    for i = 1, #groups do
        if groups[i] == mSelectedGroup then
            showIndex = i;
            break;
        end
    end
    if showIndex then
        local members = mGroupMemberTable[mSelectedGroup];
        for i =1,#members do
            table.insert(groups,i+1,members[i]);
        end
    end
    mWrapTable:ResetAllWithShowData(groups,showIndex or 1);
end

local function OnGroupClick()
    mToggleGroup = not mToggleGroup;
    mBasicPanel.groupSelectGo:SetActive(mToggleGroup);
    ShowTableAsSetting();
end
--全选
local function OnFriendAllClick()

    SetToggleSelectAll(not mToggleSelectAll);
    if #mAllFriends == 0 then return; end
    mSelectedCount = 0;

    for i, friend in ipairs(mAllFriends) do
        SetSelectedFriend(friend,mToggleSelectAll);
        if mToggleSelectAll then
            mSelectedCount = mSelectedCount + 1;
        end
    end
    UpdateSelectCount();

    local allGroups = FriendMgr.GetGroupFriends();
    for i, group in ipairs(allGroups) do
        mSelectedGroupAll[group] = mToggleSelectAll;
    end
    mWrapTable:UpdateWithPosition();
end
---------子UI使用和驱动
function OnFriendSelected(friend,wrapUI)
    SetSelectedFriend(friend,not mSelctedFriends[friend]);
    mSelectedCount = mSelctedFriends[friend] and mSelectedCount + 1 or mSelectedCount -1;
    UpdateSelectCount();
    wrapUI:OnRefresh();
end
function IsFriendSelected(friend)
    return mSelctedFriends[friend] and true or false;
end

function OnGroupSelected(group,wrapUI)
    if mSelectedGroup == group then return; end
    mSelectedGroup = group;
    for i = #mGroupList,1,-1 do
        local cname = mGroupList[i].__cname;
        if cname == "SocialPlayer" then
            table.remove(mGroupList,i);
        end
    end
    local showIndex = nil;
    for i = 1, #mGroupList do
        if mGroupList[i] == group then
            showIndex = i;
            break;
        end
    end
    if showIndex then
        local members = mGroupMemberTable[group]
        for i = #members,1,-1 do
            table.insert(mGroupList,showIndex+1,members[i]);
        end
    else
        GameLog.LogError("Not found selected group (gid=%s)",group:GetID());
    end
    mWrapTable:ResetAllWithShowData(mGroupList,showIndex or 1);
end

function IsGroupSelected(group)
    return mSelectedGroup == group;
end

function OnGroupAllSelected(group,wrapUI)
    mSelectedGroupAll[group] = not mSelectedGroupAll[group];
    local members = mGroupMemberTable[group];

    for i,friend in ipairs(members) do
        SetSelectedFriend(friend,mSelectedGroupAll[group]);
    end
    mSelectedCount = 0;
    for friend,b in pairs(mSelctedFriends) do
        if b then
            mSelectedCount = mSelectedCount + 1;
        end
    end
    UpdateSelectCount();
    mWrapTable:UpdateWithPosition();
end

function IsGroupAllSelected(group)
    return mSelectedGroupAll[group];
end

function GetAll_Online_MemberCount(group)
    local count = 0;
    for i,player in ipairs(mGroupMemberTable) do
        if player:IsOnline() then
            count = count + 1;
        end
    end
    return count, #mGroupMemberTable[group];
end


function OnCreate(ui)
    mBasicPanel = {};
    mBasicPanel.searchInput = ui:FindComponent("LuaUIInput","Offset/Top/InputName");
    mBasicPanel.askCountLabel = ui:FindComponent("UILabel","Offset/Top/LabelCount");

    mBasicPanel.memberCountLabel  = ui:FindComponent("UILabel","Offset/Bottom/LabelCount");
    mBasicPanel.noticeLabel = ui:FindComponent("UILabel","Offset/Bottom/LabelNotice");
    mBasicPanel.allSelectGo = ui:Find("Offset/Bottom/ToggleSelect/Active").gameObject;
    mBasicPanel.groupSelectGo = ui:Find("Offset/Top/ToggleSelect/Active").gameObject;

    EventDelegate.Set(mBasicPanel.searchInput.onChange,EventDelegate.Callback(SearchPlayer));


    path = "Offset/Center/DragAreaNone";
    mPanelNoneGo =  ui:Find(path).gameObject;

    local path = "Offset/Center/DragAreaFriend";
    mPanelFriendGo = ui:Find(path).gameObject;

    local WrapUIQunGroupContent = require("Logic/Presenter/UI/Friend/QunAddPlayer/WrapUIQunGroupContent");
    local WrapUIQunPlayer = require("Logic/Presenter/UI/Friend/QunAddPlayer/WrapUIQunPlayer");
    local wrapUIs = {WrapUIQunGroupContent,WrapUIQunPlayer};
    mWrapTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,200,5,UI_Friend_QunAddPlayer);
    
    mWrapTable:RegisterData("FriendGroupFriend","WrapUIQunGroupContent",62);
    mWrapTable:RegisterData("SocialPlayer","WrapUIQunPlayer",97);

end

function OnEnable(ui)
    mSelctedFriends = {};
    mSelectedCount = 0;
    UpdateSelectCount();
    mSelectedGroup = nil;
    mSelectedGroupAll = {};

    mAllFriends = FriendMgr.GetMembersWithCondition(FriendCondition);
    mPanelNoneGo:SetActive(#mAllFriends==0);
    mPanelFriendGo:SetActive(#mAllFriends>0);

    local currentCount, maxCount = mQun:GetCurrentMaxCapacity();
    mBasicPanel.memberCountLabel.text = string.format("%s/%s",currentCount, maxCount);
    mBasicPanel.noticeLabel.text = WordData.GetWordStringByKey("friend_add_player_notice");--群添加好友

    mToggleGroup = true;
    mBasicPanel.groupSelectGo:SetActive(mToggleGroup);

    SetToggleSelectAll(false);
    mBasicPanel.allSelectGo:SetActive(mToggleSelectAll);

    if #mAllFriends>0 then
        InitTableWithGroup();
    end
end

function OnDisable(ui)
    mSelctedFriends = nil;
    mSelectedCount = 0;
    mSelectedGroup = nil;
    mSelectedGroupAll = nil;
end

function OnClick(go, id)

    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_QunAddPlayer);
    elseif id == 1 then
        --发出邀请
        local hasAny = false;
        for friend,b in pairs(mSelctedFriends) do
            if b then
                hasAny = true;
                ChatMgr.SendJoinCligroup(mQun, friend);
            end
        end
        if not hasAny then
            TipsMgr.TipByKey("friend_qun_add_player_select_none");--群邀请没有选任何玩家提醒
            return;
        end
        UIMgr.UnShowUI(AllUI.UI_Friend_QunAddPlayer);
    elseif id == 2 then
        SearchPlayer();
    elseif id == 3 then
        OnFriendAllClick();
    elseif id == 4 then
        OnGroupClick();
    elseif id >= 200 then
        mWrapTable:OnClick(id);
    end
end

function ShowQun(qun)
    mQun = qun;
    UIMgr.ShowUI(AllUI.UI_Friend_QunAddPlayer);
end