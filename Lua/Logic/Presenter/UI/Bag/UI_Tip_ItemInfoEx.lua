module("UI_Tip_ItemInfoEx", package.seeall)

--组件
local mSelf
local mOffset
local mBg
local mItemTipsTemp

--变量
local mIsShowed = false
local mData
local mItemTips

local mLeftPos = Vector3(-20, 0, 0)
local mRightPos = Vector3(420, 0, 0)

--ItemTips
local ItemTips = class("ItemTips", nil)
function ItemTips:ctor(trs, ui, path)
	self._transform = trs
	self._gameObject = trs.gameObject
	
	self._ui = ui
	path = path .. "/"
	self._path = path
	
	self._offset = ui:Find(path .. "offset")
	self._offsetBg = ui:FindComponent("UISprite", path .. "offset")
	self._table = ui:FindComponent("UITable", path .. "offset/table")
	self._area1 = ui:FindComponent("UISprite", path .. "offset/table/area1")
	self._name = ui:FindComponent("UILabel", path .. "offset/table/area1/name")
	self._itemBg = ui:FindComponent("UISprite", path .. "offset/table/area1/item/itembg")
	self._itemicon = ui:FindComponent("UISprite", path .. "offset/table/area1/item/itemicon")
	self._type = ui:FindComponent("UILabel", path .. "offset/table/area1/type")
	self._func = ui:FindComponent("UILabel", path .. "offset/table/area1/func")
	self._area1Bg = ui:FindComponent("UISprite", path .. "offset/table/area1/bg")
	
	self._widget = ui:FindComponent("UIWidget", path .. "offset/table/widget")
	self._tempWidget = ui:FindComponent("UIWidget", path .. "offset/table/widget/tempwidget")
	self._widgetPanel = ui:FindComponent("UIPanel", path .. "offset/table/widget/panel")
	self._widgetTable = ui:FindComponent("UITable", path .. "offset/table/widget/panel/table")
	self._widgetHeight = 300

	self._area2 = ui:FindComponent("UISprite", path .. "offset/table/widget/panel/table/area2")
	self._dateDes = ui:FindComponent("UILabel", path .. "offset/table/widget/panel/table/area2/datedes")
	self._date = ui:FindComponent("UILabel", path .. "offset/table/widget/panel/table/area2/date")

	self._area3 = ui:FindComponent("UISprite", path .. "offset/table/widget/panel/table/area3")
	self._area3Des = ui:FindComponent("UILabel", path .. "offset/table/widget/panel/table/area3/des")
	
	self._area4 = ui:FindComponent("UISprite", path .. "offset/table/widget/panel/table/area4")
	self._area4Des = ui:FindComponent("UILabel", path .. "offset/table/widget/panel/table/area4/des")
	self._area5 = ui:FindComponent("UISprite", path .. "offset/table/widget/panel/table/area5")
	ui:FindComponent("GameCore.UIEvent", path .. "offset/table/widget/panel/table/area5/arrow").id = 1
	self._area6 = ui:FindComponent("UISprite", path .. "offset/table/area6")

	self._edge = ui:FindComponent("UISprite", path .. "offset/edge")
	
	self._btnlistTable = ui:FindComponent("UITable", path .. "offset/btnlist")
	--使用
	self._useBtn = ui:FindGo(path .. "offset/btnlist/btn1")
	--分解
	self._decomposeBtn = ui:FindGo(path .. "offset/btnlist/btn2")
	--存入仓库
	self._todepotBtn = ui:FindGo(path .. "offset/btnlist/btn3")
	--取回背包
	self._tobagBtn = ui:FindGo(path .. "offset/btnlist/btn4")
	--赠送
	self._donateBtn = ui:FindGo(path .. "offset/btnlist/btn5")
	
	for idx = 1, 6 do
		local uiEvent = ui:FindComponent("GameCore.UIEvent", path .. "offset/btnlist/btn" .. tostring(idx))
		uiEvent.id = 10 + idx
	end
	
	self._colorWhite = Color.New(1, 1, 1, 1)
	self._name.color = self._colorWhite
	self._type.color = self._colorWhite
	self._func.color = self._colorWhite
	
	self._colorTypeEnable = "[ffddad]"
	self._colorTypeDisable = "[ff0000]"
	self._colorFuncEnable = "[ffddad]"
	self._colorFuncDisable = "[ff0000]"

	self._widgetPanelBaseClipRegion = Vector4(196, -91.5, 392, 183)
end

function ItemTips:CheckType()
	local selfRacial = UserData.GetRacial()
	if self._data.data.itemData.useRacial<=0 or (self._data.data.itemData.useRacial and self._data.data.itemData.useRacial == selfRacial) then
		return true
	else
		return false
	end
end

function ItemTips:CheckLevel()
	local selfLevel = UserData.GetLevel()
	return selfLevel >= self._data.data.itemData.useLevelDown
end

function ItemTips:CheckEquip()
	local itemInfoType = self._data.data.itemData.itemInfoType
	return itemInfoType == Item_pb.ItemInfo.EQUIP
end

function ItemTips:Show(data)
	self._data = data
	self._gameObject:SetActive(true)
	
	local itemData = self._data.data.itemData
	if not itemData then
		return
	end
	
	--先全部隐藏，再选择性打开，然后自适应
	local quality = itemData and itemData.quality or - 1
	local qualityColor = UIUtil.GetItemQualityColorStr(quality)
	local itemBgName = UIUtil.GetItemQualityBgSpName(quality)
	self._area1Bg.color = EquipMgr.GetEquipTipsArea1Color(quality)
	--UIUtil.SetTexture(itemData.icon_big, self._itemicon)
	self._itemicon.spriteName = itemData.icon_big
	self._itemBg.spriteName = itemBgName
	self._name.text = qualityColor .. itemData.name .. "[-]"
	if self:CheckEquip() then
		if self:CheckType() then
			self._type.text = self._colorTypeEnable .. itemData.typedesc .. "[-]"
		else
			self._type.text = self._colorTypeDisable .. itemData.typedesc .. "[-]"
		end
	else
		self._type.text = self._colorTypeEnable .. itemData.typedesc .. "[-]"
	end
	
	if self:CheckEquip() then
		if self:CheckLevel() then
			self._func.text = self._colorFuncEnable .. itemData.coredesc .. "[-]"
		else
			self._func.text = self._colorFuncDisable .. itemData.coredesc .. "[-]"
		end
	else
		self._func.text = self._colorFuncEnable .. itemData.coredesc .. "[-]"
	end
	
	--有效期
	self._area2.gameObject:SetActive(false)
	
	--功能信息描述
	self._area3.gameObject:SetActive(true)
	self._area3Des.text = itemData.fundesc
	self._area3Des:Update()
	self._area3:Update()
	
	--文字包装描述
	if(not itemData.clientdesc) or(itemData.clientdesc and itemData.clientdesc == "-1") then
		self._area4.gameObject:SetActive(false)
	else
		self._area4.gameObject:SetActive(true)
		self._area4Des.text = itemData.clientdesc
		self._area4Des:Update()
		self._area4:Update()
	end
	
	--获取途径
	self._area5.gameObject:SetActive(true)

	--处理滑动区域
	self._widgetTable:Reposition()
	self._tempWidget:Update()
	local widgetHeight = self._tempWidget.height
	if widgetHeight > self._widgetHeight then  
		widgetHeight = self._widgetHeight
	end
	self._widget.height = widgetHeight
	self._widgetPanelBaseClipRegion.y = -widgetHeight / 2
	self._widgetPanelBaseClipRegion.w = widgetHeight
	self._widgetPanel.baseClipRegion = self._widgetPanelBaseClipRegion
	
	self._table:Reposition()
	self._offsetBg:Update()
	--self._edge:Update()
	
	if self._data.style == EquipMgr.ItemTipsStyle.FromTempId 
	or self._data.style == EquipMgr.ItemTipsStyle.FromUseItem then
		self:HideAllBtn()
	else
		if self._data.style == EquipMgr.ItemTipsStyle.FromBagOnEquip and itemData.use then
			self._useBtn:SetActive(true)
		else
			self._useBtn:SetActive(false)
		end
		if self._data.style == EquipMgr.ItemTipsStyle.FromBagOnEquip and itemData.decompose then
			self._decomposeBtn:SetActive(true)
		else
			self._decomposeBtn:SetActive(false)
		end
		if self._data.style == EquipMgr.ItemTipsStyle.FromBagOnDepot then
			self._todepotBtn:SetActive(true)
		else
			self._todepotBtn:SetActive(false)
		end
		if self._data.style == EquipMgr.ItemTipsStyle.FromDepot
		or self._data.style == EquipMgr.ItemTipsStyle.FromTempBag then
			self._tobagBtn:SetActive(true)
		else
			self._tobagBtn:SetActive(false)
		end
		if self._data.style == EquipMgr.ItemTipsStyle.FromBagOnEquip 
			or self._data.style == EquipMgr.ItemTipsStyle.FromBagOnDepot then
			self._donateBtn:SetActive(true)
		else
			self._donateBtn:SetActive(false)
		end
	end
	
	self._btnlistTable:Reposition()
end

function ItemTips:SetPos(pos)
	self._transform.localPosition = pos
end

function ItemTips:Hide()
	self._gameObject:SetActive(false)
end

function ItemTips:HideAllBtn()
	self._useBtn:SetActive(false)
	self._decomposeBtn:SetActive(false)
	self._todepotBtn:SetActive(false)
	self._tobagBtn:SetActive(false)
	self._donateBtn:SetActive(false)
end

--local方法
local function Show()
	if not mData then
		return
	end
	
	mItemTips:Show(mData)
	if mData.style == EquipMgr.ItemTipsStyle.FromDepot then
		mItemTips:SetPos(mRightPos)
	elseif mData.style == EquipMgr.ItemTipsStyle.FromBagOnEquip
	or mData.style == EquipMgr.ItemTipsStyle.FromBagOnDepot
	or mData.style == EquipMgr.ItemTipsStyle.FromUseItem 
	or mData.style == EquipMgr.ItemTipsStyle.FromTempBag then
		mItemTips:SetPos(mLeftPos)
	end
	mItemTips:Show(mData)
	--在非主界面打开时，需要添加tips背景遮罩
	if mData.style == EquipMgr.ItemTipsStyle.FromTempId 
	or mData.style == EquipMgr.ItemTipsStyle.FromUseItem then
		mBg:SetActive(true)
	else
		mBg:SetActive(false)
	end
end

local function OnUseItemCloseBtn()
	if mData.style == EquipMgr.ItemTipsStyle.FromUseItem then
		BagMgr.HideItemTips()
	end
end

local function OnUIClosed(uiData)
	if uiData == AllUI.UI_Tip_UseItem then
		if mData.style == EquipMgr.ItemTipsStyle.FromUseItem then
			BagMgr.HideItemTips()
		end
	end
end

local function RegEvent(self)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN, OnUseItemCloseBtn)
	GameEvent.Reg(EVT.COMMON, EVT.CLICKGROUD, OnUIClosed)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN, OnUseItemCloseBtn);
	GameEvent.UnReg(EVT.COMMON, EVT.CLICKGROUD,OnUIClosed);
end

--全局方法
function OnCreate(self)
	mSelf = self
	mOffset = self:Find("offset")
	mBg = self:FindGo("offset/bg")
	mBg:SetActive(false)
	mItemTipsTemp = self:Find("offset/item")
	mItemTipsTemp.gameObject:SetActive(false)
	
	local trs = self:DuplicateAndAdd(mItemTipsTemp, mOffset, 0)
	trs.name = "item1"
	mItemTips = ItemTips.new(trs, self, "offset/item1")
end

function OnEnable(self)
	RegEvent(self)
	mIsShowed = true
	Show()
end

function OnDisable(self)
	mIsShowed = false
	mItemTips:Hide()
	UnRegEvent(self)
end

function OnClick(go, id)
	if id == - 1 then
		UIMgr.UnShowUI(AllUI.UI_Tip_ItemInfoEx)
	elseif id == 1 then
		--获取途径
		TipsMgr.TipByKey("equip_share_not_support")
	elseif id == 11 then
		--使用
		if mData.data.itemData.use then
			BagMgr.UniqueUseItem(mData.bagType,mData.data,1)
			-- --batchUse是int字段
			-- if mData.data.itemData.batchUse == 1 and mData.data.item.count > 1 then
			-- 	mData.data.Num = 1
			-- 	BagMgr.ShowMultiUseItems(1, mData.data, mData.bagType, true)
			-- else
			-- 	BagMgr.RequestUseBagItem(mData.bagType, mData.data.slotId, mData.data.item.id, 1)
			-- end
		end
	elseif id == 12 then
		--分解
		if mData.data.itemData.decompose then
			if mData.data.item.count > 1 then
				BagMgr.ShowMultiUseItems(2, mData.data, mData.bagType, true)
			else
				BagMgr.RequestDecomposeBagItem(mData.bagType, mData.data.slotId, mData.data.item.id, 1)
			end
		end
	elseif id == 13 then
		--存入仓库
		BagMgr.RequestMoveBagItem(mData.bagType, mData.data.slotId, mData.data.item.id, UI_Bag_Storage.mCurSelectDEPOT, - 1)
	elseif id == 14 then
		--取回背包
		BagMgr.RequestMoveBagItem(mData.bagType, mData.data.slotId, mData.data.item.id, Bag_pb.NORMAL, - 1)
	elseif id == 15 then
		--赠送
		require("Logic/Presenter/UI/Gift/UI_Gift_Main")
		UI_Gift_Main.ShowSendItem(mData.data.itemData.id)
	end
	UIMgr.UnShowUI(AllUI.UI_Tip_ItemInfoEx)
end

function IsShowed()
	return mIsShowed
end

function SetData(data)
	mData = data
end

function ShowTips()
	Show()
end
