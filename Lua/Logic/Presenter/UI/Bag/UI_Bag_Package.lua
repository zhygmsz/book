--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_Package", package.seeall);
--格子对象数组
local mWrapGrids = {}

--itemwrap组件
local mWrap;
local mWrapCallBack;
local itemCountPerLine = 5
local MAX_WRAPITEM_COUNT = 35;
local MAX_GRID_COUNT = BagMgr.GetMaxGridCount(Bag_pb.NORMAL);
local MIN_GRID_COUNT = BagMgr.GetMinGridCount(Bag_pb.NORMAL)
local mDragPanel;
local DragOffSetTable = {}
--全部格子数据数组
local mGridDatas = {};
local MAX_UNLOCK = 10;
local mCurGridCount = 50;
local mCurGridLock = 0;
--当前选中格子
local mCurSelectIndex = - 1;
--当前背包数据
local mCurrentBagData = nil
local mLastSelectC = - 1
--当前选择的物品类别
local mCurSelectC = - 1;
--全部
local mToggleAll;
--装备
local mToggleEquip;
--材料
local mToggleStuff;
--消耗品
local mToggleConsume;

local mDoubleClick = false
--格子占用label
local mPercentNum

local mScrollView = nil
local mScrollPanel = nil

local mArrangeBtn = nil

local mOriginY = 0
local mEndY = 1540
local mCountPerLine = 5
local mBackData = {}
local mForwardData = {}
local mBackBeginIdx
local mBackEndIdx
local mForwardBeginIdx
local mForwardEndIdx
local mMoveSVMaxDeltaY = 500
local mCanArrange = true
--整理倒计时
local mTimer = nil
local mTimeLbale = nil
--==============================--
--desc:界面创建初始化 注册事件
--time:2018-04-26 08:00:16
--@self:
--@return 
--==============================--
function OnCreate(self)
	local itemPrefab = self:Find("Offset/ItemPrefab");
	mWrap = self:FindComponent("UIWrapContent", "Offset/ItemParent/ScrollView/ItemWrap");
	mWrap.itemCountPerLine = itemCountPerLine
	mCountPerLine = mWrap.itemCountPerLine
	mDragPanel = self:Find("Offset/ItemParent/ScrollView").transform;
	
	mToggleAll = self:FindComponent("UIToggle", "Offset/CToggles/TAll");
	mToggleEquip = self:FindComponent("UIToggle", "Offset/CToggles/TEquip");
	mToggleStuff = self:FindComponent("UIToggle", "Offset/CToggles/TStuff");
	mToggleConsume = self:FindComponent("UIToggle", "Offset/CToggles/TConsume");
	mPercentNum = self:FindComponent("UILabel", "Offset/PercentNum");
	
	for i = 1, MAX_WRAPITEM_COUNT do
		mWrapGrids[i] = NewItem(self, itemPrefab, i);
	end
	itemPrefab.gameObject:SetActive(false);
	mScrollView = mDragPanel:GetComponent("UIScrollView");
	mOriginY = mScrollView.transform.localPosition.y
	mScrollPanel = mDragPanel:GetComponent("UIPanel");
	mArrangeBtn = self:FindComponent("GameCore.UIEvent", "Offset/ArrangeBtn");
	mTimeLbale = self:FindComponent("UILabel", "Offset/ArrangeBtn/timer");
	mParentEvent = self:FindComponent("UIEvent", "Offset/ItemParent");
	mParentEvent.id = -10000
	InitPanel();
end

function NewItem(self, obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemicon = item.transform:Find("ItemIcon"):GetComponent("UISprite");
	item.itemcount = item.transform:Find("ItemCount"):GetComponent("UILabel");
	item.itemselect = item.transform:Find("ItemSelect").gameObject;
	item.itemlock = item.transform:Find("ItemLock").gameObject;
	item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
	--item.loader = LoaderMgr.CreateTextureLoader(item.itemicon);
	item.gameObject:SetActive(false);
	BagMgr.AddNewItemEffectToBagItem(item)
	return item;
end

local mEvents = {};
function RegEvent(self)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE, OnPackageUpdate);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UNLOCK_GRID, OnGridUnLock);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_ARRANGE_BAG, OnPackageArrange);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID, OnGridUpdate);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, OnMoveItem);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, OnUseItem);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, OnOtherSelect);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_DECOMPOSE, OnDeCompose);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE, OnPackageUpdate);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UNLOCK_GRID, OnGridUnLock);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_ARRANGE_BAG, OnPackageArrange);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID, OnGridUpdate);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, OnMoveItem);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, OnUseItem);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, OnOtherSelect);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_DECOMPOSE, OnDeCompose);
	mEvents = {};
end

function OnEnable(self)
	RegEvent(self);
	--BagMgr.RequestBagData({Bag_pb.NORMAL});
	mToggleAll.value = true
	mToggleEquip.value = false
	mToggleStuff.value = false
	mToggleConsume.value = false
	UpdateView()
	InitBorderData()
	UpdateBeat:Add(Update,self);
end

function OnDisable(self)
	DragOffSetTable[mCurSelectC] = mDragPanel.localPosition
	mCurSelectC = - 1;
	mCurSelectIndex = - 1;
	mLastSelectC = - 1
	UnRegEvent(self);
	UIUtil.CleanTextureCache()
	UpdateBeat:Remove(Update,self);
end

function onDestroy(self)
	BagMgr.ClearBagNewItems()
end

function Update()
	if mTimer then
		mTimeLbale.text = string.format("%.2d",GameTimer.GetTimerLeftDuration(mTimer)) 
	else
		mTimeLbale.text = ""
	end
end
--==============================--
--desc:UI布局函数
--time:2018-04-26 08:00:51
--@return 
--==============================--
--初始化面板
function InitPanel()
	mScrollView.resetOffset = Vector3.zero;
	mScrollPanel.clipOffset = Vector2.zero;
	mDragPanel.localPosition = Vector3.zero;
	--mScrollView.onStoppedMoving= LateUpdatView
end


function LateUpdatView()
	mWrap:WrapContent();
end

--移动的最大数值
function MoveOffsetMaxY()
	local count = NewGridCount()
	local countPerLine = mCountPerLine
	local cellHeight = mWrap.itemHeight
	local itemHeight = mWrapGrids[1].itembg.height
	local padding = cellHeight - itemHeight
	local lines = math.ceil(count / countPerLine)
    local viewSizeY = mScrollPanel.baseClipRegion.w
    mMoveSVMaxDeltaY = viewSizeY
	local defaultLines = math.floor(viewSizeY / cellHeight)
	local beginY = mOriginY
	mEndY = cellHeight * lines - padding - viewSizeY + beginY
	return mEndY
end

--刷险背包界面显示
function UpdateView()
	local selectindex = mLastSelectC ~= mCurSelectC and mLastSelectC or mCurSelectC
	mLastSelectC = mCurSelectC
	mCurrentBagData = BagMgr.BagData[Bag_pb.NORMAL]
	if mCurrentBagData then
		mGridDatas = BagMgr.GetGridDatas(Bag_pb.NORMAL, mCurSelectC)
		if DragOffSetTable[selectindex] == nil then
			DragOffSetTable[selectindex] = Vector3.New(0, 0, 0)
		else
			DragOffSetTable[selectindex].y =Mathf.Clamp(mDragPanel.localPosition.y, 0, MoveOffsetMaxY())
		end
		local N = table.getn(mCurrentBagData.items)
		mPercentNum.text = string.format("%d/%d", N, mCurrentBagData.maxSlots)
		UpdateLayout();
	end
end

--scrollowview布局
function UpdateLayout()
	local mDRAG_FINISH_OFFSET = DragOffSetTable[mCurSelectC] or Vector3.New(0, 0, 0)
	table.sort(mWrapGrids, function(a, b) return a.gameObject.name < b.gameObject.name; end);
	for k, v in pairs(mWrapGrids) do if v then v.uiEvent.id = k; end end
	if not mWrapCallBack then mWrapCallBack = UIWrapContent.OnInitializeItem(OnInitGrid); end
	mWrap:WrapContentWithPosition(NewGridCount(), mWrapCallBack, mDRAG_FINISH_OFFSET);
end

--当前物品格子数
function NewGridCount()
	local curGridCount = #mGridDatas;
	mCurGridCount = curGridCount <= MAX_GRID_COUNT and curGridCount or MAX_GRID_COUNT;
	if mCurGridCount <= MIN_GRID_COUNT then
		mCurGridCount = MIN_GRID_COUNT
	end
	return mCurGridCount;
end

--初始化各自信息 范围内的可见 
function OnInitGrid(go, wrapIndex, realIndex)
	if realIndex >= 0 and realIndex < mCurGridCount then
		go:SetActive(true);
		InitGrid(wrapIndex + 1, realIndex + 1);
	else
		-- local Grid = mWrapGrids[gridID];
		-- BagMgr.ShowNewItemEffect(Bag_pb.NORMAL,Grid)
		go:SetActive(false);
	end
end

--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID, dataID)
	local Grid = mWrapGrids[gridID];
	local data = mGridDatas[dataID];
	Grid.itemicon.spriteName = ""
	if data and data.itemData then
		-- local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
		-- UIUtil.SetTexture(loadResID,Grid.itemicon)
		Grid.itemicon.spriteName = data.itemData.icon_big
	end

	local bgid =(data and data.itemData) and data.itemData.quality or nil
	if data and data.lock then bgid = -1 end
	Grid.itembg.spriteName = UIUtil.GetItemQualityBgSpName(bgid)
	Grid.itemcount.text =(data and data.item and data.item.count > 1) and tostring(data.item.count) or "";
	Grid.itemselect:SetActive((data) and mCurSelectIndex == dataID or false);
	Grid.itemlock:SetActive(data and data.lock or false);
	Grid.data = nil
	if data then
		Grid.data = data
	end
	Grid.gridID = gridID;
	Grid.dataID = dataID;
	Grid.gameObject:SetActive(true);
	BagMgr.ShowNewItemEffect(Bag_pb.NORMAL,Grid)
end

--清楚新物品显示
function ClearNewItemIcons()
	for i = 1, MAX_WRAPITEM_COUNT do
		local item = mWrapGrids[i];
		if item then
			BagMgr.RemoveNewItemEffect(Bag_pb.NORMAL,item)
		end
	end
end

function UpdateSelect()
	for i = 1, MAX_WRAPITEM_COUNT do
		local item = mWrapGrids[i];
		if item and item.gameObject.activeSelf then
			item.itemselect:SetActive((item.data) and mCurSelectIndex == item.dataID or false);
			if mCurSelectIndex == item.dataID then
			   BagMgr.RemoveNewItemEffect(Bag_pb.NORMAL,item)
			end
		end
	end
end

function OnLeftOnEquipTips()
    local leftDataId = BagMgr.GetLastEquipDataIndex(Bag_pb.NORMAL, mCurSelectC, mCurSelectIndex)
	--代码模拟拖拽，更新mWrapGrids内容
	AdjustScrollView(leftDataId, true)
	for i = 1, #mWrapGrids do
		local item = mWrapGrids[i]
		if item and item.dataID == leftDataId then
            --OnClick(nil, i)
            DoClick(i)
		end
	end
end

function OnRightOnEquipTips()
    local rightDataId = BagMgr.GetNextEquipDataIndex(Bag_pb.NORMAL, mCurSelectC, mCurSelectIndex)
    AdjustScrollView(rightDataId, false)
	for i = 1, #mWrapGrids do
		local item = mWrapGrids[i]
		if item and item.dataID == rightDataId then
            --OnClick(nil, i)
            DoClick(i)
		end
	end
end

function DoClick(id)
	if mDoubleClick == false then
		if id >= 1 then
			--点击物品
			local item = mWrapGrids[id];
			mCurSelectIndex = item.dataID;
			if item.data and item.data.lock then
				BagMgr.UnlockPackageGrid(0)
				EquipMgr.HideEquipTips()
				BagMgr.HideItemTips()
			else
				if item.data and item.data.itemData then
					UI_Bag_Main.CloseSecondUI();
					local itemInfoType = item.data.itemData.itemInfoType
					--装备显示装备详情
					if itemInfoType == Item_pb.ItemInfo.EQUIP then
						if UI_Bag_Main.mCurSelectR == 101 then
                            EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromBagOnEquip, item.data.titem)
						elseif UI_Bag_Main.mCurSelectR == 102 then
                            EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromBagOnDepot, item.data.titem)
						end
					else
						--其他类型
						if UI_Bag_Main.mCurSelectR == 101 then
                            BagMgr.OpenItemTipsByData(EquipMgr.ItemTipsStyle.FromBagOnEquip, item.data, Bag_pb.NORMAL)
						elseif UI_Bag_Main.mCurSelectR == 102 then
                            BagMgr.OpenItemTipsByData(EquipMgr.ItemTipsStyle.FromBagOnDepot, item.data, Bag_pb.NORMAL)
						end
					end
				else
					UI_Bag_Main.CloseSecondUI();
				end
			end
			UpdateSelect();
			GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, AllUI.UI_Bag_Package);
		else
			UI_Bag_Main.CloseSecondUI();
		end
	end
end
--整理按钮恢复
function ResetArrangeBtn()
	mCanArrange = true
	mTimer = nil
end

--点击事件处理
function OnClick(go, id)
	GameLog.Log("id %d", id)
	mDoubleClick = false;
	if id <= - 1 and id >= - 4 then
		if mCurSelectC ~= id then
			UI_Bag_Main.CloseSecondUI();
			mScrollView.currentMomentum = Vector3.New(0, 0, 0)
			mScrollView:DisableSpring()
			--点击类别按钮
			mLastSelectC = mCurSelectC
			mCurSelectC = id
			UpdateView()
		end
	elseif id == - 5 then
		if mCanArrange then
			--点击整理
			BagMgr.RequestArrangeBag(Bag_pb.NORMAL);
			mCanArrange = false
			local cd = BagMgr.GetArrangementCd()
			mTimer = GameTimer.AddTimer(cd, 1, ResetArrangeBtn,nil, id);
		else
			TipsMgr.TipByKey("backpack_info_3");
		end
	elseif id >= 1 then
		GameTimer.AddTimer(0.2, 1, DoClick,nil, id);
	end
end

function OnDoubleClick(id)
	if id >= 1 then
		mDoubleClick = true;
		UI_Bag_Main.CloseSecondUI();
		local item = mWrapGrids[id];
		mCurSelectIndex = item.dataID;
		UpdateSelect();
		GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_OTHER_SELECT, AllUI.UI_Bag_Package);
		if item.data and item.data.itemData then
			--装备界面打开状态
			if UI_Bag_Main.mCurSelectR == 101 then
				BagMgr.UniqueUseItem(Bag_pb.NORMAL,item.data,1)
				--仓库界面打开状态
			elseif UI_Bag_Main.mCurSelectR == 102 then
				if item.data and item.data.itemData and item.data.item.count >= 1 then
					BagMgr.RequestMoveBagItem(Bag_pb.NORMAL, item.data.slotId, item.data.item.id, UI_Bag_Storage.mCurSelectDEPOT, - 1)
				end
			end
		end
	end
end

--==============================--
--desc:消息回调
--time:2018-04-26 08:02:15
--@bagType:
--@return 
--==============================--
--收到背包信息更新的回调
function OnPackageUpdate(bagType)
	if bagType == Bag_pb.NORMAL then
		BagMgr.CheckTempNewItemTempId(Bag_pb.NORMAL)
		UpdateView();
	end
end
--解锁回调
function OnGridUnLock()
	UpdateView();
end

--整理回调
function OnPackageArrange(result)
	--成功
	if result.ret == 0 and result.bagType == Bag_pb.NORMAL then
		UI_Bag_Main.CloseSecondUI()
		BagMgr.SaveTempNewItemTempId(Bag_pb.NORMAL)
		ClearNewItemIcons()
		BagMgr.RequestBagData({Bag_pb.NORMAL})
	end
end

function OnGridUpdate(bagType)
	if bagType == Bag_pb.NORMAL then
		UpdateView();
	end
end

function OnOpenStorage(state)
	if mGold then
		mGold.transform.parent.gameObject:SetActive(not state);
		mYB.transform.parent.gameObject:SetActive(not state);
		OnSwitch();
	end
end

function OnSwitch()
	mCurSelectIndex = - 1;
	--UpdateLayout();
end

function OnMoveItem(redata)
	if redata.fromType == Bag_pb.NORMAL or redata.toType == Bag_pb.NORMAL then
		UI_Bag_Main.CloseSecondUI();
	end
end

function OnUseItem(redata)
	if redata and redata.bagType == Bag_pb.NORMAL then
		UI_Bag_Main.CloseSecondUI();
		--UpdateView();
	end
end

function OnOtherSelect(uiType)
	if uiType ~= AllUI.UI_Bag_Package then
		mCurSelectIndex = - 1;
		UpdateSelect();
	end
end

function OnDeCompose(bagType)
	if bagType == Bag_pb.NORMAL then
		UI_Bag_Main.CloseSecondUI();
	end
end

--初始化边界值位置
function InitBorderData()
	local count = NewGridCount()
	local countPerLine = mCountPerLine
	local cellHeight = mWrap.itemHeight
	local itemHeight = mWrapGrids[1].itembg.height
	local padding = cellHeight - itemHeight
	local lines = math.ceil(count / countPerLine)
    local viewSizeY = mScrollPanel.baseClipRegion.w
    mMoveSVMaxDeltaY = viewSizeY
	local defaultLines = math.floor(viewSizeY / cellHeight)
	local beginY = mOriginY
	mEndY = cellHeight * lines - padding - viewSizeY + beginY
	local endYTemp = mEndY
    local beginYTemp = beginY
    
    mBackBeginIdx = defaultLines + 1
    mBackEndIdx = lines
    mForwardBeginIdx = 1
    mForwardEndIdx = lines - defaultLines
	
	mBackData = {}
	for lineIdx = lines, defaultLines + 1, - 1 do
		local downY = endYTemp
		if lineIdx < lines then
			downY = downY + padding
		end
		local upY = endYTemp - itemHeight
		mBackData[lineIdx] = {upY = upY, downY = downY}
		endYTemp = endYTemp - itemHeight - padding
	end
	
	mForwardData = {}
	for lineIdx = 1, lines - defaultLines, 1 do
		local upY = beginYTemp
		if lineIdx > 1 then
			upY = upY - padding
		end
		local downY = beginYTemp + itemHeight
		mForwardData[lineIdx] = {upY = upY, downY = downY}
		beginYTemp = beginYTemp + itemHeight + padding
	end
end

--调整scrollview，模拟拖拽
function AdjustScrollView(dataID, isLeft)
    local minDataID = GetMinDataIDInView()
    local maxDataID = GetMaxDataIDInView()
    if isLeft then
        if dataID < minDataID then
            DoAdjustScrollView(dataID, true)
        else
            --从第一个跳转到最后一个
            local dataCount = BagMgr.GetMaxDataID(Bag_pb.NORMAL, mCurSelectC)
            if dataID == dataCount then
                DoAdjustScrollView(dataID, false)
            else
                --超出视野范围
                if dataID > maxDataID then
                    DoAdjustScrollView(dataID, false)
                end
            end
        end
    else
        if dataID > maxDataID then
            DoAdjustScrollView(dataID, false)
        else
            --从最后一个跳转到第一个
            if dataID == 1 then
                DoAdjustScrollView(dataID, true)
            else
                --超出视野范围
                if dataID < minDataID then
                    DoAdjustScrollView(dataID, true)
                end
            end
        end
    end
end

--真正调整scrollview的代码
function DoAdjustScrollView(dataID, isUp)
    if isUp then
        local targetLineIdx = GetLineIdxByDataID(dataID)
        local forwardData = GetForwardData(targetLineIdx)
        if forwardData then
            local curY = mScrollView.transform.localPosition.y
            local deltaY = forwardData.upY - curY
            MoveScrollView(deltaY)
            --mScrollView:MoveRelative(Vector3(0, deltaY, 0))
        end
    else
        local targetLineIdx = GetLineIdxByDataID(dataID)
        local backData = GetBackData(targetLineIdx)
        if backData then
            local curY = mScrollView.transform.localPosition.y
            local deltaY = backData.downY - curY
            MoveScrollView(deltaY)
            --mScrollView:MoveRelative(Vector3(0, deltaY, 0))
        end
    end
end

--分批次拖拽scrollview
function MoveScrollView(deltaY)
    local sign = 1
    if deltaY < 0 then
        sign = -1
    end
    deltaY = math.abs(deltaY)
    local num = math.floor(deltaY / mMoveSVMaxDeltaY)
    local mod = deltaY - num * mMoveSVMaxDeltaY
    for idx = 1, num do
        mScrollView:MoveRelative(Vector3(0, mMoveSVMaxDeltaY * sign, 0))
    end
    mScrollView:MoveRelative(Vector3(0, mod * sign, 0))
end

--获取panel显式区域的最大dataID
function GetMaxDataIDInView()
	local lineIdx = 0
	local curY = mScrollView.transform.localPosition.y
	for idx, data in pairs(mBackData) do
		if data.upY < curY and curY <= data.downY then
			lineIdx = idx
			break
		end
    end

    if lineIdx == 0 then
        local backData = mBackData[mBackEndIdx]
        if backData and curY > backData.downY then
            lineIdx = mBackEndIdx
        end
    end
    
	local maxDataID = lineIdx * mCountPerLine
	return maxDataID
end

--获取panel显式区域的最小dataID
function GetMinDataIDInView()
	local lineIdx = 0
	local curY = mScrollView.transform.localPosition.y
	for idx, data in pairs(mForwardData) do
		if data.upY <= curY and curY < data.downY then
			lineIdx = idx
			break
		end
    end
    if lineIdx == 0 then
        local forwardData = mForwardData[mForwardBeginIdx]
        if forwardData and curY < forwardData.upY then
            lineIdx = mForwardBeginIdx
        end
    end
	local minDataID =(lineIdx - 1) * mCountPerLine + 1
	return minDataID
end

--根据dataID算出行索引
function GetLineIdxByDataID(dataID)
	local lineIdx = math.ceil(dataID / mCountPerLine)
	return lineIdx
end

function GetForwardData(lineIdx)
	if lineIdx then
		return mForwardData[lineIdx]
	end
end

function GetBackData(lineIdx)
	if lineIdx then
		return mBackData[lineIdx]
	end
end

return UI_Bag_Package
