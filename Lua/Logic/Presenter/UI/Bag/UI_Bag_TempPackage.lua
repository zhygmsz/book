--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_TempPackage",package.seeall);

--格子对象数组
local mWrapGrids = {}
local mWrap;
local mWrapCallBack;
--全部格子数据数组
local mGridDatas={};
local mCurSelectIndex = -1;
local  mCurrentBagData = nil
local MAX_WRAPITEM_COUNT =24;
local MAX_GRID_COUNT = BagMgr.GetMaxGridCount(Bag_pb.TEMP);
local MIN_GRID_COUNT =  BagMgr.GetMinGridCount(Bag_pb.TEMP)
local DoubleClick = false
local mDragPanel;
local itemCountPerLine = 4
local DRAG_FINISH_OFFSET = Vector3.New(0,0,0);
local mCurGridCount = 16;
local scrollView = nil
local scrollPanel = nil

--==============================--
--desc:界面创建初始化 注册事件
--time:2018-04-26 08:00:16
--@self:
--@return 
--==============================--
function OnCreate(self)
    local itemPrefab = self:Find("Offset/BG/ItemPrefab");
    mWrap = self:FindComponent("UIWrapContent","Offset/BG/ItemParent/ScrollView/ItemWrap");
    mWrap.itemCountPerLine=itemCountPerLine
    mDragPanel = self:Find("Offset/BG/ItemParent/ScrollView").transform;
    scrollView = mDragPanel:GetComponent("UIScrollView");
    scrollPanel = mDragPanel:GetComponent("UIPanel");

    for i = 1,MAX_WRAPITEM_COUNT do
        mWrapGrids[i] = NewItem(self,itemPrefab,i);
    end 
    itemPrefab.gameObject:SetActive(false);
    
end

function NewItem(self,obj,index)
    local item = {};
    item.index = index;
    item.gameObject = self:DuplicateAndAdd(obj,mWrap.transform,index).gameObject;
    item.gameObject.name = tostring(10000 + index);
    item.transform = item.gameObject.transform;
    item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    item.itemicon = item.transform:Find("ItemIcon"):GetComponent("UISprite");
    item.itemcount = item.transform:Find("ItemCount"):GetComponent("UILabel");
    item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.itemlock = item.transform:Find("ItemLock").gameObject;
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.gameObject:SetActive(false);
    return item;
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,OnPackageUpdate);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID,OnGridUpdate);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,OnOtherSelect);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,OnMoveItem);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,OnPackageUpdate);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID,OnGridUpdate);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,OnOtherSelect);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,OnMoveItem);
    mEvents = {};
end

function OnEnable(self)   
    RegEvent(self);
    InitPanel();
    UpdateView()
end

function OnDisable(self)
    mCurSelectIndex = -1;    
    UnRegEvent(self);
end

--==============================--
--desc:UI布局函数
--time:2018-04-26 08:00:51
--@return 
--==============================--
function InitPanel()
    scrollView.resetOffset = Vector3.zero;
    scrollPanel.clipOffset = Vector2.zero;
    mDragPanel.localPosition = Vector3.zero;
end

--刷险背包界面显示
function UpdateView()
    mCurrentBagData = BagMgr.BagData[Bag_pb.TEMP]
    if mCurrentBagData then
        mGridDatas=BagMgr.GetGridDatas(Bag_pb.TEMP,-1)
        DRAG_FINISH_OFFSET=mDragPanel.localPosition
        UpdateLayout();
    end
end

--scrollowview布局
function UpdateLayout()
    table.sort(mWrapGrids,function(a,b) return a.gameObject.name < b.gameObject.name; end);
    for k,v in pairs(mWrapGrids) do if v then v.uiEvent.id = k; end end  
    if not mWrapCallBack then mWrapCallBack = UIWrapContent.OnInitializeItem(OnInitGrid); end
    mWrap:WrapContentWithPosition(NewGridCount(),mWrapCallBack,DRAG_FINISH_OFFSET);
end

--当前物品格子数
function NewGridCount()
    local curGridCount = #mGridDatas;
    mCurGridCount = curGridCount <= MAX_GRID_COUNT and curGridCount or MAX_GRID_COUNT;
    if mCurGridCount<=MIN_GRID_COUNT then 
        mCurGridCount=MIN_GRID_COUNT
    end
    return mCurGridCount;
end

--初始化各自信息 范围内的可见 
function OnInitGrid(go,wrapIndex,realIndex)
    if realIndex >= 0 and realIndex < mCurGridCount then
        go:SetActive(true);

        InitGrid(wrapIndex + 1,realIndex + 1);
    else
        go:SetActive(false);
    end
end

--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID,dataID)
    local Grid = mWrapGrids[gridID];
    local data = mGridDatas[dataID];
    -- if Grid.itemicon.mainTexture then
	-- 	Grid.itemicon.mainTexture = nil
    -- end
    Grid.itemicon.spriteName = ""
	if data and data.itemData then
        -- local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
        -- UIUtil.SetTexture(loadResID,Grid.itemicon)
        Grid.itemicon.spriteName = data.itemData.icon_big
	end
	

    local bgid = (data and data.itemData) and data.itemData.quality or -1
    if data and data.lock then bgid=nil end
    Grid.itembg.spriteName =  UIUtil.GetItemQualityBgSpName(bgid)  
    Grid.itemcount.text = (data and data.item and data.item.count > 1) and tostring(data.item.count) or "";
    Grid.itemselect:SetActive((data) and mCurSelectIndex == dataID or false);
    Grid.itemlock:SetActive(data and data.lock or false);
    Grid.data = nil
    if data then
        Grid.data = data 
    end
    Grid.gridID = gridID;
    Grid.dataID = dataID;
    Grid.gameObject:SetActive(true);
    
end
--更新物品显示
function UpdateItem()
    for i = 1,MAX_WRAPITEM_COUNT do
        local item = mWrapGrids[i];
        if item and item.gameObject.activeSelf then 
            InitGrid(i,item.gridID);
        end
    end
end


function UpdateSelect()
    for i = 1,MAX_WRAPITEM_COUNT do
       local item = mWrapGrids[i];
       if item and item.gameObject.activeSelf then 
            item.itemselect:SetActive((item.data) and mCurSelectIndex == item.dataID or false);
       end
    end
end

function DoClick(id)
    if DoubleClick==false then
        if id >= 1 then
            --点击物品
            local item = mWrapGrids[id];
                mCurSelectIndex = item.dataID;
                if item.data and item.data.itemData then
                   CloseSecondUI();
                    local itemInfoType = item.data.itemData.itemInfoType
                    --装备显示装备详情
                    if itemInfoType == Item_pb.ItemInfo.EQUIP then
                        local itemSlot = {}
                        itemSlot.slotId = item.data.slotId
                        itemSlot.item = item.data.item
                        EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromTempBag, itemSlot)
                    else
                        --其他类型
                        BagMgr.OpenItemTipsByData(EquipMgr.ItemTipsStyle.FromTempBag, item.data, Bag_pb.TEMP)
                    end
                    
                else
                   CloseSecondUI();
                end
                UpdateSelect();
                GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,AllUI.UI_Bag_TempPackage);
            --end
        else  
           CloseSecondUI();
        end
    end
end
--点击事件处理
function OnClick(go,id)
    GameLog.Log("id %d",id)
    DoubleClick=false;
    if id ==0 then  --关闭
        UIMgr.UnShowUI(AllUI.UI_Bag_TempPackage);
    elseif id ==-1 then
        --一键取回
        if BagMgr.IsFull(Bag_pb.NORMAL) then
            TipsMgr.TipByKey("backpack_info_7");
        else
            BagMgr.RequestClearTempPackage()
        end
    elseif id >= 1 then
        GameTimer.AddTimer(0.2, 1,DoClick,nil,id);
    end
end
function OnDoubleClick(id)
    if id >= 1 then
        DoubleClick=true;
       CloseSecondUI();
        local item = mWrapGrids[id];   
        mCurSelectIndex = item.dataID; 
        UpdateSelect();
        if item.data and item.data.itemData then
            if BagMgr.IsFull(Bag_pb.NORMAL) then
                TipsMgr.TipByKey("backpack_info_7");
            else
                BagMgr.RequestMoveBagItem(Bag_pb.TEMP,item.data.slotId,item.data.item.id,Bag_pb.NORMAL,-1)
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
   if bagType == Bag_pb.TEMP then
        UpdateView();
    end
end


function OnGridUpdate(bagType)
    if bagType == Bag_pb.TEMP then
        UpdateView();
    end
end

function OnOtherSelect(uiType)
    if uiType ~= AllUI.UI_Bag_TempPackage then
        mCurSelectIndex = -1;
        UpdateSelect();
    end
end

function  CloseSecondUI()
    if UI_Bag_Main then
        UI_Bag_Main.CloseSecondUI();
    end
end

function OnMoveItem(redata)
    if redata.fromType == Bag_pb.TEMP or redata.toType == Bag_pb.TEMP then
        CloseSecondUI();
        UpdateView();
    end
end