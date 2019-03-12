--[[
易变属性，几乎每个玩家的这些属性都会被调用，而且经常变化，所以单独归为一类
author:{hesinian}
time:2019-01-21 18:24:38
]]
local PlayerVolatileAttr = class("PlayerVolatileAttr",PlayerBaseAttr)

function PlayerVolatileAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 0.5;

    self._detailparams = 'playerid';--
    self._userparams = 'level';--等级 和 在线信息 OnlineStatus 默认存在
    --需要的 racialID, profesID, spouseID, 
end

function PlayerVolatileAttr:RequestSyncAttr()
    local function OnSyncFriendAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    local params = string.format("id=%s&detailparams=%s&usrdata_fields=%s",self._id, self._detailparams,self._userparams);
    SocialNetworkMgr.RequestAction("AskPlayerIndex",params,OnSyncFriendAttr);
end

function PlayerVolatileAttr:Refresh(data)
    self.super.Refresh(self);
    self._realTable.onlineStatus = data.OnlineStatus;
    self._realTable.level = tonumber(data.level);
end

function PlayerVolatileAttr:GetLevel()
    return self._proxy.level or 0;
end

--onlineStatus: true,false代表离线在线，值3表示在线离开
function PlayerVolatileAttr:IsOnline()
    if self._proxy.onlineStatus == true or tonumber(self._proxy.onlineStatus)==3 then return true; end
    return false;
end

function PlayerVolatileAttr:IsOnlineAndLeave()
    return tonumber(self._proxy.onlineStatus)==3 ;
end

function PlayerVolatileAttr:SetOnline(status)
    if self._realTable.onlineStatus == status then return; end
    self._realTable.onlineStatus = status;
    GameEvent.Trigger(EVT.SOCIAL,EVT.ON_OFF_LINE,self._player);
    -- body
end


return PlayerVolatileAttr;