--[[
    玩家性别，星座，生日信息
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerPrivateAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerPrivateAttr");
local PlayerSelfPrivateAttr = class("PlayerSelfPrivateAttr",PlayerPrivateAttr)

function PlayerSelfPrivateAttr:ctor(player)
    PlayerBaseAttr.ctor(self, player);
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
end

function PlayerSelfPrivateAttr:Refresh(data)
    PlayerBaseAttr.Refresh(self,data);
    if data==nil then return  end
    self._proxy.star = tonumber(tag["61"]);
    self._proxy.gender = tonumber(tag["60"]);
    self._proxy.birth = tonumber(tag["69"]);
end

--社交生日                                                            
function PlayerSelfPrivateAttr:SetBirthdayBySecond(value)
    if self._proxy.birth == value then return; end
    self._proxy.birth = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF,EVT.PLAYER_BIRTHDAY,value);
end

--社交性别--1男2女3保密
function PlayerSelfPrivateAttr:SetGender(value)
    if self._proxy.gender == value then return; end
    self._proxy.gender = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF,EVT.PLAYER_GENDER,value);
end

--社交星座
function PlayerSelfPrivateAttr:SetStar(value)
    if self._proxy.star == value then return; end
    self._proxy.star = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF,EVT.PLAYER_STAR,value);
end

return PlayerSelfPrivateAttr;