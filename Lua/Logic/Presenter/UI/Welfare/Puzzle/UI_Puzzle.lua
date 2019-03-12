module("UI_Puzzle", package.seeall)

local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

--组件
local mSelf

local mTop

local mMiddle
local mPieceItemTemp
local mPieceListParent

local mBottom
local mIconItemTemp
local mIconItemParentList = {}
local mSpecIconItemParent
local mPopListTemp
local mFlyTempParent
local mFlyTemp

local mRight


--变量
local mPieceItemList = {}
local mIconItemList = {}
local mSpecIconItem
local mPopList
local mFlyItem
local mPieceList

local mEvents = {}

--PieceItem
local PieceItem = class("PieceItem")
function PieceItem:ctor(ui, path, clickHandler)
	--组件
	self._transfrom = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._tex = ui:FindComponent("UITexture", path .. "tex")
	self._texTrs = ui:Find(path .. "tex")
	self._texGo = ui:FindGo(path .. "tex")
	self._tweenAlpha = ui:FindComponent("TweenAlpha", path .. "tex")
    self._tweenAlpha.enabled = false
    self._lis = UIEventListener.Get(self._texGo)
	self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)
	
	--loader
	self._texLoader = LoaderMgr.CreateTextureLoader(self._tex)
	
	--变量
	self._data = {}
	self._pos = Vector3.zero
	self._duration = 0.5
	self._fromAlpha = 1
	self._toAlpha = 0
	self._left = 0
	self._right = 0
	self._up = 0
    self._down = 0
    self._clickSpecIconItem = false
    self._clickHandler = clickHandler
	
	self:Hide()
end

--万能碎片被点击使用按钮后，点击了某个碎片
function PieceItem:OnClick(eventData)
    if self._clickHandler then
        self._clickHandler(self._data, self._clickSpecIconItem)
    end
    if self._clickSpecIconItem then
        self._clickSpecIconItem = false
    end
end

function PieceItem:Hide()
	self._gameObject:SetActive(false)
end

--界面销毁时，销毁loader，并卸载资源
function PieceItem:OnDestroy()
	if self._texLoader then
		LoaderMgr.DeleteLoader(self._texLoader)
		self._texLoader = nil
	end
end

function PieceItem:Show(data)
	self._data = data
	self._gameObject:SetActive(true)
	
	local resID = ResConfigData.GetResConfigID(self._data.data.texName)
	self._texLoader:LoadObject(resID)
	self._texLoader:SetPixelPerfect();
	self._pos.x = self._data.data.posX
	self._pos.y = self._data.data.posY
	self._texTrs.localPosition = self._pos
	
	self._right = self._tex.width / 2
	self._left = - self._right
	self._up = self._tex.height / 2
	self._down = - self._up
	
	self:CheckInsetState()
end

--显示碎片是否拼合
function PieceItem:ShowInsetState(isInset)
	self._fromAlpha = isInset and 1 or 0.5
	self._tex.alpha = self._fromAlpha
end

--检测该碎片是否已经镶嵌
function PieceItem:CheckInsetState()
	local isInset = self:CheckIsInset()
	self:ShowInsetState(isInset)
end

function PieceItem:CheckIsInset()
	return PuzzleMgr.CheckIsInset(self._data.data.pieceId)
end

--领取完大奖后，刷新
function PieceItem:OnGetAward()
    self:CheckInsetState()
end

--播放镶嵌碎片特效
function PieceItem:PlayAddAni()
	GameLog.LogError("--------------------------------------PieceItem.PlayAddAni -> 播放镶嵌特效")
end

function PieceItem:OnAdd()
	self:CheckInsetState()
	self:PlayAddAni()
end

--播放卸下碎片特效（目前没这个需求）
function PieceItem:PlayRemoveAni()
	GameLog.LogError("--------------------------------------PieceItem.PlayRemoveAni -> 播放卸下特效")
end

function PieceItem:OnRemove()
	self:CheckInsetState()
	self:PlayRemoveAni()
end

function PieceItem:GetPosition()
	return self._texTrs.position
end

function PieceItem:GetData()
    return self._data
end

--播放可镶嵌特效
function PieceItem:PlayAni(clickSpecIconItem)
    self._clickSpecIconItem = clickSpecIconItem

	self._tweenAlpha.enabled = true
	self._tweenAlpha.from = self._fromAlpha
	self._tweenAlpha.to = self._toAlpha
	self._tweenAlpha.duration = self._duration
	self._tweenAlpha:ResetToBeginning()
	self._tweenAlpha:PlayForward()
end

function PieceItem:IsClickSpecIconItem()
    return self._clickSpecIconItem
end

function PieceItem:StopAni()
	self._tweenAlpha.enabled = false
	self._tweenAlpha:ResetToBeginning()
    self._tex.alpha = self._fromAlpha
    
    if self._clickSpecIconItem then
        self._clickSpecIconItem = false
    end
end

--检查一个世界坐标是否落在该碎片区域内
function PieceItem:CheckIsInPiece(position)
	local localPos = self._texTrs:InverseTransformPoint(position)
	if self._left <= localPos.x and localPos.x <= self._right
	and self._down <= localPos.y and localPos.y <= self._up then
		return true
	else
		return false
	end
end

function PieceItem:GetPieceId()
    return self._data.data.pieceId
end

--IconItem
local IconItem = class("IconItem")
function IconItem:ctor(ui, path, clickHandler, dragStartHandler, dragEndHandler)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	self._widget = ui:FindComponent("UIWidget", path)

	self._ui = ui
	path = path .. "/"
	self._path = path
	
	self._itemTrs = ui:Find(path .. "item")
	self._temp = ui:Find(path .. "temp")
	self._count = ui:FindComponent("UILabel", path .. "count")
	self._lis = UIEventListener.Get(self._gameObject)
	self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)
	self._lis.onDragStart = UIEventListener.VoidDelegate(self.OnDragStart, self)
	self._lis.onDragEnd = UIEventListener.VoidDelegate(self.OnDragEnd, self)
	self._lis.onDrag = UIEventListener.VectorDelegate(self.OnDrag, self)

	--
	self._item = GeneralItem.new(self._itemTrs, nil)
	
	--变量
	self._data = {}
	self._clickHandler = clickHandler
	self._draged = false
	self._dragedPos = Vector2.zero
	self._tempPos = Vector3.zero
	self._uiRoot = UIMgr.GetUIRoot()
	self._dragStartHandler = dragStartHandler
	self._dragEndHandler = dragEndHandler
	
	self:Hide()
end

function IconItem:OnClick(eventData)
	if self._clickHandler then
		self._clickHandler(self._data)
	end
end

function IconItem:OnDrag(eventData, delta)
	if self._draged then
		delta = delta * self._uiRoot.pixelSizeAdjustment
		self._dragedPos = self._dragedPos + delta
		self._tempPos.x = self._dragedPos.x
		self._tempPos.y = self._dragedPos.y
		self._temp.localPosition = self._tempPos
		mFlyItem:Drag(self._temp.position)
	end
end

function IconItem:OnDragStart(eventData)
	--判断该碎片数量
	local num = PuzzleMgr.GetItemNum(self._data.data.itemId)
	if num <= 0 then
		TipsMgr.TipByFormat("碎片不足")
		return
	end
	self._dragedPos.x = self._transform.localPosition.x
	self._dragedPos.y = self._transform.localPosition.y
	self._draged = true
	mFlyItem:DragStart(self._data)
	
	if self._dragStartHandler then
		self._dragStartHandler(self._data)
	end
end

function IconItem:OnDragEnd(eventData)
	if self._draged then
		self._draged = false
		if self._dragEndHandler then
			self._dragEndHandler(self._data)
		end
		--最后执行
		mFlyItem:DragEnd()
	end
end

function IconItem:DoShowItem()
	self._item:ShowByItemId(self._data.data.itemId)
end

function IconItem:DoShowNum()
	local num = PuzzleMgr.GetItemNum(self._data.data.itemId)
	self._count.text = tostring(num)
	self:ShowState(num)
end

function IconItem:Show(data)
	self._data = data
	self._gameObject:SetActive(true)
	
    self:DoShowItem()
    self:DoShowNum()
end

function IconItem:OnNumChange()
    self:DoShowNum()
end

function IconItem:ShowState(num)
	if num > 0 then
		self._widget.alpha = 1
	else
		self._widget.alpha = 0.5
	end
end

function IconItem:Hide()
	self._gameObject:SetActive(false)
end

function IconItem:OnDisable()
end

function IconItem:GetPosition()
	return self._transform.position
end

function IconItem:GetData()
    return self._data
end

function IconItem:OnDestroy()
	self._item:OnDestroy()
end

--PopList
local PopList = class("PopList")
function PopList:ctor(ui, path, useHandler)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._wishBtn = ui:FindGo(path .. "btn1")
	self._useBtn = ui:FindGo(path .. "btn2")
	self._wishLis = UIEventListener.Get(self._wishBtn)
	self._wishLis.onClick = UIEventListener.VoidDelegate(self.OnClickWish, self)
	self._useLis = UIEventListener.Get(self._useBtn)
	self._useLis.onClick = UIEventListener.VoidDelegate(self.OnClickUse, self)
	self._mask = ui:FindGo(path .. "mask")
	self._maskLis = UIEventListener.Get(self._mask)
	self._maskLis.onClick = UIEventListener.VoidDelegate(self.OnClickMask, self)
	
	--变量
	self._isShowed = false
	self._showPos = Vector3(0, 100, 0)
	self._data = {}
	self._useHandler = useHandler
	
	self:Hide()
end

function PopList:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function PopList:Show(data, position, showUse, showWish)
	self:SetVisible(true)
	self._data = data
	
	self:SetPos(position)
    self._useBtn:SetActive(showUse)
    self._wishBtn:SetActive(showWish)
end

function PopList:SetPos(position)
	self._transform.position = position
	self._transform.localPosition = self._transform.localPosition + self._showPos
end

function PopList:Hide()
	self:SetVisible(false)
end

--祈愿
function PopList:OnClickWish(eventData)
	PuzzleMgr.SendWish()
end

--使用
function PopList:OnClickUse(eventData)
	if self._useHandler then
		self._useHandler(self._data)
	end
end

--遮罩
function PopList:OnClickMask(eventData)
	self:Hide()
end

function PopList:GetData()
    return self._data
end

--FlyItem
local FlyItem = class("FlyItem")
function FlyItem:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._mask = ui:FindGo(path .. "mask")
	self._itemTrs = ui:Find(path .. "item")
	self._tweenPos = ui:FindComponent("TweenPosition", path .. "item")
	self._tweenPos.enabled = false
	self._finishFuncOnTp = EventDelegate.Callback(self.OnTpFinish, self)
	EventDelegate.Set(self._tweenPos.onFinished, self._finishFuncOnTp)

	--
	self._item = GeneralItem.new(self._itemTrs, nil)
	
	--变量
	self._isShowed = false
    self._iconData = {}
    self._pieceData = {}
	self._duration = 0.5
	self._zeroPos = Vector3.zero
	
	self:Hide()
end

function FlyItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function FlyItem:Show(iconData, pieceData)
    self._iconData = iconData
    self._pieceData = pieceData
	self:SetVisible(true)
	self:DoShowItem()	
end

function FlyItem:DoShowItem()
	self._item:ShowByItemId(self._iconData.data.itemId)
end

function FlyItem:Fly(iconData, pieceData, fromPos, toPos)
	self:Show(iconData, pieceData)
	
	self._tweenPos.enabled = true
	self._tweenPos.worldSpace = true
	self._tweenPos.from = fromPos
	self._tweenPos.to = toPos
	self._tweenPos.duration = self._duration
	self._tweenPos:ResetToBeginning()
	self._tweenPos:PlayForward()
end

function FlyItem:Hide()
	self._tweenPos.enabled = false
	self:SetVisible(false)
end

function FlyItem:ShowMask()
	self._mask:SetActive(true)
end

function FlyItem:HideMask()
	self._mask:SetActive(false)
end

function FlyItem:OnTpFinish()
    self:Hide()
    
	local type = NetCS_pb.CSPuzzleOnOff.PUT_ON
	local mapId = PuzzleMgr.GetCurPuzzleId()
    local itemId = self._iconData.data.itemId
    local pieceId = self._pieceData.data.pieceId
	PuzzleMgr.SendInset(type, mapId, itemId, pieceId)
end

function FlyItem:DragStart(data)
	self:Show(data)
end

function FlyItem:Drag(position)
	self:SetItemParentPos(position)
end

function FlyItem:DragEnd()
	self:ResetItemParentPos()
	self:Hide()
end

function FlyItem:SetItemParentPos(position)
	self._itemTrs.position = position
end

function FlyItem:ResetItemParentPos()
	self._itemTrs.localPosition = self._zeroPos
end

function FlyItem:GetPosition()
	return self._itemTrs.position
end

function FlyItem:OnDestroy()
	self._item:OnDestroy()
end

--PieceList
local PieceList = class("PieceList")
function PieceList:ctor(ui, path, enabledHandler, insetHandler)
    --组件
    self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	self._panel = ui:FindComponent("UIPanel", path)
	self._tweenScale = ui:FindComponent("TweenScale", path)
	
	self._ui = ui
	path = path .. "/"
	self._path = path

	
	self._mask = ui:FindGo(path .. "mask")
	self._inset = ui:FindGo(path .. "inset")
    self._maskLis = UIEventListener.Get(self._mask)
    self._maskLis.onClick = UIEventListener.VoidDelegate(self.OnClickMask, self)
    self._insetLis = UIEventListener.Get(self._inset)
    self._insetLis.onClick = UIEventListener.VoidDelegate(self.OnClickInset, self)
    self._tweenScale.enabled = false

    --变量
    self._enabled = false
    self._depthEnable = 320
    self._depthDisable = 301
    self._enabledHandler = enabledHandler
    self._insetHandler = insetHandler
    self._fromScale = Vector3.one
    self._toScale = Vector3(0.95, 0.95, 1)
    self._duration = 0.5

    self:SetEnabled(false)
    self:SetInsetVisible(false)
end

function PieceList:SetPanelDepth(enabled)
    if enabled then
        self._panel.depth = self._depthEnable
        self._panel.sortingOrder = self._depthEnable
    else
        self._panel.depth = self._depthDisable
        self._panel.sortingOrder = self._depthDisable
    end
end

function PieceList:SetMaskVisible(visible)
    self._mask:SetActive(visible)
end

function PieceList:ShowInset()
    self:SetInsetVisible(true)
end

function PieceList:HideInset()
    self:SetInsetVisible(false)
end

function PieceList:SetInsetVisible(visible)
    self._inset:SetActive(visible)
end

function PieceList:SetEnabled(enabled)
	self._enabled = enabled

    self:SetPanelDepth(self._enabled)
    self:SetMaskVisible(self._enabled)

    if self._enabledHandler then
        self._enabledHandler(self._enabled)
    end
end

function PieceList:OnClickMask(eventData)
    self:SetEnabled(false)
end

function PieceList:OnClickInset(eventData)
    if self._insetHandler then
        self._insetHandler()
    end
end

--全部拼合后的特效
function PieceList:PlayAni()
    self._tweenScale.enabled = true
    self._tweenScale.from = self._fromScale
    self._tweenScale.to = self._toScale
    self._tweenScale.duration = self._duration
    self._tweenScale:ResetToBeginning()
    self._tweenScale:PlayForward()

    self:ShowInset()

    GameLog.LogError("----------------------------------PieceList.PlayAni -> 全部拼合后的特效")
end

function PieceList:StopAni()
    self._tweenScale.enabled = false
    self._tweenScale:ResetToBeginning()
    self._transform.localScale = self._fromScale

    self:HideInset()
end

--local方法
local function StopAllPieceItemAni()
    for _, item in pairs(mPieceItemList) do
        if item and item:IsClickSpecIconItem() then
            item:StopAni()
        end
    end
end

--PieceList.enabled变化，外部处理方法
local function OnSetPieceListEnabled(enabled)
    if not enabled then
        StopAllPieceItemAni()
    end
end

--点击PieceList的Inset按钮，外部处理方法
local function OnClickPieceListInset()
    --检测是否全部拼合
    if PuzzleMgr.CheckInsetAll() then
        mPieceList:StopAni()

        --发送领取大奖
        local curPuzzleId = PuzzleMgr.GetCurPuzzleId()
        PuzzleMgr.SendGetAward(curPuzzleId)
    end
end

--点击IconItem外部处理方法
local function OnClickIconItem(data)
	local iconItem = mIconItemList[data.data.pieceId]
    local num = PuzzleMgr.GetItemNum(data.data.itemId)
    local showPopList = true
    local showUse = num > 0
    local showWish = true
	if data.spec then
        iconItem = mSpecIconItem
        showWish = false
        showPopList = showUse
    end
	if showPopList and iconItem and mPopList then
        local position = iconItem:GetPosition()
        mPopList:Show(data, position, showUse, showWish)
	end
end

local function CheckPieceItemAndPlayAni(pieceItem, clickSpecIconItem)
    if pieceItem and not pieceItem:CheckIsInset() then
        pieceItem:PlayAni(clickSpecIconItem)
    end
end

--拖拽IconItem开始
local function OnDragIconItemStart(data)
	if data.spec then
		--万能碎片
        for _, item in pairs(mPieceItemList) do
            CheckPieceItemAndPlayAni(item, false)
		end
	else
		--没拼合，对应碎片显示特效
        local pieceItem = mPieceItemList[data.data.pieceId]
        CheckPieceItemAndPlayAni(pieceItem, false)
	end
end


local function CheckPieceItemAndSendInset(pieceItem, position, data)
	if pieceItem then
		pieceItem:StopAni()
		--在碎片区域内
		if pieceItem:CheckIsInPiece(position) then
			--还未拼合
			if not pieceItem:CheckIsInset() then
				local type = NetCS_pb.CSPuzzleOnOff.PUT_ON
				local mapId = PuzzleMgr.GetCurPuzzleId()
                local itemId = data.data.itemId
                local pieceId = data.data.pieceId
                if data.spec then
                    pieceId = pieceItem:GetPieceId()
				end
				if data.spec then
					--弹出确认框
					local str = "是否使用万能碎片"
					local okFunc = function()
						PuzzleMgr.SendInset(type, mapId, itemId, pieceId)	
					end
					TipsMgr.TipConfirmByStr(str, okFunc)
				else
					PuzzleMgr.SendInset(type, mapId, itemId, pieceId)
				end
			else
				--已经拼合
				TipsMgr.TipByFormat("该碎片已镶嵌")
			end
		end
	end
end

--拖拽IconItem结束
local function OnDragIconItemEnd(data)
    local position = mFlyItem:GetPosition()
	if data.spec then
		--万能碎片
        for _, item in pairs(mPieceItemList) do
            CheckPieceItemAndSendInset(item, position, data)
		end
	else
		--判断是否拖拽到了指定碎片上
        local pieceItem = mPieceItemList[data.data.pieceId]
        CheckPieceItemAndSendInset(pieceItem, position, data)
	end
end

local function CheckAndFly(iconItem, pieceItem)
    if iconItem and pieceItem then
        local fromPos = iconItem:GetPosition()
        local toPos = pieceItem:GetPosition()
        local iconData = iconItem:GetData()
        local pieceData = pieceItem:GetData()
        mFlyItem:Fly(iconData, pieceData, fromPos, toPos)
    end
end

--当使用了万能碎片后，点击PieceItem，外部处理方法
local function OnClickPieceItem(data, clickSpecIconItem)
    if clickSpecIconItem then
        mPieceList:SetEnabled(false)
    end

    if clickSpecIconItem then
        local iconData = mPopList:GetData()
        local iconItem = mIconItemList[iconData.data.pieceId]
        if iconData.spec then
            iconItem = mSpecIconItem
        end
		local pieceItem = mPieceItemList[data.data.pieceId]
		local str = "是否使用万能碎片"
		local okFunc = function()
			CheckAndFly(iconItem, pieceItem)
		end
		TipsMgr.TipConfirmByStr(str, okFunc)
    end
end

--点击PopList的使用按钮，外部处理方法
local function OnClickPopListUseBtn(data)
    --检查该碎片是否已经镶嵌
    if data.spec then
        if PuzzleMgr.CheckInsetAll() then
            TipsMgr.TipByFormat("拼图已完成")
            return            
        end
    else
        if PuzzleMgr.CheckIsInset(data.data.pieceId) then
            TipsMgr.TipByFormat("该碎片已镶嵌")
            return
        end
    end
    mPopList:Hide()
	if data.spec then
        mPieceList:SetEnabled(true)
        for _, item in pairs(mPieceItemList) do
            CheckPieceItemAndPlayAni(item, true)
        end
    else
        local iconItem = mIconItemList[data.data.pieceId]
        local pieceItem = mPieceItemList[data.data.pieceId]
        CheckAndFly(iconItem, pieceItem)
	end
end

local function InitPieceItemList()
	local list = PuzzleMgr.GetStaticData()
	local trs
	local childPath = nil
	for idx, data in ipairs(list) do
		if not data.spec then
			trs = mSelf:DuplicateAndAdd(mPieceItemTemp, mPieceListParent, 0)
			trs.name = "pieceitem" .. tostring(idx)
			if not mPieceItemList[data.data.pieceId] then
				childPath = "offset/middle/piecelist/pieceitem" .. tostring(idx)
				mPieceItemList[data.data.pieceId] = PieceItem.new(mSelf, childPath, OnClickPieceItem)
			else
				GameLog.LogError("UI_Puzzle.InitPieceItemList -> pieceId repeated, pieceId = %s", data.data.pieceId)
			end
		end
	end
end

local function InitIconItemList()
	local list = PuzzleMgr.GetStaticData()
	local trs
	local zero = Vector3.zero
	local norIdx = 0
	local childPath = nil
	for _, data in ipairs(list) do
		if not data.spec then
			trs = mSelf:DuplicateAndAdd(mIconItemTemp, mIconItemParentList[data.data.pieceId], 0)
			trs.name = "iconitem"
			trs.localPosition = zero
			if not mIconItemList[data.data.pieceId] then
				norIdx = norIdx + 1
				childPath = string.format("%s%s%s", "offset/bottom/iconlist/icon", tostring(norIdx), "/iconitem")
				mIconItemList[data.data.pieceId] = IconItem.new(mSelf, childPath, OnClickIconItem, OnDragIconItemStart, OnDragIconItemEnd)
			else
				GameLog.LogError("UI_Puzzle.InitIconItemList -> pieceId repeated, pieceId = %s", data.data.pieceId)
			end
		else
			trs = mSelf:DuplicateAndAdd(mIconItemTemp, mSpecIconItemParent, 0)
			trs.name = "iconitem"
			trs.localPosition = zero
			childPath = "offset/bottom/iconspec/iconitem"
			mSpecIconItem = IconItem.new(mSelf, childPath, OnClickIconItem, OnDragIconItemStart, OnDragIconItemEnd)
		end
	end
end

local function ShowPieceList()
	local list = PuzzleMgr.GetStaticData()
	local item
	for _, data in pairs(list) do
		if not data.spec then
			item = mPieceItemList[data.data.pieceId]
			if item then
				item:Show(data)
			end
		end
	end
end

local function ShowIconList()
	local list = PuzzleMgr.GetStaticData()
	local item
	for _, data in pairs(list) do
		if data.spec then
			item = mSpecIconItem
		else
			item = mIconItemList[data.data.pieceId]
		end
		if item then
			item:Show(data)
		end
	end
end

local function AllIconItemOnDestroy()
	for _, item in pairs(mIconItemList) do
		if item then
			item:OnDestroy()
		end
	end
	if mSpecIconItem then
		mSpecIconItem:OnDestroy()
		mSpecIconItem = nil
	end

	if mFlyItem then
		mFlyItem:OnDestroy()
		mFlyItem = nil
	end
end

--界面暂时没有OnDestroy事件
local function AllPieceItemOnDestroy()
	for _, pieceItem in ipairs(mPieceItemList) do
		if pieceItem then
			pieceItem:OnDestroy()
		end
	end
end

--检测是否全部拼合
local function CheckInsetAll()
    if PuzzleMgr.CheckInsetAll() then
        mPieceList:PlayAni()
    end
end

--领取完奖励
local function OnGetAward()
    for _, item in pairs(mPieceItemList) do
        if item then
            item:OnGetAward()
        end
    end
end

--获取拼图进度数据
local function OnGetPieceIdNums()
    ShowPieceList()
    CheckInsetAll()
end

--获取到拼图背包数据
local function OnGetBagData()
	ShowIconList()
end

local function OnBagUpdate()
    for _, item in pairs(mIconItemList) do
        if item then
            item:OnNumChange()
        end
    end
    if mSpecIconItem then
        mSpecIconItem:OnNumChange()
    end
end

--拼图里增加新碎片
local function OnAddPiece(pieceId)
	if pieceId then
		local pieceItem = mPieceItemList[pieceId]
		if pieceItem then
			pieceItem:OnAdd()
		end
    end

    CheckInsetAll()
end

--拼图里某个碎片被卸下（目前没这个需求）
local function OnRemovePiece(pieceId)
	if pieceId then
		local pieceItem = mPieceItemList[pieceId]
		if pieceItem then
			pieceItem:OnRemove()
		end
	end
end

local function RegEvent(self)
	GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETPUZZLEDATA, OnGetPieceIdNums)
	GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETBAGDATA, OnGetBagData)
	GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_ADDPIECE, OnAddPiece)
    GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_REMOVEPIECE, OnRemovePiece)
    GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETAWARD, OnGetAward)
    GameEvent.Reg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_UPDATEBAGDATA, OnBagUpdate)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETPUZZLEDATA, OnGetPieceIdNums)
	GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETBAGDATA, OnGetBagData)
	GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_ADDPIECE, OnAddPiece)
    GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_REMOVEPIECE, OnRemovePiece)
    GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETAWARD, OnGetAward)
    GameEvent.UnReg(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_UPDATEBAGDATA, OnBagUpdate)
end

function OnCreate(self)
	mSelf = self
	
	mMiddle = self:Find("offset/middle")
	mPieceItemTemp = self:Find("offset/middle/temp")
	mPieceItemTemp.localPosition = Vector3.zero
	mPieceItemTemp.gameObject:SetActive(false)
    mPieceListParent = self:Find("offset/middle/piecelist")
    mPieceList = PieceList.new(mSelf, "offset/middle/piecelist", OnSetPieceListEnabled, OnClickPieceListInset)
	
	mBottom = self:Find("offset/bottom")
	mIconItemTemp = self:Find("offset/bottom/temp")
	mIconItemTemp.gameObject:SetActive(false)
	for idx = 1, 8 do
		mIconItemParentList[idx] = self:Find("offset/bottom/iconlist/icon" .. idx)
	end
	mSpecIconItemParent = self:Find("offset/bottom/iconspec")
	mPopListTemp = self:FindGo("offset/bottom/poplist")
	mPopListTemp:SetActive(false)
	mPopList = PopList.new(mSelf, "offset/bottom/poplist", OnClickPopListUseBtn)
    mFlyTempParent = self:Find("offset/bottom/flytempparent")
    mFlyTempParent.gameObject:SetActive(true)
	mFlyTemp = self:FindGo("offset/bottom/flytempparent/flytemp")
	mFlyTemp:SetActive(false)
	mFlyItem = FlyItem.new(mSelf, "offset/bottom/flytempparent/flytemp")
	
	--
	InitPieceItemList()
	InitIconItemList()
end

function OnEnable(self)
	RegEvent(self)
	
	PuzzleMgr.SendOnOpenUI()
end

function OnDisable(self)
	UnRegEvent(self)
end

function OnClick(go, id)
	if id == - 1 then
		--UIMgr.UnShowUI(AllUI.UI_Puzzle)
	end
end

--界面销毁时，销毁loader
function OnDestroy(self)
	AllPieceItemOnDestroy()
	AllIconItemOnDestroy()
end
