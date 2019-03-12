
module("UI_Gang_MapList",package.seeall)

--格子对象数组
local mWrapGrids = {}
--itemwrap组件
local mWrap;
local mWrapCallBack;
local MAX_WRAPITEM_COUNT = 6;
local MAX_GRID_COUNT = 100;
local MIN_GRID_COUNT = 4
local mDragPanel;
local DragOffSet =nil
--全部格子数据数组
local mGridDatas = {};
local mCurGridCount = 0;
local mCurGridLock = 0;
--当前选中格子
local mCurSelectIndex = 1;

local CurrentData=nil

function OnCreate(self)
    BgObj = self:Find("Offset/Bg").gameObject;
    BgSprite = self:FindComponent("UISprite","Offset/Bg");
    BgWidth=BgSprite.width
    BgHeight=BgSprite.height
    Name = self:FindComponent("UILabel","Offset/Bg/Name");
    ServerName = self:FindComponent("UILabel","Offset/Bg/ServerName");
    Level = self:FindComponent("UILabel","Offset/Bg/Level");
    Icon = self:FindComponent("UISprite","Offset/Bg/Icon");
    PersonLabel = self:FindComponent("UILabel","Offset/Bg/MsgBg/PersonLabel");
    SendMsgLabel = self:FindComponent("UILabel","Offset/Bg/SendMsg/Label");
    AddFriendLabel = self:FindComponent("UILabel","Offset/Bg/AddFriend/Label");
    AskBeTeamerLabel = self:FindComponent("UILabel","Offset/Bg/AskBeTeamer/Label");
    AskBeGangerLabel = self:FindComponent("UILabel","Offset/Bg/AskBeGanger/Label");
    PrivateSpaceLabel = self:FindComponent("UILabel","Offset/Bg/PrivateSpace/Label");
    AddBlackListLabel = self:FindComponent("UILabel","Offset/Bg/AddBlackList/Label");

    local itemPrefab = self:Find("Offset/Bg/ItemPrefab");
	mWrap = self:FindComponent("UIWrapContent", "Offset/Bg/ItemParent/ScrollView/ItemWrap");
	mCountPerLine = mWrap.itemCountPerLine
    mDragPanel = self:Find("Offset/Bg/ItemParent/ScrollView").transform;
    --列表
    for i = 1, MAX_WRAPITEM_COUNT do
		mWrapGrids[i] = NewItem(self, itemPrefab, i);
    end
	itemPrefab.gameObject:SetActive(false);
	scrollView = mDragPanel:GetComponent("UIScrollView");
	scrollPanel = mDragPanel:GetComponent("UIPanel");
end

function NewItem(self, obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
    item.transform = item.gameObject.transform;

    item.player={}
    item.player.transform=item.transform:Find("PlayerPrefab")
    item.player.gameObject=item.transform:Find("PlayerPrefab").gameObject
    item.player.nameLabel=item.player.transform:Find("Name"):GetComponent("UILabel");
    item.player.serverNameLabel=item.player.transform:Find("ServerName"):GetComponent("UILabel");
    item.player.levelLabel=item.player.transform:Find("Level"):GetComponent("UILabel");
    item.player.gangIcon = item.player.transform:Find("GangIcon"):GetComponent("UISprite");
    item.player.icon = item.player.transform:Find("Icon"):GetComponent("UISprite");
    item.player.itemselect = item.player.transform:Find("ItemSelect").gameObject;

	item.gang={}
    item.gang.transform=item.transform:Find("GangPrefab")
    item.gang.gameObject=item.transform:Find("GangPrefab").gameObject
    item.gang.nameLabel=item.gang.transform:Find("Name"):GetComponent("UILabel");
    item.gang.distanceLabel=item.gang.transform:Find("Distance"):GetComponent("UILabel");
    item.gang.levelLabel=item.gang.transform:Find("Level"):GetComponent("UILabel");
    item.gang.icon = item.gang.transform:Find("Icon"):GetComponent("UISprite");
    item.gang.itemselect = item.gang.transform:Find("ItemSelect").gameObject;

    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.gridID = index;
	item.dataID = index;
	item.gameObject:SetActive(false);
	return item;
end


function OnEnable(self)
    TouchMgr.SetEnableNGUIMode(true)
    Show=true
    UpdateView()
end

function OnDisable(self)
    TouchMgr.SetEnableNGUIMode(false)
    Show=false
end

function CheckShow()
    return Show
end

--==============================--
--desc:UI布局函数
--time:2018-04-26 08:00:51
--@return 
--==============================--
--初始化面板
function InitPanel()
	scrollView.resetOffset = Vector3.zero;
	scrollPanel.clipOffset = Vector2.zero;
	mDragPanel.localPosition = Vector3.zero;
end


function LateUpdatView()
	mWrap:WrapContent();
end

--刷界面显示
function UpdateView()
	DragOffSet= mDragPanel.localPosition
    mGridDatas = GangMgr.GetMapListData()
    UpdateLayout();
    GlobalMapMgr.MapTipArchorPosition(BgObj,BgWidth,BgHeight,mGridDatas[1].Coordinate)
end

--scrollowview布局
function UpdateLayout()
	local mDRAG_FINISH_OFFSET = DragOffSet or Vector3.New(0, 0, 0)
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
    Grid.index = dataID
    if data then
        Grid.gang.gameObject:SetActive(false);
        Grid.player.gameObject:SetActive(false);
        --1 帮派 2 玩家
        if data.type==1 then--帮派
            Grid.gang.gameObject:SetActive(true);
            Grid.gang.nameLabel.text=data.Name
            Grid.gang.distanceLabel=data.Distance
            Grid.gang.levelLabel= data.Level
            Grid.gang.icon.spriteName = data.Icon
            Grid.gang.itemselect:SetActive(mCurSelectIndex == dataID or false);
        elseif data.type==2 then-- 2 玩家
            Grid.player.gameObject:SetActive(true);
            Grid.player.nameLabel.text=data.Name
            Grid.player.serverNameLabel=data.ServerName
            Grid.player.levelLabel= data.Level
            Grid.player.icon.spriteName = data.Icon
            Grid.player.gangIcon.spriteName = GangMgr.GetGangDataById(data.GangId).Icon
            Grid.player.itemselect:SetActive(mCurSelectIndex == dataID or false);
        end
        Grid.gridID = gridID;
        Grid.dataID = dataID;
        Grid.gameObject:SetActive(true);
    else
        Grid.gameObject:SetActive(false);
    end
	
end

function OnClick(go,id)
    GameLog.Log(" OnClick %d",id)
    if id >0 then--发消息
        local item = mGridDatas[id];
        if item.type==1 then
            GangMgr.SetCurrentGangIndex(item.Index)
            UIMgr.UnShowUI(AllUI.UI_Gang_MapList)
            UIMgr.ShowUI(AllUI.UI_Gang_MapGangTip)
        elseif item.type==2 then
            GangMgr.SetCurrentPlayerIndex(item.Index)
            UIMgr.UnShowUI(AllUI.UI_Gang_MapList)
            UIMgr.ShowUI(AllUI.UI_Gang_MapPlayerTip)
        end
       
    elseif id == -100 then--关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_MapList)
    end
end
--endregion
