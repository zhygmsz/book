local ContentWidgetBase = class("ContentWidgetBase")

--[[
    @desc: 
    --@trs:
	--@Item:
	--@eventIdBase: 总起始偏移
	--@eventIdSpan: 每个Item内的uievent数量
]]
function ContentWidgetBase:ctor(trs, Item, eventIdBase, eventIdSpan)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._panelTrs = trs:Find("scrollview")
    self._panel = self._panelTrs:GetComponent("UIPanel")
    self._sv = self._panelTrs:GetComponent("UIScrollView")
    self._wrapTrs = trs:Find("scrollview/wrapcontent")
    self._wrap = self._wrapTrs:GetComponent("UIWrapContent")
    
    self._contentNum = self._wrap.maxIndex + 1

    --
    self._Item = Item

    --
    self._funcOnInit = UIWrapContent.OnInitializeItem(self.OnInit, self)

    --变量
    self._isShowed = false
    self._dataList = nil
    self._itemList = nil
    self._lastPanelPos = self._panelTrs.localPosition
    self._restorePos = false

    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan
    --计算出该组件内的uieventid范围，供UI.OnClick方法精准判断
    self._eventIdMin = eventIdBase + 1
    self._eventIdMax = eventIdBase + self._contentNum * eventIdSpan

    self._beginIdx = 1
    self._endIdx = 1

    self:CacheAllItem()
    self:Hide()
end

function ContentWidgetBase:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function ContentWidgetBase:CacheAllItem()
    if not self._itemList then
        self._itemList = {}
    end
    local trs = nil
    local eventIdSpanOffset = 0
    for idx = 1, self._contentNum do
        trs = self._wrapTrs:Find(tostring(10000 + idx - 1))
        eventIdSpanOffset = self._eventIdBase + (idx - 1) * self._eventIdSpan
        self._itemList[idx] = self._Item.new(trs, idx, eventIdSpanOffset)
    end
end

--[[
    @desc: 
    --@dataList:
    --@restorePos: 是否恢复当前浏览位置
    --@beginIdx: 闭区间
	--@endIdx: 以上两个参数，同时有效，设置了，就读取list内的区间内来刷新UI
]]
function ContentWidgetBase:Show(dataList, restorePos, beginIdx, endIdx)
    self:SetVisible(true)
    self._dataList = dataList
    self._restorePos = restorePos
    self._beginIdx = beginIdx or 1
    self._endIdx = endIdx or #dataList
    
    local count = self._endIdx - self._beginIdx + 1
    if self._restorePos and count >= self._contentNum then
        --恢复位置时，还要考虑data和item数量之间的大小关系
        self._wrap:WrapContentWithPosition(count, self._funcOnInit, self._panelTrs.localPosition)
        local pos = self._panelTrs.localPosition
        local off = self._panel.clipOffset
        pos.y = pos.y + 2
        off.y = off.y - 2
        self._panel.clipOffset = off
        self._panelTrs.localPosition = pos
        self._sv:RestrictWithinBounds(true)

        pos = self._panelTrs.localPosition
        off = self._panel.clipOffset
        pos.y = pos.y - 2
        off.y = off.y + 2
        self._panelTrs.localPosition = pos
        self._panel.clipOffset = off
    else
        self._wrap:ResetWrapContent(count, self._funcOnInit)
    end
end

--[[
    @desc: 虚方法，该方法的内部实现依赖于交互方式（UI表现方式）
    --@go:
	--@wrapIdx:
	--@realIdx: 
]]
function ContentWidgetBase:OnInit(go, wrapIdx, realIdx)
    local item = self._itemList[wrapIdx + 1]
    local data = self._dataList[self._beginIdx + realIdx]

    if item and data then
        item:Show(data, self._beginIdx + realIdx)

        --和交互方式有关的设置，交给子类
        return item, data
    end
end

--[[
    @desc: 计算落在哪个idx里，并且区分是哪个类型的点击事件
    --@eventId: 
]]
function ContentWidgetBase:CalItemAndSpanIdx(eventId)
    eventId = eventId - self._eventIdBase - 1
    local quotient = math.floor(eventId / self._eventIdSpan)
    local remainder = eventId - quotient * self._eventIdSpan
    local itemIdx = quotient + 1
    local spanIdx = remainder + 1
    return itemIdx, spanIdx
end

--[[
    @desc: 检测指定eventid是否落在该组件内
    --@eventId: 
]]
function ContentWidgetBase:CheckEventIdIsIn(eventId)
    return self._eventIdMin <= eventId and eventId <= self._eventIdMax
end

function ContentWidgetBase:Hide()
    self:SetVisible(false)
end

function ContentWidgetBase:AllItemOnDestroy()
    for _, item in ipairs(self._itemList) do
        item:OnDestroy()
    end
end

function ContentWidgetBase:InvokeFunc(funcName, ...)
    for _, item in ipairs(self._itemList) do
        if item[funcName] then
            --应该先判断item的可见性，但CS组件无法同步给lua层
            --待实现
            --在循环滚动过程中，一个item进入视野/离开视野，由CS通知lua层
            --最小通知开销
            item[funcName](item, ...)
        else
            GameLog.LogError("ContentWidgetBase.InvokeFunc -> item[funcName] is nil, funcName = %s", funcName)
        end
    end
end

function ContentWidgetBase:GetDataList()
    return self._dataList
end

function ContentWidgetBase:RealIdx2Item(realIdx)
    local targetItem = nil

    if realIdx then
        for _, item in ipairs(self._itemList) do
            if item:GetRealIdx() == realIdx then
                targetItem = item
                break
            end
        end
    end

    return targetItem
end

function ContentWidgetBase:OnDestroy()
    self:Hide()
    self:AllItemOnDestroy()
    self._dataList = nil
    self._itemList = nil
    self._lastPanelPos = nil
    self._curEventId = nil
    self._curRealIdx = -1
end

return ContentWidgetBase