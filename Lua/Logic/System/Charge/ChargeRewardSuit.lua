--首充奖励
local ChargeRewardSuit = class("ChargeRewardSuit");

function ChargeRewardSuit:ctor(showID,index)
    self._showID = showID;
    self._index = index;
    self._name = WordData.GetWordStringByKey("Pay_first_color"..index);
end

function ChargeRewardSuit:GetID()
    return self._static.id;
end

function ChargeRewardSuit:GetName()
    return self._name;
end

function ChargeRewardSuit:GetShowModelId()
    return self._showID;
end


return ChargeRewardSuit;