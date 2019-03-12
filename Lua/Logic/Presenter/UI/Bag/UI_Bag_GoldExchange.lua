--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_GoldExchange",package.seeall);
require "Logic/Presenter/UI/Common/NumberKeyboard/UI_NumberKeyboard"

--itemwrap组件
local mWrap;
local mDragPanel
local MAX_WRAPITEM_COUNT =0;
--格子对象数组
local mWrapGrids = {}
--全部格子数据数组
local mGridDatas={};
local DRAG_FINISH_OFFSET = Vector3.New(0,0,0);
--兑换模式
local mExchangeMode = 1
--兑换目标品类 1 金币 2 银币
local mExchangeType = 1
local mHoldLabel
local mHoldIcon
local mHoldNum
local mEarnLabel 
local mEarnIcon
local mEarnNum
local mToggle1
local mToggle2
local mToggle2Obj
local mRateTitle
local mRate1
local mRate2
local mAccessTitle
local mTitle
local mInGotNum
local mExchange
local mInputNum = {value = 0 ,defaultText = ""}
local mInputLabel = nil
local itemCountPerLine=1
--兑换比率
local ingotgold=1
local ingotsilver=1
local goldsilver =1

local mToggleScript1 = nil
local mToggleScript2 = nil
local mExPad = nil
local mContentTable = nil
local mAccessLabel = nil
local mAccessTitle = nil

function GetCoinIconName(coinType)
   return BagMgr.GetCoinIconName(coinType)
end

function GetCoinName(coinType)
    return BagMgr.GetCoinName(coinType)
end
--标题
function GetTitle(earntype)
    local coin = GetCoinName(earntype)
    return TipsMgr.GetTipByKey("bag_exchange_ex",coin)
end
--我的XX
function GetItemTitle(earntype)
    local coin = GetCoinName(earntype)
    local text =TipsMgr.GetTipByKey("bag_exchange_my",coin)
    return string.format("%s：",text)
end
--获得XX
function GetEarnTitle(earntype)
    local coin = GetCoinName(earntype)
    local text =TipsMgr.GetTipByKey("bag_exchange_earn",coin)
    return string.format( "%s：",text)
end

--==============================--
function OnCreate(self)
    mTitle = self:FindComponent("UILabel","Offset/Title");
    mContentTable =  self:FindComponent("UITable","Offset/Table");
    mExPad= self:Find("Offset/Table/ExPad")
    mIcon = self:FindComponent("UISprite","Offset/Table/InputPad/Icon");
    mHoldLabel = self:FindComponent("UILabel","Offset/Table/HoldPad/HoldLabel");
    mHoldIcon = self:FindComponent("UISprite","Offset/Table/HoldPad/HoldIcon");
    mHoldNum = self:FindComponent("UILabel","Offset/Table/HoldPad/HoldNum");
    mEarnLabel = self:FindComponent("UILabel","Offset/Table/EarnPad/EarnLabel");
    mEarnIcon = self:FindComponent("UISprite","Offset/Table/EarnPad/EarnIcon");
    mEarnNum = self:FindComponent("UILabel","Offset/Table/EarnPad/EarnNum");
    mRateTitle = self:FindComponent("UILabel","Offset/RateTitle");
    mRate1 = self:FindComponent("UILabel","Offset/Rate1");
    mRate2 = self:FindComponent("UILabel","Offset/Rate2");
    mToggle1 = self:FindComponent("UILabel","Offset/Table/ExPad/Toggles/Part1/Name");
    mToggle2Obj = self:Find("Offset/Table/ExPad/Toggles/Part2");
    mToggle2 = self:FindComponent("UILabel","Offset/Table/ExPad/Toggles/Part2/Name");
    mToggleScript1 = self:FindComponent("UIToggle","Offset/Table/ExPad/Toggles/Part1");
    mToggleScript2 = self:FindComponent("UIToggle","Offset/Table/ExPad/Toggles/Part2");
    mExchange = self:FindComponent("UILabel","Offset/Table/InputPad/Exchange");
   -- mInputNum = self:FindComponent("LuaUIInput","Offset/InputBg/InputNum");
   -- local call = EventDelegate.Callback(OnChange);
  --  EventDelegate.Set(mInputNum.onChange,call);
    mInputLabel = self:FindComponent("UILabel","Offset/Table/InputPad/InputBg/Label");
    local itemPrefab = self:Find("Offset/Access/ItemPrefab");
    mWrap = self:FindComponent("UIWrapContent","Offset/Access/ItemParent/ScrollView/ItemWrap");
	mWrap.itemCountPerLine=itemCountPerLine
    mDragPanel = self:Find("Offset/Access/ItemParent/ScrollView").transform;
    for i = 1,MAX_WRAPITEM_COUNT do
        mWrapGrids[i] = NewItem(self,itemPrefab,i);
    end 
    itemPrefab.gameObject:SetActive(false);
    mAccessTitle =  self:FindComponent("UILabel","Offset/Access/Title");
    mAccessLabel =  self:FindComponent("UILabel","Offset/Access/ItemParent/ScrollView/Content");
end

function NewItem(self,obj,index)
    local item = {};
    item.index = index;
    item.gameObject = self:DuplicateAndAdd(obj,mWrap.transform,index).gameObject;
    item.gameObject.name = tostring(10000 + index);
    item.transform = item.gameObject.transform;
    item.Icon = item.transform:Find("Icon"):GetComponent("UISprite");
    item.Des = item.transform:Find("Des"):GetComponent("UILabel");
    item.Select = item.transform:Find("ItemSelect"):GetComponent("UISprite");
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.gameObject:SetActive(false);
    return item;
end

local mEvents = {};
function RegEvent(self)
   GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,SetLabelText)
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,SetLabelText);
    mEvents = {};
end

function OnEnable(self,mType,mMode)
    mExchangeType = mType or 1
    mExchangeMode = mMode or 1
    mInputNum.value=0
    RegEvent(self);
    InitPanel();
    UpdateView()
end

function OnDisable(self)
    UnRegEvent(self);
end

--初始化面板
function InitPanel()
    local scrollView = mDragPanel:GetComponent("UIScrollView");
    local scrollPanel = mDragPanel:GetComponent("UIPanel");
    scrollView.resetOffset = Vector3.zero;
    scrollPanel.clipOffset = Vector2.zero;
    mDragPanel.localPosition = Vector3.zero;
end

--当前物品格子数
function NewGridCount()
    local curGridCount = 0
    if mGridDatas then curGridCount =table.getn(mGridDatas); end
    GameLog.Log("curGridCount &d",curGridCount)
    return curGridCount;
end

--刷险背包界面显示
function UpdateView()
    mGridDatas={}
    DRAG_FINISH_OFFSET=mDragPanel.localPosition
    mHoldType =  mExchangeMode==1 and Coin_pb.INGOT or mExchangeType==1 and Coin_pb.SILVER or Coin_pb.GOLD
    mEarnType =  mExchangeType==1 and Coin_pb.GOLD or Coin_pb.SILVER
    mExPad.gameObject:SetActive(mEarnType == Coin_pb.SILVER)
    mContentTable.padding = mEarnType == Coin_pb.SILVER and Vector2.zero or Vector2(0,10)
    if mExchangeMode==2 then
        mToggleScript2:Set(true,true)
    end
    UpdateLayout();
    SetLabelText()
    mAccessLabel.text = mEarnType == Coin_pb.SILVER and  TipsMgr.GetTipByKey("bag_exchange_getyinbiway2") or TipsMgr.GetTipByKey("bag_exchange_getjinbiway2") 
    mAccessTitle.text = mEarnType == Coin_pb.SILVER and  TipsMgr.GetTipByKey("bag_exchange_getyinbiway1") or TipsMgr.GetTipByKey("bag_exchange_getjinbiway1") 
    OnChange(mInputNum.value)
    mContentTable:Reposition()
end

--scrollowview布局
function UpdateLayout()
    table.sort(mWrapGrids,function(a,b) return a.gameObject.name < b.gameObject.name; end);
    for k,v in pairs(mWrapGrids) do if v then v.uiEvent.id = 30+k; end end  
    mWrap:ResetWrapContent(NewGridCount(),OnInitGrid);
end

--设置文本
function SetLabelText(onlyNum)
    ingotgold = ConfigData.GetIntValue("bag_exchange_cashtogold") or 100
    goldsilver = ConfigData.GetIntValue("bag_exchange_goldtosilver") or 100
    ingotsilver = ingotgold*goldsilver
    mTitle.text = GetTitle(mEarnType)
    mHoldLabel.text = GetItemTitle(mHoldType)
    mHoldIcon.spriteName = GetCoinIconName(mHoldType)
    mHoldNum.text = string.NumberFormat(BagMgr.GetMoney(mHoldType),0);
    mEarnLabel.text = GetEarnTitle(mEarnType)
    mEarnIcon.spriteName = GetCoinIconName(mEarnType)
    local rate = mEarnType == Coin_pb.GOLD and ingotgold or mHoldType == Coin_pb.INGOT and ingotsilver or goldsilver
    mEarnNum.text =string.NumberFormat(mInputNum.value*rate,0)
    local MaxCount = GetExchangeMaxCount()
    if mInputNum.value<=0 and MaxCount>0 then
        mInputNum.value=1
    elseif mInputNum.value>=0 and MaxCount<=0 then
        mInputNum.value=0
    end
    mInputLabel.text = string.NumberFormat(mInputNum.value,0) 
    mIcon.spriteName = GetCoinIconName(mHoldType)
    mExchange.text = string.format("%s：",TipsMgr.GetTipByKey("bag_exchange_num"))
    mInputNum.defaultText = TipsMgr.GetTipByKey("bag_exchange_inputdefault")
    mToggle1.text = TipsMgr.GetTipByKey("bag_coin_ingot") 
    mToggle2.text =  mExchangeType==1 and TipsMgr.GetTipByKey("bag_coin_silver")  or TipsMgr.GetTipByKey("bag_coin_gold") 
    mToggle2Obj.gameObject:SetActive(mExchangeType == 2)
    mRateTitle.text =TipsMgr.GetTipByKey("bag_exchange_rate")
    local ratestr1 = mEarnType == Coin_pb.GOLD and TipsMgr.GetTipByKey("bag_exchange_ingotgold",string.NumberFormat(ingotgold,0)) or  TipsMgr.GetTipByKey("bag_exchange_ingotsilver",string.NumberFormat(ingotsilver,0))
    local ratestr2 =  TipsMgr.GetTipByKey("bag_exchange_goldsilver",string.NumberFormat(goldsilver,0))
    mRate1.text = ratestr1
    mRate2.text = ratestr2
    mRate2.gameObject:SetActive(mEarnType == Coin_pb.SILVER)

    mHoldIcon:MakePixelPerfect()
    mIcon:MakePixelPerfect()
    mEarnIcon:MakePixelPerfect()
end


--初始化各自信息 范围内的可见 
function OnInitGrid(go,wrapIndex,realIndex)
    if realIndex >= 0 then --and realIndex <= CurrentBagData.maxSlots 
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
    Grid.Icon.spriteName = "" 
    Grid.Des.text = tostring(dataID)
    Grid.data = nil
    if data then
        Grid.data = data 
    end
    Grid.gridID = gridID;
    Grid.dataID = dataID;
    Grid.gameObject:SetActive(true);
end

function Exchange(value,input)
    mInputNum.value = value
    local MaxCount,holdoverSysMax = GetExchangeMaxCount()
    if mInputNum.value<=0 and MaxCount>0 then
        mInputNum.value=1
    elseif mInputNum.value>=0 and MaxCount<=0 then
        mInputNum.value=0
    end
    if mInputNum.value >= MaxCount and input then
        if holdoverSysMax then
            TipsMgr.TipByKey("bag_exchange_over")
        else
            TipsMgr.TipByKey("bag_exchange_overmax")
        end
    end
    local useNum =  tonumber(mInputNum.value)
    if useNum==nil then useNum=0 end
    if useNum<0 then useNum=0 end
    if useNum>MaxCount then useNum=MaxCount end
    local rate = mEarnType == Coin_pb.GOLD and ingotgold or mHoldType == Coin_pb.INGOT and ingotsilver or goldsilver
    mEarnNum.text =string.NumberFormat(mInputNum.value*rate,0)
    mInputLabel.text = string.NumberFormat(mInputNum.value,0) 
end

function OnChange(value,input)
    Exchange(value,input)
end

function OnSubmit(value,input)
    Exchange(value,input)
end

--获取兑换最大值
function GetExchangeMaxCount()
    local key = "bag_exchange_maxbao"
    if mHoldType == Coin_pb.GOLD then key = "bag_exchange_maxgold" end
    local mymax = BagMgr.GetMoney(mHoldType)
    local sysmax = ConfigData.GetIntValue(key)
    local max = math.min(mymax,sysmax)
    return max,sysmax>=mymax
end

--点击事件处理
function OnClick(go,id)
    GameLog.Log("id %d",id)
    if id ==-1 then
        mExchangeMode = 1
        mInputNum.value=0
        UpdateView()
    elseif id ==-2 then
        mExchangeMode = 2
        mInputNum.value=0
        UpdateView()
    elseif id ==13 then
        --兑换
        OnChange(mInputNum.value)
        if mInputNum.value >0 then
            BagMgr.ExchangeCoin(mHoldType,mEarnType,mInputNum.value)
            mInputNum.value= 0
            UpdateView()
        else
            TipsMgr.TipByKey("bag_exchange_num_msg")
        end
    elseif id ==14 then
        --取消
        UIMgr.UnShowUI(AllUI.UI_Bag_GoldExchange);
    elseif id ==0 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Bag_GoldExchange);
    elseif id >=30 then
        --点击获取途径
    elseif id ==10 then
        local max =GetExchangeMaxCount()
        UI_NumberKeyboard.SetDefaultText(mInputNum.defaultText)
        UI_NumberKeyboard.ShowKeyboard(mInputLabel,mInputNum.value,max,OnSubmit,OnChange,Vector3(486.7,68.1,0))
    end
end