local HpNameItem = class("HpNameItem", nil)

--所有血条姓名版基类
function HpNameItem:ctor(ui, path, hpNameType)
    self._transform = ui:Find(path)
    self._gameObject = ui:FindGo(path)
    
    self._hpNameType = hpNameType

    self._target = nil
    self._name = nil

    self._localOffset = Vector3.zero
    self._followOffset = Vector3.zero

    self._isShowed = false
end

function HpNameItem:SetName(name)
    self._name.text = name
    self._name:Update()
end

function HpNameItem:GetHpNameType()
    return self._hpNameType
end

function HpNameItem:SetNameColor(nameColor)
    if self._name then
        self._name.color = nameColor
    end
end

--重置颜色值
function HpNameItem:ResetColor()
    --self._name.color = Color.New(1, 1, 1, 1)
end

function HpNameItem:SetVisible(isShow)
    self._gameObject:SetActive(isShow)
    self._isShowed = isShow
end

function HpNameItem:IsShowed()
    return self._isShowed
end

function HpNameItem:ResetFollow()
    local followTarget = self._target:GetModelComponent():GetEntityRoot();
    self._followOffset.y = self._target:GetPropertyComponent():GetHeight()
    self._followID = GameUIFollow.AddFollow(followTarget,self._transform,self._followOffset,self._localOffset);
end

function HpNameItem:OnHeightChange()
    local newHeight = self._target:GetPropertyComponent():GetHeight()
    GameUIFollow.ModifyTargetOffsetY(self._followID, newHeight)
end

function HpNameItem:Clean()
    if self._target then
        GameUIFollow.RemoveFollow(self._followID);
        self:SetVisible(false)
        --self._target:SetHpNameItem(nil)
        HpNameMgr.DeleteHpNameItemByEntity(self._target)
        self._target = nil
    end
end

function HpNameItem:ResetTarget(target)
    if target then
        --target:SetHpNameItem(self)
        HpNameMgr.AddHpNameItemByEntity(target, self)
        self._target = target
        self:SetVisible(true)
    else
        GameLog.LogError("HpNameItem.ResetTarget -> target is nil")
    end
end

function HpNameItem:GetLocalOffset()
    return self._localOffset
end

return HpNameItem
