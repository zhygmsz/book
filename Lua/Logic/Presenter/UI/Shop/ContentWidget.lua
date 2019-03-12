local ContentWidget = class("ContentWidget")

function ContentWidget:ctor(trs, funcOnClickItem, eventIdBase, Item)
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
    self._funcOnClickItem = funcOnClickItem
    self._eventIdBase = eventIdBase
    self._Item = Item

    --
    self._funcOnInit = UIWrapContent.OnInitializeItem(self.OnInit, self)

    --变量
    self._isShowed = false
    self._dataList = nil
    self._itemList = nil
    self._lastPanelPos = self._panelTrs.localPosition
    self._curEventId = nil
    self._curRealIdx = -1
    self._restorePos = false

    self:CacheAllItem()
    self:Hide()
end

function ContentWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function ContentWidget:CacheAllItem()
    if not self._itemList then
        self._itemList = {}
    end
    local trs = nil
    local eventId = 0
    for idx = 1, self._contentNum do
        trs = self._wrapTrs:Find(tostring(10000 + idx - 1))
        eventId = self._eventIdBase + idx
        self._itemList[idx] = self._Item.new(trs, eventId)
    end
end

--[[
    @desc: 
    --@dataList:
	--@restorePos: 是否恢复当前浏览位置
]]
function ContentWidget:Show(dataList, restorePos)
    self:SetVisible(true)
    self._dataList = dataList
    self._restorePos = restorePos

    self._curRealIdx = -1
    self._curEventId = nil
    
    local count = #self._dataList
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
    --[[
    if self._restorePos then
        --恢复位置时，还要考虑data和item数量之间的大小关系
        self._wrap:WrapContentWithPosition(count, self._funcOnInit, self._panelTrs.localPosition)
    else
        self._wrap:ResetWrapContent(count, self._funcOnInit)
    end
    --]]
end

function ContentWidget:OnInit(go, wrapIdx, realIdx)
    local item = self._itemList[wrapIdx + 1]
    local data = self._dataList[realIdx + 1]

    if item and data then
        data.wrapIdx = wrapIdx + 1
        data.realIdx = realIdx + 1
        item:Show(data, self._curRealIdx)
    end
end

function ContentWidget:GetCurRealIdx()
    return self._curRealIdx
end

--[[
    @desc: 获取当前选中的数据
]]
function ContentWidget:GetCurSelectData()
    return self._dataList[self._curRealIdx]
end

--[[
    @desc: 把data同步到list
    --@realIdx:
	--@data: 
]]
function ContentWidget:UpdateItem(realIdx, data)
    if not realIdx or not data then
        return
    end
    self._dataList[realIdx] = data
    for _, item in ipairs(self._itemList) do
        if item:GetRealIdx() == realIdx then
            item:Show(data, self._curRealIdx)
        end
    end
end

function ContentWidget:ToNorItem(eventId)
    if not eventId then
        return
    end
    local wrapIdx = eventId - self._eventIdBase
    local item = self._itemList[wrapIdx]
    if item then
        item:ToNor()
    end
end

function ContentWidget:ToSpecItem(eventId)
    if not eventId then
        return
    end
    local wrapIdx = eventId - self._eventIdBase
    local item = self._itemList[wrapIdx]
    if item then
        item:ToSpec()
        self._curRealIdx = item:GetRealIdx()

        --向外抛出事件
        local data = item:GetData()
        if self._funcOnClickItem then
            self._funcOnClickItem(data)
        end
    end
end

function ContentWidget:OnClick(eventId)
    if not eventId then
        return
    end
    if self._curEventId and self._curEventId == eventId then
        self:ToSpecItem(self._curEventId)
        return
    end

    self:ToNorItem(self._curEventId)
    self._curEventId = eventId
    self:ToSpecItem(self._curEventId)
end

function ContentWidget:AutoSelectWrapIdx(wrapIdx)
    if not wrapIdx then
        return
    end
    local item = self._itemList[wrapIdx]
    if not item then
        return
    end
    self:OnClick(item:GetUIEventId())
end

function ContentWidget:AutoSelectRealIdx(realIdx)
    if not realIdx or not self._dataList[realIdx] then
        return
    end
    local  flag = false
    for _, item in ipairs(self._itemList) do
        if item:GetRealIdx() == realIdx then
            self:OnClick(item:GetUIEventId())
            flag = true
            break
        end
    end

    if not flag then
        self._wrap:WrapContentWithRealIndex(#self._dataList, self._funcOnInit, realIdx)
    end

end

function ContentWidget:Hide()
    self:SetVisible(false)
end

function ContentWidget:AllItemOnDestroy()
    for _, item in ipairs(self._itemList) do
        item:OnDestroy()
    end
end

function ContentWidget:OnDestroy()
    self:Hide()
    self:AllItemOnDestroy()
    self._dataList = nil
    self._itemList = nil
    self._lastPanelPos = nil
    self._curEventId = nil
    self._curRealIdx = -1
end

function ContentWidget:InvokeFunc(funcName, ...)
    for _, item in ipairs(self._itemList) do
        if item[funcName] then
            --应该先判断item的可见性，但CS组件无法同步给lua层
            --待实现
            --在循环滚动过程中，一个item进入视野/离开视野，由CS通知lua层
            --最小通知开销
            item[funcName](item, ...)
        else
            GameLog.LogError("ContentWidget.InvokeFunc -> item[funcName] is nil, funcName = %s", funcName)
        end
    end
end

return ContentWidget