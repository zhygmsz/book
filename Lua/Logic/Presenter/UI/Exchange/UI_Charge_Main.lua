module("UI_Charge_Main",package.seeall)

local mIngotCount;

local mToggleGroup;



function OnCreate(ui)
    local title = ui:FindComponent("UILabel","ChoiceTabList/RechargeTab/nor/Label");
    mToggleGroup = ToggleGroupUIMgr.new(title);
    local rechargeTrans = ui:Find("ChoiceTabList/RechargeTab");
    mToggleGroup:AddItem({trs = rechargeTrans,eventId = 1, ui = AllUI.UI_Charge_Recharge});

    local btnTrans = ui:Find("ChoiceTabList/RebateTab");
    mToggleGroup:AddItem({trs = btnTrans,eventId = 2, ui = AllUI.UI_Charge_Rebate});

    local mExclamatoryBtn = ui:Find("ChoiceTabList/ExclamatoryBtn").gameObject;
    if SystemInfo.IsEditor() or SystemInfo.IsIosPlatform() then
        mExclamatoryBtn:SetActive(true);
    else
        mExclamatoryBtn:SetActive(false);
    end
end

function OnEnable(ui)
    if (not ChargeMgr.GetEntryUI()) and ChargeMgr.NeedShowEntry() then
        UIMgr.ShowUI(AllUI.UI_ChargeFirst);
    end
    ChargeMgr.RequestInitCharge();
    mToggleGroup:OnClick(1);
end

function OnDisable(ui)
    mToggleGroup:Reset();
end

function OnClick(go,id)
    if id == 1 or id == 2 then
        mToggleGroup:OnClick(id);
    elseif id == 0 then
        UIMgr.ShowUI(AllUI.UI_Charge_Instruction);
    end
end