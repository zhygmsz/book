--商会购买
local UITableAndGrid_OneItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_OneItem")
local UITableAndGrid_TwoItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_TwoItem")
local UITableAndGrid = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

------------------------------------MiddleItem------------------------------------
local MiddleItem = class("MiddleItem")
function MiddleItem:ctor(trs, funcOnClick)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject
	self._itemTrs = trs:Find("item")
	self._name = trs:Find("name"):GetComponent("UILabel")
	--待实现
	--对于一张图片/文字，使用shader置灰，看效果是够满足美术要求
	--如果可以则省下一份资源，不行再说
	self._priceBg = trs:Find("price"):GetComponent("UISprite")
	self._priceIcon = trs:Find("price/icon"):GetComponent("UISprite")
	self._priceNum = trs:Find("price/num"):GetComponent("UILabel")
	self._count = trs:Find("count"):GetComponent("UILabel")
	self._discountGo = trs:Find("discount").gameObject
	self._discountSp = trs:Find("discount"):GetComponent("UISprite")
	self._discountNum = trs:Find("discount/num"):GetComponent("UILabel")
	self._selectedGo = trs:Find("selected").gameObject
	self._lis = UIEventListener.Get(self._gameObject)
	self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)
	self._funcOnClick = funcOnClick
	
	--变量
	self._isShowed = false
	self._data = {}
	self._item = GeneralItem.new(self._itemTrs, nil)
	self._freeStr = "免费"
	self._discountSpName = "icon_common_dazhe"
	self._discountSpNameGray = "icon_common_shoukong"
	self._discountDesSellOut = "售空"
	self._nameColor = Color(171 / 255, 62 / 255, 32 / 255, 1)
	self._nameColorSellOut = Color(92 / 255, 90 / 255, 91 / 255, 1)
	self._priceNumColor = Color(105 / 255, 61 / 255, 33 / 255, 1)
	self._priceNumColorSellOut = Color(67 / 255, 67 / 255, 67 / 255, 1)
	self._countColor = Color(139 / 255, 91 / 255, 73 / 255, 1)
	self._countColorSellOut = Color(92 / 255, 90 / 255, 91 / 255, 1)
	self._zero = Vector3.zero
	self._one = Vector3.one
	
	self:SetSelected(false)
	self:Hide()
end

function MiddleItem:OnClick(eventData)
	if self._funcOnClick then
		self._funcOnClick(self._data)
	end
end

function MiddleItem:SetSelected(selected)
	self._selectedGo:SetActive(selected)
end

function MiddleItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function MiddleItem:IsShowed()
	return self._isShowed
end

function MiddleItem:DoShowItem()
	self._item:ShowByItemData(self._data.itemData,nil,true)
	--self._item:ShowBg(self._data.itemData.quality)
end

function MiddleItem:DoShowPrice()
	self._priceIcon.spriteName = self._data.moneyItemData.icon_big
	if self._data.tableData.selltype == Shop_pb.GoodsInfo.ORIGINAL_PRICE then
		--原价
		self._discountGo:SetActive(false)
		self._priceNum.text = string.NumberFormat(self._data.tableData.price, 0)
	elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.DISCOUNT_PRICE then
		--折扣
		self._discountGo:SetActive(true)
		self._priceNum.text = string.NumberFormat(CommerceMgr.GetRealPrice(self._data.tableData, 1), 0)
		self._discountNum.text = CommerceMgr.GetDiscountNumStr(self._data)
	elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.FREE_PRICE then
		--免费
		self._discountGo:SetActive(false)
		self._priceNum.text = string.NumberFormat(self._freeStr, 0)
	elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.DINAMIC_PRICE then
		--价格波动
		self._discountGo:SetActive(false)
		self._priceNum.text = string.NumberFormat(self._data.info.dynamicprice, 0)
	end
end

function MiddleItem:Show(data, selectedRealIdx)
	self:SetVisible(true)
	self._data = data
	
	self:DoShowItem()
	self._name.text = self._data.itemData.name
	self:DoShowPrice()
	
	self._count.text = tostring(self._data.info.leftbuycount)
	self:CheckIsSellOut()
	
	--判断是否选中
	self:SetSelected(self._data.realIdx == selectedRealIdx)
end

--[[    @desc: 购买后的处理
]]
function MiddleItem:OnBuy()
	self._count.text = tostring(self._data.info.leftbuycount)
	self:CheckIsSellOut()
end

--检测是否售空
function MiddleItem:CheckIsSellOut()
	local leftBuyCount = CommerceMgr.GetLeftBuyCountByData(self._data)
	if leftBuyCount >= 1 then
		--self._name.color = self._nameColor
		--待实现
		--图片或文字的置灰处理
		--self._priceBg
		--self._priceNum.color = self._priceNumColor
		--self._count.color = self._countColor
		self._discountSp.spriteName = self._discountSpName
	else
		--self._name.color = self._nameColorSellOut
		--self._priceNum.color = self._priceNumColorSellOut
		--self._count.color = self._countColorSellOut
		self._discountGo:SetActive(true)
		self._discountSp.spriteName = self._discountSpNameGray
		self._discountNum.text = self._discountDesSellOut
	end
end

function MiddleItem:Hide()
	self:SetVisible(false)
	self._data = nil
end

function MiddleItem:GetGoodsId()
	return self._data.tableData.id
end

function MiddleItem:SetParent(parent)
	self._transform.parent = parent
	self._transform.localPosition = self._zero
	self._transform.localScale = self._one
end

function MiddleItem:OnDestroy()
	self._item:OnDestroy()
end
------------------------------------MiddleItem------------------------------------
local OneItem = class("OneItem", UITableAndGrid_OneItem)
function OneItem:ctor(trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
	UITableAndGrid_OneItem.ctor(self, trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
	
	--变量
end

function OneItem:InitUI()
	UITableAndGrid_OneItem.InitUI(self)
	
	self._norLbl = self._transform:Find("nor/label"):GetComponent("UILabel")
	self._specLbl = self._transform:Find("spec/label"):GetComponent("UILabel")
	self._specLbl.text = ""
	self._norLbl.text = ""
end

function OneItem:Show(sourceData, oneDataIdx)
	UITableAndGrid_OneItem.Show(self, sourceData, oneDataIdx)
	
	self._norLbl.text = self._data.content
	self._specLbl.text = self._data.content
end

function OneItem:Hide()
	UITableAndGrid_OneItem.Hide(self)
	
	self._norLbl.text = ""
	self._specLbl.text = ""
end

local TwoItem = class("TwoItem", UITableAndGrid_TwoItem)
function TwoItem:ctor(trs, funcOnClick)
	UITableAndGrid_TwoItem.ctor(self, trs, funcOnClick)
	
	--变量
end

function TwoItem:InitUI()
	UITableAndGrid_TwoItem.InitUI(self)
	
	self._norLbl = self._transform:Find("nor/label"):GetComponent("UILabel")
	self._specLbl = self._transform:Find("spec/label"):GetComponent("UILabel")
	self._specLbl.text = ""
	self._norLbl.text = ""
end

function TwoItem:Show(sourceData, oneDataIdx, twoDataIdx)
	UITableAndGrid_TwoItem.Show(self, sourceData, oneDataIdx, twoDataIdx)
	
	self._norLbl.text = self._data.content
	self._specLbl.text = self._data.content
end

function TwoItem:Hide()
	UITableAndGrid_TwoItem.Hide(self)
	
	self._norLbl.text = ""
	self._specLbl.text = ""	
end

------------------------------------BuyWidget------------------------------------
local BuyWidget = class("BuyWidget")
function BuyWidget:ctor(trs, ui, rightItem)
	--组件
	self._ui = ui
	self._transform = trs
	self._gameObject = trs.gameObject
	
	--left
	self._oneItemTemp = trs:Find("left/oneitem")
	self._twoItemTemp = trs:Find("left/twoitem")
	self._oneItemTemp.gameObject:SetActive(false)
	self._twoItemTemp.gameObject:SetActive(false)
	self._tableAndGridTrs = trs:Find("left/panel/tableandgrid")
	self._tableAndGrid = UITableAndGrid.new(self._tableAndGridTrs, self._ui, self._oneItemTemp, self._twoItemTemp)
	local funcOnOneItemClick = function(oneDataIdx, expanded)
		self:OnOneItemClick(oneDataIdx, expanded)
	end
	local funcOnTwoItemClick = function(twoDataIdx, selected)
		self:OnTwoItemClick(twoDataIdx, selected)
	end
	self._tableAndGrid:Init(OneItem, TwoItem, funcOnOneItemClick, funcOnTwoItemClick, - 2, false)
	
	--middle
	self._widgetTrs = trs:Find("middle/widget")
	self._middleItemTemp = trs:Find("middle/item")
	self._middleItemTemp.gameObject:SetActive(false)
	self._middlePanelTrs = trs:Find("middle/widget/scrollview")
	self._middlePanel = self._middlePanelTrs:GetComponent("UIPanel")
	self._middleSV = self._middlePanelTrs:GetComponent("UIScrollView")
	self._wrapTrs = trs:Find("middle/widget/scrollview/wrapcontent")
	self._wrap = self._wrapTrs:GetComponent("UIWrapContent")
	
	--right
	self._rightItem = rightItem
	
	--变量
	self._isShowed = false
	self._middleItemList = {}
	self._middleItemDataList = {}
	self._middleItemMaxNum = 6  --一共存放6个item，供循环使用
	
	self._funcOnInit = UIWrapContent.OnInitializeItem(self.OnInit, self)
	self._funcOnMiddleItemClick = function(data)
		self:OnMiddleItemClick(data)
	end
	--onetwo列表
	self._sourceData = nil
	self._curOneDataIdx = - 1
	self._curTwoDataIdx = - 1
	self._curOneType = - 1
	self._curTwoType = - 1
	--当前middle区域，选中的item，middle区域刷新时重置
	self._curMiddleItemRealIdx = - 1
	self._events = {}
	self._originPanelPos = self._middlePanelTrs.localPosition
	self._lastPanelPos = self._middlePanelTrs.localPosition
	self._buyOrSell = 1
	
	self:CacheMiddleItemList()
	
	self:Hide()
end

function BuyWidget:HideAllMiddleItemSelected()
	for _, middleItem in ipairs(self._middleItemList) do
		if middleItem then
			middleItem:SetSelected(false)
		end
	end
end

function BuyWidget:ShowMiddleItemSelected(id)
	local middleItem = self._middleItemList[id]
	if middleItem then
		middleItem:SetSelected(true)
	end
end

function BuyWidget:OnMiddleItemClick(data)
	self:HideAllMiddleItemSelected()
	self:ShowMiddleItemSelected(data.wrapIdx)
	self._curMiddleItemRealIdx = data.realIdx
	
	--刷新right区域
	self._rightItem:Show(data, self._buyOrSell)
end

--expanded:是否是展开状态
function BuyWidget:OnOneItemClick(oneDataIdx, expanded)
	if not CommerceMgr.CheckServerDataIsInited() then
		return
	end
	
	if expanded then
		self._curOneDataIdx = oneDataIdx
		self._curOneType = self._sourceData[oneDataIdx].oneType
	else
		self._curOneDataIdx = - 1
		self._curOneType = - 1
	end
	
	CommerceMgr.SetLastLeftType(self._curOneType, - 1)
end

function BuyWidget:OnTwoItemClick(twoDataIdx, selected)
	if not selected then
		return
	end
	if not CommerceMgr.CheckServerDataIsInited() then
		return
	end
	if self._curOneDataIdx == - 1 then
		return
	end
	
	self._curTwoDataIdx = twoDataIdx
	--待实现，添加防御式编程
	self._curTwoType = self._sourceData[self._curOneDataIdx].list[twoDataIdx].twoType
	--刷新middle区域
	local list = CommerceMgr.GetFullDataList(1, self._curOneType, self._curTwoType)
	if not list then
		return
	end
	self:ShowMiddle(list, - 1)
	
	--同步当前选择的onetwotype记录
	CommerceMgr.SetLastLeftType(self._curOneType, self._curTwoType)
	CommerceMgr.SetLastMiddleType(self._curOneType, self._curTwoType)
end

function BuyWidget:CacheMiddleItemList()
	local trs = nil
	for idx = 1, self._middleItemMaxNum do
		trs = self._ui:DuplicateAndAdd(self._middleItemTemp, self._wrapTrs, 0)
		trs.name = tostring(10000 + idx)
		self._middleItemList[idx] = MiddleItem.new(trs, self._funcOnMiddleItemClick)
	end
end

function BuyWidget:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function BuyWidget:IsShowed()
	return self._isShowed
end

function BuyWidget:OneType2DataIdx(oneType)
	for idx, oneData in ipairs(self._sourceData) do
		if oneData.oneType == oneType then
			return idx
		end
	end
	return - 1
end

function BuyWidget:TwoType2DataIdx(oneDataIdx, twoType)
	for idx, twoData in ipairs(self._sourceData[oneDataIdx].list) do
		if twoData.twoType == twoType then
			return idx
		end
	end
	return - 1
end

--收到商品特殊信息后，刷新middle区域，进而选择性的刷新right区域
--选择性的恢复左侧的浏览记录
function BuyWidget:OnGotSpecInfo()
	--恢复左侧一二级列表浏览记录
	local lastLeftType = CommerceMgr.GetLastLeftType()
	if lastLeftType.one ~= - 1 then
		self._curOneType = lastLeftType.one
		self._curTwoType = lastLeftType.two
		self._curOneDataIdx = self:OneType2DataIdx(self._curOneType)
		self._curTwoDataIdx = self:TwoType2DataIdx(self._curOneDataIdx, self._curTwoType)
		self._tableAndGrid:CustomShowOneTwoExpanded(self._curOneDataIdx, self._curTwoDataIdx)
	end
	
	local lastMiddleId = CommerceMgr.GetLastMiddleType()
	local middleDataList = nil
	if lastMiddleId.one == - 1 and lastMiddleId.two == - 1 then
		--策划设定：如果middle区域没有浏览记录，则显示第一大类的第一小类
		middleDataList = CommerceMgr.GetFullDataList(1, 1, 1)
	else
		middleDataList = CommerceMgr.GetFullDataList(1, lastMiddleId.one, lastMiddleId.two)
	end
	if not middleDataList then
		return
	end
	
	local lastGoodsId = CommerceMgr.GetLastGoodsId()
	self:ShowMiddle(middleDataList, lastGoodsId)
end

--升级监听
function BuyWidget:OnLevelUp(entity)
	if entity == nil or entity:IsSelf() then
		local newMiddleDataList = CommerceMgr.GetFullDataList(1, self._curOneType, self._curTwoType)
		--比较新获取的MiddleData列表长度和目前的是否一致
		if #newMiddleDataList > #self._middleItemDataList then
			--说明升级导致了新的MiddleData可见，刷新middle
			--待实现
			--考虑当升级导致刷新时，panel位置不做改变，right区域也不重置
			self:ShowMiddle(newMiddleDataList, - 1)
		end
	end
end

--在Middle区域，找goodsId相同的MiddleItem
function BuyWidget:GetMiddleItemByGoodsId(goodsId)
	for _, middleItem in ipairs(self._middleItemList) do
		if middleItem and middleItem:GetGoodsId() == goodsId then
			return middleItem
		end
	end
	return nil
end

function BuyWidget:GetMiddleDataByGoodsId(goodsId)
	for _, middleData in ipairs(self._middleItemDataList) do
		if middleData and middleData.tableData.id == goodsId then
			return middleData
		end
	end
	return nil
end

--给定一个商品id刷新其MiddleItem，如果没找到则不作处理
function BuyWidget:UpdateMiddleItem(goodsId)
	local middleItem = self:GetMiddleItemByGoodsId(goodsId)
	if middleItem then
		middleItem:OnBuy()
	end
	
	--刷新right区域当前显示
	local middleData = self:GetMiddleDataByGoodsId(goodsId)
	if middleData then
		self._rightItem:UpdateOnBuy(middleData)
	else
		GameLog.LogError("CommerceBuy.BuyWidget.UpdateMiddleItem -> middleData is nil, goodsId = %s", goodsId)
	end
end

--购买返回
function BuyWidget:OnBuy(goodsId)
	--刷新对应的MiddleDataItem
	self:UpdateMiddleItem(goodsId)
end

function BuyWidget:RegEvent()
	if #self._events > 0 then
		return
	end
	self._events[1] = MessageSub.Register(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO, self.OnGotSpecInfo, self)
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, self.OnLevelUp, self);
	self._events[3] = MessageSub.Register(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_BUY, self.OnBuy, self)
end

function BuyWidget:UnRegEvent()
	if #self._events == 0 then
		return
	end
	MessageSub.UnRegister(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO, self._events[1])
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, self.OnLevelUp, self);
	MessageSub.UnRegister(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_BUY, self._events[3])
	self._events = {}
end

--在界面内，从其他页签切换到该页签回调
function BuyWidget:Show()
	self:RegEvent()
	
	self:SetVisible(true)
	
	--初始化左侧列表
	self._sourceData = CommerceMgr.GetOneTwoList()
	self._tableAndGrid:Show(self._sourceData)
	
	--每次打开，请求服务器数据
	--但内部，是否真的发送消息由Mgr判断并维护
	CommerceMgr.SendGoodsSpecInfo()
end

function BuyWidget:HideAllMiddleItem()
	for _, middleItem in ipairs(self._middleItemList) do
		if middleItem then
			middleItem:Hide()
		end
	end
end

--在界面内，从该页签切换到其他页签回调
function BuyWidget:Hide()
	self:SetVisible(false)
	self:HideAllMiddleItem()
	self._tableAndGrid:Hide()
	self._rightItem:Hide()
	
	self._curOneDataIdx = - 1
	self._curTwoDataIdx = - 1
	self._curOneType = - 1
	self._curTwoType = - 1
	self._curMiddleItemRealIdx = - 1
	
	self._lastPanelPos = self._middlePanelTrs.localPosition
	
	self:UnRegEvent()
end

function BuyWidget:GoodsId2RealIdx(goodsId)
	if not self._middleItemDataList then
		return - 1
	end
	for idx, middleData in ipairs(self._middleItemDataList) do
		if middleData and middleData.tableData.id == goodsId then
			return idx
		end
	end
	return - 1
end

function BuyWidget:RealIdx2MiddleData(realIdx)
	if realIdx and self._middleItemDataList then
		return self._middleItemDataList[realIdx]
	end
	return nil
end

--goodsId为-1时重置right，如果不为-1则用特定goodsId对应的MiddleData初始化
function BuyWidget:ShowMiddle(middleItemDataList, goodsId)
	
	self._middleItemDataList = middleItemDataList
	
	if goodsId == - 1 then
		self._curMiddleItemRealIdx = - 1
	else
		self._curMiddleItemRealIdx = self:GoodsId2RealIdx(goodsId)
	end
	
	local showingData = self:RealIdx2MiddleData(self._curMiddleItemRealIdx)
	self._rightItem:Show(showingData, self._buyOrSell)
	
	local count = #self._middleItemDataList
	if count >= self._middleItemMaxNum then
		if self._curMiddleItemRealIdx ~= - 1 and showingData then
			--有要主动显示的物品时，scrollview下滑到该物品位置
			self._wrap:WrapContentWithPosition(count, self._funcOnInit, self._lastPanelPos)
		else
			self._wrap:ResetWrapContent(count, self._funcOnInit)
		end
	else
		self._wrap:ResetWrapContent(count, self._funcOnInit)
	end
end

function BuyWidget:OnInit(go, wrapIdx, realIdx)
	local item = self._middleItemList[wrapIdx + 1]
	local data = self._middleItemDataList[realIdx + 1]
	
	if item and data then
		data.wrapIdx = wrapIdx + 1
		data.realIdx = realIdx + 1
		item:Show(data, self._curMiddleItemRealIdx)
	end
end

function BuyWidget:OnDestroy()
	for _, middleItem in ipairs(self._middleItemList) do
		if middleItem then
			middleItem:OnDestroy()
		end
	end
	self._tableAndGrid:OnDestroy()
end
------------------------------------BuyWidget------------------------------------
return BuyWidget 