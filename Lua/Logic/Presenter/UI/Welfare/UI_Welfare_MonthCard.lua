module("UI_Welfare_MonthCard",package.seeall);
local MonthlyReceivePanel = require("Logic/Presenter/UI/Welfare/Subscribe/MonthlyReceivePanel");
local mBuyGo;
local mReceiveGo;
local mReceivePnale;
local mTimerID;

local mNumberGrid1;
local mNumberGrid2;
local mNumberGrid3;
local mPriceRMBLabel1;
local mPriceRMBLabel2;
local mPriceIngotLabel;
local mPriceIngotLabe2;

local mLabels = {};
local mLabelType = {MonthlyValue=1,ImmediatelyAfterPurchase=2,Discount=3,AfterSubscription=4}

local function RefreshBuyInfo()
    local buy = AllPackageMgr.IsMonthlyBuy();
    mBuyGo:SetActive(not buy);
    mReceiveGo:SetActive(buy);
    if buy then
        mReceivePnale:OnRefresh();
        mTimerID = GameTimer.AddForeverTimer(1,mReceivePnale.RefreshAwardTime,mReceivePnale);
    end
end

function OnCreate(ui)
    mBuyGo = ui:Find("Offset/Buy").gameObject;
    mReceiveGo = ui:Find("Offset/Receive").gameObject;
    mReceivePnale = MonthlyReceivePanel.new(ui,"Offset/Receive");



    mNumberGrid1 = ui:FindComponent("UIGrid","Offset/Buy/lable/Grid1");
    mNumberGrid2 = ui:FindComponent("UIGrid","Offset/Buy/lable/Grid2");
    mNumberGrid3 = ui:FindComponent("UIGrid","Offset/Buy/lable/Grid3");
    mNumberGrid1 = UISpriteNumber.new(ui,mNumberGrid1,"num_common_0");
    mNumberGrid2 = UISpriteNumber.new(ui,mNumberGrid2,"num_common_0");
    mNumberGrid3 = UISpriteNumber.new(ui,mNumberGrid3,"num_common_0");

    local label1,label2,label3=nil,nil,nil;
    label1 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable01");
    label2 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable02");
    mLabels[mLabelType.MonthlyValue]={label1,label2};
    
    label1 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable07");
    label2 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable10");
    mLabels[mLabelType.ImmediatelyAfterPurchase]={label1,label2};

    label1 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable03");
    label2 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable04");
    label3 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable05");
    mLabels[mLabelType.Discount]={label1,label2,label3};
    
    label1 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable06");
    label2 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable11");
    label3 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable12");
    mLabels[mLabelType.AfterSubscription]={label1,label2,label3};
    --todo 动态修改Label字

    mPriceRMBLabel1 = ui:FindComponent("UILabel","Offset/Buy/Bg/lable08");
    mPriceRMBLabel2 = ui:FindComponent("UILabel","Offset/Buy/OneBtn/lable");
    mPriceIngotLabel = ui:FindComponent("UILabel","Offset/Buy/Bg/lable09");
    mPriceIngotLabe2 = ui:FindComponent("UILabel","Offset/Buy/FiveBtn/lable");


    local monthIngotCount = ConfigData.GetIntValue("monthCard_month_ingot_count") or 3000;
    local instantIngotCount = ConfigData.GetIntValue("monthCard_instant_ingot_count") or 3000;
    local primePrice = ConfigData.GetIntValue("monthCard_prime_price") or 1000;
    local rmbPrice = ConfigData.GetIntValue("monthCard_rmb_price") or 1;
    local goldPrice = ConfigData.GetIntValue("monthCard_gold_price") or 500;
    mNumberGrid1:SetNumber(monthIngotCount);
    mNumberGrid2:SetNumber(instantIngotCount);
    mNumberGrid3:SetNumber(primePrice);

end

function OnEnable(ui)
    RefreshBuyInfo();
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_CARD_BUY,RefreshBuyInfo);--购买月卡
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_CARD_EXPIRE,mReceivePnale.RefreshExpire,mReceivePnale);--月卡到期时间

    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_DAILY_AWARD_CHANGE,mReceivePnale.RefreshDailyAward,mReceivePnale);--每日奖励变化
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_DAILY_AWARD_RECEIVE,mReceivePnale.RefreshDailyButton,mReceivePnale);--每日奖励领取

    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE,mReceivePnale.RefreshSubscribeButton,mReceivePnale);--月卡订阅
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_AWARD_RECEIVE,mReceivePnale.RefreshSubscribeButton,mReceivePnale);--订阅奖励领取
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_AWARD_CHANGE,mReceivePnale.RefreshSubscribeAward,mReceivePnale);--订阅奖励变化
end

function OnDisable(ui)
    if mTimerID then
        GameTimer.DeleteTimer(mTimerID);
        mTimerID = nil;
    end
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_CARD_BUY,RefreshBuyInfo);
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_CARD_EXPIRE,mReceivePnale.RefreshExpire,mReceivePnale);--月卡到期时间

    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_DAILY_AWARD_CHANGE,mReceivePnale.RefreshDailyAward,mReceivePnale);--每日奖励变化
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_DAILY_AWARD_RECEIVE,mReceivePnale.RefreshDailyButton,mReceivePnale);--每日奖励领取

    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE,mReceivePnale.RefreshSubscribeButton,mReceivePnale);--月卡订阅
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_AWARD_RECEIVE,mReceivePnale.RefreshSubscribeButton,mReceivePnale);--订阅奖励领取
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_AWARD_CHANGE,mReceivePnale.RefreshSubscribeAward,mReceivePnale);--订阅奖励变化
end

function OnClick(go,id)
    if id==0 then
    --月卡说明
    GameLog.LogError("点击月卡Tips按钮");
    elseif id == 1 then
        --这里要向sdk或者服务器发送订阅通知，现在功能还没有直接跳转领取界面
        local desStr = WordData.GetWordStringByKey("monthcard_buy_using_ingot");
        if desStr and desStr~= "monthcard_buy_using_ingot" then
            TipsMgr.TipConfirmByStr(desStr,AllPackageMgr.RequestBuyUsingIngot);
        else
            TipsMgr.TipConfirmByStr("亲爱的小主,您确定要花费500金币购买月卡？",AllPackageMgr.RequestBuyUsingIngot);
        end
    elseif id == 2 then
        --这里要弹出一个tips，现在功能还没有直接跳转领取界面
        AllPackageMgr.RequestBuyUsingRMB();
    else
        mReceivePnale:OnClick(id);
    end
end