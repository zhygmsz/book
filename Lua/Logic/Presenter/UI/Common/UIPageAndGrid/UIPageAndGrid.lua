local Page = class("Page")
function Page:ctor(trs, ui, Item, numPerPage, pageIdx, eventIdBase, eventIdSpan)
    --组件
    self._ui = ui
    self._transform = trs
    self._gameObject = trs.gameObject
    self._itemTemp = trs:Find("item")
    self._itemTemp.gameObject:SetActive(false)
    self._gridTrs = trs:Find("grid")
    self._grid = self._gridTrs:GetComponent("UIGrid")
    self._grid.enabled = false

    --self._itemTemp对应的组件
    self._Item = Item

    --变量
    self._isShowed = false
    self._dataList = {}
    self._itemList = {}
    self._pageIdx = pageIdx
    self._idxOffset = 0
    self._numPerPage = numPerPage
    self._originPos = self._gridTrs.localPosition

    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan

    self:InitItemList()

    self:Hide()
end

function Page:InitItemList()
    local trs = nil
    for idx = 1, self._numPerPage do
        trs = self._ui:DuplicateAndAdd(self._itemTemp, self._gridTrs, 0)
        trs.name = "item" .. tostring(idx)
        local eventIdBase = self._eventIdBase + (idx - 1) * self._eventIdSpan
        self._itemList[idx] = self._Item.new(trs, eventIdBase, self._eventIdSpan)
    end
end

function Page:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function Page:IsShowed()
    return self._isShowed
end

function Page:Show(dataList)
    self:SetVisible(true)

    self._dataList = dataList
    self._idxOffset = (self._pageIdx - 1) * self._numPerPage

    local data = nil
    local maxIdx = 0
    for idx, item in ipairs(self._itemList) do
        data = self._dataList[idx + self._idxOffset]
        if data then
            item:Show(data, idx + self._idxOffset)
            maxIdx = idx
        else
            item:SetVisible(true)
        end
    end

    self._grid:Reposition()
    self._gridTrs.localPosition = self._originPos

    for idx = maxIdx + 1, self._numPerPage do
        if self._itemList[idx] then
            self._itemList[idx]:Hide()
        end
    end
end

function Page:Hide()
    self:SetVisible(false)
end

function Page:InvokeFunc(funcName, ...)
    for _, item in ipairs(self._itemList) do
        if item:IsShowed() then
            if item[funcName] then
                item[funcName](item, ...)
            else
                GameLog.LogError("UIPageAndGrid.Page.InvokeFunc -> item[funcName] is nil, funcName = %s", funcName)
                break
            end
        end
    end
end

--[[
    @desc: 
    --@idx: self._itemList数组索引
]]
function Page:GetItem(idx)
    if idx then
        return self._itemList[idx]
    else
        return nil
    end
end

function Page:OnDestroy()
    for _, item in ipairs(self._itemList) do
        item:OnDestroy()
    end
end

-------------------------------------------------------------------------------

local PointItem = class("PointItem")
function PointItem:ctor(trs, showParent, hideParent)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._showParent = showParent
    self._hideParent = hideParent

    self._sp = trs:GetComponent("UISprite")

    --变量
    self._isShowed = false
    self._selected = false

    self:Hide()
end

function PointItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function PointItem:IsShowed()
    return self._isShowed
end

function PointItem:SetSelected(selected)
    self._selected = selected

    if selected then
        self._sp.spriteName = "icon_liaotian_tubiao05"
    else
        self._sp.spriteName = "icon_liaotian_tubiao06"
    end
end

function PointItem:Show(selected)
    self:SetParent(self._showParent)

    self:SetVisible(true)
    
    self:SetSelected(selected)
end

function PointItem:Hide()
    self:SetVisible(false)

    self:SetParent(self._hideParent)
end

function PointItem:SetParent(parent)
    self._transform.parent = parent
end

-------------------------------------------------------------------------------

local UIPageAndGrid = class("UIPageAndGrid")
function UIPageAndGrid:ctor(trs, ui, Item, numPerPage, eventIdBase, eventIdSpan)
    --组件
    self._ui = ui
    self._Item = Item

    self._transform = trs
    self._gameObject = trs.gameObject
    self._pageTemp = trs:Find("scrollview/page")
    self._pageTemp.gameObject:SetActive(false)
    self._gridTrs = trs:Find("scrollview/grid")
    self._grid = self._gridTrs:GetComponent("UIGrid")
    self._grid.enabled = false

    --panel
    self._svPanel = trs:Find("scrollview"):GetComponent("UIPanel")
    self._sizeLen = self._svPanel.baseClipRegion.z
    if self._sizeLen == 0 then
        self._sizeLen = 2
    end

    self._svPanel.onClipMove = self._svPanel.onClipMove + UIPanel.OnClippingMoved(self.OnClipMove, self)

    --point
    self._pointListTrs = trs:Find("pointlist")
    self._pointGridTrs = trs:Find("pointlist/grid")
    self._pointGrid = self._pointGridTrs:GetComponent("UIGrid")
    self._pointTemp = trs:Find("pointlist/point")
    self._pointTemp.gameObject:SetActive(false)

    --变量
    self._isShowed = false
    self._dataList = {}
    self._dataCount = 0
    self._numPerPage = numPerPage
    self._pageList = {}
    self._pageNum = 0

    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan

    self._pointList = {}

    self:CachePoint()
end

function UIPageAndGrid:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function UIPageAndGrid:CreatePage()
    local trs = self._ui:DuplicateAndAdd(self._pageTemp, self._gridTrs, 0)
    local pageIdx = #self._pageList + 1
    trs.name = "page" .. tostring(pageIdx)
    local eventIdBase = self._eventIdBase + (pageIdx - 1) * self._numPerPage * self._eventIdSpan
    self._pageList[#self._pageList + 1] = Page.new(trs, self._ui, self._Item, self._numPerPage,
                                            pageIdx, eventIdBase, self._eventIdSpan)
    return self._pageList[#self._pageList]
end

function UIPageAndGrid:GetUnShowedPage()
    for _, page in ipairs(self._pageList) do
        if not page:IsShowed() then
            return page
        end
    end
    return nil
end

function UIPageAndGrid:GetPage()
    local page = self:GetUnShowedPage()
    if page then
        return page
    else
        return self:CreatePage()
    end
end

--[[
    @desc: 刷新/重刷，根据dataList划分页面
    --@dataList: 
]]
function UIPageAndGrid:Show(dataList)
    self:SetVisible(true)

    self._dataList = dataList
    self._dataCount = #dataList
    
    if self._numPerPage and type(self._numPerPage) == "number" and self._numPerPage ~= 0 then
        self._pageNum = math.ceil(self._dataCount / self._numPerPage)
    else
        self._pageNum = 0
    end

    --先隐藏所有page
    self:HideAllPage()

    local page = nil
    for idx = 1, self._pageNum do
        page = self:GetPage()
        if page then
            page:Show(dataList)
        end
    end

    self:Reposition()

    --分配point并定位
    self:ResetPointList()
end

--[[
    @desc: 重排序
]]
function UIPageAndGrid:Reposition()
    self._grid:Reposition()
end

function UIPageAndGrid:HideAllPage()
    for _, page in ipairs(self._pageList) do
        if page:IsShowed() then
            page:Hide()
        end
    end
end

function UIPageAndGrid:Hide()
    self:SetVisible(false)

    self:HideAllPage()
    self._dataList = {}
end

--[[
    @desc: 
    --@dataIdx: 数据列表索引，[1, 最大数量]
]]
function UIPageAndGrid:GetItem(dataIdx)
    local pageIdx, offset = self:GetPageIdxAndOffset(dataIdx)
    local page = self._pageList[pageIdx]
    if page then
        return page:GetItem(offset)
    else
        return nil
    end
end

--[[
    @desc: 获取分页idx，和页内偏移
    --@dataIdx: 
]]
function UIPageAndGrid:GetPageIdxAndOffset(dataIdx)
    local pageIdx = 0
    local offset = 0
    if dataIdx then
        pageIdx = math.ceil(dataIdx / self._numPerPage)
        offset = dataIdx - (pageIdx - 1) * self._numPerPage
    end
    return pageIdx, offset
end

--[[
    @desc: 根据事件id计算落在哪个item里，并计算spanidx是多少
    --@eventId: 
]]
function UIPageAndGrid:CalItemAndSpanIdx(eventId)
    eventId = eventId - self._eventIdBase - 1
    local quotient = math.floor(eventId / self._eventIdSpan)
    local remainder = eventId - quotient * self._eventIdSpan
    local itemIdx = quotient + 1
    local spanIdx = remainder + 1
    return itemIdx, spanIdx
end

function UIPageAndGrid:InvokeFuncByDataIdx(dataIdx, funcName, ...)
    local item = self:GetItem(dataIdx)
    if item and item:IsShowed() then
        if item[funcName] then
            item[funcName](item, ...)
        else
            GameLog.LogError("UIPageAndGrid.UIPageAndGrid.InvokeFuncByDataIdx -> item[funcName] is nil, funcName = %s", funcName)            
        end
    else
        GameLog.LogError("UIPageAndGrid.UIPageAndGrid.InvokeFuncByDataIdx -> item is nil or item is hide")
    end
end

function UIPageAndGrid:InvokeFunc(funcName, ...)
    for _, page in ipairs(self._pageList) do
        if page:IsShowed() then
            page:InvokeFunc(funcName, ...)
        end
    end
end

--[[
    @desc: 数据源变化，调整分页
    --待实现
    该方法废弃，使用Show方法重刷，并恢复位置
]]
function UIPageAndGrid:OnDataListChange()
    local newDataCount = #self._dataList
    --比较newDataCount和self._dataCount之间的关系，重新构建page
end

function UIPageAndGrid:CachePoint()
    --一次性创建10个备用
    for idx = 1, 10 do
        self:CreatePoint()
    end
end

function UIPageAndGrid:CreatePoint()
    local trs = self._ui:DuplicateAndAdd(self._pointTemp, self._pointListTrs, 0)
    trs.name = "point" .. tostring(#self._pointList + 1)
    self._pointList[#self._pointList + 1] = PointItem.new(trs, self._pointGridTrs, self._pointListTrs)
    
    return self._pointList[#self._pointList]
end

function UIPageAndGrid:GetUnShowedPoint()
    for _, point in ipairs(self._pointList) do
        if not point:IsShowed() then
            return point
        end
    end
    return nil
end

function UIPageAndGrid:GetPoint()
    local point = self:GetUnShowedPoint()
    if point then
        return point
    else
        return self:CreatePoint()
    end
end

function UIPageAndGrid:HideAllPoint()
    for _, point in ipairs(self._pointList) do
        point:Hide()
    end
end

--[[
    @desc: 根据当前分页数量，重建pointlist
]]
function UIPageAndGrid:ResetPointList()
    self:HideAllPoint()

    local point = nil
    for idx = 1, self._pageNum do
        point = self:GetPoint()
        if point then
            point:Show(false)
        end
    end

    self._pointGrid:Reposition()

    --定位
    self:LocatePoint()
end

function UIPageAndGrid:OnClipMove(panel)
    self:LocatePoint()
end

--[[
    @desc: 定位point，距离panel中心最近的分页为point选中状态
]]
function UIPageAndGrid:LocatePoint()
    --分页为0，直接返回
    if self._pageNum <= 0 then
        return
    end

    local offsetX = self._svPanel.clipOffset.x
    local integer, remainder = math.modf(offsetX / self._sizeLen)
    if remainder <= 0.5 then
        integer = integer + 1
    else
        integer = integer + 2
    end

    local point = self._pointList[integer]
    if point then
        point:Show(true)
    end

    for idx, point in ipairs(self._pointList) do
        if point:IsShowed() then
            if idx ~= integer then
                point:Show(false)
            end
        end
    end
end

function UIPageAndGrid:OnDestroy()
    for _, page in ipairs(self._pageList) do
        page:OnDestroy()
    end
end

return UIPageAndGrid
