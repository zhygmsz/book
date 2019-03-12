--一二级分类列表

local UITableAndGrid = class("UITableAndGrid")
function UITableAndGrid:ctor(trs, ui, oneItemTemp, twoItemTemp)
    --组件
    self._ui = ui
    self._transform = trs
    self._gameObject = trs.gameObject

    self._panelTrs = trs.parent
    self._panel = self._panelTrs:GetComponent("UIPanel")
    self._sv = self._panelTrs:GetComponent("UIScrollView")

    self._tableTrs = trs:Find("table")
    self._table = self._tableTrs:GetComponent("UITable")
    self._table.onCustomSort = System.Comparison_UnityEngine_Transform(self.CustomTableSort, self)
    self._gridCustomSort = System.Comparison_UnityEngine_Transform(self.CustomGridSort, self)

    local pos = self._tableTrs.localPosition
    self._tableOriginPos = Vector3(pos.x, pos.y, pos.z)

    self._funcOnClickOneItem = function(oneDataIdx)
        self:OnOneItemClick(oneDataIdx, true)
    end

    self._funcOnClickTwoItem = function(twoDataIdx)
        self:OnTwoItemClick(twoDataIdx, true)
    end

    self._funcGetTwoItem = function()
        return self:GetTwoItem()
    end

    --变量
    self._sourceData = nil
    self._oneItemTemp = oneItemTemp
    self._twoItemTemp = twoItemTemp
    self.OneItem = nil
    self.TwoItem = nil
    self._funcOnOneItemClick = nil
    self._funcOnTwoItemClick = nil
    self._oneItemBottomOffset = -5
    self._oneItemHasBg = false
    self._oneItemList = {}
    self._twoItemList = {}
    self._curOneDataIdx = -1
    self._curTwoDataIdx = -1
    self._isShowed = false

    self:Hide()
end

------------------------------对外------------------------------
--[[
    @desc: 该方法在new之后调用，算是ctor方法的补充
    --@OneItem:
	--@TwoItem:
	--@funcOnOneItemClick:
	--@funcOnTwoItemClick:
	--@oneItemBottomOffset:
	--@oneItemHasBg: 
]]
function UITableAndGrid:Init(OneItem, TwoItem, funcOnOneItemClick, funcOnTwoItemClick, oneItemBottomOffset, oneItemHasBg)
    self.OneItem = OneItem
    self.TwoItem = TwoItem
    self._funcOnOneItemClick = funcOnOneItemClick
    self._funcOnTwoItemClick = funcOnTwoItemClick
    self._oneItemBottomOffset = oneItemBottomOffset
    self._oneItemHasBg = oneItemHasBg

    self:CacheOneItemList()
    self:CacheTwoItemList()
end

--[[
    @desc: 该方法推荐在UI.OnEnable方法里调用
    --@sourceData: 
    { 
        { xxx, list = { { xxx },{ xxx },{ xxx }, } },
        { xxx, list = { { xxx },{ xxx },{ xxx }, } },
        { xxx, list = { { xxx },{ xxx },{ xxx }, } },
    }
]]
function UITableAndGrid:Show(sourceData)
    self:SetVisible(true)

    self._sourceData = sourceData

    self:Reset()

    for idx, _ in ipairs(self._sourceData) do
        local oneItem = self:GetOneItem()
        if oneItem then
            oneItem:Show(sourceData, idx)
        end
    end

    self:Reposition(true)
end

function UITableAndGrid:Hide()
    self:SetVisible(false)
    self:Reset()
end

--[[
    @desc: 手动选中一二级列表按钮的点击状态，不抛出点击事件
    --@oneDataIdx: -1则无效
	--@twoDataIdx: -1则无效
]]
function UITableAndGrid:CustomShowOneTwoExpanded(oneDataIdx, twoDataIdx)
    if oneDataIdx ~= -1 then
        self:OnOneItemClick(oneDataIdx, false)

        if twoDataIdx ~= -1 then
            self:OnTwoItemClick(twoDataIdx, false)
        end
    end
end

--[[
    @desc: 重展开当前oneitem，用于list变动后重刷，只针对当前选中的oneDataIdx
]]
function UITableAndGrid:ReExpandCurOneItem()
    if not self:CheckOneDataRange(self._curOneDataIdx) then
        return
    end
    --当前oneitem处于必须展开状态
    local oneItem = self:GetOneItemByIdx(self._curOneDataIdx)
    if not oneItem then
        return
    end
    if not oneItem:GetExpanded() then
        return
    end
    --重置twoid
    self._curTwoDataIdx = -1
    self:TakeTwoItem()
    self:SpecOneItem(self._curOneDataIdx, false)
    self:Reposition(false)
end

function UITableAndGrid:GetCurOneDataIdx()
    return self._curOneDataIdx
end

function UITableAndGrid:GetCurTwoDataIdx()
    return self._curTwoDataIdx
end

--[[
    @desc: 返回当前选中的data
]]
function UITableAndGrid:GetCurData()
    local oneData = self._sourceData[self._curOneDataIdx]
    if oneData then
        return oneData.list[self._curTwoDataIdx]
    else
        return nil
    end
end

--[[
    @desc: 由UI.OnEnable方法调用
]]
function UITableAndGrid:OnEnable()
    
end

--[[
    @desc: 由UI.OnDisable方法调用
]]
function UITableAndGrid:OnDisable()
    
end

--[[
    @desc: 由UI.OnDestroy方法调用
]]
function UITableAndGrid:OnDestroy()
    for _, twoItem in ipairs(self._twoItemList) do
        if twoItem then
            twoItem:OnDestroy()
        end
    end
    self._twoItemList = nil
    for _, oneItem in ipairs(self._oneItemList) do
        if oneItem then
            oneItem:OnDestroy()
        end
    end
    self._oneItemList = nil
end
------------------------------对外------------------------------

function UITableAndGrid:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function UITableAndGrid:IsShowed()
    return self._isShowed
end

function UITableAndGrid:CustomSort(left, right)
    local leftName = left.name
    local rightName = right.name
    local leftNum = tonumber(string.sub(leftName, 8))
    local rightNum = tonumber(string.sub(rightName, 8))
    if leftNum < rightNum then
        return -1
    elseif leftNum > rightNum then
        return 1
    else
        return 0
    end
end

function UITableAndGrid:CustomGridSort(left, right)
    return self:CustomSort(left, right)
end

function UITableAndGrid:CustomTableSort(left, right)
    return self:CustomSort(left, right)
end

function UITableAndGrid:Reset()
    self:TakeTwoItem()
    self:TakeOneItem()
    self._curOneDataIdx = -1
    self._curTwoDataIdx = -1
end

function UITableAndGrid:CheckOneDataRange(oneDataIdx)
    if oneDataIdx then
        return self._sourceData[oneDataIdx] ~= nil
    else
        return false
    end
end

function UITableAndGrid:GetTwoDataList(oneDataIdx)
    if oneDataIdx then
        local oneData = self:GetOneDataByIdx(oneDataIdx)
        if oneData then
            return oneData.list
        end
    else
        return nil
    end
end

function UITableAndGrid:CheckTwoDataRange(twoDataIdx)
    if twoDataIdx then
        local twoDataList = self:GetTwoDataList(self._curOneDataIdx)
        if twoDataList then
            return twoDataList[twoDataIdx] ~= nil
        else
            return false
        end
    else
        return false
    end
end

function UITableAndGrid:GetOneDataByIdx(oneDataIdx)
    if oneDataIdx then
        return self._sourceData[oneDataIdx]
    else
        return nil
    end
end

function UITableAndGrid:GetOneItemByIdx(oneDataIdx)
    for _, oneItem in ipairs(self._oneItemList) do
        if oneItem:IsShowed() and oneItem:GetOneDataIdx() == oneDataIdx then
            return oneItem
        end
    end
    return nil
end

function UITableAndGrid:InvokeOneClickFunc(oneDataIdx)
    if self._funcOnOneItemClick then
        local oneItem = self:GetOneItemByIdx(oneDataIdx)
        if oneItem then
            self._funcOnOneItemClick(oneDataIdx, oneItem:GetExpanded())
        end
    end
end

function UITableAndGrid:NorOneItem(oneDataIdx, throwEvent)
    if not self:CheckOneDataRange(oneDataIdx) then
        return
    end
    local oneItem = self:GetOneItemByIdx(oneDataIdx)
    if not oneItem then
        return
    end
    oneItem:ToNor()

    --回收twoitem
    self:TakeTwoItem()

    --重置twoid
    self._curTwoDataIdx = -1

    if throwEvent then
        self:InvokeOneClickFunc(oneDataIdx)
    end
end

function UITableAndGrid:SpecOneItem(oneDataIdx, throwEvent)
    if not self:CheckOneDataRange(oneDataIdx) then
        return
    end
    local oneItem = self:GetOneItemByIdx(oneDataIdx)
    if not oneItem then
        return
    end
    oneItem:ToSpec()

    if throwEvent then
        self:InvokeOneClickFunc(oneDataIdx)
    end
end

function UITableAndGrid:GetTwoItemByIdx(twoDataIdx)
    for _, twoItem in ipairs(self._twoItemList) do
        if twoItem:IsShowed() and twoItem:GetTwoDataIdx() == twoDataIdx then
            return twoItem
        end
    end
    return nil
end

function UITableAndGrid:InvokeTwoClickFunc(twoDataIdx, selected)
    if self._funcOnTwoItemClick then
        local twoItem = self:GetTwoItemByIdx(twoDataIdx)
        if twoItem then
            self._funcOnTwoItemClick(twoDataIdx, selected)
        end
    end
end

function UITableAndGrid:NorTwoItem(twoDataIdx, throwEvent)
    if not self:CheckTwoDataRange(twoDataIdx) then
        return
    end
    local twoitem = self:GetTwoItemByIdx(twoDataIdx)
    if not twoitem then
        return
    end
    twoitem:ToNor()

    if throwEvent then
        self:InvokeTwoClickFunc(twoDataIdx, false)
    end
end

function UITableAndGrid:SpecTwoItem(twoDataIdx, throwEvent)
    if not self:CheckTwoDataRange(twoDataIdx) then
        return
    end
    local twoItem = self:GetTwoItemByIdx(twoDataIdx)
    if not twoItem then
        return
    end
    twoItem:ToSpec()

    if throwEvent then
        self:InvokeTwoClickFunc(twoDataIdx, true)
    end
end

--[[
    @desc: 将所有的twoitem回收
]]
function UITableAndGrid:TakeTwoItem()
    for _, twoItem in ipairs(self._twoItemList) do
        if twoItem and twoItem:IsShowed() then
            twoItem:SetParent(self._transform)
            twoItem:Hide()
        end
    end
end

--[[
    @desc: 回收所有的oneitem
]]
function UITableAndGrid:TakeOneItem()
    for _, oneItem in ipairs(self._oneItemList) do
        if oneItem and oneItem:IsShowed() then
            oneItem:Hide()
        end
    end
end

function UITableAndGrid:Reposition(resetSv)
    self._table:Reposition()
    if resetSv then
        self._tableTrs.localPosition = self._tableOriginPos
        self._sv:ResetPosition()
    else
        --待实现
        --回复位置
    end
end

--[[
    @desc: oneitem点击回调
    --@oneDataIdx:
	--@throwEvent: 是否抛出点击事件
]]
function UITableAndGrid:OnOneItemClick(oneDataIdx, throwEvent)
    if not self:CheckOneDataRange(oneDataIdx) then
        return
    end
    if self._curOneDataIdx == oneDataIdx then
        local oneItem = self:GetOneItemByIdx(oneDataIdx)
        if oneItem then
            if oneItem:GetExpanded() then
                self:NorOneItem(self._curOneDataIdx, throwEvent)
            else
                self:SpecOneItem(self._curOneDataIdx, throwEvent)
            end
        end
    else
        self:NorOneItem(self._curOneDataIdx, throwEvent)
        self._curOneDataIdx = oneDataIdx
        self:SpecOneItem(self._curOneDataIdx, throwEvent)
    end

    self:Reposition(true)
end

--[[
    @desc: twoitem点击回调
    --@twoDataIdx:
	--@throwEvent: 是否抛出点击事件
]]
function UITableAndGrid:OnTwoItemClick(twoDataIdx, throwEvent)
    if not self:CheckTwoDataRange(twoDataIdx) then
        return
    end
    if self._curTwoDataIdx == twoDataIdx then
        return
    end
    self:NorTwoItem(self._curTwoDataIdx, throwEvent)
    self._curTwoDataIdx = twoDataIdx
    self:SpecTwoItem(self._curTwoDataIdx, throwEvent)
end

--初始化固定数量的oneitem备用
function UITableAndGrid:CacheOneItemList()
    --数字20没有逻辑意义
    for idx = 1, 20 do
        self:CreateOneItem()
    end
end

function UITableAndGrid:CreateOneItem()
    local trs = self._ui:DuplicateAndAdd(self._oneItemTemp, self._tableTrs, 0)
    trs.name = "oneitem" .. tostring(#self._oneItemList + 1)
    trs.localScale = Vector3.one

    self._oneItemList[#self._oneItemList + 1] =
        self.OneItem.new(
        trs,
        self._funcOnClickOneItem,
        self._funcGetTwoItem,
        self._oneItemBottomOffset,
        self._oneItemHasBg
    )
    return self._oneItemList[#self._oneItemList]
end

function UITableAndGrid:GetUnShowedOneItem()
    for _, oneItem in ipairs(self._oneItemList) do
        if oneItem and not oneItem:IsShowed() then
            return oneItem
        end
    end
    return nil
end

function UITableAndGrid:GetOneItem()
    local oneItem = self:GetUnShowedOneItem()
    if oneItem then
        return oneItem
    else
        return self:CreateOneItem()
    end
end

--初始化固定数量twoitem备用
function UITableAndGrid:CacheTwoItemList()
    --数字20没有逻辑意义
    for idx = 1, 20 do
        self:CreateTwoItem()
    end
end

function UITableAndGrid:CreateTwoItem()
    local trs = self._ui:DuplicateAndAdd(self._twoItemTemp, self._transform, 0)
    trs.name = "twoitem" .. tostring(#self._twoItemList + 1)
    trs.localScale = Vector3.one

    self._twoItemList[#self._twoItemList + 1] = self.TwoItem.new(trs, self._funcOnClickTwoItem)
    return self._twoItemList[#self._twoItemList]
end

function UITableAndGrid:GetUnShowedTwoItem()
    for _, twoItem in ipairs(self._twoItemList) do
        if twoItem and not twoItem:IsShowed() then
            return twoItem
        end
    end
    return nil
end

function UITableAndGrid:GetTwoItem()
    local twoItem = self:GetUnShowedTwoItem()
    if twoItem then
        return twoItem
    else
        return self:CreateTwoItem()
    end
end

return UITableAndGrid
