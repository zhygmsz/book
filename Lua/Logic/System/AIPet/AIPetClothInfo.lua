--[[
    author:{hesinian}
    time:2019-01-03 11:24:08
]]
local AIPetClothInfo = class("AIPetClothInfo")

function AIPetClothInfo:ctor(info)
    
    self._id = info.id;
    self._pet = pet;
    self._ctype = info.subType[3];--所属部位
    self._expireTime = nil;
    self._info = info;
    self._item = ItemData.GetItemInfo(info.itemID);
end

function AIPetClothInfo:SetExpireTime(time)
    if self._expireTime ~= time then
        self._expireTime = time;
        GameEvent.Trigger(EVT.AIPET,EVT.AIPET_CLOTH_AVAILABLE,self);
    end
end

function AIPetClothInfo:IsClothAvailable( )
    return self._expireTime ~= nil;
end

function AIPetClothInfo:GetExpireTime( )
    return self._expireTime;
end

function AIPetClothInfo:GetPart( )
    return self._ctype;
end

function AIPetClothInfo:GetIcon()
    return self._item.icon_big;
end

function AIPetClothInfo:GetName()
    return self._item.name;
end
return AIPetClothInfo;