module("UI_Relation",package.seeall)

local mPanelID;
local mPanels = {};
local mToggleGroup;

local function RegisterPanel(btnTrans,id,UIPanel,title)
    mPanels[id] = {trs = btnTrans,eventId = id, ui = UIPanel,content=title};
    mToggleGroup:AddItem(mPanels[id]);
end

function OnCreate(ui)
    local title = ui:FindComponent("UILabel","Offset/Bg/Title");
    mToggleGroup = ToggleGroupUIMgr.new(title);
    local trans = ui:Find("Offset/TabList/Tog1");
    RegisterPanel(trans,1,AllUI.UI_Friend_Main);
    
    trans = ui:Find("Offset/TabList/Tog2");
    RegisterPanel(trans,2,AllUI.UI_Mail);

    trans = ui:Find("Offset/TabList/Tog3");
    RegisterPanel(trans,3,AllUI.UI_Friend_Main);

    trans = ui:Find("Offset/TabList/Tog4");
    RegisterPanel(trans,4,AllUI.UI_Friend_Main);

    trans = ui:Find("Offset/TabList/Tog5");
    RegisterPanel(trans,5,AllUI.UI_Friend_Main);
end

function OnEnable(ui)
    mToggleGroup:OnClick(mPanelID);
    UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_Relation));
end

function OnDisable()
    mToggleGroup:Reset();
    UIMgr.MaskUI(false);
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Relation);
        if mPanelID then
            UIMgr.UnShowUI(mPanels[mPanelID].ui);
        end
    else
        mToggleGroup:OnClick(id);
        mPanelID = id;
    end
end

--1好友,2邮件,3师徒,4结拜,5姻缘
function ShowUI(id)
    mPanelID = id;
    UIMgr.ShowUI(AllUI.UI_Relation);

    if id == 2 then
        UIMgr.ShowUI(AllUI.UI_Mail)
    end
end