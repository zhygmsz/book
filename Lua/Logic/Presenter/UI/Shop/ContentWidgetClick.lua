local ContentWidgetBase = require("Logic/Presenter/UI/Shop/ContentWidgetBase")
local InteractForClick = require("Logic/Presenter/UI/Common/InteractMode/InteractForClick")

local ContentWidgetClick = class("ContentWidgetClick", ContentWidgetBase)

function ContentWidgetClick:ctor(trs, Item, eventIdBase, eventIdSpan, funcOnNor, funcOnSpec, funcOnSpanClick)
    ContentWidgetBase.ctor(self, trs, Item, eventIdBase, eventIdSpan)
    --组件

    --回调
    self._funcOnNor = funcOnNor
    self._funcOnSpec = funcOnSpec
    self._funcOnSpanClick = funcOnSpanClick

    self._interactClick = InteractForClick.new(self.ToNorItem, self.ToSpecItem, self.OnClickSame, self)

    --变量
end

function ContentWidgetClick:Show(dataList, restorePos, beginIdx, endIdx)
    --独有逻辑
    self._interactClick:Clear()
    ContentWidgetBase.Show(self, dataList, restorePos, beginIdx, endIdx)
end

function ContentWidgetClick:OnInit(go, wrapIdx, realIdx)
    local item, data = ContentWidgetBase.OnInit(self, go, wrapIdx, realIdx)
    if item and data then
        --独有逻辑
        if self._interactClick:GetCurDataIdx() == item:GetRealIdx() then
            item:ToSpec()
        else
            item:ToNor()
        end
    end
end

function ContentWidgetClick:AutoSelectWrapIdx(itemIdx)
    if not itemIdx then
        return
    end
    local item = self._itemList[itemIdx]
    if not item then
        return
    end
    self:OnClick(item:GetFirstUIEventId())
end

function ContentWidgetClick:AutoSelectRealIdx(realIdx)
    if not realIdx or not self._dataList[realIdx] then
        return
    end
    local item = self:RealIdx2Item(realIdx)
    if item then
        self:OnClick(item:GetFirstUIEventId())
    end
end

function ContentWidgetClick:OnClick(eventId)
    if not eventId then
        return
    end

    local itemIdx, spanIdx = self:CalItemAndSpanIdx(eventId)
    local item = self._itemList[itemIdx]
    if not item then
        return
    end

    local realIdx = item:GetRealIdx()

    --独有逻辑
    if spanIdx == 1 then
        self._interactClick:OnClick(realIdx)
    else
        self:InvokeOnSpanClick(realIdx, spanIdx)
    end
end

function ContentWidgetClick:ToNorItem(realIdx)
    local item = self:RealIdx2Item(realIdx)
    if item then
        item:ToNor()
        self:InvokeOnNor(realIdx)
    end
end

function ContentWidgetClick:ToSpecItem(realIdx)
    local item = self:RealIdx2Item(realIdx)
    if item then
        item:ToSpec()
        self:InvokeOnSpec(realIdx)
    end
end

--[[
    @desc: 点中同一个item，处理行为，子类继承实现
]]
function ContentWidgetClick:OnClickSame()
    self:ToSpecItem(self._interactClick:GetCurDataIdx())
end

function ContentWidgetClick:InvokeOnNor(realIdx)
    if self._funcOnNor then
        self._funcOnNor(realIdx)
    end
end

function ContentWidgetClick:InvokeOnSpec(realIdx)
    if self._funcOnSpec then
        self._funcOnSpec(realIdx)
    end
end

function ContentWidgetClick:InvokeOnSpanClick(realIdx, spanIdx)
    if self._funcOnSpanClick then
        self._funcOnSpanClick(realIdx, spanIdx)
    end
end

function ContentWidgetClick:GetCurRealIdx()
    return self._interactClick:GetCurDataIdx()
end

--[[
    @desc: 获取当前选中的数据
]]
function ContentWidgetClick:GetCurSelectData()
    return self._dataList[self._interactClick:GetCurDataIdx()]
end

function ContentWidgetClick:OnDestroy()
    ContentWidgetBase.OnDestroy(self)
    --独有逻辑
    self._interactClick:OnDestroy()
end

return ContentWidgetClick