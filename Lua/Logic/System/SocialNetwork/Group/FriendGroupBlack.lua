local FriendGroupBlack = class("FriendGroupBlack",FriendGroupBase);

function FriendGroupBlack:ctor(id)
    self.super.ctor(self,id);
end

function FriendGroupBlack:RemoveMember(mem)
    local fid = mem:GetID();
    self._memberTable[fid] = nil;
    mem:GetFriendAttr():SetInBlackList(false);
end
--黑名单不设置玩家group SetGroup
function FriendGroupBlack:AddMember(mem)
    local fid = mem:GetID();
    if self._memberTable[fid] then return; end
    self._memberTable[fid] = mem;
    mem:GetFriendAttr():SetGroup(self);
    mem:GetFriendAttr():SetInBlackList(true);
end

local function SortFunc(a,b)
    if (a:IsOnline() == b:IsOnline()) then
        return a:GetFriendAttr():GetBlackTime() > b:GetFriendAttr():GetBlackTime() ;
    end
    return a:IsOnline();
end

function FriendGroupBlack:GetAllMembers()
    local list = {};
    for id,member in pairs(self._memberTable) do
        table.insert(list,member);
    end
    table.sort(list,SortFunc);
    return list;
end

function FriendGroupBlack:GetAll_Online_MemberCount()
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

return FriendGroupBlack;