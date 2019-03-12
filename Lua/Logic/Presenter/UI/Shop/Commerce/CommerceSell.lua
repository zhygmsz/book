--商会售出
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")


------------------------------------LeftItem------------------------------------
local LeftItem = class("LeftItem")
function LeftItem:ctor(trs, funcOnClick)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --
    self._lis = UIEventListener.Get(self._gameObject)
    self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)
    self._funcOnClick = funcOnClick

    --
    self._item = GeneralItem.new(self._transform, nil)
    
    --变量
    self._isShowed = false
    self._zero = Vector3.zero
    self._data = {}
    self._one = Vector3.one

    self:Hide()
end

function LeftItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function LeftItem:IsShowed()
    return self._isShowed
end

function LeftItem:DoShowItem()
    self._item:ShowByItemData(self._data.itemData,self._data.count,true)
    --self._item:ShowBg(self._data.itemData.quality)
    --self._item:ShowCount(self._data.count)
end

function LeftItem:Show(data, selectedRealIdx)
    self:SetVisible(true)
    self._data = data

    self:DoShowItem()

    self:SetSelected(self._data.realIdx == selectedRealIdx)
end

function LeftItem:Hide()
    self:SetVisible(false)
end

function LeftItem:OnClick(eventData)
    if self._funcOnClick then
        self._funcOnClick(self._data)
    end
end

function LeftItem:SetSelected(selected)
    self._item:SetSelectedVisible(selected)
end

--调整父节点，用于回收LeftItem
function LeftItem:SetParent(parent)
    self._transform.parent = parent
    self._transform.localPosition = self._zero
    self._transform.localScale = self._one
end

function LeftItem:GetGoodsId()
    return self._data.tableData.id
end

function LeftItem:GetItemId()
    return self._data.itemData.id
end

function LeftItem:OnDestroy()
    self:Hide()
    self._item:OnDestroy()
    self._data = {}
end
------------------------------------LeftItem------------------------------------

------------------------------------SellWidget------------------------------------
local SellWidget = class("SellWidget")
function SellWidget:ctor(trs, ui, rightItem)
    --组件
    self._ui = ui
    self._transform = trs
    self._gameObject = trs.gameObject

    --item
    self._itemTemp = trs:Find("left/item")
    self._itemTemp.gameObject:SetActive(false)

    --widget
    self._widgetTrs = trs:Find("left/widget")
    self._leftPanelTrs = trs:Find("left/widget/scrollview")
    self._leftPanel = self._leftPanelTrs:GetComponent("UIPanel")
    self._leftSV = self._leftPanelTrs:GetComponent("UIScrollView")
    self._wrapTrs = trs:Find("left/widget/scrollview/wrapcontent")
    self._wrap = self._wrapTrs:GetComponent("UIWrapContent")

    --right
    self._rightItem = rightItem

    --变量
    self._isShowed = false
    self._events = {}
    --存放所有的LeftItem
    self._leftItemList = {}
    --左侧的数据列表，数据源来自背包，做了包装
    self._leftDataList = {}
    self._MaxLeftItemNum = 56
    self._funcOnLeftItemClick = function(data)
        self:OnLeftItemClick(data)
    end
    
    self._funcOnInit = UIWrapContent.OnInitializeItem(self.OnInit, self)
    --当前选中的LeftData列表的索引，源自Wrap组件的OnInit方法，从1开始
    self._curLeftItemRealIdx = -1
    self._buyOrSell = 2

    --该方法会在UI.OnCreate里执行，一次性缓存self._MaxLeftItemNum个
    self:CacheLeftItemList()

    self:Hide()
end

function SellWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function SellWidget:IsShowed()
    return self._isShowed
end

--缓存固定数量LeftItem，供循环使用
function SellWidget:CacheLeftItemList()
    local trs = nil
    for idx = 1, self._MaxLeftItemNum do
        trs = self._ui:DuplicateAndAdd(self._itemTemp, self._wrapTrs, 0)
        trs.name = tostring(10000 + idx)
        self._leftItemList[idx] = LeftItem.new(trs, self._funcOnLeftItemClick)
    end
end

function SellWidget:HideAllLeftItemSelected()
    for _, leftItem in ipairs(self._leftItemList) do
        if leftItem and leftItem:IsShowed() then
            leftItem:SetSelected(false)
        end
    end
end

function SellWidget:ShowLeftItemSelected(id)
    local leftItem = self._leftItemList[id]
    if leftItem and leftItem:IsShowed() then
        leftItem:SetSelected(true)
    end
end

--LeftItem点击回调
function SellWidget:OnLeftItemClick(data)
    if data.realIdx == self._curLeftItemRealIdx then
        return
    end
    self:HideAllLeftItemSelected()
    self:ShowLeftItemSelected(data.wrapIdx)
    self._curLeftItemRealIdx = data.realIdx

    --刷新right区域
    self._rightItem:Show(data, self._buyOrSell)
end


--刷新left区域
--curRealIdx：待选中的realIdx，-1则表示该次刷新不选中
function SellWidget:ShowLeft(leftDataList, curRealIdx)
    self._leftDataList = leftDataList

    local count = #self._leftDataList

    self._curLeftItemRealIdx = curRealIdx
    self._wrap:ResetWrapContent(count, self._funcOnInit)
end

--wrap组件的回调
function SellWidget:OnInit(go, wrapIdx, realIdx)
    local leftItem = self._leftItemList[wrapIdx + 1]
    local leftData = self._leftDataList[realIdx + 1]

    if leftItem and leftData then
        leftData.wrapIdx = wrapIdx + 1
        leftData.realIdx = realIdx + 1
        leftItem:Show(leftData, self._curLeftItemRealIdx)
    end
end

function SellWidget:CheckGoodsIdIsInLeftDataList(goodsId)
    for _, leftData in ipairs(self._leftDataList) do
        if leftData and leftData.tableData.id == goodsId then
            return true
        end
    end
    return false
end

function SellWidget:GetLeftItemByGoodsId(goodsId)
    if not self:CheckGoodsIdIsInLeftDataList(goodsId) then
        return nil
    end
    for _, leftItem in ipairs(self._leftItemList) do
        if leftItem and leftItem:IsShowed() and leftItem:GetGoodsId() == goodsId then
            return leftItem
        end
    end
    return nil
end

--更新self._leftDataList数据
function SellWidget:UpdateLeftDataList(newLeftData)
    for key, leftData in ipairs(self._leftDataList) do
        if leftData.tableData.id == newLeftData.tableData.id then
            newLeftData.wrapIdx = self._leftDataList[key].wrapIdx
            newLeftData.realIdx = self._leftDataList[key].realIdx
            self._leftDataList[key] = newLeftData
        end
    end
end

function SellWidget:UpdateLeftItem(goodsId)
    local leftItem = self:GetLeftItemByGoodsId(goodsId)
    if leftItem then
        local newLeftData = CommerceMgr.GetLeftData(goodsId)
        if not newLeftData then
            return
        end
        --更新数据源self._leftDataList
        self:UpdateLeftDataList(newLeftData)
        --刷新LeftItem显示数量
        leftItem:Show(newLeftData, self._curLeftItemRealIdx)
        --显示right区域
        self._rightItem:UpdateOnSell(newLeftData)
    end
end

--出售剩余次数返回
function SellWidget:OnGotSpecInfo()
    local leftDataList = CommerceMgr.GetLeftDataList()
    self:ShowLeft(leftDataList, -1)
    self._rightItem:Show(nil, self._buyOrSell)
end

--出售返回
function SellWidget:OnSell(goodsId)
    --重刷wrap区域
    local leftDataList = CommerceMgr.GetLeftDataList()
    self:ShowLeft(leftDataList, -1)
    self._rightItem:Show(nil, self._buyOrSell)

    --[[
    --背包剩余数量和出售剩余次数同时决定是否显示在left区域内
    local itemCount = CommerceMgr.GetItemCountByGoodsId(goodsId)
    local leftSellCount = CommerceMgr.GetLeftSellCountById(goodsId)
    if itemCount >= 1 and leftSellCount >= 1 then
        self:UpdateLeftItem(goodsId)
    else
        --重刷wrap区域
        local leftDataList = CommerceMgr.GetLeftDataList()
        self:ShowLeft(leftDataList, -1)
        self._rightItem:Show(nil, self._buyOrSell)
    end
    ]]
end

--realIdx转换成itemid
function SellWidget:RealIdx2ItemId(realIdx)
    local itemId = -1

    if realIdx then
        local leftData = self._leftDataList[realIdx]
        if leftData then
            itemId = leftData.itemData.id
        end
    end

    return itemId
end

--itemid转换成realidx
function SellWidget:ItemId2RealIdx(itemId, leftDataList)
    if itemId and leftDataList then
        for idx, leftData in ipairs(leftDataList) do
            if leftData.itemData.id == itemId then
                return idx
            end
        end
    end
    return -1
end

--背包数据更新
function SellWidget:OnBagOperation(bagType, oper, changeNum)
    if bagType == Bag_pb.NORMAL then
        --只有NORMAL类型背包内增加新物品时，和已有物品数量增加时，才刷新Left区域
        if (oper.operType == Bag_pb.BAGOPERTYPE_ADD) 
            or (oper.operType == Bag_pb.BAGOPERTYPE_UPDATE and changeNum > 0) then
            --刷新，但依旧保留旧的选中状态
            local leftDataList = CommerceMgr.GetLeftDataList()
            local curItemId = self:RealIdx2ItemId(self._curLeftItemRealIdx)
            local newRealIdx = self:ItemId2RealIdx(curItemId, leftDataList)
            self:ShowLeft(leftDataList, newRealIdx)

            --right区域不用处理
        end
    end
end

function SellWidget:RegEvent()
    if #self._events > 0 then
        return
    end
    self._events[1] = MessageSub.Register(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO, self.OnGotSpecInfo, self)
    self._events[2] = MessageSub.Register(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_SELL, self.OnSell, self)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, self.OnBagOperation, self)
end

function SellWidget:UnRegEvent()
    if #self._events == 0 then
        return
    end
    MessageSub.UnRegister(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO, self._events[1])
    MessageSub.UnRegister(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_SELL, self._events[2])
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, self.OnBagOperation, self)
    self._events = {}
end

function SellWidget:Show()
    self:RegEvent()

    self:SetVisible(true)

    --请求剩余出售次数
    CommerceMgr.SendGoodsSpecInfo()
end

function SellWidget:Hide()
    self:SetVisible(false)
    self._rightItem:Hide()

    self._curLeftItemRealIdx = -1

    self:UnRegEvent()
end

function SellWidget:OnDestroy()
    for _, leftItem in ipairs(self._leftItemList) do
        if leftItem then
            leftItem:OnDestroy()
        end
    end
end

return SellWidget
------------------------------------SellWidget------------------------------------