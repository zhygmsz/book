--[[
    author:{hesinian}
    time:2019-01-21 18:24:38
]]

local PlayerFriendAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerFriendAttr");
local PlayerSelfFriendAttr = class("PlayerSelfFriendAttr",PlayerFriendAttr);

function PlayerSelfFriendAttr:ctor(player)
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
end

function PlayerSelfFriendAttr:GetIntimacy()
    return 0;
end

function PlayerSelfFriendAttr:GetHeat()
    return 0;
end

function PlayerSelfFriendAttr:GetHeatMTime()
    return 0;
end

--共同好友数量
function PlayerSelfFriendAttr:GetShareFriends()
    return table.emptyTable;
end


return PlayerSelfFriendAttr;