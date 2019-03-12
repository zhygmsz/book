module("UI_Tip_EnsureSupplyExchange",package.seeall)

local mUIdata ={}
local showData = {}

function OnCreate(self)
    mUIdata.mAsk = self:FindComponent("UILabel","Offset/Bg/Content/Ask");
    mUIdata.mTitle = self:FindComponent("UILabel","Offset/Bg/Title");
    mUIdata.mDisplay = self:FindComponent("UILabel","Offset/Bg/Content/Display");
    mUIdata.mCostNum = self:FindComponent("UILabel","Offset/Bg/Content/CostNumBg/CostNum");
    mUIdata.mCostIcon = self:FindComponent("UISprite","Offset/Bg/Content/CostNumBg/CostIcon");

    mUIdata.mGoldSupply = self:Find("Offset/Bg/Content/GoldSupply");
    mUIdata.mGoldSupplyEvent = self:FindComponent("UIEvent","Offset/Bg/Content/GoldSupply/Btn_GoldSure");
    mUIdata.mGoldSupplyEvent.id = 101
    mUIdata.mGoldSupplyLabel =self:FindComponent("UILabel","Offset/Bg/Content/GoldSupply/Btn_GoldSure/Label");
    mUIdata.mGoldSupplyNum = self:FindComponent("UILabel","Offset/Bg/Content/GoldSupply/Btn_GoldSure/Num");
    mUIdata.mGoldSupplyIcon = self:FindComponent("UISprite","Offset/Bg/Content/GoldSupply/Btn_GoldSure/Icon");

    mUIdata.mSilverSupply = self:Find("Offset/Bg/Content/SilverSupply");
    mUIdata.mSilverSupplyEvent1 = self:FindComponent("UIEvent","Offset/Bg/Content/SilverSupply/Btn_SilvertSure1");
    mUIdata.mSilverSupplyEvent1.id = 102
    mUIdata.mSilverSupplyLabel1 =self:FindComponent("UILabel","Offset/Bg/Content/SilverSupply/Btn_SilvertSure1/Label");
    mUIdata.mSilverSupplyNum1 = self:FindComponent("UILabel","Offset/Bg/Content/SilverSupply/Btn_SilvertSure1/Num");
    mUIdata.mSilverSupplyIcon1 = self:FindComponent("UISprite","Offset/Bg/Content/SilverSupply/Btn_SilvertSure1/Icon");
    mUIdata.mSilverSupplyEvent2 = self:FindComponent("UIEvent","Offset/Bg/Content/SilverSupply/Btn_SilvertSure2");
    mUIdata.mSilverSupplyEvent2.id = 103
    mUIdata.mSilverSupplyLabel2 =self:FindComponent("UILabel","Offset/Bg/Content/SilverSupply/Btn_SilvertSure2/Label");
    mUIdata.mSilverSupplyNum2 = self:FindComponent("UILabel","Offset/Bg/Content/SilverSupply/Btn_SilvertSure2/Num");
    mUIdata.mSilverSupplyIcon2 = self:FindComponent("UISprite","Offset/Bg/Content/SilverSupply/Btn_SilvertSure2/Icon");
 
    mUIdata.mBtn_Tip = self:FindComponent("UIEvent","Offset/Bg/Content/Btn_Tip");
    mUIdata.mBtn_Tip.id = 20
end

function OnEnable(self)
    UpdateView()
end

function OnDisable(self)
end

-- function OnPress(id, press)
-- 	if id ==20 then
-- 		if press then
-- 			TipsMgr.TipByKey("common_exchange_silver_msg")
-- 		end
-- 	end
-- end

function UpdateView()
    if showData.supplyType then
        mUIdata.mDisplay.text = TipsMgr.GetTipByKey("common_exchange_goldless",BagMgr.GetCoinName(showData.supplyType))
        --TipsMgr.GetTipByKey("bag_coin_supply_display",BagMgr.GetCoinName(showData.supplyType))
        mUIdata.mCostNum.text = showData.supplyNum and string.NumberFormat(showData.supplyNum,0) or ""
        mUIdata.mCostIcon.spriteName = BagMgr.GetCoinIconName(showData.supplyType)
    end
    --金币不足补充
    if showData.supplyType and showData.supplyType== Coin_pb.GOLD then
        mUIdata.mAsk.gameObject:SetActive(true)
        mUIdata.mSilverSupply.gameObject:SetActive(false)
        mUIdata.mGoldSupply.gameObject:SetActive(true)
        mUIdata.mBtn_Tip.gameObject:SetActive(false)
        --mUIdata.mAsk.text =TipsMgr.GetTipByKey("bag_coin_supply_ensureask",costnum,costname,leftnum,supplyname)
        --金币只有元宝兑换
        SetExchangeButton(3,mUIdata.mGoldSupplyEvent.gameObject,mUIdata.mGoldSupplyLabel,mUIdata.mGoldSupplyNum,mUIdata.mGoldSupplyIcon)
    --银币不足补充 两种兑换方案
    elseif showData.supplyType and showData.supplyType== Coin_pb.SILVER then 
        mUIdata.mAsk.gameObject:SetActive(false)
        mUIdata.mBtn_Tip.gameObject:SetActive(true)
        mUIdata.mSilverSupply.gameObject:SetActive(true)
        mUIdata.mGoldSupply.gameObject:SetActive(false)
        SetExchangeButton(1,mUIdata.mSilverSupplyEvent1.gameObject,mUIdata.mSilverSupplyLabel1,mUIdata.mSilverSupplyNum1,mUIdata.mSilverSupplyIcon1)
        SetExchangeButton(2,mUIdata.mSilverSupplyEvent2.gameObject,mUIdata.mSilverSupplyLabel2,mUIdata.mSilverSupplyNum2,mUIdata.mSilverSupplyIcon2)   
    end
end

function SetExchangeButton(solindex,obj,label,num,icon)
    if showData.supplySolution and showData.supplySolution[solindex] then
        obj:SetActive(true)
        local sol = showData.supplySolution[solindex]
        local costname = BagMgr.GetCoinName(sol.from)
        local costnum=string.NumberFormat(sol.num,0)
        local leftnum=string.NumberFormat(sol.left,0)
        local supplyname= BagMgr.GetCoinName(showData.supplyType)
        mUIdata.mAsk.text =TipsMgr.GetTipByKey("common_exchange_gold_msg",costnum,costname,leftnum,supplyname)
        local key = "common_exchange_gold_byingot"
        if sol.from == Coin_pb.GOLD and sol.to ==Coin_pb.SILVER then
            key="common_exchange_silver_bygold" 
        elseif sol.from ==Coin_pb.INGOT and sol.to == Coin_pb.SILVER  then
            key= "common_exchange_silver_byingot"
        end
        label.text = TipsMgr.GetTipByKey(key,"")
        num.text = sol.enough and TipsMgr.GetTipByKey("common_exchange_normal_color",costnum) or TipsMgr.GetTipByKey("common_exchange_warning_color",costnum)
        icon.spriteName = BagMgr.GetCoinIconName(sol.from)
        icon:MakePixelPerfect()
    else
        obj:SetActive(false)
    end
end

function SetData(supplyType,supplyNum,supplySolution,iokFunc,icancelFunc)
    showData.supplyType = supplyType
    showData.supplyNum = supplyNum
    showData.supplySolution = supplySolution
    showData.okFunc = iokFunc
    showData.cancelFunc = icancelFunc
end

--supplyType补充兑换的货币类型:Coin_pb.INGOT Coin_pb.GOLD supplyNum须要补充的数量
--supplySolution 兑换解决方案数组 {[1]={from=Coin_pb.INGOT ,to=Coin_pb.GOLD,num = 100,left = 20}}
function ShowTip(supplyType,showIndex,supplySolution,iokFunc,icancelFunc)
    if supplySolution[showIndex] then
        SetData(supplyType,supplySolution[showIndex].supplyNum,supplySolution,iokFunc,icancelFunc)
    end
    UIMgr.ShowUI(AllUI.UI_Tip_EnsureSupplyExchange);
end

function OnClick(go,id)
    if id == 101 then--金币补给
        UIMgr.UnShowUI(AllUI.UI_Tip_EnsureSupplyExchange);
        if showData.okFunc then
            showData.okFunc(showData.supplySolution,3)
        end
    elseif id == 102 then--银币补给 方案1 用金币
        UIMgr.UnShowUI(AllUI.UI_Tip_EnsureSupplyExchange);
            if showData.okFunc then
                showData.okFunc(showData.supplySolution,1)
            end
    elseif id == 103 then--银币补给 方案2 用元宝
        UIMgr.UnShowUI(AllUI.UI_Tip_EnsureSupplyExchange);
        if showData.okFunc then
            showData.okFunc(showData.supplySolution,2)
        end
    elseif id == 0 then--关闭
        UIMgr.UnShowUI(AllUI.UI_Tip_EnsureSupplyExchange);
        if showData.cancelFunc then showData.cancelFunc() end
    elseif id ==20 then
        local title = TipsMgr.GetTipByKey("common_exchange_describe")
        local content = TipsMgr.GetTipByKey("common_exchange_silver_msg")
        TipsMgr.TipDerscribe({title = title,content = content})
    end
end
