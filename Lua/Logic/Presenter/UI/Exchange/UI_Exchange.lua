module("UI_Exchange",package.seeall)

local mPanelID;
local mPanels = {};
local mToggleGroup;

local function RegisterPanel(btnTrans,id,UIPanel,title)
    mPanels[id] = {trs = btnTrans,eventId = id, ui = UIPanel,content=title};
    mToggleGroup:AddItem(mPanels[id]);
end

function OnCreate(ui)
    local title = ui:FindComponent("UILabel","Offset/Title");
    mToggleGroup = ToggleGroupUIMgr.new(title);
    local trans = ui:Find("Offset/TabList/MallTab");
    RegisterPanel(trans,2,AllUI.UI_Shop_Store);
    
    trans = ui:Find("Offset/TabList/ChamberTab");
    RegisterPanel(trans,1,AllUI.UI_Shop_Commerce);

    trans = ui:Find("Offset/TabList/TradingBankTab");
    RegisterPanel(trans,3,AllUI.UI_Charge_Main);

    trans = ui:Find("Offset/TabList/Recharge");
    local name = WordData.GetWordStringByKey("charge_title_name")--充值
    RegisterPanel(trans,4,AllUI.UI_Charge_Main,name);
end

function OnEnable(ui)
    mToggleGroup:OnClick(mPanelID);
    UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_Exchange));
end

function OnDisable()
    mToggleGroup:Reset();
    UIMgr.MaskUI(false);
end
function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Exchange);
        UIMgr.UnShowUI(mPanels[mPanelID].ui);
    else
        mToggleGroup:OnClick(id);
        mPanelID = id;
    end
end

--1商城,2商会,3交易行,4充值界面
function ShowUI(id)
    mPanelID = id;
    UIMgr.ShowUI(AllUI.UI_Exchange);
end