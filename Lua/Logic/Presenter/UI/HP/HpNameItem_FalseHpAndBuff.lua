local HpNameItem_TrueHp = require("Logic/Presenter/UI/HP/HpNameItem_TrueHp")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_FalseHpAndBuff = class("HpNameItem_FalseHpAndBuff", HpNameItem_TrueHp)

function HpNameItem_FalseHpAndBuff:ctor(ui, path, hpNameType)
    HpNameItem_TrueHp.ctor(self, ui, path, hpNameType)

    path = path .. "/"

    self._falseHp = nil
    self._falsePanel = nil
    self._hpSprite = nil

    self._buffCountDown = ui:FindComponent("UIProgressBar", path .. "Table/0_Buff/CountDown")
    self._buffGo = ui:FindGo(path .. "Table/0_Buff")
    self._buffGo:SetActive(false)

    self._buffIcon = ui:FindComponent("UISprite", path .. "BuffIcon")
    self._buffIconGo = ui:FindGo(path .. "BuffIcon")
    self._buffIconGo:SetActive(false)

    --重置target时赋值一次，减少计算
    self._hasFalseHp = false
    self._hasBuffCountDown = false

    --动态计算是否需要血条缓动，buff倒计时
    self._needFalseHp = false
    self._needBuffCountDown = false
    
    --当前buff的总时长
    self._buffDuration = 1

    self._baseClipRegion = Vector4(1, 0, 1, 20)

end

function HpNameItem_FalseHpAndBuff:ResetTarget(target)
    HpNameItem_TrueHp.ResetTarget(self, target)

    self._hasFalseHp = HpNameItem_Helper.HasFalseHp(target)
    self._hasBuffCountDown = HpNameItem_Helper.HasBuffCountDown(target)
end

--刚创建的血条，在ResetTarget里调用该方法时，一并设置FalseHp的进度
--跳过血条缓动效果
function HpNameItem_FalseHpAndBuff:SetHp(hpPer)
    if self._hasFalseHp then
        self:SetFalseHpPanel(hpPer)

        self._needFalseHp = true
        self:StartUpdate()
    end

    HpNameItem_TrueHp.SetHp(self, hpPer)
end

--设置假血条的panel和进度
function HpNameItem_FalseHpAndBuff:SetFalseHpPanel(trueHpPer)
    local width = self._hpSprite.width
    local minWidth = 20
    local centerX = width / 2 * trueHpPer + minWidth / 2
    local sizeX = (width + minWidth) - width * trueHpPer
    self._baseClipRegion.x = centerX
    self._baseClipRegion.z = sizeX
    self._falsePanel.baseClipRegion = self._baseClipRegion
end

--刚创建的玩家如果血量值不是满的，则会在血条创建之初显示血条缓动效果
--如果不需要这个效果，则可以在设置SetHp时，一并设置FalseHp
--但只能在ResetTarget里调用SetHp方法时有效
function HpNameItem_FalseHpAndBuff:UpdateFalseHp()
    if self._target then
        if self._falseHp.value > self._trueHp.value then
            --血条的缓动速度可以设置和配置
            self._falseHp.value = self._falseHp.value - UnityEngine.Time.deltaTime * 0.5
        else
            self._falseHp.value = self._trueHp.value

            self._needFalseHp = false
            self:StopUpdate()
        end
    else
        self._needFalseHp = false
        self:StopUpdate()
    end
end

function HpNameItem_FalseHpAndBuff:ResetBuff(status)
    if self._status and status then
        if self._status:GetID() == status:GetID() then
            return
        end
    end

    self._status = status

    self._buffDuration = status:GetDuration()
    if self._buffDuration == 0 then
        GameLog.LogError("HpNameItem_FalseHpAndBuff.ResetBuff -> self._buffDuration is 0")
        self._needBuffCountDown = false
        self:StopUpdate()
        return
    end
    
    self:SetBuffVisible(true)
    local iconName = BuffData.GetBuffIcon(status:GetLayer())
    self:SetBuffIcon(iconName)

    self:SetBuffPer(1 - status:GetRunningTime() / self._buffDuration)
    self._needBuffCountDown = true
    self:StartUpdate()
end

function HpNameItem_FalseHpAndBuff:SetBuffIcon(iconName)
    self._buffIcon.spriteName = iconName
end

function HpNameItem_FalseHpAndBuff:SetBuffPer(per)
    self._buffCountDown.value = per
end

function HpNameItem_FalseHpAndBuff:SetBuffVisible(isShow)
    self._buffGo:SetActive(isShow)
    self._buffIconGo:SetActive(isShow)

    self:Reposition()
end

function HpNameItem_FalseHpAndBuff:UpdateBuff()
    if self._status then
        local per = 1 - (self._status:GetRunningTime() / self._buffDuration)
        if per >= 0.001 then
            self:SetBuffPer(per)
        else
            self:SetBuffVisible(false)
            self._status = nil

            self._needBuffCountDown = false
            self:StopUpdate()
        end
    end
end

function HpNameItem_FalseHpAndBuff:Update()
    if self._hasFalseHp and self._needFalseHp then
        self:UpdateFalseHp()
    end

    if self._hasBuffCountDown and self._needBuffCountDown then
        self:UpdateBuff()
    end
end

function HpNameItem_FalseHpAndBuff:StartUpdate()
    UpdateBeat:Remove(self.Update, self)
    UpdateBeat:Add(self.Update, self)
end

function HpNameItem_FalseHpAndBuff:StopUpdate()
    if not self._needFalseHp and not self._needBuffCountDown then
        UpdateBeat:Remove(self.Update, self)
    end
end

return HpNameItem_FalseHpAndBuff