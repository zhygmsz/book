module("UI_Charge_Recharge",package.seeall)

local UIChargeGoodsWrapUI = require("Logic/Presenter/UI/Exchange/Charge/UIChargeGoodsWrapUI");
local mGoodsTable;
local mUI;
--6 30 50 98 198 298 488 648
local mGoodsEffectResId = {400400072,400400073,400400074,400400075,400400076,400400077,400400078,400400079}

function OnCreate(ui)
    mUI = ui;
    mIngotCount = ui:FindComponent("UILabel","Have_bg/HaveCount" );
    local path = "Scroll View";
    mGoodsTable = BaseWrapContentEx.new(ui,path,12,UIChargeGoodsWrapUI,4,UI_Charge_Recharge);
    mGoodsTable:SetUIEvent(100,5,OnGoodsClick);
    ui:FindComponent("UILabel","Have_bg/BottomTip").text = WordData.GetWordStringByKey("Pay_shop_message");
end

local function OnIngotChange()
    mIngotCount.text = ChargeMgr.NumberFormatPerMille(ChargeMgr.GetMyIngotCount(),",");
end

function OnClick(go,id)
    if id<1000 then
    mGoodsTable:OnClick(id);
    else
        OnPackageClick(id);
    end
end

function OnGoodsClick(goods)
    ChargeMgr.RequestBuyGoods(goods);
end

local function OnGoodsValueChange(goods)
    mGoodsTable:RefreshWrapUI(goods);
end

function OnEnable(ui)
    OnIngotChange();
    OnRefreshRecharge();
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_FREE_DOUBLE,OnGoodsValueChange);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_GIFT_PACKAGE,OnGoodsValueChange);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_HAS_RECHARGE_UPDATEUI,OnRefreshRecharge);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,OnIngotChange);
end

function OnDisable(ui)
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_FREE_DOUBLE,OnGoodsValueChange);
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_GIFT_PACKAGE,OnGoodsValueChange);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_HAS_RECHARGE_UPDATEUI,OnRefreshRecharge);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,OnIngotChange);
end

function GetUIFrame()
    return mUI;
end

function OnRefreshRecharge()
    local allGoods = ChargeMgr.GetChargeGoods();
    mGoodsTable:ResetWithData(allGoods);
end

function OnPackageClick(id)
    if ItemData.GetItemInfo(id) ==nil then GameLog.LogError("Show Charge Rebate Gift Package Tips,Cant find the item %s",id); return; end
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, id);
end

function GetGoodsEffectRes(idx)
    if mGoodsEffectResId and mGoodsEffectResId[idx] then
        return mGoodsEffectResId[idx];
    else
        return nil;
    end
end