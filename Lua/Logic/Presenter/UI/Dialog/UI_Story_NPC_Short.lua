module("UI_Story_NPC_Short", package.seeall)

--组件
local mSelf
local mLeftAnchor
local mRightAnchor
local mMiddleAnchor
local mFreeAnchor  --引导对话设置相对位置时使用
local mOffset
local mLeftItem
local mRightItem
local mFreeItem

--变量
local mLeftItemList = {}
local mRightItemList = {}
local mFreeItemList = {}
local mParamData

local mLeftBaseEventId = 100
local mRightBaseEventId = 200
local mFreeBaseEventId = 300

local mEventIdSpan = 2

--ShortItem
local ShortItem = class("ShortItem")
function ShortItem:ctor(ui, path, hideHandler, eventIdBase)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._widget = ui:FindComponent("UIWidget", path .. "offset")
	self._name = ui:FindComponent("UILabel", path .. "offset/name")
	self._content = ui:FindComponent("UILabel", path .. "offset/content")
	self._contentTrs = self._content.transform
	self._contentTemp = ui:FindComponent("UILabel", path .. "offset/contenttemp")
	self._contentTemp.alpha = 0.01
	self._icon = ui:FindComponent("UITexture", path .. "offset/iconpanel/icon")
	self._icon.gameObject:SetActive(false)
	self._iconPanelTrs = ui:Find(path .. "offset/iconpanel")
	self._iconPanel = ui:FindComponent("UIPanel", path .. "offset/iconpanel")
	self._iconPanelSortingOrder = self._iconPanel.sortingOrder

	self._eventIdBase = eventIdBase
	self._bgUIEvent = ui:FindComponent("GameCore.UIEvent", path .. "offset/bg")
	self._bgUIEvent.id = eventIdBase + 1
	self._panelWidgetUIEvent = ui:FindComponent("GameCore.UIEvent", path .. "offset/panelWidget")
	self._panelWidgetUIEvent.id = eventIdBase + 2

	--loader
	self._aniLoader = LoaderMgr.CreateEffectLoader()
	
	--变量
	self._isShowed = false
	self._isLineM = true
	self._pos = self._contentTrs.localPosition
	self._posM = Vector3(self._pos.x, self._pos.y + 12, self._pos.z)
	self._contentMaxLen = 298
	self._timerIdx = nil
	self._outputData = {}
	self._hideHandler = hideHandler

	self._aniPosLeft = Vector3(-751, 58, 0)
	self._aniPosRight = Vector3(320, 58, 0)
	self._aniScale = Vector3(30, 30, 1)
end

function ShortItem:IsLineM()
	self._contentTemp.text = self._dialogData.content[1].data
	self._contentTemp:Update()
	return self._contentTemp.width > self._contentMaxLen
end

function ShortItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
end

function ShortItem:SetAlpha(alpha)
	self._widget.alpha = alpha
end

function ShortItem:Show(dialogData)
	self:Reset()
	self._dialogData = dialogData
	self._isLineM = self:IsLineM()
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	self._name.text = self._dialogData.title
	self._content.text = self._dialogData.content[1].data
	self._content:Update()
	
	local resId = DialogMgr.GetPicResId(self._dialogData.headIconName, self._dialogData)
	self._aniLoader:Clear()
	self._aniLoader:LoadObject(resId)
	self._aniLoader:SetParent(self._iconPanelTrs)
	if dialogData.headPosType == Dialog_pb.DialogData.LEFT then
		self._aniLoader:SetLocalPosition(self._aniPosLeft)
	elseif dialogData.headPosType == Dialog_pb.DialogData.RIGHT then
		self._aniLoader:SetLocalPosition(self._aniPosRight)
	end
	self._aniLoader:SetLocalScale(self._aniScale)
	self._aniLoader:SetSortOrder(self._iconPanelSortingOrder + 1)
	self._aniLoader:SetActive(true)
	
	self._isFirstShort = self._dialogData.id == mParamData.dialogDatas[1].id
	self._outputData.dialogType = Dialog_pb.DialogData.SHORT
	self._outputData.dialogID = dialogData.id
	self._outputData.groupID = dialogData.dialogID
	
	if self._isFirstShort then
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_ENTER,self._outputData);
	end
	
	local disAppearTime = self._dialogData.disAppearTime[1]
	if not disAppearTime then
		disAppearTime = 5000
	end
	local showedTime = disAppearTime / 1000
	self._timerIdx = GameTimer.AddTimer(showedTime, 1, self.OnShowEnd, self)
end

function ShortItem:OnShowEnd()
	self._timerIdx = nil
	self:Hide(true)
end

function ShortItem:Hide(isExeHandler)
	self._gameObject:SetActive(false)
	self._isShowed = false
	
	self:Reset()
	
	if self._isFirstShort then
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_FINISH,self._outputData);
	end
	
	if isExeHandler then
		if self._hideHandler then
			self._hideHandler()
		end
	end

	self._aniLoader:Clear()
end

function ShortItem:IsShowed()
	return self._isShowed
end

function ShortItem:SetParent(parent)
	if not tolua.isnull(parent) then
		self._transform.parent = parent
	end
end

function ShortItem:SetPos(pos)
	self._transform.localPosition = pos
end

function ShortItem:GetDialogGroupId()
	if self._dialogData then
		return self._dialogData.dialogID
	else
		return - 1
	end
end

function ShortItem:OnDestroy()
	if self._aniLoader then
		LoaderMgr.DeleteLoader(self._aniLoader)
		self._aniLoader = nil
	end
end

--[[
    @desc: 点击关闭该对话
]]
function ShortItem:OnClick()
	self:Hide(true)
end

--local方法
local function IsGuide()
	return mParamData.pos ~= nil
end

local function CreateShortItem(isLeft, index)
	local trs = nil
	local eventIdBase = nil
	if IsGuide() then
		eventIdBase = mFreeBaseEventId
		trs = mSelf:DuplicateAndAdd(mFreeItem, mOffset, 0)
		trs.name = "free" .. tostring(index)
	else
		if isLeft then
			eventIdBase = mLeftBaseEventId
			trs = mSelf:DuplicateAndAdd(mLeftItem, mOffset, 0)
			trs.name = "left" .. tostring(index)
		else
			eventIdBase = mRightBaseEventId
			trs = mSelf:DuplicateAndAdd(mRightItem, mOffset, 0)
			trs.name = "right" .. tostring(index)
		end
	end
	eventIdBase = eventIdBase + mEventIdSpan * (index - 1)
	return ShortItem.new(mSelf, "offset/" .. trs.name, HideHandler, eventIdBase)
end

local function GetItemList(isLeft)
	if IsGuide() then
		return mFreeItemList
	else
		if isLeft then
			return mLeftItemList
		else
			return mRightItemList
		end
	end
end

local function GetUnShowedIdx(isLeft)
	local itemList = GetItemList(isLeft)
	if not itemList then
		return
	end
	local targetIndex = - 1
	for idx, item in ipairs(itemList) do
		if not item:IsShowed() then
			targetIndex = idx
			break
		end
	end
	if targetIndex == - 1 then
		targetIndex = #itemList + 1
		local shortItem = CreateShortItem(isLeft, targetIndex)
		itemList[targetIndex] = shortItem
	end
	return targetIndex
end

local function GetShortItem(isLeft)
	local index = GetUnShowedIdx(isLeft)
	if not index then
		return
	end
	if IsGuide() then
		return mFreeItemList[index]
	else
		if isLeft then
			return mLeftItemList[index]
		else
			return mRightItemList[index]
		end
	end
end

local function SetParent(shortItem, isLeft)
	if not shortItem then
		return
	end
	local isGuide = IsGuide()
	if isGuide then
		shortItem:SetParent(mFreeAnchor)
		shortItem:SetPos(mParamData.pos)
	else
		if isLeft then
			shortItem:SetParent(mLeftAnchor)
		else
			shortItem:SetParent(mRightAnchor)
		end
		shortItem:SetPos(Vector3.zero)
	end
end

local function HideShortList(shortList)
	for _, shortItem in pairs(shortList) do
		if shortItem and shortItem:IsShowed() then
			shortItem:Hide()
		end
	end
end

local function HideAllShort()
	HideShortList(mLeftItemList)
	HideShortList(mRightItemList)
	HideShortList(mFreeItemList)
end

local function CollectSameIdShort(inList, outList, id)
	for _, item in pairs(inList) do
		if item and item:GetDialogGroupId() == id then
			table.insert(outList, item)
		end
	end
end

local function GetShortItemListById(dialogGroupID)
	local shortItemList = {}
	CollectSameIdShort(mLeftItemList, shortItemList, dialogGroupID)
	CollectSameIdShort(mRightItemList, shortItemList, dialogGroupID)
	CollectSameIdShort(mFreeItemList, shortItemList, dialogGroupID)
	return shortItemList
end

local function CheckIsAllHide()
	for idx = 1, #mLeftItemList do
		local item = mLeftItemList[idx]
		if item and item:IsShowed() then
			return false
		end
	end
	for idx = 1, #mRightItemList do
		local item = mRightItemList[idx]
		if item and item:IsShowed() then
			return false
		end
	end

	for idx = 1, #mFreeItemList do
		local item = mFreeItemList[idx]
		if item and item:IsShowed() then
			return false
		end
	end
	
	return true
end

local function DoDestroyShortItem(list)
	if not list then
		return
	end
	for _, item in ipairs(list) do
		if item and item:IsShowed() then
			item:OnDestroy()
		end
	end
end

local function AllShortItemOnDestroy()
	DoDestroyShortItem(mLeftItemList)
	DoDestroyShortItem(mRightItemList)
	DoDestroyShortItem(mFreeItemList)
end

local function OnItemClick(itemList, eventIdBase, eventId)
	eventId = eventId - eventIdBase - 1
	local itemIdx = math.floor(eventId / mEventIdSpan) + 1
	local item = itemList[itemIdx]
	if item then
		item:OnClick()
	end
end

local function RegEvent(self)
end

local function UnRegEvent(self)
end

--全局方法
function OnCreate(self)
	mSelf = self
	mLeftAnchor = self:Find("leftanchor")
	mRightAnchor = self:Find("rightanchor")
	mMiddleAnchor = self:Find("middleanchor")
	mFreeAnchor = self:Find("freeanchor")
	mOffset = self:Find("offset")
	mLeftItem = self:Find("offset/left")
	mRightItem = self:Find("offset/right")
	mFreeItem = self:Find("offset/free")
	mLeftItem.gameObject:SetActive(false)
	mRightItem.gameObject:SetActive(false)
	mFreeItem.gameObject:SetActive(false)
end

function OnEnable(self)
	RegEvent(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.SHORT, true)
	
	ShowShort()
end

function OnDisable(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.SHORT, false)
	UnRegEvent(self)
end

function OnDestroy(self)
	AllShortItemOnDestroy()
end

function OnClick(go, id)
	if mLeftBaseEventId < id and id < mRightBaseEventId then
		OnItemClick(mLeftItemList, mLeftBaseEventId, id)
	elseif mRightBaseEventId < id and id < mFreeBaseEventId then
		OnItemClick(mRightItemList, mRightBaseEventId, id)
	elseif mFreeBaseEventId < id then
		OnItemClick(mFreeItemList, mFreeBaseEventId, id)
	end
end

function SetData(paramData)
	mParamData = paramData
end

function ShowShort()
	local dialogDatas = mParamData.dialogDatas
	for idx = 1, #dialogDatas do
		local dialogData = dialogDatas[idx]
		local isLeft = dialogData.headPosType == Dialog_pb.DialogData.LEFT
		local shortItem = GetShortItem(isLeft)
		if shortItem then
			SetParent(shortItem, isLeft)
			shortItem:Show(dialogData)
		end
	end
end

function HideShortById(dialogGroupID)
	local shortItemList = GetShortItemListById(dialogGroupID)
	for _, item in pairs(shortItemList) do
		if item and item:IsShowed() then
			item:Hide(true)
		end
	end
end

function HideHandler()
	if CheckIsAllHide() then
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_Short)
	end
end