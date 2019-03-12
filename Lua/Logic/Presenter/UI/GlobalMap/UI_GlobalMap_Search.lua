module("UI_GlobelMap_Search",package.seeall);
require("UI/UI_GlobalMap")
require("Logic/Data/RegionData")
require("Logic/Data/RegionCoordinateData")
local mWrapCallBack1;
local mWrapCallBack2;

local mCurGridCount=0
--按钮
local CityBtnLabels={}
--搜索栏
local SearchBarInput=nil
--搜索面板
local SearchPanel={
    [1]={
        MAX_WRAPITEM_COUNT =7,
        MAX_GRID_COUNT = 100,
        MIN_GRID_COUNT = 4,
        --当前选中格子
        mCurSelectIndex = -1;
    },
    [2]={
        MAX_WRAPITEM_COUNT =11,
        MAX_GRID_COUNT = 100,
        MIN_GRID_COUNT = 8,
        mCurSelectIndex = -1;
    }
}
local CatalogData={"省/直辖市","市区","区","详细地址"}
local HotCitys={
    [1]={name="北京",key="北京市-北京市-北京市",address="北京市市辖区",Indexs={1,1,1}},
    [2]={name="上海",key="上海市-上海市-上海市",address="上海市市辖区",Indexs={9,1,1}},
    [3]={name="深圳",key="广东省-深圳市-深圳市",address="广东省深圳市市辖区",Indexs={19,3,1}},
    [4]={name="广州",key="广东省-广州市-广州市",address="广东省广州市市辖区",Indexs={19,1,1}},
    [5]={name="杭州",key="浙江省-杭州市-杭州市",address="浙江省杭州市市辖区",Indexs={11,1,1}},
    [6]={name="武汉",key="湖北省-武汉市-武汉市",address="湖北省武汉市市辖区",Indexs={17,1,1}}
}
local PopData={}
local Catalog=1
local First = 1
local Second = 1
local Third = 1
local Fourth=1
local Address = ""

function OnCreate(self)
    mSelf=self
    Offset = self:Find("Offset").gameObject;
    for i=1,6 do
        local City = self:FindComponent("UILabel", string.format("Offset/HotCitys/City%d/Label",i));
        CityBtnLabels[i]=City
        CityBtnLabels[i].text = HotCitys[i].name
        local uievent = self:FindComponent("UIEvent", string.format("Offset/HotCitys/City%d",i))
      --  item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
        uievent.id=-1*i;
    end
    --搜索输入框
    SearchBarInput= self:FindComponent("LuaUIInput", "Offset/SearchBar/Input");

    local itemPrefab = self:Find("Offset/ItemPrefab");
    for i=1,2 do
        SearchPanel[i].Panel=self:Find(string.format("Offset/SearchPanel%d",i)).transform;
        SearchPanel[i].mWrap = self:FindComponent("UIWrapContent", string.format("Offset/SearchPanel%d/ItemParent/ScrollView/ItemWrap",i));
        SearchPanel[i].mCountPerLine =  SearchPanel[i].mWrap.itemCountPerLine
        SearchPanel[i].mDragPanel = self:Find(string.format("Offset/SearchPanel%d/ItemParent/ScrollView",i)).transform;
        SearchPanel[i].scrollView = SearchPanel[i].mDragPanel:GetComponent("UIScrollView");
        SearchPanel[i].scrollPanel = SearchPanel[i].mDragPanel:GetComponent("UIPanel");
        SearchPanel[i].mWrapGrids={}
        SearchPanel[i].DragOffSet=nil
        --全部格子数据数组
        SearchPanel[i].mGridDatas = {};
        --列表
        for j = 1,SearchPanel[i].MAX_WRAPITEM_COUNT do
            SearchPanel[i].mWrapGrids[j] = NewItem(self, itemPrefab,SearchPanel[i].mWrap,i, j);
            SearchPanel[i].mWrapGrids[j].PanelIndex=i
            SearchPanel[i].mWrapGrids[j].gameObject:GetComponent("UIDragScrollView").scrollView=SearchPanel[i].scrollView
        end
       
        InitPanel(i);
    end
	itemPrefab.gameObject:SetActive(false);
    
end

function OnEnable(self)
    RegEvent(self)
    TouchMgr.SetEnableNGUIMode(true)
    GetPopData()
    UpdateAllView()
end

function OnDisable(self)
    TouchMgr.SetEnableNGUIMode(false)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    UpdateBeat:Add(Update,self);
end

function UnRegEvent(self)
    UpdateBeat:Remove(Update,self);
    mEvents = {};
end

function OnShowOver()
end

function UpdateAllView()
    for i=1,2 do
        UpdateView(i)
    end
end

function NewItem(self,obj,mWrap,panelindex,index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
    item.gameObject.name = tostring(panelindex*10000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.Content = item.transform:Find("Content"):GetComponent("UILabel");
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.gridID = index;
	item.dataID = index;
	item.gameObject:SetActive(false);
	return item;
end
function InitPanel(index)
    local panel =SearchPanel[index]
    panel.scrollView.resetOffset = Vector3.zero;
    panel.scrollPanel.clipOffset = Vector2.zero;
    panel.mDragPanel.localPosition = Vector3.zero;
end
--刷界面显示
function UpdateView(index)
    local panel =SearchPanel[index]
	panel.DragOffSet= panel.mDragPanel.localPosition
    panel.mGridDatas = PopData[index]
	UpdateLayout(index);
end
function UpdateLayout(index)
    local panel =SearchPanel[index]
    local mDRAG_FINISH_OFFSET = panel.DragOffSet or Vector3.New(0, 24, 0)
    table.sort(panel.mWrapGrids, function(a, b) return a.gameObject.name < b.gameObject.name; end);
    for k, v in pairs(panel.mWrapGrids) do if v then v.uiEvent.id = index*10000+k; end end
    if index==1 then 
        if not mWrapCallBack1 then mWrapCallBack1 = UIWrapContent.OnInitializeItem(OnInitGrid1); end
        panel.mWrap:WrapContentWithPosition(NewGridCount(index), mWrapCallBack1, mDRAG_FINISH_OFFSET);
    else
        if not mWrapCallBack2 then mWrapCallBack2 = UIWrapContent.OnInitializeItem(OnInitGrid2); end
        panel.mWrap:WrapContentWithPosition(NewGridCount(index), mWrapCallBack2, mDRAG_FINISH_OFFSET);
    end
   
end
--当前物品格子数
function NewGridCount(index)
    local panel =SearchPanel[index]
	local curGridCount = #panel.mGridDatas;
	mCurGridCount = curGridCount <= panel.MAX_GRID_COUNT and curGridCount or panel.MAX_GRID_COUNT;
	if mCurGridCount <= panel.MIN_GRID_COUNT then
		mCurGridCount = panel.MIN_GRID_COUNT
	end
	return mCurGridCount;
end
--初始化各自信息 范围内的可见 
function OnInitGrid1(go, wrapIndex, realIndex)
	if realIndex >= 0 and realIndex < mCurGridCount then
        go:SetActive(true);
        go.name = tostring(10000 + wrapIndex);
        --local index=tonumber(string.sub(go.name,1,1))
		InitGrid(wrapIndex + 1, realIndex + 1,1);
	else
		go:SetActive(false);
	end
end
--初始化各自信息 范围内的可见 
function OnInitGrid2(go, wrapIndex, realIndex)
	if realIndex >= 0 and realIndex < mCurGridCount then
        go:SetActive(true);
        go.name = tostring(20000 + wrapIndex);
        --local index=tonumber(string.sub(go.name,1,1))
		InitGrid(wrapIndex + 1, realIndex + 1,2);
	else
		go:SetActive(false);
	end
end
--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID, dataID,index)
    local panel =SearchPanel[index]
	local Grid = panel.mWrapGrids[gridID];
    local data = panel.mGridDatas[dataID];
    Grid.index = dataID
    if data then
        Grid.itembg.gameObject:SetActive(true);
        Grid.itemselect:SetActive(panel.mCurSelectIndex == dataID or false);
        Grid.Content.text = data
        Grid.gridID = gridID;
        Grid.dataID = dataID;
        if panel.mCurSelectIndex == dataID then
        end
        Grid.gameObject:SetActive(true);
    else
        Grid.gameObject:SetActive(false);
    end
end


--更新当前查询地址
function UpdateAddress()
    local privstr=""
    local citystr= ""
    local areastr =""
    local streetstr=""
    local priv=RegionData.Data[First]
    if priv then
        privstr=priv.name
        local city= (priv.children~=nil and priv.children[Second]~=nil) and priv.children[Second]
        if city then
            citystr=city.name
            local area = (city.children~=nil and city.children[Third]~=nil) and  city.children[Third]
            if area then
                areastr=area.name
                local street= (area.children~=nil and area.children[Fourth]~=nil) and area.children[Fourth]
                if street then
                    streetstr=street.name
                end
            end
        end
    end
    local address= string.format("%s%s%s%s",privstr,citystr,areastr,streetstr)
    local key= string.format("%s-%s-%s",privstr,citystr,areastr)
    key=string.gsub(key,"市辖区",privstr)
    local coordinate=RegionCoordinateData.Data[key]
    UI_GlobalMap.SetAddress(key)
    if coordinate then
        UI_GlobalMap.LocateToCoordinate(Vector2(coordinate.longitude,coordinate.latitude))
    end
    return address
end

function HotKeyClick(index)
    First=HotCitys[index].Indexs[1]
    Second=HotCitys[index].Indexs[2]
    Third=HotCitys[index].Indexs[3]
    Catalog=3
    SearchPanel[1].mCurSelectIndex=3
    SearchPanel[2].mCurSelectIndex=Third
    Fourth=1
end

--获取显示列表数据
function GetPopData()
    PopData={[1]=CatalogData,[2]={}}

    local priv=RegionData.Data[First]
    if priv then
        PopData[1][1]=priv.name
        local city= (priv.children~=nil and priv.children[Second]~=nil) and priv.children[Second]
        if city then
            PopData[1][2]=city.name
            local area = (city.children~=nil and city.children[Third]~=nil) and  city.children[Third]
            if area then
                PopData[1][3]=area.name
                local street= (area.children~=nil and area.children[Fourth]~=nil) and area.children[Fourth]
                if street then
                    PopData[1][4]=street.name
                end
            end
        end
    end

    if Catalog==1 then
        for i=1,#RegionData.Data do
            table.insert(PopData[2],RegionData.Data[i].name)
        end
    elseif Catalog==2 then
        if RegionData.Data[First] then
            local temp=RegionData.Data[First].children
            if temp then 
                for i=1,#temp do
                    table.insert(PopData[2],temp[i].name)
                end
            end
        end
    elseif Catalog==3 then
        if RegionData.Data[First] and RegionData.Data[First].children then
            local temp=RegionData.Data[First].children[Second].children
            if temp then 
                for i=1,#temp do
                    table.insert(PopData[2],temp[i].name)
                end
            end
        end
    elseif Catalog==4 then
        if RegionData.Data[First] and 
        RegionData.Data[First].children and 
        RegionData.Data[First].children[Second]
         and RegionData.Data[First].children[Second].children then
            local temp=RegionData.Data[First].children[Second].children[Third].children
            if temp then 
                for i=1,#temp do
                    table.insert(PopData[2],temp[i].name)
                end
            end
        end
    end
end

function ResetIndex()
    First=-1
    Second=-1
    Third=-1
    Fourth=-1
end

function OnClick(go,id)
	if id == -100 then
      --退出
      UIMgr.UnShowUI(AllUI.UI_GlobelMap_Search)
    elseif id <= -1 and id >= -6 then
        --热门城市
        HotKeyClick(-1*id)
        SearchBarInput.value= UpdateAddress()
        GetPopData()
        UpdateAllView()
    elseif id == -7 then
        --取消
        SearchBarInput.value=""
        ResetIndex()
    elseif id == -8 then
        --搜索
    elseif id > 0 then--点击图标
        local panelindex = math.floor(id/10000) 
        local index = math.floor(id%10000)
          --点击物品
        local panel =SearchPanel[panelindex]
		local item = panel.mWrapGrids[index];
        panel.mCurSelectIndex = item.dataID;
        --点击第一层
        if panelindex==1 then
            Catalog=item.dataID
        elseif panelindex==2 then
            if Catalog==1 then
                First = item.dataID
            elseif Catalog==2 then
                Second = item.dataID
            elseif Catalog==3 then
                Third = item.dataID
            elseif Catalog==4 then
                Fourth = item.dataID
            end
        end
        SearchBarInput.value= UpdateAddress()
        GetPopData()
        UpdateAllView()
	end
end

function Update()
   
end