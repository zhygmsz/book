--[[
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerUserDefineAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerVolatileAttr");
local PlayerSelfVolatileAttr = class("PlayerSelfVolatileAttr")

function PlayerSelfVolatileAttr:ctor(player)
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
end

function PlayerSelfVolatileAttr:GetLevel()
    return UserData.GetLevel();
end

function PlayerSelfVolatileAttr:IsOnline()
    return true;
end
function PlayerSelfVolatileAttr:IsOnlineAndLeave()
    return FriendMgr.GetLeaveState();
end

return PlayerSelfVolatileAttr;