FriendGroupBase = class("FriendGroupBase");

function FriendGroupBase:ctor(id)
    self._id = id;
    self._memberTable = {};
end

function FriendGroupBase:SetName(name,tip)
    if self._name and self._name ~= "" then
        self._name = name;
        if name == "" then--删除分组
            GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,self);
            if tip then
                TipsMgr.TipByKey("friend_group_delete_success");--分组删除成功
            end
        else--修改名字
            GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_INFO,self);
        end
    elseif name ~= "" then--新建分组
        self._name = name;
        GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,self);
        if tip then
            TipsMgr.TipByKey("friend_group_add_sucess");--分组创建成功
        end
    end
end

function FriendGroupBase:GetName()
    return self._name or "";
end

function FriendGroupBase:GetID()
    return self._id;
end
local function SortFunc(a,b)
    if (a:IsHusbandWife() ~= b:IsHusbandWife()) then return a:IsHusbandWife(); end
    if (a:IsMaster() ~= b:IsMaster()) then return a:IsMaster(); end
    if (a:IsApprentice() ~= b:IsApprentice()) then return a:IsApprentice(); end
    if (a:IsBrothers() ~= b:IsBrothers()) then return a:IsBrothers(); end    
    if (a:IsOnline() ~= b:IsOnline()) then return a:IsOnline(); end
    if (a:GetIntimacy() ~= b:GetIntimacy()) then return a:GetIntimacy();end
    return a:GetLevel() > b:GetLevel();
end
--不包括NPC,不包括黑名单
function FriendGroupBase:GetAllMembers()
    local list = {};
    for id,member in pairs(self._memberTable) do
        table.insert(list,member);
    end
    table.sort(list,SortFunc);
    return list;
end

function FriendGroupBase:GetMemberCount()
    local count = 0;
    for id, member in pairs(self._memberTable) do
        count = count + 1;
    end
    return count;
end

function FriendGroupBase:GetAllMembersWithBlack()
    local list = {};
    for id,member in pairs(self._memberTable) do
        table.insert(list,member);
    end
    return list;
end
--自定义条件
function FriendGroupBase:GetAllMembersWithCondition(Condition)
    local list = {};
    for id,member in pairs(self._memberTable) do
        if Condition(member) then
            table.insert(list,member);
        end
    end
    return list;
end

function FriendGroupBase:GetMemberByID(mid)
    return self._memberTable[mid];
end

function FriendGroupBase:ClearMembers(groupStranger)
    for _, mem in pairs(self._memberTable) do
        groupStranger:AddMember(mem);
    end
    self._memberTable = {};
end

function FriendGroupBase:AddMember(member,quiet)
    local fid = member:GetID();
    self._memberTable[fid] = member;
    member:GetFriendAttr():SetGroup(self);
    self:OnAddMember(member);
    
    if not quiet then
        GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_MEMBERCOUNT,self);
    end
end

function FriendGroupBase:OnAddMember(member )
    member:GetFriendAttr():SetIntimacy(0);
end

function FriendGroupBase:RemoveMember(member,quiet)
    local fid = member:GetID();
    self._memberTable[fid] = nil;
    if not quiet then
        GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_MEMBERCOUNT,self);
    end
end

function FriendGroupBase:ContainMember(member)
    local fid = member:GetID();
    return self._memberTable[fid] ~= nil;
end

function FriendGroupBase:GetAll_Online_MemberCount()
    local count = 0;
    local online = 0;
    for id,member in pairs(self._memberTable) do
        if member:IsOnline() then
            online = online + 1;
        end
        count = count + 1;
    end
    return online, count;
end

function FriendGroupBase:IsInUse()
    return true;
end

function FriendGroupBase:IsEditable()
    return false;
end

function FriendGroupBase:IsGroupFriend()
    return self._id <= FriendMgr.FRIENDGROUP.LASTFRIEND;
end

return FriendGroupBase;