module("UI_Story_NPC_Guide", package.seeall)

--组件
local mSelf
local mRoot
local mItemTempS
local mItemTempM
local mContent

--变量
local mParamData
local mGuideItemListS = {}
local mGuideItemListM = {}
local mMaxContentLen = 275
local mEvents = {}

--GuideItem
local GuideItem = class("GuideItem", nil)
function GuideItem:ctor(trs, hideHandler)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject
	self._offset = trs:Find("offset")
	self._bg = trs:Find("offset/bg"):GetComponent("UISprite")
	self._content = trs:Find("offset/content"):GetComponent("UILabel")
	self._arrow = {}
	self._arrowSp = {}
	for idx = 1, 4 do
		self._arrow[idx] = trs:Find("offset/bg/arrow" .. tostring(idx))
		self._arrowSp[idx] = self._arrow[idx]:GetComponent("UISprite")
		self._arrow[idx].gameObject:SetActive(false)
	end

	--变量
	self._isShowed = false
	self._hideHandler = hideHandler
end

function GuideItem:GetDialogGroupId()
	if self._dialogData then
		return self._dialogData.dialogID
	else
		return -1
	end
end

function GuideItem:HideAllArrow()
	for idx = 1, 4 do
		self._arrow[idx].gameObject:SetActive(false)
	end
end

function GuideItem:Show(dialogData)
	self._gameObject:SetActive(true)
	self._isShowed = true
	self._dialogData = dialogData
	
	self._content.text = dialogData.content[1].data
	self._content:Update()
	
	self._bg:Update()
	
	local arrow = self._arrow[dialogData.guideArrow]
	local arrowSp = self._arrowSp[dialogData.guideArrow]
	if arrow and arrowSp then
		arrow.gameObject:SetActive(true)
		arrow.localPosition = self:GetArrowPos(dialogData.guideArrow, arrowSp)
	end
	
	self._offset.localPosition = Vector3(dialogData.offsetX, dialogData.offsetY, 0)

end

function GuideItem:GetArrowPos(guideArrow, arrowSp)
	local bgWidthHalf = self._bg.width / 2
	local bgHeightHalf = self._bg.height / 2
	local arrowHeightHalf = arrowSp.height / 2
	
	local posX = 0
	local posY = 0
	if guideArrow == Dialog_pb.GUIDEARROW_LEFT then
		posX = -(bgWidthHalf + arrowHeightHalf - 1.5)
	elseif guideArrow == Dialog_pb.GUIDEARROW_RIGHT then
		posX =(bgWidthHalf + arrowHeightHalf - 1.5)
	elseif guideArrow == Dialog_pb.GUIDEARROW_UP then
		posY =(bgHeightHalf + arrowHeightHalf - 1.5)
	elseif guideArrow == Dialog_pb.GUIDEARROW_BELOW then
		posY = -(bgHeightHalf + arrowHeightHalf - 1.5)
	end
	return Vector3(posX, posY, 0)
end

function GuideItem:Hide(isExeHandler)
	self._gameObject:SetActive(false)
	self._isShowed = false

	self:HideAllArrow()

	if isExeHandler then
		if self._hideHandler then
			self._hideHandler()
		end
	end
end

function GuideItem:IsShowed()
	return self._isShowed
end

--local方法
local function RegEvent(self)
end

local function UnRegEvent(self)
end

local function GetIndex(isSingle)
	local itemList = mGuideItemListM
	if isSingle then
		itemList = mGuideItemListS
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
		local trs = mSelf:DuplicateAndAdd(isSingle and mItemTempS or mItemTempM, mRoot, 0)
		itemList[targetIndex] = GuideItem.new(trs, HideHandler)
	end
	return targetIndex
end

local function GetGuideItem(isSingle)
	local index = GetIndex(isSingle)
	if isSingle then
		return mGuideItemListS[index]
	else
		return mGuideItemListM[index]
	end
end

local function CheckIsAllHide()
	local isAllHide = true
	for idx = 1, #mGuideItemListS do
		local item = mGuideItemListS[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	for idx = 1, #mGuideItemListM do
		local item = mGuideItemListM[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	return isAllHide
end

local function IsSingle(dialogData)
	mContent.text = dialogData.content[1].data
	mContent:Update()
	return mContent.width <= mMaxContentLen
end

local function HideGuideList(guideList)
	for _, item in pairs(guideList) do
		if item and item:IsShowed() then
			item:Hide()
		end
	end
end

local function HideAllGuide()
	HideGuideList(mGuideItemListS)
	HideGuideList(mGuideItemListM)
end

local function CollectSameIdGuide(inGuideList, outGuideList, dialogGroupID)
	for _, item in pairs(inGuideList) do
		if item and item:GetDialogGroupId() == dialogGroupID then
			table.insert(outGuideList, item)
		end
	end
end

local function GetGuideItemListByID(dialogGroupID)
	local guideItemList = {}
	CollectSameIdGuide(mGuideItemListS, guideItemList, dialogGroupID)
	CollectSameIdGuide(mGuideItemListS, guideItemList, dialogGroupID)
	return guideItemList
end

function OnCreate(self)
	mSelf = self
	mRoot = self:Find("offset")
	mItemTempS = self:Find("offset/item1")
	mItemTempM = self:Find("offset/item2")
	mContent = self:Find("offset/content"):GetComponent("UILabel")
	mItemTempS.gameObject:SetActive(false)
	mItemTempM.gameObject:SetActive(false)
end

function OnEnable(self)
	RegEvent(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.GUIDE, true)
	ShowGuide()
end

function OnDisable(self)
	HideAllGuide()
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.GUIDE, false)
	UnRegEvent(self)
end

function SetData(paramData)
	mParamData = paramData
end

function ShowGuide()
	local dialogDatas = mParamData.dialogDatas
	if not dialogDatas then
		return
	end
	for idx = 1, #dialogDatas do
		local dialogData = dialogDatas[idx]
		if dialogData then
			local isSingle = IsSingle(dialogData)
			local item = GetGuideItem(isSingle)
			if item then
				item:Show(dialogData)
			end
		end
	end
end

function HideHandler()
	if CheckIsAllHide() then
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_Guide)
	end
end 

function HideGuideByID(dialogGroupID)
	local guideItemList = GetGuideItemListByID(dialogGroupID)
	for _, item in pairs(guideItemList) do
		if item and item:IsShowed() then
			item:Hide(true)
		end
	end
end