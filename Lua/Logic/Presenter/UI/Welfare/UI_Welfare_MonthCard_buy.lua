module("UI_Welfare_MonthCard_buy",package.seeall)
local UI_Welfare = require("Logic/Presenter/UI/Welfare/UI_Welfare")
local mLabels = {}
local mEventType = {
    Close=1,
    Buy=2,
}

function OnCreate(ui)
    mLabels[1] = ui:FindComponent("UILabel","Offset/Title/Label");
    mLabels[2] = ui:FindComponent("UILabel","Offset/des");
    mLabels[3] = ui:FindComponent("UILabel","Offset/Button/Label");

    mLabels[2].text = WordData.GetWordStringByKey("welfare_monthCard_Springwindow_UI");
    mLabels[3].text = WordData.GetWordStringByKey("welfare_monthCard_Springwindow_get");

    local mClickBtnEvent = ui:FindComponent("UIEvent","Offset/Bg/CloseBtn");
    local mBuyBtnEvent = ui:FindComponent("UIEvent","Offset/Button");
    mClickBtnEvent.id = mEventType.Close;
    mBuyBtnEvent.id = mEventType.Buy;
end

function OnEnable(ui)
end

function OnDisable(ui)
end

function OnClick(go,id)
    if id == mEventType.Close then
        UIMgr.UnShowUI(AllUI.UI_Welfare_MonthCard_buy);
    elseif id==mEventType.Buy then
        UIMgr.UnShowUI(AllUI.UI_Welfare_MonthCard_buy);
        UI_Welfare.ShowUI(5);--打开月卡
    end
end