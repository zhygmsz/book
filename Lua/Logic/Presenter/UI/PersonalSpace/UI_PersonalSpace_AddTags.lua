module("UI_PersonalSpace_AddTags",package.seeall)

--格子对象数组
local mWrapGrids = {}

--itemwrap组件
local mWrap;
local mWrapCallBack;
local itemCountPerLine = 5
local MAX_WRAPITEM_COUNT = 28;
local MAX_GRID_COUNT = 40;
local MIN_GRID_COUNT = 20
local mDragPanel;
local DragOffSetTable = {}
--全部格子数据数组
local mGridDatas = {};
local mCurGridCount = 50;
--当前选中格子
local mCurSelectIndex = - 1;

local mSelectedTag ={}
local mLastSelectC = -1
--当前选择的物品类别
local mCurSelectC = -1;
--爱好
local mToggleFavorite;
--性格
local mToggleNatural;
--特征
local mToggleFeature;

local mScrollView = nil
local mScrollPanel = nil

local mCloseEvent=nil
--实例化回调
local mPickedTagsTable = nil
--添加的tag
local mPickedTags = {}
--tag实体数组
local mPickTagItems = {}
local MAX_PICK_NUM = 10
local mPlayerInfo={}
--==============================--
--desc:界面创建初始化 注册事件
--time:2018-04-26 08:00:16
--@self:
--@return 
--==============================--
function OnCreate(self)
	local itemPrefab = self:Find("Offset/Dynamic/ItemPrefab");
	mWrap = self:FindComponent("UIWrapContent", "Offset/Dynamic/ItemParent/ScrollView/ItemWrap");
	mWrap.itemCountPerLine = itemCountPerLine
	mCountPerLine = mWrap.itemCountPerLine
	mDragPanel = self:Find("Offset/Dynamic/ItemParent/ScrollView").transform;
	
	mToggleFavorite = self:FindComponent("UIToggle", "Offset/Dynamic/CToggles/TFavorite");
	mToggleNatural = self:FindComponent("UIToggle", "Offset/Dynamic/CToggles/TNature");
	mToggleFeature = self:FindComponent("UIToggle", "Offset/Dynamic/CToggles/TFeature");
    mPickedTagsTable = self:FindComponent("UITable", "Offset/Dynamic/PickedTags");

	for i = 1, MAX_WRAPITEM_COUNT do
		mWrapGrids[i] = NewItem(self, itemPrefab, i);
    end
    for i = 1, MAX_PICK_NUM do
		mPickTagItems[i] =PickTag(self,itemPrefab, i)
    end
	itemPrefab.gameObject:SetActive(false);
	mScrollView = mDragPanel:GetComponent("UIScrollView");
	mOriginY = mScrollView.transform.localPosition.y
	mScrollPanel = mDragPanel:GetComponent("UIPanel");
	mParentEvent = self:FindComponent("UIEvent", "Offset/Dynamic/ItemParent");
    mParentEvent.id = -10000
    mCloseEvent = self:FindComponent("UIEvent", "Offset/Dynamic/Close");
	mCloseEvent.id = 0
	InitPanel();
end

function NewItem(self,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
	item.itemselect = item.transform:Find("ItemSelect").gameObject;
	item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
	item.gameObject:SetActive(false);
	return item;
end

function PickTag(self,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mPickedTagsTable.transform, index).gameObject;
	item.gameObject.name = tostring(20000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	local kind = math.random(1,9)
	item.itembg.spriteName = string.format("teps_geren_0%d",kind)
	item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
	item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.uiEvent.id = 20000 + index
	item.gameObject:SetActive(false);
	return item;
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
	mEvents = {};
end

function OnEnable(self)
	RegEvent(self);
	--BagMgr.RequestBagData({Bag_pb.NORMAL});
	mToggleFavorite.value = true
	mToggleNatural.value = false
	mToggleFeature.value = false
	mCurSelectIndex=-1
	InitData()
end

function InitData()
	PersonSpaceMgr.GetSelfPlayerInfo(PlayerInfoLoaded)
end

function OnDisable(self)
	DragOffSetTable[mCurSelectC] = mDragPanel.localPosition
	mCurSelectC = - 1;
	mCurSelectIndex = - 1;
	mLastSelectC = - 1
	UnRegEvent(self);
end
 
--初始化面板
function InitPanel()
	mScrollView.resetOffset = Vector3.zero;
	mScrollPanel.clipOffset = Vector2.zero;
	mDragPanel.localPosition = Vector3.zero;
end

function PlayerInfoLoaded(playerid,playerInfo)
    if tostring(playerid) == tostring(UserData.PlayerID) then
        mPlayerInfo=playerInfo
        if mPlayerInfo then
			UpdateView()
        end
    end
end

--刷险背包界面显示
function UpdateView()
	if mLastSelectC ~= mCurSelectC then
		if DragOffSetTable[mLastSelectC] == nil then
			DragOffSetTable[mLastSelectC] = Vector3.New(0, 0, 0)
		else
			DragOffSetTable[mLastSelectC] = mDragPanel.localPosition
		end
	else
		if DragOffSetTable[mCurSelectC] == nil then
			DragOffSetTable[mCurSelectC] = Vector3.New(0, 0, 0)
		else
			DragOffSetTable[mCurSelectC] = mDragPanel.localPosition
		end
	end
	mLastSelectC = mCurSelectC
	local tagtype = mLastSelectC==-1 and CharacterTag_pb.CharacterTag.HOBBY or mLastSelectC==-2 and CharacterTag_pb.CharacterTag.CHARACTER or CharacterTag_pb.CharacterTag.PERSONALITY
	mGridDatas = CharacterTagData.GetCharacterTagList(tagtype)
	local tags = mPlayerInfo:GetCharacterTags()
	for i,v in ipairs(tags) do
		if v>0 then
			local tag = CharacterTagData.GetCharacterTag(v)
			local cindx = -1-tag.tagtype
		--	if mSelectedTag[cindx]== nil then mSelectedTag[cindx]={} end
		--	mSelectedTag[cindx][tag.index]= tag.index
		--	mPickedTags[i]={data =tag ,cIndex = cindx,sIndex =tag.index}
			AddTag(cindx,tag.index,tag)
		end
	end

	UpdateLayout();
	mPickedTagsTable:Reposition()
	UpdateSelect()
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
		go:SetActive(false);
	end
end

--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID, dataID)
	local Grid = mWrapGrids[gridID];
    local data = mGridDatas[dataID];
	--Grid.itembg.spriteName = UIUtil.GetItemQualityBgSpName(bgid)
	local kind = math.random(1,9)
	Grid.itembg.spriteName = kind <10 and string.format("teps_geren_0%d",kind) or string.format("teps_geren_%d",kind)
	Grid.itemlabel.text = data.value;
	Grid.data = nil
	if data then
		Grid.data = data
	end
	Grid.gridID = gridID;
	Grid.dataID = dataID;
	Grid.gameObject:SetActive(true);
end

function UpdateSelect()
	for i = 1, MAX_WRAPITEM_COUNT do
		local item = mWrapGrids[i];
		if item and item.gameObject.activeSelf then
			local select  = mSelectedTag[mCurSelectC]==nil or mSelectedTag[mCurSelectC][item.dataID]==nil
			item.itemselect:SetActive(not select);
		end
	end
end

function AddTag(cindex,sindex,tag)
	local max = table.getn(mPickedTags)
	if mSelectedTag[cindex]==nil then
		mSelectedTag[cindex]={}
	end
	if max < MAX_PICK_NUM and mSelectedTag[cindex][sindex] ==nil then
		local item = mPickTagItems[max+1]
		item.itemlabel.text = tag.value;
		item.tagIndex = max+1
		mSelectedTag[cindex][sindex]= item.tagIndex
		item.gameObject:SetActive(true);
		mPickedTags[item.tagIndex]={data =tag ,cIndex = cindex,sIndex =sindex}
		mPickedTagsTable:Reposition()
	end
end

function RemoveTag(cindex,sindex,tag)
	local max = table.getn(mPickedTags)
	if mSelectedTag[cindex]==nil then
		mSelectedTag[cindex]={}
	end
	if max <= MAX_PICK_NUM and mSelectedTag[cindex][sindex]~=nil then
		local tagIndex = mSelectedTag[cindex][sindex]
		local item = mPickTagItems[tagIndex]
		mSelectedTag[cindex][sindex]=nil
		item.gameObject:SetActive(false);
		mPickedTags[item.tagIndex]=nil
		mPickedTagsTable:Reposition()
	end
end

--点击事件处理
function OnClick(go, id)
	GameLog.Log("id %d", id)
	if id <= - 1 and id >= - 3 then
		if mCurSelectC ~= id then
			mScrollView.currentMomentum = Vector3.New(0, 0, 0)
			mScrollView:DisableSpring()
			--点击类别按钮
			mLastSelectC = mCurSelectC
			mCurSelectC = id
			mCurSelectIndex=-1
			UpdateView()
		end
	elseif id == 0 then--关闭
		local temp ={}
		for k,v in pairs(mPickedTags) do
			table.insert(temp,v.data.id)
		end
        mPlayerInfo:SaveCharacterTags(temp,true)
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_AddTags);
	elseif id >= 1 and id <20000 then
	    --点击物品
        local mitem = mWrapGrids[id];
		mCurSelectIndex = mitem.dataID;

		local tag = mGridDatas[mCurSelectIndex]

		if mSelectedTag[mCurSelectC]==nil then
			mSelectedTag[mCurSelectC]={}
		end
		local max = table.getn(mPickedTags)
        if max < MAX_PICK_NUM and mSelectedTag[mCurSelectC][mCurSelectIndex] ==nil then
			AddTag(mCurSelectC,mCurSelectIndex,tag)
		elseif max <= MAX_PICK_NUM and mSelectedTag[mCurSelectC][mCurSelectIndex]~=nil then
			RemoveTag(mCurSelectC,mCurSelectIndex,tag)
		end
		UpdateSelect()
    elseif id >20000 then--点击到picked tag
		 --点击物品
		 mCurSelectIndex=-1
        local index = id -20000
        local item = mPickTagItems[index];
        local tag = mGridDatas[mCurSelectIndex]
		if item then
			local cIndex = mPickedTags[item.tagIndex].cIndex
			local sIndex = mPickedTags[item.tagIndex].sIndex
			mSelectedTag[cIndex][sIndex]=nil
            mPickedTags[item.tagIndex]=nil
            item.gameObject:SetActive(false);
            mPickedTagsTable:Reposition()
		end
		UpdateSelect()
         
	end
end
