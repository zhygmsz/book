--[[
    author:{hesinian}
    time:2018-12-25 13:35:29
]]
module("UI_Welfare_Weekly",package.seeall)
local UIWeekPackageItem = require("Logic/Presenter/UI/Welfare/WeekPackage/UIWeekPackageItem");
local UIDayAward = require("Logic/Presenter/UI/Welfare/WeekPackage/UIDayAward");
local mUIDayAward;
local mUIDayTime;

local mUIPackageGrid;
local mUIPackageTime;

local mUI;
local function OnPackageChange(container)
    mUIPackageGrid:RefreshWrapUI(container);
end

local function OnPackageTimeChange()

end

local function OnDayAwardChange(award)
    mUIDayAward:Refresh(award);
end

local function OnDayAwardTimeChange()

end

function GetUI()
    return mUI;
end

function OnCreate(ui)
    mUI = ui;
    mUIPackageGrid = BaseWrapContentEx.new(ui,"Offset/Receive/WeekAward/Scroll View",3,UIWeekPackageItem,3,UI_Welfare_Weekly);
    mUIPackageGrid:SetUIEvent(100,20);
    mUIPackageTime = ui:FindComponent("UILabel","Offset/Receive/WeekAward/TimeWeek");

    mUIDayAward = UIDayAward.new(ui,"Offset/Receive/DayAward",10);
    mUIDayTime = ui:FindComponent("UILabel","Offset/Receive/DayAward/TimeDay");
end

function OnEnable(ui)
    local containers = AllPackageMgr.GetWeekPackageContainers();
    mUIPackageGrid:ResetWithData(containers);
    OnDayAwardChange(AllPackageMgr.GetDayAward());
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_STATE,OnPackageChange);
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_CHANGE,OnPackageChange);
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_TIME,OnPackageTimeChange);
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_CHANGE,OnDayAwardChange);
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_STATE,OnDayAwardChange);
    GameEvent.Reg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_TIME,OnDayAwardTimeChange);
end

function OnDisable(ui)
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_STATE,OnPackageChange);
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_CHANGE,OnPackageChange);
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_TIME,OnPackageTimeChange);
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_CHANGE,OnDayAwardChange);
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_STATE,OnDayAwardChange);
    GameEvent.UnReg(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_TIME,OnDayAwardTimeChange);
end

function OnClick(go,id)
    if id>= 100 then
        mUIPackageGrid:OnClick(id);
    elseif id >= 10 then
        mUIDayAward:OnClick(id);
    end
end


return UI_Welfare_Weekly;