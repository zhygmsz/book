local HpNameItem = require("Logic/Presenter/UI/HP/HpNameItem")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_TrueHp = class("HpNameItem_TrueHp", HpNameItem)

--有血条的基类
function HpNameItem_TrueHp:ctor(ui, path, hpNameType)
    HpNameItem.ctor(self, ui, path, hpNameType)

    self._trueHp = nil
end

function HpNameItem_TrueHp:SetHpValue(curHp, maxHp)
    if maxHp ~= 0 then
        self:SetHp(curHp / maxHp)
    else
        if self._target then
            GameLog.LogError("HpNameItem_TrueHp.SetHpValue -> id = %s, name = %s", self._target:GetID(), self._target:GetName())
        end
    end
end

function HpNameItem_TrueHp:SetHp(hpPer)
    self._trueHp.value = hpPer

    if hpPer <= 0 then
        self:OnDie()
    end
end

--entity的血条百分比为0时调用
--百分比为0时已经死亡，只不过这时还在播放死亡特效，需要隐藏血条
function HpNameItem_TrueHp:OnDie()
    self:Clean()
end

return HpNameItem_TrueHp