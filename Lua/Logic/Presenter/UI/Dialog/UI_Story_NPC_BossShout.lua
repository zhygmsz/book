module("UI_Story_NPC_BossShout", package.seeall)

--组件
local mSelf
local mRoot
local mItemTemp
local mItemTempA
local mContent

--变量
local mParamData
local mShoutItemList = {}
local mShoutItemListA = {}
local mMaxContentLen = 350

--BossShoutItem
local BossShoutItem = class("BossShoutItem", nil)
function BossShoutItem:ctor(ui, path, hideHandler)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offset = ui:Find(path .. "offset")
	self._bg = ui:FindComponent("UISprite", path .. "offset/bg")
	self._content = ui:FindComponent("UILabel", path .. "offset/content")

	--变量
	self._isShowed = false
	self._hideHandler = hideHandler
end

function BossShoutItem:Show(dialogData)
	self:Reset()

	self._dialogData = dialogData
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	self._content.text = dialogData.content[1].data
	self._content:Update()
	
	self._bg:Update()
	
	--写死位置，不再接受配置
	--self._offset.localPosition = Vector3(dialogData.offsetX, dialogData.offsetY, 0)
	
	local disAppearTime = dialogData.disAppearTime[1]
	if not disAppearTime then
		disAppearTime = 5000
	end
	local showedTime = tonumber(disAppearTime / 1000)
	self._timerIdx = GameTimer.AddTimer(showedTime, 1, self.OnShowEnd, self)
end

function BossShoutItem:OnShowEnd()
	self._timerIdx = nil
	self:Hide(true)
end

function BossShoutItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
end

function BossShoutItem:GetDialogGroupId()
	if self._dialogData then
		return self._dialogData.dialogID
	else
		return - 1
	end
end

function BossShoutItem:Hide(isExeHandler)
	self._gameObject:SetActive(false)
	self._isShowed = false

	self:Reset()
	
	if isExeHandler then
		if self._hideHandler then
			self._hideHandler()
		end
	end
end

function BossShoutItem:IsShowed()
	return self._isShowed
end


--local方法
local function RegEvent(self)
	
end

local function UnRegEvent(self)
	
end

local function GetIndex(needAnchor)
	local itemList = mShoutItemList
	if needAnchor then
		itemList = mShoutItemListA
	end
	local targetIndex = - 1
	for idx = 1, #itemList do
		local item = itemList[idx]
		if item and(not item:IsShowed()) then
			targetIndex = idx
			break
		end
	end
	if targetIndex == - 1 then
		targetIndex = #itemList + 1
		local trs = mSelf:DuplicateAndAdd(needAnchor and mItemTempA or mItemTemp, mRoot, 0)
		trs.name = needAnchor and "itemtempa" or "itemtemp"
		trs.name = trs.name .. tostring(targetIndex)
		itemList[targetIndex] = BossShoutItem.new(mSelf, "offset/" .. trs.name, HideHandler)
	end
	return targetIndex
end

local function GetShoutItem(needAnchor)
	local index = GetIndex(needAnchor)
	if not index then
		return
	end
	if needAnchor then
		return mShoutItemListA[index]
	else
		return mShoutItemList[index]
	end
end

local function IsNeedAnchor(dialogData)
	mContent.text = dialogData.content[1].data
	mContent:Update()
	return mContent.width > mMaxContentLen
end

local function CheckIsAllHide()
	local isAllHide = true
	for idx = 1, #mShoutItemList do
		local item = mShoutItemList[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	for idx = 1, #mShoutItemListA do
		local item = mShoutItemListA[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	return isAllHide
end

local function HideShoutList(shoutList)
	for _, item in pairs(shoutList) do
		if item and item:IsShowed() then
			item:Hide()
		end
	end
end

local function HideAllShout()
	HideShoutList(mShoutItemList)
	HideShoutList(mShoutItemListA)
end

local function CollectSameIdShout(inShoutList, outShoutList, dialogGroupID)
	for _, item in pairs(inShoutList) do
		if item and item:GetDialogGroupId() == dialogGroupID then
			table.insert(outShoutList, item)
		end
	end
end

local function GetShoutItemListByID(dialogGroupID)
	local shoutItemList = {}
	CollectSameIdShout(mShoutItemList, shoutItemList, dialogGroupID)
	CollectSameIdShout(mShoutItemListA, shoutItemList, dialogGroupID)
	return shoutItemList
end


--全局方法
function OnCreate(self)
	mSelf = self
	mRoot = self:Find("offset")
	mItemTemp = self:Find("offset/item1")
	mItemTempA = self:Find("offset/item2")
	mItemTemp.gameObject:SetActive(false)
	mItemTempA.gameObject:SetActive(false)
	mContent = self:FindComponent("UILabel", "offset/content")
end

function OnEnable(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.BOSS_SHOUT, true)
	RegEvent(self)
	ShowShout()
end

function OnDisable(self)
	HideAllShout()
	UnRegEvent(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.BOSS_SHOUT, false)
end

function SetData(paramData)
	mParamData = paramData
end

function ShowShout()
	local dialogDatas = mParamData.dialogDatas
	if not dialogDatas then
		return
	end
	for idx = 1, #dialogDatas do
		local dialogData = dialogDatas[idx]
		if dialogData then
			local needAnchor = IsNeedAnchor(dialogData)
			local item = GetShoutItem(needAnchor)
			if item then
				item:Show(dialogData)
			end
		end
	end
end

function HideHandler()
	if CheckIsAllHide() then
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_BossShout)
	end
end

function HideShoutByID(dialogGroupID)
	local shoutItemList = GetShoutItemListByID(dialogGroupID)
	for _, item in pairs(shoutItemList) do
		if item and item:IsShowed() then
			item:Hide(true)
		end
	end
end 