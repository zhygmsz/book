module("UI_BigMap", package.seeall);

local MapModel = {
	WorldMap = 1,
	DetailMap = 2,
}

local mSelf;
local mUIRoot;
local mCurrentMapModel;
local mEvents;
local mIsNpcSearchMenuShown;
local mCurrentSceneId = - 1;

local mNavFlag = false;
local mNavPos;

local mOffset;

local mModelSwitchBtn;

local mWorldMapPanel;
local mWorldMapGroupTrans;
local mWorldMapTexture;
local mWorldMapLocalFlag;

local mWorldMapItemPrefab;

local mDetailMapPanel;
local mDetailMapTexture;
local mDetailMapTextureLoader;
local mDetailMapLocalFlag;
local mDetailMapNameLabel;
local mNpcItemPrefab;
local mNpcSearchMenu;
local mNpcSearchPrefab;
local mSearchScrollViewTable;
local mWorldMapItemList = {};

local mMaxNpcCount = 20;
local mNpcPool = {};
local mNpcList = {};
local mNpcSearchPool = {};
local mNpcSearchList = {};

local mTouchBeginPosition = Vector2.New(0, 0);
local mWroldMapGroupBeginPosition;

local mDetailMapScale_H;
local mDetailMapScale_V;
local mSceneCenter;

local mNpcCount = 0;

local mMapDesPanel;
local mMapDesNameLabel;
local mMapDesTable;
local mMapDesLabelList = {};

function OnCreate(self)
	mSelf = self;
	moffset = self:Find("Offset");
	mUIRoot = UIMgr.GetUIRoot()
	mModelSwitchBtn = self:FindComponent("UISprite", "Offset/UIPanel/BtnList/SwitchBtn");
	
	mWorldMapPanel = self:FindComponent("UIPanel", "Offset/WorldMapPanel");
	mWorldMapGroupTrans = self:Find("Offset/WorldMapPanel/WorldMapGroup").transform;
	mWorldMapTexture = self:FindComponent("UITexture", "Offset/WorldMapPanel/WorldMapGroup/WorldMap");
	mWorldMapLocalFlag = self:FindComponent("UISprite", "Offset/WorldMapPanel/WorldMapGroup/WroldLocalFlag");
	
	mWorldMapItemPrefab = self:Find("Offset/WorldMapPanel/WorldMapGroup/MapItemPrefab").transform;
	mWorldMapItemPrefab.gameObject:SetActive(false);
	
	mDetailMapPanel = self:FindComponent("UIPanel", "Offset/DetailMapPanel");
	mDetailMapTexture = self:FindComponent("UITexture", "Offset/DetailMapPanel/DetailMap");
	mDetailMapTextureLoader = LoaderMgr.CreateTextureLoader(mDetailMapTexture);
	mDetailMapLocalFlag = self:FindComponent("UISprite", "Offset/DetailMapPanel/DetailMap/DetailLocalFlag");
	mNpcItemPrefab = self:Find("Offset/DetailMapPanel/DetailMap/NpcItemPrefab").transform;
	mNpcItemPrefab.gameObject:SetActive(false);
	mNpcSearchMenu = self:FindComponent("UISprite", "Offset/UIPanel/SearchMenu");
	mDetailMapNameLabel = self:FindComponent("UILabel", "Offset/DetailMapPanel/MapNameBg/MapNameLabel");
	
	mSearchScrollViewTable = self:FindComponent("UITable", "Offset/UIPanel/SearchMenu/NpcListScrollView/Table");
	mNpcSearchPrefab = self:Find("Offset/UIPanel/SearchMenu/NpcListScrollView/Table/NpcSearchPrefab").transform;
	mNpcSearchPrefab.gameObject:SetActive(false);
	
	mMapDesPanel = self:FindComponent("UIPanel", "Offset/MapDesPanel");
	mMapDesPanel.gameObject:SetActive(false);
	mMapDesNameLabel = self:FindComponent("UILabel", "Offset/MapDesPanel/MapNameLabel");
	mMapDesTable = self:FindComponent("UITable", "Offset/MapDesPanel/MapDesScrollView/Table");
	local desLabel0 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel0");
	local desLabel1 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel1");
	local desLabel2 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel2");
	local desLabel3 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel3");
	local desLabel4 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel4");
	local desLabel5 = self:FindComponent("UILabel", "Offset/MapDesPanel/MapDesScrollView/Table/DesLabel5");
	table.insert(mMapDesLabelList, desLabel0);
	table.insert(mMapDesLabelList, desLabel2);
	table.insert(mMapDesLabelList, desLabel3);
	table.insert(mMapDesLabelList, desLabel4);
	table.insert(mMapDesLabelList, desLabel5);
	table.insert(mMapDesLabelList, desLabel6);
	
	InitNpcPool();
	InitWorldMap();
end

function OnEnable(self)
	InitBigMap();
	SetTouchEnable(true);
	SetCurrentMapModel(MapModel.DetailMap);
	UpdateBeat:Add(OnUpdate, self);
end

function OnDisable(self)
	SetTouchEnable(false);
	UpdateBeat:Remove(OnUpdate, self);
end

function RegisterEvent()
	-- body
end

function UnregisterEvent()
	-- body
end

function InitBigMap()
	SetNpcSearchMenuVisible(false);
	SetMapDescriptionVisible(false);
end

function OnClick(go, id)
	if id ~= - 1 then
		mNavFlag = false;
	end
	
	if id == 0 then
		--返回
		UIMgr.UnShowUI(AllUI.UI_Main_Money);
		UIMgr.UnShowUI(AllUI.UI_BigMap);
	elseif id == 1 then
		--查询
		if mIsNpcSearchMenuShown then
			SetNpcSearchMenuVisible(false);
		else
			SetNpcSearchMenuVisible(true);
		end
	elseif id == 2 then
		--切换
		if mCurrentMapModel == MapModel.WorldMap then
			SetCurrentMapModel(MapModel.DetailMap)
		else
			SetCurrentMapModel(MapModel.WorldMap)
		end
	elseif id == 3 then
		--传送至帮派
	elseif id == 4 then	
		--传送至师门
	elseif id == 5 then
		--打开地图简介界面
		SetMapDescriptionVisible(true);
	elseif id == 6 then
		SetMapDescriptionVisible(false);
	elseif id > 100 and id < 200 then
		--地图传送
		for k, v in ipairs(mWorldMapItemList) do
			if id == v.id then
				MapMgr.RequestEnterMap(v.spaceId, v.mapUnitId, v.transPointId);
				break;			
			end
		end
	elseif id > 200 and id < 300 then
		--寻路到NPC
	elseif id > 300 and id < 400 then
		for k, v in ipairs(mNpcList) do
			if v.id == id then
				mNavFlag = true;
				mNavPos = v.worldPos;
				break;
			end
		end
	end
	if mNavFlag then
		local player = MapMgr.GetMainPlayer();
		player:GetAIComponent():MoveWithDest(mNavPos);
		UIMgr.UnShowUI(AllUI.UI_Main_Money);
		UIMgr.UnShowUI(AllUI.UI_BigMap);
	end
end

function OnUpdate()
	if mCurrentMapModel == MapModel.DetailMap then
		UpdatePlayerPosFlag();
	end
end

function OnTouchStart(gesture)
	local touchPosition = UIMgr.GetCamera():ScreenToWorldPoint(Vector3(gesture.position.x, gesture.position.y, 0));
	if mCurrentMapModel == MapModel.WorldMap then
		mTouchBeginPosition:Set(touchPosition.x, touchPosition.y);
		mWroldMapGroupBeginPosition = mWorldMapGroupTrans.localPosition;
		--判断手指点击的范围
	else
		--获得手指点击坐标（相对于map的localPosition）
		local detailMapPos = mDetailMapTexture.transform.position;
		local relativePos = touchPosition - detailMapPos;
		local relativeNguiPos = relativePos / mUIRoot.transform.localScale.x;
		--mDetailMapLocalFlag.transform.localPosition = Vector3.New(relativeNguiPos.x, relativeNguiPos.y, mWorldMapLocalFlag.transform.localPosition.z);
		local worldPos = DetailMapPosToWorldPos(relativeNguiPos)
		local hit = GameUtil.GameFunc.PhysicsRaycast(worldPos, Vector3.New(0, - 1, 0), 200, CameraLayer.CanMoveLayer);
		if hit.transform ~= nil then
			mNavFlag = true;
			mNavPos = hit.point;
		else
			mNavFlag = false;
		end
	end
end

function OnTouchDown(gesture)
	if mCurrentMapModel == MapModel.WorldMap then
		local touchPosition = UIMgr.GetCamera():ScreenToWorldPoint(Vector3(gesture.position.x, gesture.position.y, 0));
		local fingerOffset =(Vector2(touchPosition.x, touchPosition.y) - mTouchBeginPosition) / mUIRoot.transform.localScale.x;
		--local uiOffset = UIMgr.GetCamera():ScreenToWorldPoint(Vector3(fingerOffset.x,fingerOffset.y,0));
		--移动范围判断
		local newPosition = mWroldMapGroupBeginPosition + Vector3.New(fingerOffset.x, fingerOffset.y, 0);
		local horizontalBoundary =(mWorldMapTexture.width - mWorldMapPanel.baseClipRegion.z) / 2;
		local verticalBoundary =(mWorldMapTexture.height - mWorldMapPanel.baseClipRegion.w) / 2;
		local targetPosition = mWorldMapGroupTrans.localPosition:Clone();
		if newPosition.x > mWorldMapPanel.transform.localPosition.x + mWorldMapPanel.baseClipRegion.x + horizontalBoundary or newPosition.x < mWorldMapPanel.transform.localPosition.x + mWorldMapPanel.baseClipRegion.x - horizontalBoundary then
			--水平方向超出范围
		else
			targetPosition.x = newPosition.x;
		end
		
		if newPosition.y > mWorldMapPanel.transform.localPosition.y + mWorldMapPanel.baseClipRegion.y + verticalBoundary or newPosition.y < mWorldMapPanel.transform.localPosition.y + mWorldMapPanel.baseClipRegion.y - verticalBoundary then
			--竖直方向超出范围
		else
			targetPosition.y = newPosition.y;
		end
		mWorldMapGroupTrans.localPosition = targetPosition;
	end
end

function OnTouchUp(gesture)
	
end

function SetCurrentMapModel(mapModel)
	mCurrentMapModel = mapModel;
	if mapModel == MapModel.WorldMap then
		mWorldMapPanel.gameObject:SetActive(true);
		mDetailMapPanel.gameObject:SetActive(false);
		--SetTouchEnable(true);
		mModelSwitchBtn.spriteName = "button_ditu_02";
		UpdateWroldLocalFlag();
	else	
		mWorldMapPanel.gameObject:SetActive(false);
		mDetailMapPanel.gameObject:SetActive(true);
		--SetTouchEnable(false);
		mModelSwitchBtn.spriteName = "button_ditu_06";
		InitDetailMap();
	end
end

function SetTouchEnable(isEnable)
	if isEnable then
		TouchMgr.SetEnableNGUIMode(false);
		TouchMgr.SetEnableCameraOperate(false);
		TouchMgr.SetListenOnTouch(UI_BigMap, true);
	else
		TouchMgr.SetTouchEventEnable(false)
		TouchMgr.SetEnableNGUIMode(true)
		TouchMgr.SetEnableCameraOperate(true)
		TouchMgr.SetListenOnTouch(UI_BigMap, false);
	end
end

function InitNpcPool()
	for i = 1, mMaxNpcCount do
		local npcItem = {};
		npcItem.id = 0;
		npcItem.name = "";
		npcItem.gameObject = mSelf:DuplicateAndAdd(mNpcItemPrefab, mDetailMapTexture.transform, i).gameObject;
		npcItem.gameObject:SetActive(false);
		npcItem.gameObject.name = "";
		npcItem.transform = npcItem.gameObject.transform;
		npcItem.npcIcon = npcItem.transform:GetComponent("UISprite");
		npcItem.uiEvent = npcItem.transform:GetComponent("UIEvent");
		npcItem.npcId = 0;
		npcItem.worldPos = Vector3.New(0, 0, 0);
		mNpcPool[i] = npcItem;
		
		local npcSearchItem = {};
		npcSearchItem.id = 0;
		npcSearchItem.name = "";
		npcSearchItem.gameObject = mSelf:DuplicateAndAdd(mNpcSearchPrefab, mSearchScrollViewTable.transform, i).gameObject;
		npcSearchItem.gameObject:SetActive(false);
		npcSearchItem.gameObject.name = "";
		npcSearchItem.transform = npcSearchItem.gameObject.transform;
		npcSearchItem.ItemBg = npcSearchItem.transform:GetComponent("UISprite");
		npcSearchItem.uiEvent = npcSearchItem.transform:GetComponent("UIEvent");
		npcSearchItem.itemLabel = npcSearchItem.transform:Find("NpcNameLabel"):GetComponent("UILabel");
		npcSearchItem.npcId = 0;
		npcSearchItem.worldPos = Vector3.New(0, 0, 0);
		mNpcSearchPool[i] = npcSearchItem;
	end
end

function InitWorldMap()
	--获取地图信息
	local worldMapItemInfoList = BigMapMgr.GetWorldMapItemList();
	for i, worldMapItemInfo in ipairs(worldMapItemInfoList) do
		local worldMapItem = {};
		worldMapItem.id = worldMapItemInfo.id;
		worldMapItem.name = worldMapItemInfo.itemName;
		worldMapItem.gameObject = mSelf:DuplicateAndAdd(mWorldMapItemPrefab, mWorldMapGroupTrans.transform, #mWorldMapItemList + 1).gameObject;
		worldMapItem.gameObject:SetActive(true);
		worldMapItem.gameObject.name = tostring(worldMapItemInfo.id);
		worldMapItem.transform = worldMapItem.gameObject.transform;
		worldMapItem.mapItemIcon = worldMapItem.transform:Find("MapItemIcon"):GetComponent("UISprite");
		worldMapItem.mapItemIcon.spriteName = worldMapItemInfo.resName;
		worldMapItem.mapItemIcon:MakePixelPerfect();--设置图标大小
		worldMapItem.mapItemNameLabel = worldMapItem.transform:Find("MapItemNameBg/MapItemNameLabel"):GetComponent("UILabel");
		worldMapItem.mapItemNameLabel.text = worldMapItemInfo.itemName;
		worldMapItem.uiEvent = worldMapItem.transform:Find("MapItemIcon"):GetComponent("UIEvent");
		worldMapItem.transform.localPosition = Vector2.New(worldMapItemInfo.iconPosX, worldMapItemInfo.iconPosY);
		worldMapItem.uiEvent.id = worldMapItemInfo.id;
		worldMapItem.sceneId = worldMapItemInfo.sceneId;
		worldMapItem.spaceId = worldMapItemInfo.spaceId;
		worldMapItem.mapUnitId = worldMapItemInfo.mapUnitId;
		worldMapItem.transPointId = worldMapItemInfo.transPoint;
		mWorldMapItemList[#mWorldMapItemList + 1] = worldMapItem;
	end
end

function InitDetailMap()
	--获取根据场景id获取地图id，获取地图信息
	local sceneId = MapMgr.GetSceneID();
	if sceneId ~= mCurrentSceneId then
		mCurrentSceneId = sceneId;
		local detailMapInfo = BigMapMgr.GetAreaMapInfoById(sceneId);
		if detailMapInfo == nil then
			UIMgr.UnShowUI(AllUI.UI_Main_Money);
			UIMgr.UnShowUI(AllUI.UI_BigMap);
			return;
		end
		mDetailMapNameLabel.text = detailMapInfo.name;
		--加载地图图片资源
		mDetailMapTextureLoader:LoadObject(detailMapInfo.resId);
		--获取地图标准点
		local standardPoint1 = Vector3.New(detailMapInfo.pointLTX, 0, detailMapInfo.pointLTZ);
		local standardPoint2 = Vector3.New(detailMapInfo.pointRBX, 0, detailMapInfo.pointRBZ);
		local sceneWidth = math.abs((standardPoint2.x - standardPoint1.x));
		local sceneHeight = math.abs((standardPoint2.z - standardPoint1.z))
		local mapWidth = mDetailMapTexture.width;
		local mapHeight = mDetailMapTexture.height;
		mDetailMapScale_H = mapWidth / sceneWidth;
		mDetailMapScale_V = mapHeight / sceneHeight;
		mSceneCenter =(standardPoint1 + standardPoint2) / 2;
		
		--获取Npc列表
		local mapUnit = MapMgr.GetMapUnit();
		local npcList = mapUnit.entities.npcs;
		ResetNpc();
		local npcCount = 0;
		for i, npcUnit in ipairs(npcList) do
			local id = npcUnit.tempID;
			local npcInfo = NPCData.GetNPCInfo(id);
			if npcInfo then
				npcCount = npcCount + 1;
				local npcWorldPos = npcUnit.position;
				local npcMapPos = WorldPosToDetailMapPos(npcWorldPos);
				local npcItem = mNpcPool[i];
				if npcItem and npcInfo.id then
					npcItem.id = 300 + npcCount;
					npcItem.name = npcInfo.npcName;
					npcItem.gameObject:SetActive(true);
					npcItem.gameObject.name = tostring(npcInfo.id);
					--设置npc图标
					npcItem.uiEvent.id = 300 + npcCount;
					npcItem.npcId = npcInfo.id;
					npcItem.transform.localPosition = npcMapPos;
					npcItem.worldPos = npcWorldPos;
					table.insert(mNpcList, npcItem);
					mNpcCount = npcCount;
				end
				
				local npcSearchItem = mNpcSearchPool[i];
				if npcSearchItem then
					npcSearchItem.id = 300 + npcCount;
					npcSearchItem.name = npcInfo.npcName;
					npcSearchItem.gameObject:SetActive(true);
					npcSearchItem.gameObject.name = tostring(npcInfo.id);
					npcSearchItem.itemLabel.text = npcInfo.npcName;
					if i % 2 == 0 then
						npcSearchItem.ItemBg.spriteName = "frame_ditu_03";
					else
						npcSearchItem.ItemBg.spriteName = "frame_ditu_04";
					end
					npcSearchItem.npcId = npcInfo.id;
					npcSearchItem.uiEvent.id = 300 + npcCount;
					npcSearchItem.worldPos = npcWorldPos;
					table.insert(mNpcSearchList, npcSearchItem);
				end
			end
		end
		
		mSearchScrollViewTable:Reposition();
		
		--获取怪物列表
	end
	UpdatePlayerPosFlag();
end

function ResetNpc()
	mNpcCount = 0;
	--隐藏全部NPC图标
	for i, npcPoolItem in ipairs(mNpcPool) do
		npcPoolItem.gameObject:SetActive(false);
	end
	
	for i, npcPoolSearchItem in ipairs(mNpcSearchPool) do
		npcPoolSearchItem.gameObject:SetActive(false);
	end
	--清空mNpcList列表
	mNpcList = {};
	mNpcSearchList = {};
end

function WorldPosToDetailMapPos(worldPos)
	local posFormWorldCenter = worldPos - mSceneCenter;
	local mapPos = Vector3.New(posFormWorldCenter.x * mDetailMapScale_H, posFormWorldCenter.z * mDetailMapScale_V, 0);
	return mapPos;
end

function DetailMapPosToWorldPos(DetailMapPos)
	local PosFromWorldCenter = Vector3.New(DetailMapPos.x / mDetailMapScale_H, 100, DetailMapPos.y / mDetailMapScale_V);
	local worldPos = PosFromWorldCenter + mSceneCenter;
	return worldPos;
end

function SetNpcSearchMenuVisible(isVisible)
	mNpcSearchMenu.gameObject:SetActive(isVisible);
	mIsNpcSearchMenuShown = isVisible;
end

function SetMapDescriptionVisible(isVisible)
	mMapDesPanel.gameObject:SetActive(isVisible);
	if isVisible then
		local sceneId = MapMgr.GetSceneID();
		local detailMapInfo = BigMapMgr.GetAreaMapInfoById(sceneId);
		for i, v in ipairs(detailMapInfo.mapDesList) do
			mMapDesLabelList[i].text = v;
		end
		for i = #detailMapInfo.mapDesList + 1, #mMapDesLabelList do
			mMapDesLabelList[i].text = "";
		end
		--设置地图介绍文字
		mMapDesTable:Reposition();
	end
end

function UpdatePlayerPosFlag()
	--设置玩家位置和朝向
	local player = MapMgr.GetMainPlayer();
	local playerPos = player:GetPropertyComponent():GetPosition();
	local playerFor = player:GetPropertyComponent():GetForward();
	local vecFrome = Vector3.New(1, 0, 0);
	local vecTo = Vector3.New(playerFor.x, playerFor.z, 0);
	local angle = Vector3.Angle(vecFrome, vecTo);
	local dir = Vector3.Dot(Vector3.New(0, 0, 1), Vector3.Cross(vecFrome, vecTo));
	if dir < 0 then
		dir = - 1;
	else
		dir = 1;
	end
	local playerMapPos = WorldPosToDetailMapPos(playerPos);
	mDetailMapLocalFlag.transform.localPosition = playerMapPos;
	mDetailMapLocalFlag.transform.localEulerAngles = Vector3.New(0, 0, angle * dir);
end

function UpdateWroldLocalFlag()
	local sceneId = MapMgr.GetMapUnitID();
	for k, v in ipairs(mWorldMapItemList) do
		if v.spaceId == sceneId then
			mWorldMapLocalFlag.transform.localPosition = v.transform.localPosition;
			break;
		end
	end
end 