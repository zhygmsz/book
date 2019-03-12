--[[
    author:{hesinian}
    time:2018-12-26 11:00:18
]]

module("UI_Welfare_Subscribe",package.seeall)

local mAwardGrid;
local mSubGo;
local mCancelGo;
local mDesLabel1;
local mDesLabel2;

local function Refresh()
    local subscribed = AllPackageMgr.IsSubscribed();
    mSubGo:SetActive(not subscribed);
    mCancelGo:SetActive(subscribed);
end

function OnCreate(ui)
    local grid = ui:FindComponent("UIGrid","Offset/Buy/Grid");
    local prefab = ui:Find("Offset/Buy/Grid/item");
    mAwardGrid = UICommonDropItemGrid.new(ui,grid,prefab,10);
    mSubGo = ui:Find("Offset/Buy/BuyBtn").gameObject;
    mCancelGo = ui:Find("Offset/Buy/CancelBtn").gameObject;

    mDesLabel1= ui:FindComponent("UILabel","Offset/Buy/Des");
    mDesLabel2= ui:FindComponent("UILabel","Offset/Buy/tip");

    mDesLabel1.text = WordData.GetWordStringByKey("welfare_subscribe_label_1")~="welfare_subscribe_label_1" and WordData.GetWordStringByKey("welfare_subscribe_label_1") or "订阅说明\n特权自动续订！30天为一个周期，每期1元。\n订阅到期后自动续费更多心悦信息及取消续订";
    mDesLabel2.text = WordData.GetWordStringByKey("welfare_subscribe_label_2")~="welfare_subscribe_label_2" and WordData.GetWordStringByKey("welfare_subscribe_label_2") or "自动续费声明:\n1.付款：自动续费商品包括“鹿鼎记助手”，您确认购买后，会从您的iTunes账户扣费;\n2.续费特权：你的特权到期前24小时，苹果会自动为您从iTunes账户扣费，成功后有效期自动延长一个周期;\n3.取消续费：若需要取消续费，请在到期前24小时在“ios-账户设置”关闭，关闭后不再扣费。";
    
    local items = AllPackageMgr.GetFirstSubscribeItems();
    mAwardGrid:Refresh(items);
end

function OnEnable(ui)
    Refresh();
    GameEvent.Reg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE,Refresh);
end

function OnDisable(ui)
    GameEvent.UnReg(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE,Refresh);
end

function OnClick(go,id)
    if id == 0 then
        --订阅说明
    elseif id == 1 then--打开月卡
        UI_Welfare.ShowUI(5);
    elseif id == 2 then--打开每周礼包
        UI_Welfare.ShowUI(4);
    elseif id == 3 then--开启订阅
        AllPackageMgr.RequestOpenSubscribe();
    elseif id == 4 then--取消订阅
        AllPackageMgr.RequestCancelSubscribe();
    elseif id >= 10 then
        mAwardGrid:OnClick(id);
    end
end
