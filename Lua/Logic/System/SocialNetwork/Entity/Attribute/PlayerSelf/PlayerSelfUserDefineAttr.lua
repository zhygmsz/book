--[[
    玩家标签
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerUserDefineAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerUserDefineAttr");
local PlayerSelfUserDefineAttr = class("PlayerSelfUserDefineAttr",PlayerUserDefineAttr)

function PlayerSelfUserDefineAttr:ctor(player)
    PlayerBaseAttr.ctor(self, player);
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
end

function PlayerSelfUserDefineAttr:Refresh(characterTag)
    PlayerBaseAttr.Refresh(self,characterTag);
    if characterTag==nil then return  end

    self._proxy.characterTag ={}
    self._proxy.characterTagFromOther ={}
    self._proxy.systemTag ={}
    self._proxy.systemTagShowing ={}

    local datas = characterTag[self._id];
    for k,v in pairs(datas) do
        local index = tonumber(k)
        if index>=10000 and index <=10009 then
            table.insert(self._proxy.characterTag,v)
        elseif index>=10010 and index <=10019 then
            table.insert(self._proxy.characterTagFromOther,v)
        elseif index>=10020 and index <=10029 then
            table.insert(self._proxy.systemTagShowing,v)
        elseif index>=10030 and index <=10054 then
            table.insert(self._proxy.systemTag,v)
        end
    end
end

return PlayerSelfUserDefineAttr;