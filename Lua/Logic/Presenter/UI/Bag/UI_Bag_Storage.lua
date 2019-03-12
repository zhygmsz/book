--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_Storage",package.seeall);

local mStorageName;
--格子对象数组
local mWrapGrids = {}
--itemwrap组件
local mWrap;
local mWrapCallBack;
--全部格子数据数组
local mGridDatas={};
--创建的格子的最大数量
local MAX_WRAPITEM_COUNT =30;
--所有格子数据的最大数量
local MAX_GRID_COUNT = BagMgr.GetMaxGridCount(Bag_pb.DEPOT1);
local MIN_GRID_COUNT =  BagMgr.GetMinGridCount(Bag_pb.DEPOT1)
local mEvents = {};


local mDragPanel;
--local mDragTip;
local DRAG_TIPS_MAX_POS_1 = -50;
local DRAG_TIPS_MAX_POS_2 = -100;
local DRAG_FINISH_OFFSET = Vector3.New(0,-50,0);
local itemCountPerLine = 6
--当前选中的仓库
mCurSelectDEPOT = Bag_pb.DEPOT1;
local mCurSelectIndex = -1;

local mDoubleClick = false
local mArrangeBtn=nil
--格子占用label
local mPercentNum

--整理倒计时
local mTimer = nil
local mTimeLbale = nil
local mCanArrange = true

function OnCreate(self)
    local itemPrefab = self:Find("Offset/ItemPrefab");
    mWrap = self:FindComponent("UIWrapContent","Offset/ItemParent/ScrollView/ItemWrap");
	mWrap.itemCountPerLine=itemCountPerLine
    --mDragTip = self:FindComponent("UILabel","Offset/DragTip");
    mDragPanel = self:Find("Offset/ItemParent/ScrollView").transform;
    mStorageName = self:FindComponent("UILabel","Offset/Storages/NameBtn/Name");
    for i = 1,MAX_WRAPITEM_COUNT do
        mWrapGrids[i] = NewItem(self,itemPrefab,i);
    end 
    mPercentNum = self:FindComponent("UILabel","Offset/PercentNum"); 
    itemPrefab.gameObject:SetActive(false);
    --mDragTip.gameObject:SetActive(false);
    mTimeLbale = self:FindComponent("UILabel", "Offset/ArrangeBtn/timer");
    mArrangeBtn= self:FindComponent("GameCore.UIEvent","Offset/ArrangeBtn"); 
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
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PAGENAME,OnUpdatePageName);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID,OnGridUpdate);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,OnOtherSelect);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,OnMoveItem);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_ARRANGE_BAG,OnPackageArrange);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UNLOCK_PAGE,OnUnLockPage);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,OnPackageUpdate);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PAGENAME,OnUpdatePageName);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID,OnGridUpdate);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,OnOtherSelect);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,OnMoveItem);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_ARRANGE_BAG,OnPackageArrange);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UNLOCK_PAGE,OnUnLockPage);
    mEvents = {};
end

function OnEnable(self)
    RegEvent(self);
   -- BagMgr.RequestBagData({Bag_pb.DEPOT1,Bag_pb.DEPOT2,Bag_pb.DEPOT3,Bag_pb.DEPOT4,Bag_pb.DEPOT5,Bag_pb.DEPOT6});
    InitPanel();
    UpdateView()
	UpdateBeat:Add(Update,self);
end

function OnDisable(self)
    mCurSelectIndex = -1;
    UnRegEvent(self);
	UpdateBeat:Remove(Update,self);
end

function Update()
	if mTimer then
		mTimeLbale.text = string.format("%.2d",GameTimer.GetTimerLeftDuration(mTimer)) 
	else
		mTimeLbale.text = ""
	end
end

function InitName()
    mStorageName.text = BagMgr.GetDEPOTName(mCurSelectDEPOT);
end
--==============================--
--desc:UI布局函数
--time:2018-04-26 08:00:51
--@return 
--==============================--
--初始化面板
function InitPanel()
    local scrollView = mDragPanel:GetComponent("UIScrollView");
    local scrollPanel = mDragPanel:GetComponent("UIPanel");
    scrollView.resetOffset = Vector3.zero;
    scrollPanel.clipOffset = Vector2.zero;
    mDragPanel.localPosition = Vector3.zero;
end

--刷险背包界面显示
function UpdateView()
    CurrentBagData = BagMgr.BagData[mCurSelectDEPOT]
    if CurrentBagData then
        mGridDatas=BagMgr.GetGridDatas(mCurSelectDEPOT,-1)
        local N= table.getn(CurrentBagData.items)
        mPercentNum.text = string.format("%d/%d",N,CurrentBagData.maxSlots)
        UpdateLayout();
        InitName();
    end
end

--scrollowview布局
function UpdateLayout()
    table.sort(mWrapGrids,function(a,b) return a.gameObject.name < b.gameObject.name; end);
    for k,v in pairs(mWrapGrids) do if v then v.uiEvent.id = k; end end  
    if not mWrapCallBack then mWrapCallBack = UIWrapContent.OnInitializeItem(OnInitGrid); end
    mWrap:ResetWrapContent(NewGridCount(),mWrapCallBack);
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
    Grid.itemicon.spriteName = ""
	if data and data.itemData then
        -- local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
        -- UIUtil.SetTexture(loadResID,Grid.itemicon)
        Grid.itemicon.spriteName = data.itemData.icon_big
	end
    local bgid = (data and data.itemData) and data.itemData.quality or nil
    if data and data.lock then bgid=-1 end
    Grid.itembg.spriteName =  UIUtil.GetItemQualityBgSpName(bgid)  
    Grid.itemcount.text = (data and data.item and data.item.count > 1) and tostring(data.item.count) or "";
    Grid.itemselect:SetActive((data and data.itemData) and mCurSelectIndex == gridID or false);
    Grid.itemlock:SetActive(data and data.lock or false);
    Grid.data = data;
    Grid.gridID = gridID;
    Grid.dataID = dataID;
    Grid.gameObject:SetActive(true);
end


--更新物品显示
function UpdateItem()
    for i = 1,MAX_WRAPITEM_COUNT do
        local item = mWrapGrids[i];
        if item.gameObject.activeSelf then 
            InitGrid(i,item.gridID);
        end
    end
end

function UpdateSelect()
    for i = 1,MAX_WRAPITEM_COUNT do
        local item = mWrapGrids[i];
        item.itemselect:SetActive(mCurSelectIndex == item.gridID);
    end
end

function OnInitItem(go,wrapIndex,realIndex)
    if realIndex >= 0 then--and realIndex <= BagMgr.GetMaxGridCount(Bag_pb.WAREHOUSE) then
        go:SetActive(true);
        InitItem(wrapIndex + 1,realIndex + 1);
    else
        go:SetActive(false);
    end
end

function DoClick(id)
    if mDoubleClick==false then
        if id >= 1 then
            --点击物品
            local item = mWrapGrids[id];
                mCurSelectIndex = item.dataID;
                if  item.data.itemData then  
                    UI_Bag_Main.CloseSecondUI();
                    local itemInfoType = item.data.itemData.itemInfoType
                    --装备显示装备详情
                    if itemInfoType == Item_pb.ItemInfo.EQUIP then
                        local itemSlot = {}
                        itemSlot.slotId = item.data.slotId
                        itemSlot.item = item.data.item
                        EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromDepot, itemSlot)
                    else
                        --其他类型
                        BagMgr.OpenItemTipsByData(EquipMgr.ItemTipsStyle.FromDepot, item.data, mCurSelectDEPOT)
                    end
                else
                    UI_Bag_Main.CloseSecondUI();
                end
                UpdateSelect();
                GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,AllUI.UI_Bag_Storage);
        --  end
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
function OnClick(go,id)
  --  GameLog.Log("id %d",id)
    mDoubleClick=false;
    if id == -1 then
        --整理仓库
        if mCanArrange then
			--点击整理
			BagMgr.RequestArrangeBag(mCurSelectDEPOT);
			mCanArrange = false
			local cd = BagMgr.GetArrangementCd()
			mTimer = GameTimer.AddTimer(cd, 1, ResetArrangeBtn,nil, id);
		else
			TipsMgr.TipByKey("backpack_info_3");
        end
    elseif id == -2 then 
        --仓库列表
        UIMgr.ShowUI(AllUI.UI_Bag_StorageList);
    elseif id == -3 then
        --下一页
        mCurSelectDEPOT = BagMgr.GetNextDepot(mCurSelectDEPOT)
        UpdateView()
    elseif id == -4 then
        --上一页
        mCurSelectDEPOT = BagMgr.GetLastDepot(mCurSelectDEPOT)
        UpdateView()
    elseif id == -5 then
        --改名
        UIMgr.ShowUI(AllUI.UI_Bag_ModifyName);
    elseif id >= 1 then
        GameTimer.AddTimer(0.2, 1,DoClick,nil,id);
    end
end

--双击取回背包
function OnDoubleClick(id)
    if id >= 1 then
        mDoubleClick=true;
        local item = mWrapGrids[id];   
        if mCurSelectIndex ~= item.dataID then
          mCurSelectIndex = item.dataID;
          UpdateSelect();
          GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_OTHER_SELECT,AllUI.UI_Bag_Storage);
        end 
        if item.data and  item.data.itemData then
            BagMgr.RequestMoveBagItem(mCurSelectDEPOT,item.data.slotId,item.data.item.id,Bag_pb.NORMAL,-1)
        end   
    end
end

function OnDrag()
    --计算拖拽距离,显示TIPS
   --[[ local dragTrans = mDragPanel;
    if dragTrans.localPosition.y <= DRAG_TIPS_MAX_POS_1 then
        --mDragTip.gameObject:SetActive(true);
        if dragTrans.localPosition.y <= DRAG_TIPS_MAX_POS_2 then
            mDragTip.text = WordData.GetStringValue(WordData.storage_drag_tip_2);
        else
            mDragTip.text = WordData.GetStringValue(WordData.storage_drag_tip_1);
        end
    else
       -- mDragTip.gameObject:SetActive(false);
    end
    --]]
end

function OnDragFinish()
   --[[ --拖拽结束
    if mDragPanel.localPosition.y <= DRAG_TIPS_MAX_POS_2 then
        UI_Bag_Main.CloseSecondUI();
        mDragTip.text = WordData.GetStringValue(WordData.storage_drag_tip_3);
        UpdateScrollView(false);
        BagMgr.RequestArrangeBag(Bag_pb.WAREHOUSE,mCurSelectDEPOT);
    else
        mDragTip.gameObject:SetActive(false);
    end--]]
end


--==============================--
--desc:消息回调
--time:2018-04-26 08:02:15
--@bagType:
--@return 
--==============================--
--收到背包信息更新的回调
function OnPackageUpdate(bagType)
    if bagType == mCurSelectDEPOT then
        UpdateView()
     end
 end

--整理回调
function OnPackageArrange(result)
    --成功
    if result.ret ==0 and result.bagType== mCurSelectDEPOT then
        UI_Bag_Main.CloseSecondUI()
        BagMgr.RequestBagData({mCurSelectDEPOT})
    end
end


--修改仓库名称的回调
function OnUpdatePageName(bagType,result)
    if result == 0 then
        if bagType ==mCurSelectDEPOT then
            InitName();
        end
    end
end

function OnGridUpdate(bagType)
    if bagType == mCurSelectDEPOT then
        UpdateView();
    end
end

function OnMoveItem(redata)
    if redata.fromType == mCurSelectDEPOT or redata.toType == mCurSelectDEPOT then
        UI_Bag_Main.CloseSecondUI();
        UpdateSelect();
    end
end

function OnOtherSelect(uiType)
    if uiType ~= AllUI.UI_Bag_Storage then
        mCurSelectIndex = -1;
        UpdateSelect();
    end
end

function OnUnLockPage(bagType)
    mCurSelectDEPOT = bagType
    UpdateView()
    UIMgr.UnShowUI(AllUI.UI_Bag_StorageList);
end
--endregion
