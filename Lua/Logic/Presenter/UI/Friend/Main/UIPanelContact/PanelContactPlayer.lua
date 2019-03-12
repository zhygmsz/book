local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/UIPanelContactBase")
local PanelContactPlayer = class("PanelContactPlayer",Base);

---------子UI使用和驱动
function PanelContactPlayer:OnGroupSelected(group,wrapui)
    if self._selectedGroup == group then 
        self._selectedGroup = nil; 
    else
        self._selectedGroup = group;
    end
    for i = #self._tableDataList,1,-1 do
        local cname = self._tableDataList[i].__cname;
        if cname == "SocialPlayer" then
            table.remove(self._tableDataList,i);
        end
    end
    
    local showIndex = nil;
    for i = 1, #self._tableDataList do
        if self._tableDataList[i] == group then
            showIndex = i;
            break;
        end
    end

    if showIndex and self._selectedGroup then
        local members = group:GetAllMembers();
        for i = #members,1,-1 do
            table.insert(self._tableDataList,showIndex+1,members[i]);
        end
    end
    self._collapseTable:ResetAllWithShowData(self._tableDataList,showIndex or 1);
end

function PanelContactPlayer:IsGroupSelected(group)
    return self._selectedGroup == group;
end

---------事件驱动-----------
function PanelContactPlayer:RefreshGroup(group)
    if group and group == self._selectedGroup then
        self:UpdateAllTableData();
    else
        self._collapseTable:RefreshUIWithData(group);
    end
end

function PanelContactPlayer:OnUpdateGroupInfo(group)
    self._collapseTable:RefreshUIWithData(group);
end

function PanelContactPlayer:OnUpdateGroupMemberCount(group1,group2)
    self:RefreshGroup(group1);
    if group2 then self:RefreshGroup(group2);end
end

function PanelContactPlayer:OnUpdateGroupCount(group)
    self:UpdateAllTableData();
end

function PanelContactPlayer:OnUpdateBlackList(player)
    local selfGroup = player:GetFriendAttr():GetGroup();
    local groupBlack = FriendMgr.GetGroupBlack();
    self:RefreshGroup(selfGroup);
    self:RefreshGroup(groupBlack);
end
        
function PanelContactPlayer:OnUpdateAllRelationInfo()
    self:UpdateAllTableData();
end

function PanelContactPlayer:ctor(ui,path)
    self.super.ctor(self, ui,path)
    
    local WrapUIGroupContent = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIGroupContent");
    local WrapUIPlayer = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIPlayer");
    local WrapUIGroupAdd = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIGroupAdd");
    local wrapUIs = {WrapUIGroupContent,WrapUIPlayer,WrapUIGroupAdd};
    self._collapseTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,self._baseEvent,5,self);
    
    self._collapseTable:RegisterData("FriendGroupBlack","WrapUIGroupContent",60);
    self._collapseTable:RegisterData("FriendGroupFan","WrapUIGroupContent",60);
    self._collapseTable:RegisterData("FriendGroupFollow","WrapUIGroupContent",60);
    self._collapseTable:RegisterData("FriendGroupFriend","WrapUIGroupContent",60);
    self._collapseTable:RegisterData("SocialPlayer","WrapUIPlayer",90);
    self._selectedGroup = nil;

    local searchInput = ui:FindComponent("LuaUIInput",path.."/Search/Input");
    local searchInputUIEvent = ui:FindComponent("UIEvent",path.."/Search/Input");
    local searchSearchUIEvent = ui:FindComponent("UIEvent",path.."/Search/Icon");
    local searchClearUIEvent = ui:FindComponent("UIEvent",path.."/Search/Clear");
    self._searchDeleteGo = ui:FindGo(path.."/Search/Clear");
    self._searchInput = searchInput;
    searchInputUIEvent.id = 2000;
    searchSearchUIEvent.id = 2001;
    searchClearUIEvent.id = 2002;
    self._searchDeleteGo:SetActive(false);

    EventDelegate.Set(searchInput.onChange,EventDelegate.Callback(self.SearchPlayer,self));
    self._groupAdd = UICommonCollapseWrapData.new("WrapUIGroupAdd",nil,60);
end

function PanelContactPlayer:OnEnable()
    
    self.super.OnEnable(self);

    self._searchInput.value = "";
    
    self:UpdateAllTableData();

    UI_Friend_Main.ShowChat(self._selectedMember);
    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_REGROUP_INFO,self.OnUpdateGroupInfo,self);     --改变更新分组信息；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_REGROUP_MEMBERCOUNT,self.OnUpdateGroupMemberCount,self);     --改变分组成员数量；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,self.OnUpdateGroupCount,self);     --改变分组数量；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_REGROUP_BLACKLIST,self.OnUpdateBlackList,self); --改变黑名单;
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_SYNC_ALL_RELATION,self.OnUpdateAllRelationInfo,self);     --更新所有好友数据；
end

function PanelContactPlayer:OnDisable()
    self.super.OnDisable(self);
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_REGROUP_INFO,self.OnUpdateGroupInfo,self);
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_REGROUP_MEMBERCOUNT,self.OnUpdateGroupMemberCount,self);
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,self.OnUpdateGroupCount,self);
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_REGROUP_BLACKLIST,self.OnUpdateBlackList,self); --改变黑名单;
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_SYNC_ALL_RELATION,self.OnUpdateAllRelationInfo,self);  
end

function PanelContactPlayer:OnDestroy( )
    self._collapseTable = nil;
    self._searchInput = nil;
    self._groupAdd = nil;
end
function PanelContactPlayer:OnClick(id)
    if not self.super.CheckClick(self,id) then
        return;
    end
    if id == 2001 then
        self:SearchPlayer(true);
    end
    if id == 2002 then
        self:ClearInput();
    end
end

---------search---------------
function PanelContactPlayer:ClearInput()
    self._searchInput.value = "";
end

function PanelContactPlayer:SearchPlayer(force)
    local inputStr = self._searchInput.value;
    if (not force) and self._inputStr == inputStr then
        return;
    end
    self._inputStr = inputStr;
    if (not inputStr) or inputStr == "" then
        self._collapseTable:ResetAll(self._tableDataList);
        self._searchDeleteGo:SetActive(false);
    else
        local dataList = FriendMgr.GetMembersBySearchStr(inputStr);
        self._collapseTable:ResetAll(dataList);
        self._searchDeleteGo:SetActive(true);
    end
end

----------Wraptable-------------
function PanelContactPlayer:UpdateAllTableData()
    local groups = FriendMgr.GetGroupFriends();

    self._tableDataList = groups;
    local myFriendG = groups[1];
    table.remove(groups,1);

    table.insert(groups,myFriendG);

    if #groups < 10 then
        groups[#groups + 1] = self._groupAdd;
    end

    groups[#groups + 1] = FriendMgr.GetGroupFollow();
    groups[#groups + 1] = FriendMgr.GetGroupFan();
    groups[#groups + 1] = FriendMgr.GetGroupBlack();
    
    if not self._selectedGroup then
        self._collapseTable:ResetAll(self._tableDataList);
        return;
    end

    local showIndex = nil;
    for i = 1, #groups do
        if groups[i] == self._selectedGroup then
            showIndex = i;
            break;
        end
    end
    if showIndex then
        local members = self._selectedGroup:GetAllMembers();
        for i =1,#members do
            table.insert(groups,showIndex+1,members[i]);
        end
    end
    
    self._collapseTable:ResetAllWithShowData(groups,showIndex or 1);
end

return PanelContactPlayer;
