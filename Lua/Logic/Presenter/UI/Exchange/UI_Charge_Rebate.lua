module("UI_Charge_Rebate",package.seeall)
local UIChargeRebateWrapUI = require("Logic/Presenter/UI/Exchange/Charge/UIChargeRebateWrapUI");

local mRebateTable;
local mUI;

function OnCreate(ui)
    mUI=ui;
    local path = "RebateScrollView/Scroll View";
    mRebateTable = BaseWrapContentEx.new(ui,path,8,UIChargeRebateWrapUI,1,UI_Charge_Rebate);
    mRebateTable:SetUIEvent(100,10);
end

function OnEnable(ui)
    OnRefreshRebate();
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_REBATE_STATE,OnRebateValueChange);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_HAS_RECHARGE_UPDATEUI,OnRefreshRebate);
end

function OnDisable(ui)
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_REBATE_STATE,OnRebateValueChange);
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_HAS_RECHARGE_UPDATEUI,OnRefreshRebate);
end

function OnClick(go,id)
    mRebateTable:OnClick(id);
end

function OnRebateValueChange(rebate)
    mRebateTable:RefreshWrapUI(rebate);
end

function OnRefreshRebate()
    local allRebates = ChargeMgr.GetChargeRebates();
    mRebateTable:ResetWithData(allRebates);
end

function GetUIFrame()
    return mUI;
end