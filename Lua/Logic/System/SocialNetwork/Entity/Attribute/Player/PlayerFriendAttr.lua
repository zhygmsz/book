--[[
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerFriendAttr = class("PlayerFriendAttr",PlayerBaseAttr);

function PlayerFriendAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 1;
    self._remark = nil;
    self._isnpc = false;
    self._group = nil;
    self._unrequitedLover = nil;
    self._isBlack = nil;
    self._recvAutoReply = true;
end

function PlayerFriendAttr:RequestSyncAttr()
    local function OnSyncFriendAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    local param = "tpid="..self._id;
    SocialNetworkMgr.RequestAction("AskFriendInfo",param,OnSyncFriendAttr);
end

--"intimacy":"0","heat":"0","heat_mtime":"0","isnpc":"0","tpid":"10000055","playerid":"10000055","device_id":"10000055"
function PlayerFriendAttr:Refresh(data)
    self.super.Refresh(self);
    self._remark = data.remark;
    self._isnpc = data.isnpc ~="0" and true or false;
    self._blackTime = nil;

    self._intimacy = tonumber(data.intimacy);
    self._realTable.heat = tonumber(data.heat);
    self._realTable.heat_mtime = tonumber(data.heat_mtime);
end

function PlayerFriendAttr:SetRemark(remark)
    if remark == self._remark then return; end
    self._remark = remark;
    GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
end

function PlayerFriendAttr:GetRemark()
    return self._remark;
end

function PlayerFriendAttr:SetIntimacy(value)
    self._intimacy = value;
end

function PlayerFriendAttr:GetIntimacy()
    return self._intimacy or 0;
end

function PlayerFriendAttr:GetHeat()
    return self._proxy.heat or 0;
end

function PlayerFriendAttr:GetHeatMTime()
    return self._proxy.heat_mtime or 0;
end

function PlayerFriendAttr:IsNPC()
    return self._isnpc and true or false;
end

--暗恋对象
function PlayerFriendAttr:SetUnrequitedLover(value)
    if value == self._unrequitedLover then return; end
    self._unrequitedLover = value;
    GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_UNREQUITED_LOVER,self._player);
end

function PlayerFriendAttr:IsUnrequitedLover()
    return self._unrequitedLover;
end

--好友分组
function PlayerFriendAttr:SetGroup(group)
    if self._group then
        if self._group == group then return; end
        self._group:RemoveMember(self._player);
    end
    self._group = group;
    group:AddMember(self._player);
end

function PlayerFriendAttr:GetGroup()
    if not self._group then
        FriendMgr.GetGroupStranger():AddMember(self._player);
    end
    return self._group;
end

function PlayerFriendAttr:SetInBlackList(value)
    if self._isBlack == value then return; end
    self._isBlack = value;

    if value then 
        self._blackTime = TimeUtils.SystemTimeStamp(true);
        
    else
        self._blackTime = nil;
        
    end

    GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_BLACKLIST,self._player);
end

function PlayerFriendAttr:IsInBlackList()
    return self._isBlack and true or false;
end

function PlayerFriendAttr:GetBlackTime()
    return self._blackTime or 0 ;
end

function PlayerFriendAttr:IsFriend()
    if self._isBlack then return false; end
    if not self._group then return false; end
    return self._group:GetID() >=0 and self._group:GetID()<=9;
end

function PlayerFriendAttr:IsFollow()
    if self._isBlack then return false; end
    if not self._group then return false; end
    return self._group:GetID() == FriendMgr.FRIENDGROUP.FOLLOW;
end
function PlayerFriendAttr:IsFan()
    if self._isBlack then return false; end
    if not self._group then return false; end
    return self._group:GetID() == FriendMgr.FRIENDGROUP.FAN;
end
function PlayerFriendAttr:IsStranger()
    if not self._group then return true; end
    return self._group:GetID() == FriendMgr.FRIENDGROUP.STRANGER;
end
function PlayerFriendAttr:IsNPCFriend()
    if self._isBlack then return false; end
    if not self._group then return true; end
    return self._isnpc and self._group:GetID() >=0 and self._group:GetID()<=9 ;
end
function PlayerFriendAttr:IsNPCStranger()
    return self._isnpc and self:IsStranger();
end

--共同好友
function PlayerFriendAttr:GetShareFriends()
    return table.emptyTable;
end

--离线时是否接受自动回复
function PlayerFriendAttr:GetRecvOfflineAutoReply()
    return self._recvAutoReply;
end
function PlayerFriendAttr:SetRecvOfflineAutoReply(value)
    self._recvAutoReply = value;
end

return PlayerFriendAttr;