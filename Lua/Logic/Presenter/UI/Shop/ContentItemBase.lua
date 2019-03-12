local ContentItemBase = class("ContentItemBase")

function ContentItemBase:ctor(trs, itemIdx, eventIdSpanOffset)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --变量
    self._data = nil

    self._itemIdx = itemIdx
    self._dataIdx = -1
    self._eventIdSpanOffset = eventIdSpanOffset
    self:InitUIEvent()

    self._visible = false
end

function ContentItemBase:SetVisible(visible)
    self._visible = visible
    self._gameObject:SetActive(visible)
end

--[[
    @desc: 由子类去获取uievent并赋值id
]]
function ContentItemBase:InitUIEvent()
    --子类获取UIEvent，并给其赋值，形式如下，最大不超过上层设定的eventIdSpan
    --event.id = self._eventIdSpanOffset + 1
    --event.id = self._eventIdSpanOffset + 2
end

--[[
    @desc: 虚方法
    --@data: 
]]
function ContentItemBase:Show(data, dataIdx)
    self:SetVisible(true)
    self._data = data
    self._dataIdx = dataIdx
end

function ContentItemBase:Hide()
    self:SetVisible(false)
end

function ContentItemBase:GetData()
    return self._data
end

function ContentItemBase:GetWrapIdx()
    return self._itemIdx
end

function ContentItemBase:GetRealIdx()
    --待实现
    --这里的判断是保险，但最应该的是由CS同步给lua每一个UIItem的可见性
    --外部调用这些方法时，先判断该item是否可见，一切合法操作或访问的基础是可见
    return self._dataIdx
end

function ContentItemBase:GetFirstUIEventId()
    return self._eventIdSpanOffset + 1
end

--虚方法
function ContentItemBase:OnDestroy()
    self._data = nil
end

return ContentItemBase