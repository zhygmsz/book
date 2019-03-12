module("UI_Bag_Equip", package.seeall)

--组件
local mSelf
local mPanel
local mEquipScore
local mRenderTexture
local mEquipItems = {}
local MAX_EQUIP
local mCurSelectIndex = - 1
local mOffset
local mEquipedEffectMgr
local mFacadeBtn

--变量
--UI槽位到部位映射
local Index2Bodytype = nil
--部位到UI槽位映射
local Bodytype2Index = nil

local BodyType2Icon = {
	[Item_pb.ItemInfo.WEAPON] = "img_beibao_wuqi",
	[Item_pb.ItemInfo.BRACERS] = "img_beibao_huwan",
	[Item_pb.ItemInfo.GLOVES] = "img_beibao_shoutao",
	[Item_pb.ItemInfo.RING] = "img_beibao_jiezhi",
	[Item_pb.ItemInfo.CLOTHES] = "img_beibao_yifu",
	[Item_pb.ItemInfo.BELT] = "img_beibao_yaodai",
	[Item_pb.ItemInfo.SHOES] = "img_beibao_xie",
	[Item_pb.ItemInfo.NECKLACE] = "img_beibao_xianglian"
}

local mShowModelOnOpen = true

local mItemBgNormal = "frame_common_12"
local mItemBgDisable = "frame_common_hui"

local mIsDoubleClick = false


--EquipItem
local EquipItem = class("EquipItem")
function EquipItem:ctor(ui, path, idx)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	self._uiEvent = ui:FindComponent("GameCore.UIEvent", path)
	self._uiEvent.id = idx

	self._ui = ui
	path = path .. "/"
	self._path = path
	--部位索引，[1, 10]
	self._idx = idx

	self._bodyType = EquipMgr.Index2Bodytype[idx]

	self._itemIcon = ui:FindComponent("UISprite", path .. "ItemIcon")
	self._itemIconGo = ui:FindGo(path .. "ItemIcon")
	self._selectedGo = ui:FindGo(path .. "ItemSelect")
	self._bg = ui:FindComponent("UISprite", path .. "ItemBg")
	self._bgGo = ui:FindGo(path .. "ItemBg")
	self._lockGo = ui:FindGo(path .. "lock")
	self._defaultIcon = ui:FindComponent("UISprite", path .. "icon")
	self._defaultIconGo = ui:FindGo(path .. "icon")

	--这块判断静态处理，槽位开放功能作为预留
	if self._bodyType then
		--槽位开放
		self._bg.spriteName = mItemBgNormal
		self._lockGo:SetActive(false)
		self._defaultIcon.spriteName = BodyType2Icon[self._bodyType]
	else
		--槽位未开放
		self._bg.spriteName = mItemBgDisable
		self._lockGo:SetActive(true)
	end

	self._selectedGo:SetActive(false)
	self._defaultIconGo:SetActive(false)
	self._itemIconGo:SetActive(false)

	--变量
	--该槽位对应的装备数据
	self._itemSlot = nil
	self._pos = self._transform.position
end

function EquipItem:Show()
	if not self._bodyType then
		return
	end
	--尝试获取到对应部位的装备数据
	local itemSlot = EquipMgr.GetEquipedItemSlotByBodyType(self._bodyType)
	self._itemSlot = itemSlot
	if itemSlot then
		--该部位有装备
		self._defaultIconGo:SetActive(false)
		self._itemIconGo:SetActive(true)
		local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
		if itemData then
			self._itemIcon.spriteName = itemData.icon_big
			self._bg.spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality)
		else
			GameLog.LogError("EquipItem.Show -> itemData is nil")
		end
	else
		--该部位没装备
		self._bg.spriteName = UIUtil.GetItemQualityBgSpName()
		self._defaultIconGo:SetActive(true)
		self._itemIconGo:SetActive(false)
	end
end

--[[
    @desc: 
    --@curSelectedIdx: 当前选中的idx
]]
function EquipItem:UpdateSelected(curSelectedIdx)
	self._selectedGo:SetActive(curSelectedIdx == self._idx)
end

function EquipItem:GetItemSlot()
	return self._itemSlot
end

function EquipItem:GetPos()
	return self._pos
end


--EffectItem
local EffectItem = class("EffectItem")
function EffectItem:ctor()
	--组件

	--loader
	self._effLoader = LoaderMgr.CreateEffectLoader()

	--变量
	self._isShowed = false
	self._duration = 1
	self._timerIdx = nil
	--特效要播放的位置，世界坐标
	self._targetPos = nil
	self._firstSetting = true
	--用于移出屏幕来实现隐藏效果
	self._farPos = Vector3(10000, 10000, 0)

	self:Hide()
end

function EffectItem:Reset()
	if self._timerIdx then
		TimerMgr.Back(self._timerIdx)
		self._timerIdx = nil
	end
end

function EffectItem:Show(pos)
	self:Reset()

	self._targetPos = pos

	--加载特效
	self._effLoader:LoadObject(GameAsset.UI_beibao_eff01)
	
	--设置类方法，只调用一次
	if self._firstSetting then
		self._firstSetting = false

		self._effLoader:SetLayer(CameraLayer.UILayer)
		self._effLoader:SetParent(mOffset)
		self._effLoader:SetLocalPosition(Vector3.zero)
		self._effLoader:SetLocalScale(Vector3.one)
		self._effLoader:SetLocalRotation(UnityEngine.Quaternion.identity)
		self._effLoader:SetSortOrder(mPanel.sortingOrder + 1)
	end
	self._effLoader:SetPosition(self._targetPos)
	self._effLoader:SetActive(true)

	self._isShowed = true

	GameTimer.AddTimer(self._duration, 1, self.OnEffectEnd, self)
end

function EffectItem:OnEffectEnd()
	self._timerIdx = nil
	self:Hide()
end


function EffectItem:Hide()
	self:Reset()
	self._isShowed = false

	--self._effLoader:Clear()
end

function EffectItem:IsShowed()
	return self._isShowed
end

--[[
    @desc: UI.OnDisable时，移除界面
]]
function EffectItem:OnDisable()
	self._effLoader:SetPosition(self._farPos)
end

function EffectItem:OnDestroy()
	if self._effLoader then
		LoaderMgr.DeleteLoader(self._effLoader)
		self._effLoader = nil
	end
	self._firstSetting = true
end

--EquipedEffectMgr
local EquipedEffectMgr = class("EquipedEffectMgr")
function EquipedEffectMgr:ctor(trs)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject

	--变量
	self._effectList = {}

	self:Init()
end

function EquipedEffectMgr:Init()
	--预先生成1个，如果之后超过_MaxEffectNum个，则动态生成新的
	for idx = 1, 1 do
		self._effectList[idx] = EffectItem.new()
	end
end

function EquipedEffectMgr:GetUnshowedItem()
	for _, item in ipairs(self._effectList) do
		if not item:IsShowed() then
			return item
		end
	end
	return nil
end

function EquipedEffectMgr:Create()
	self._effectList[#self._effectList + 1] = EffectItem.new()
	return self._effectList[#self._effectList]
end

function EquipedEffectMgr:GetEffect()
	local item = self:GetUnshowedItem()
	if item then
		return item
	else
		return self:Create()
	end
end

function EquipedEffectMgr:Play(pos)
	local effectItem = self:GetEffect()
	if effectItem then
		effectItem:Show(pos)
	end
end

function EquipedEffectMgr:OnDisable()
	for _, item in ipairs(self._effectList) do
		item:OnDisable()
	end
end

function EquipedEffectMgr:OnDestroy()
	for _, item in ipairs(self._effectList) do
		item:OnDestroy()
	end
	self._effectList = nil
end

--local方法
local function DestroyEffect()
	if mEquipedEffectMgr then
		mEquipedEffectMgr:OnDestroy()
		mEquipedEffectMgr = nil
	end
end

--[[
    @desc: 
    --@pos: 世界坐标
]]
local function PlayEffect(pos)
	if mEquipedEffectMgr then
		mEquipedEffectMgr:Play(pos)
	end
end

--切换配装方案
local function ShowModel()
	CameraRender.RenderEntity(AllUI.UI_Bag_Equip,mRenderTexture,UserData.PlayerAtt);
end

local function OnSwitchEquip()
	ShowModel()
end

--装备格子变化前
local function OnUpdateGridPre(bagType)
	if bagType == Bag_pb.EQUIP then
		
	end
end

local function UpdateSelect()
	for _, equipItem in ipairs(mEquipItems) do
		equipItem:UpdateSelected(mCurSelectIndex)
	end
end

local function SelectEquip(index)
	mCurSelectIndex = index
	UpdateSelect()
end

local function OnOtherSelect(uiType)
	if uiType ~= AllUI.UI_Bag_Equip then
		SelectEquip(- 1)
	end
end

local function ShowEquip()
	if not mEquipItems then
		return
	end
	for _, equipItem in ipairs(mEquipItems) do
		equipItem:Show()
	end
end

--获取装备数据
local function OnUpdatePackage(bagType)
	if bagType == Bag_pb.EQUIP then
		ShowEquip()
	end
end

--装备格子变化
local function OnUpdateGrid(bagType)
	if bagType == Bag_pb.EQUIP then
		ShowEquip()
	end
end

--外显变化
local function OnApprantChange()
	mShowModelOnOpen = false
	ShowModel()
end

local function OnBagOperation(bagType, oper)
end

local function OnMoveItem(data)
	if not data then
		GameLog.LogError("UI_Bag_Main.OnMoveItem -> data is nil")
		return
	end
	if data.toType == Bag_pb.EQUIP then
		--GameLog.Log("UI_Bag_Equip.OnMoveItem -> data.toSlotId = %s", data.toSlotId)
		local index = Bodytype2Index[data.toSlotId + 1]
		local equipItem = mEquipItems[index]
		if equipItem then
			PlayEffect(equipItem:GetPos())
		else
			GameLog.LogError("UI_Bag_Main.OnMoveItem -> equipItem is nil, toSlotId = %s, index = %s", data.toSlotId, index)
		end
	end
end

local function DoClick(id)
	if mIsDoubleClick then
		return
	end
	if Index2Bodytype[id] then
		SelectEquip(id)
		GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, AllUI.UI_Bag_Equip)
		
		UI_Bag_Main.CloseSecondUI()
		local itemSlot = mEquipItems[id]:GetItemSlot()
		if itemSlot then
			EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromEquip, itemSlot)
		end
	else
		--部位未开放
		TipsMgr.TipByKey("equip_part_not_opened")
	end
end

local function Init()
	mShowModelOnOpen = true
	ShowModel()
end

local function RegEvent(self)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_SWITCH_EQUIP, OnSwitchEquip)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID_PRE, OnUpdateGridPre)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, OnOtherSelect)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE, OnUpdatePackage)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID, OnUpdateGrid)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, OnBagOperation)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, OnMoveItem)
	
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_SWITCH_EQUIP, OnSwitchEquip)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID_PRE,OnUpdateGridPre)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT,OnOtherSelect)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE,OnUpdatePackage)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID,OnUpdateGrid)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, OnBagOperation)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM,OnMoveItem)
end

function OnCreate(self)
	Index2Bodytype = EquipMgr.Index2Bodytype
	Bodytype2Index = EquipMgr.Bodytype2Index

	--分配特效资源id
	ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_beibao_eff01.prefab")

	mSelf = self
	--MAX_EQUIP = BagMgr.GetMaxGridCount(Bag_pb.EQUIP)
	--装备栏以装备界面为准，10个槽位
	MAX_EQUIP = 10
	mOffset = self:Find("Offset")
	mPanel = mOffset.parent:GetComponent("UIPanel")
	mEquipScore = self:FindComponent("UILabel", "Offset/ScoreTitle/Score")
	for idx = 1, MAX_EQUIP do
		mEquipItems[idx] = EquipItem.new(self, "Offset/ItemList/item" .. tostring(idx), idx)
	end
	mFacadeBtn = self:FindComponent("UISprite", "Offset/FacadeBtn")
	mRenderTexture = self:FindComponent("UITexture", "Offset/RenderTexture")

	mEquipedEffectMgr = EquipedEffectMgr.new(mOffset)
end

function OnEnable(self)
	RegEvent(self)
	
	Init()
	
	--请求装备背包数据
	BagMgr.RequestBagData({Bag_pb.EQUIP})
end

function OnDisable(self)
	UnRegEvent(self)
	mCurSelectIndex = - 1
	CameraRender.DeleteEntity(AllUI.UI_Bag_Equip);
	mEquipedEffectMgr:OnDisable()
end

function OnClick(go, id)
	mIsDoubleClick = false
	if id == - 3 then
		--rt纹理
		UI_Bag_Main.CloseSecondUI()
		EquipMgr.HideEquipTips()
	elseif id == - 1 then
		--外观
		UI_Bag_Main.CloseSecondUI()
		TipsMgr.TipByKey("equip_share_not_support")
	elseif id == - 2 then
		--换装
		UI_Bag_Main.CloseSecondUI()
		TipsMgr.TipByKey("equip_share_not_support")
	elseif id == - 10 then
		--tips隐藏
		EquipMgr.HideEquipTips()
	elseif 1 <= id and id <= MAX_EQUIP then
		--限制次数
		GameTimer.AddTimer(0.2, 1, DoClick, nil, id)
	end
end

function OnDoubleClick(id)
	mIsDoubleClick = true
	if 1 <= id and id <= MAX_EQUIP then
		if Index2Bodytype[id] then
			SelectEquip(id)
			GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, AllUI.UI_Bag_Equip)

			local itemSlot = mEquipItems[id]:GetItemSlot()
			if itemSlot then
				BagMgr.RequestMoveBagItem(Bag_pb.EQUIP, itemSlot.slotId, itemSlot.item.id, Bag_pb.NORMAL, - 1)
			else
				UI_Bag_Main.CloseSecondUI()
			end
		else
			--部位未开放
			TipsMgr.TipByKey("equip_part_not_opened")
		end
	end
end

function OnDrag(delta, id)
	if id == -3 then
		CameraRender.DragEntity(AllUI.UI_Bag_Equip,delta);
	end
end

function OnDestroy(self)
	DestroyEffect()
end

--装备tips上的向左按钮
function OnLeftOnEquipTips()
	local index = 1
	local tempIndex = mCurSelectIndex
	while index <= MAX_EQUIP do
		tempIndex = tempIndex - 1
		if tempIndex < 1 then
			tempIndex = MAX_EQUIP
		end
		if  mEquipItems[tempIndex]:GetItemSlot() then
			OnClick(nil, tempIndex)
			break
		end
		
		index = index + 1
	end
end

--装备tips上的向右按钮
function OnRightOnEquipTips()
	local index = 1
	local tempIndex = mCurSelectIndex
	while index <= MAX_EQUIP do
		tempIndex = tempIndex + 1
		if tempIndex > MAX_EQUIP then
			tempIndex = 1
		end
		if mEquipItems[tempIndex]:GetItemSlot() then
			OnClick(nil, tempIndex)
			break
		end
		
		index = index + 1
	end
end
--endregion

function OnShowFacadeBtn(state)
	if mFacadeBtn then
		mFacadeBtn.transform.gameObject:SetActive(state);
	end
end