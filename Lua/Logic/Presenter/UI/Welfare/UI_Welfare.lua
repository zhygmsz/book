module("UI_Welfare",package.seeall)

local mPanelStaticData = {};
local mPanelDynamicData = {};
local mContentGrid;
local mToggleGroup;

local mOpenIndex;
local function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

local function RegisterPanel(id,UIPanel,title)
    mPanelStaticData[id] = {eventId = id, ui = UIPanel,content=title};
end

--占用1,20
local function InitPanelStatic()
    RegisterPanel(1,AllUI.UI_Welfare_DailySign,WordData.GetWordStringByKey("welfare_panel_dailySign"));--每日签到
    RegisterPanel(2,AllUI.UI_Puzzle,WordData.GetWordStringByKey("welfare_panel_puzzle"));--拼图
    RegisterPanel(3,AllUI.UI_SevenDayLogin,WordData.GetWordStringByKey("welfare_panel_sevenDaySign"));--七日礼包
    RegisterPanel(4,AllUI.UI_Welfare_Weekly,WordData.GetWordStringByKey("welfare_panel_weeklyDiscount"));--每周特惠
    RegisterPanel(5,AllUI.UI_Welfare_MonthCard,WordData.GetWordStringByKey("welfare_panel_monthCard"));--月卡
    RegisterPanel(6,AllUI.UI_Welfare_Subscribe,WordData.GetWordStringByKey("welfare_panel_subscribe"));--订阅
end

local function InitPanelDynamic()
    local str = WordData.GetWordStringByKey("welfare_panel_list,1,2,3,4,5,6");
    local list = split(str,',');
    for i=1,#list do
        local flag,re = pcall(tonumber,list[i]);
        if flag then
            table.insert(mPanelDynamicData,re);
        end
    end
end

local function OnContentCreate(trans,index)
    local panelID = mPanelDynamicData[index];
    mPanelStaticData[panelID].trs = trans;

    mToggleGroup:AddItem(mPanelStaticData[panelID]);
end

function OnCreate(ui)
    local titleLable = ui:FindComponent("UILabel","Offset/Title");
    mToggleGroup = ToggleGroupUIMgr.new(titleLable);
    InitPanelStatic();
    InitPanelDynamic();
    mContentGrid = UIScrollGridTable.new(ui,"Offset/Content/Scroll View");
    mContentGrid:ResetWrapContent(#mPanelDynamicData,OnContentCreate);
    mToggleGroup._toggleGroup._itemList[2]._gameObject:SetActive(false);--暂时隐藏拼图功能
end

function OnEnable(ui)
    mOpenIndex = mOpenIndex or 1;
    mToggleGroup:OnClick(mPanelDynamicData[mOpenIndex]);
    UIMgr.MaskUI(true, 0, 199);
end

function OnDisable(ui)
    mOpenIndex = nil;
    UIMgr.MaskUI(false, 0, 199);
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Welfare);
        mToggleGroup:Reset();
    elseif id <=20 then
        mToggleGroup:OnClick(id);
    end
end

--字界面的Index,参见InitPanelStatic()方法
function ShowUI(index)
    mOpenIndex = index;
    if AllUI.UI_Welfare.enable then
        mToggleGroup:OnClick(index);
    else
        UIMgr.ShowUI(AllUI.UI_Welfare);
    end
end

return UI_Welfare