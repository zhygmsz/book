module("UI_Story_NPC_Bubble", package.seeall);

--组件
local mNormalItemTempS
local mNormalItemTempM;
local mSpecialItemTemp;
local mRoot;
local mSelf;
local mPanel
local mContent

--变量
local mNormalItemListS = {};
local mNormalItemListM = {}
local mSpecialItemList = {};
local mBubbleMaxLen = 240;
local mParamData

--BubbleItem
local BubbleItem = class("BubbleItem", nil)
function BubbleItem:ctor(ui, path, hideHandler)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offset = ui:Find(path .. "Offset")
	self._widget = self._offset:GetComponent("UIWidget")
	self._bg = ui:FindComponent("UISprite", path .. "Offset/Bg")
	self._content = ui:FindComponent("UILabel", path .. "Offset/Content")
	
	--变量
	self._isShowed = false
	self._outputData = {}
	self._localPos = Vector3.zero
	self._offsetPos = Vector3.zero
	self._localOffsetPos = Vector3.zero
	self._hideHandler = hideHandler

	self._freePos = Vector3(0, 0, 0)
end

function BubbleItem:SetAlpha(alpha)
	self._widget.alpha = alpha
end

function BubbleItem:InitOffset(dialogData)
	self._localPos.x = -(self._bg.width / 2)
	self._localPos.y = self._bg.height
	self._offset.localPosition = self._localPos

	--判断是否为自由位置
	if dialogData.bubbleX > 0 and dialogData.bubbleY > 0 then
		self._freePos.x = dialogData.bubbleX
		self._freePos.y = dialogData.bubbleY
		self._transform.localPosition = self._freePos
	else
		self:SetFollow()
	end
end

function BubbleItem:InitEventAndTimer(dialogData)
	self._isFirstBubble = dialogData.id == mParamData.dialogDatas[1].id
	self._outputData.dialogType = Dialog_pb.DialogData.BUBBLE
	self._outputData.dialogID = dialogData.id
	self._outputData.groupID = dialogData.dialogID
	
	if self._isFirstBubble then
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_ENTER,self._outputData);
	end
	
	local disAppearTime = dialogData.disAppearTime[1]
	if not disAppearTime then
		disAppearTime = 5000
	end
	local showedTime = disAppearTime / 1000
	self._timerIdx = GameTimer.AddTimer(showedTime, 1, self.OnShowEnd, self)
end

function BubbleItem:Show(dialogData)
	self:Reset()
	self._dialogData = dialogData
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	self._content.text = dialogData.content[1].data
	self._content:Update()

	self:InitEventAndTimer(dialogData)
end

function BubbleItem:OnShowEnd()
	self._timerIdx = nil
	self:Hide(true)
end

function BubbleItem:GetDialogGroupId()
	if self._dialogData then
		return self._dialogData.dialogID
	else
		return - 1
	end
end

function BubbleItem:GetHeight()
	if mParamData.isForStory then
		local npcData = NPCData.GetNPCInfo(tonumber(mParamData.npcID))
		return npcData and npcData.height
	end
	return 2
end

function BubbleItem:SetFollow()
	if mParamData.isForStory then
		if not tolua.isnull(mParamData.transform) then
			self._offsetPos.y = self:GetHeight()
			self._followID = GameUIFollow.AddFollow(mParamData.transform,self._transform,self._offsetPos,self._localOffsetPos);
		else
			GameLog.LogError("UI_Story_NPC_Bubble.BubbleItem.SetFollow -> self._dialogData.transform is null， dialogID = %s", self._dialogData.id)
		end
	else
		local playerOrNpc = nil
		--显示在指定entityID上
		if mParamData.entityID then
			playerOrNpc = MapMgr.GetEntityByID(tonumber(mParamData.entityID))
		else
			if self._dialogData.topNpcID == 0 then
				playerOrNpc = MapMgr.GetMainPlayer();
			else
				playerOrNpc = MapMgr.GetNPCByUnitID(self._dialogData.topNpcID)
			end
		end
		if playerOrNpc then
			local followTarget = playerOrNpc:GetModelComponent():GetEntityRoot()
			self._offsetPos.y = playerOrNpc:GetPropertyComponent():GetHeight()
			self._localOffsetPos.y = 40
			local hpNameItem = HpNameMgr.GetHpNameItemByEntity(playerOrNpc)
			if hpNameItem then
				local hpNameLocalOffset = hpNameItem:GetLocalOffset()
				self._localOffsetPos.y = self._localOffsetPos.y + hpNameLocalOffset.y
			end
			self._followID = GameUIFollow.AddFollow(followTarget,self._transform,self._offsetPos,self._localOffsetPos)
		else
			GameLog.LogError("UI_Story_NPC_Bubble.BubbleItem:SetFollow() -> playerOrNpc is nil, dialogID = %s", self._dialogData.id)
		end
	end
end

function BubbleItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
	
	self:SetAlpha(1)
end

function BubbleItem:Hide(isExeHandler)
	self._gameObject:SetActive(false)
	self._isShowed = false
	
	GameUIFollow.RemoveFollow(self._followID);

	if self._isFirstBubble then
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_FINISH,self._outputData);
	end
	
	self:Reset()
	
	if isExeHandler then
		if self._hideHandler then
			self._hideHandler()
		end
	end
end

function BubbleItem:IsShowed()
	return self._isShowed
end

--NormalBubble
local NormalBubble = class("NormalBubble", BubbleItem)
function NormalBubble:ctor(ui, path, hideHandler)
	BubbleItem.ctor(self, ui, path, hideHandler)
end

function NormalBubble:Show(dialogData)
	BubbleItem.Show(self, dialogData)

	self:InitOffset(dialogData)

end

--SpecialBubble
local SpecialBubble = class("SpecialBubble", BubbleItem)
function SpecialBubble:ctor(ui, path, hideHandler)
	BubbleItem.ctor(self, ui, path, hideHandler)
	
	path = path .. "/"

	self._icon = ui:FindComponent("UITexture", path .. "Offset/Icon")
	self._iconGo = self._icon.gameObject
	self._iconGo:SetActive(false)
	self._bg = ui:FindComponent("UITexture", path .. "Offset/Bg")

	self._contentTrs = ui:Find(path .. "Offset/Content")

	self._texLoader = LoaderMgr.CreateTextureLoader(self._bg);
	self._texLoader:SetPixelPerfect(true);
	self._textPos = Vector3.zero
	if self._dialogData.bubbleWidth == 0 then
		self._content.width = 100
	else
		self._content.width = self._dialogData.bubbleWidth
	end
	self._textPos.x = self._dialogData.bubbleTextX
	self._textPos.y = self._dialogData.bubbleTextY
	self._contentTrs.localPosition = self._textPos
	self._content:Update()

	self:InitOffset(self._dialogData)

	self:SetAlpha(1)
end

function SpecialBubble:Show(dialogData)
	BubbleItem.Show(self, dialogData)

	self:SetAlpha(0.01)

	--更换背景图，并调整content位置
	self._texLoader:LoadObject(dialogData.bubbleBg)
end

--local方法
local function SetAlpha(alpha)
	mPanel.alpha = alpha
end

local function OnStoryEnter()
	SetAlpha(0.01)
end

local function OnStoryFinish()
	SetAlpha(1)
end

local function HandleOnEnable()
	if UI_Story_Sequence.CheckIsShowed() then
		OnStoryEnter()
	else
		OnStoryFinish()
	end
end

local function HandleOnDisable()
	if UI_Story_Sequence.CheckIsShowed() then
		OnStoryFinish()
	end
end

local function RegEvent(self)
	GameEvent.Reg(EVT.STORY,EVT.STORY_ENTER,OnStoryEnter);
    GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH,OnStoryFinish);
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.STORY,EVT.STORY_ENTER,OnStoryEnter);
    GameEvent.UnReg(EVT.STORY,EVT.STORY_FINISH,OnStoryFinish);
end

local function CheckIsAllHide()
	local isAllHide = true
	
	for idx = 1, #mNormalItemListS do
		local item = mNormalItemListS[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	
	for idx = 1, #mNormalItemListM do
		local item = mNormalItemListM[idx]
		if item and item:IsShowed() then
			isAllHide = false
			break
		end
	end
	
	for idx = 1, #mSpecialItemList do
		local item = mSpecialItemList[idx];
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
	return mContent.width <= mBubbleMaxLen
end

local function GetItemList(norOrSpec, isSingle)
	local itemList = nil
	if norOrSpec == 1 then
		if isSingle then
			itemList = mNormalItemListS;
		else
			itemList = mNormalItemListM
		end
	elseif norOrSpec == 2 then
		itemList = mSpecialItemList;
	end
	return itemList
end

local function CreateBubbleItem(norOrSpec, isSingle, index)
	local bubbleItem = nil
	if norOrSpec == 1 then
		if isSingle then
			local trs = mSelf:DuplicateAndAdd(mNormalItemTempS, mRoot, 0)
			trs.name = "NormalItemTempS" .. tostring(index)
			bubbleItem = NormalBubble.new(mSelf, "Root/NormalItemTempS" .. tostring(index), HideHandler)
		else
			local trs = mSelf:DuplicateAndAdd(mNormalItemTempM, mRoot, 0)
			trs.name = "NormalItemTempM" .. tostring(index)
			bubbleItem = NormalBubble.new(mSelf, "Root/NormalItemTempM" .. tostring(index), HideHandler)
		end
	elseif norOrSpec == 2 then
		local trs = mSelf:DuplicateAndAdd(mSpecialItemTemp, mRoot, 0)
		trs.name = "SpecialItemTemp" .. tostring(index)
		bubbleItem = SpecialBubble.new(mSelf, "Root/SpecialItemTemp" .. tostring(index), HideHandler)
	end
	return bubbleItem
end

local function GetIndex(norOrSpec, isSingle)
	local itemList = GetItemList(norOrSpec, isSingle)
	if not itemList then
		return
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
		local bubbleItem = CreateBubbleItem(norOrSpec, isSingle, targetIndex)
		itemList[targetIndex] = bubbleItem
	end
	return targetIndex
end

local function GetBubbleItem(norOrSpec, isSingle)
	local index = GetIndex(norOrSpec, isSingle)
	if not index then
		return
	end
	if norOrSpec == 1 then
		if isSingle then
			return mNormalItemListS[index]
		else
			return mNormalItemListM[index]
		end
	elseif norOrSpec == 2 then
		return mSpecialItemList[index]
	end
end

local function HideBubbleList(bubbleList)
	for _, bubbleItem in pairs(bubbleList) do
		if bubbleItem and bubbleItem:IsShowed() then
			bubbleItem:Hide()
		end
	end
end

local function HideAllBubble()
	HideBubbleList(mNormalItemListS)
	HideBubbleList(mNormalItemListM)
	HideBubbleList(mSpecialItemList)
end

local function CollectSameIdBubble(inBubbleList, outBubbleList, dialogGroupID)
	for _, item in pairs(inBubbleList) do
		if item and item:GetDialogGroupId() == dialogGroupID then
			table.insert(outBubbleList, item)
		end
	end
end

local function GetBubbleItemListByID(dialogGroupID)
	local bubbleItemList = {}
	CollectSameIdBubble(mNormalItemListS, bubbleItemList, dialogGroupID)
	CollectSameIdBubble(mNormalItemListM, bubbleItemList, dialogGroupID)
	CollectSameIdBubble(mSpecialItemList, bubbleItemList, dialogGroupID)
	return bubbleItemList
end

function OnCreate(self)
	mSelf = self;
	mNormalItemTempS = self:Find("NormalTempS")
	mNormalItemTempM = self:Find("NormalTempM");
	mSpecialItemTemp = self:Find("SpecialTemp");
	mNormalItemTempS.gameObject:SetActive(false)
	mNormalItemTempM.gameObject:SetActive(false);
	mSpecialItemTemp.gameObject:SetActive(false);
	mRoot = self:Find("Root");
	mPanel = mRoot.parent:GetComponent("UIPanel")
	mContent = self:FindComponent("UILabel", "content")
	self:FindComponent("UILabel", "NormalTempM/Offset/Content").width = mBubbleMaxLen
end

function OnEnable(self)
	RegEvent(self);
	HandleOnEnable()
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.BUBBLE, true)
	ShowBubble()
end

function OnDisable(self)
	HideAllBubble()
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.BUBBLE, false)
	HandleOnDisable()
	UnRegEvent(self)
end

function SetData(paramData)
	mParamData = paramData
end

function ShowBubble()
	if not tolua.isnull(mParamData.transform) and mParamData.npcID then
		mParamData.isForStory = true
	else
		mParamData.isForStory = false
	end
	local dialogDatas = mParamData.dialogDatas
	for idx = 1, #dialogDatas do
		local dialogData = dialogDatas[idx]
		local norOrSpec = dialogData.bubbleType;
		local isSingle = IsSingle(dialogData)
		local bubbleItem = GetBubbleItem(norOrSpec, isSingle)
		if bubbleItem then
			bubbleItem:Show(dialogData)
		end
	end
end

function HideBubbleByID(dialogGroupID)
	local bubbleItemList = GetBubbleItemListByID(dialogGroupID)
	for _, item in pairs(bubbleItemList) do
		if item and item:IsShowed() then
			item:Hide(true)
		end
	end
end

function HideHandler()
	if CheckIsAllHide() then
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_Bubble);
	end
end 