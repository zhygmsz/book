module("UI_Vitality_Calendar", package.seeall);

local mSelf;
local mMonthLabel;

local mCurrentMonth;
local mCurrentWeekDay;

local mMondayTrans;
local mTuesdayTrans;
local mWednesdayTrans;
local mThursdayTrans;
local mFridayTrans;
local mSatrudayTrans;
local mSundayTrans;

local mTodayFlagTrans;

local mCalendarList = {};

function OnCreate(self)
	mSelf = self;
	mMonthLabel = self:FindComponent("UILabel", "Offset/Bg/BgDate/BgMonth/MonthLabel");
	
	mMondayTrans = self:Find("Offset/Bg/BgDate/BgWeek01").transform;
	mTuesdayTrans = self:Find("Offset/Bg/BgDate/BgWeek02").transform;
	mWednesdayTrans = self:Find("Offset/Bg/BgDate/BgWeek03").transform;
	mThursdayTrans = self:Find("Offset/Bg/BgDate/BgWeek04").transform;
	mFridayTrans = self:Find("Offset/Bg/BgDate/BgWeek05").transform;
	mSatrudayTrans = self:Find("Offset/Bg/BgDate/BgWeek06").transform;
	mSundayTrans = self:Find("Offset/Bg/BgDate/BgWeek07").transform;
	
	mTodayFlagTrans = self:Find("Offset/Bg/BgDate/BgWeek01/TodayFlag").transform;
	
	local week_1 = {};
	
	local dataItem_1_1 = {};
	dataItem_1_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_1/DataInfo").transform;
	dataItem_1_1.normalTipRoot = dataItem_1_1.rootTrans:Find("NormalTip");
	dataItem_1_1.normalTipNameLabel = dataItem_1_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_1.timTipRoot = dataItem_1_1.rootTrans:Find("TimeTip");
	dataItem_1_1.timeTipNameLabel = dataItem_1_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_1.timeTipTimeLabel = dataItem_1_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_1.todayFlag = dataItem_1_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_1.enableFlag = dataItem_1_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_1);
	
	local dataItem_1_2 = {};
	dataItem_1_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_2/DataInfo").transform;
	dataItem_1_2.normalTipRoot = dataItem_1_2.rootTrans:Find("NormalTip");
	dataItem_1_2.normalTipNameLabel = dataItem_1_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_2.timTipRoot = dataItem_1_2.rootTrans:Find("TimeTip");
	dataItem_1_2.timeTipNameLabel = dataItem_1_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_2.timeTipTimeLabel = dataItem_1_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_2.todayFlag = dataItem_1_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_2.enableFlag = dataItem_1_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_2);
	
	local dataItem_1_3 = {};
	dataItem_1_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_3/DataInfo").transform;
	dataItem_1_3.normalTipRoot = dataItem_1_3.rootTrans:Find("NormalTip");
	dataItem_1_3.normalTipNameLabel = dataItem_1_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_3.timTipRoot = dataItem_1_3.rootTrans:Find("TimeTip");
	dataItem_1_3.timeTipNameLabel = dataItem_1_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_3.timeTipTimeLabel = dataItem_1_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_3.todayFlag = dataItem_1_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_3.enableFlag = dataItem_1_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_3);
	
	local dataItem_1_4 = {};
	dataItem_1_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_4/DataInfo").transform;
	dataItem_1_4.normalTipRoot = dataItem_1_4.rootTrans:Find("NormalTip");
	dataItem_1_4.normalTipNameLabel = dataItem_1_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_4.timTipRoot = dataItem_1_4.rootTrans:Find("TimeTip");
	dataItem_1_4.timeTipNameLabel = dataItem_1_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_4.timeTipTimeLabel = dataItem_1_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_4.todayFlag = dataItem_1_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_4.enableFlag = dataItem_1_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_4);
	
	local dataItem_1_5 = {};
	dataItem_1_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_5/DataInfo").transform;
	dataItem_1_5.normalTipRoot = dataItem_1_5.rootTrans:Find("NormalTip");
	dataItem_1_5.normalTipNameLabel = dataItem_1_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_5.timTipRoot = dataItem_1_5.rootTrans:Find("TimeTip");
	dataItem_1_5.timeTipNameLabel = dataItem_1_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_5.timeTipTimeLabel = dataItem_1_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_5.todayFlag = dataItem_1_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_5.enableFlag = dataItem_1_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_5);
	
	local dataItem_1_6 = {};
	dataItem_1_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week01_6/DataInfo").transform;
	dataItem_1_6.normalTipRoot = dataItem_1_6.rootTrans:Find("NormalTip");
	dataItem_1_6.normalTipNameLabel = dataItem_1_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_6.timTipRoot = dataItem_1_6.rootTrans:Find("TimeTip");
	dataItem_1_6.timeTipNameLabel = dataItem_1_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_1_6.timeTipTimeLabel = dataItem_1_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_1_6.todayFlag = dataItem_1_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_1_6.enableFlag = dataItem_1_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_1, dataItem_1_6);
	
	table.insert(mCalendarList, week_1);
	
	local week_2 = {};
	
	local dataItem_2_1 = {};
	dataItem_2_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_1/DataInfo").transform;
	dataItem_2_1.normalTipRoot = dataItem_2_1.rootTrans:Find("NormalTip");
	dataItem_2_1.normalTipNameLabel = dataItem_2_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_1.timTipRoot = dataItem_2_1.rootTrans:Find("TimeTip");
	dataItem_2_1.timeTipNameLabel = dataItem_2_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_1.timeTipTimeLabel = dataItem_2_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_1.todayFlag = dataItem_2_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_1.enableFlag = dataItem_2_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_1);
	
	local dataItem_2_2 = {};
	dataItem_2_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_2/DataInfo").transform;
	dataItem_2_2.normalTipRoot = dataItem_2_2.rootTrans:Find("NormalTip");
	dataItem_2_2.normalTipNameLabel = dataItem_2_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_2.timTipRoot = dataItem_2_2.rootTrans:Find("TimeTip");
	dataItem_2_2.timeTipNameLabel = dataItem_2_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_2.timeTipTimeLabel = dataItem_2_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_2.todayFlag = dataItem_2_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_2.enableFlag = dataItem_2_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_2);
	
	local dataItem_2_3 = {};
	dataItem_2_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_3/DataInfo").transform;
	dataItem_2_3.normalTipRoot = dataItem_2_3.rootTrans:Find("NormalTip");
	dataItem_2_3.normalTipNameLabel = dataItem_2_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_3.timTipRoot = dataItem_2_3.rootTrans:Find("TimeTip");
	dataItem_2_3.timeTipNameLabel = dataItem_2_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_3.timeTipTimeLabel = dataItem_2_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_3.todayFlag = dataItem_2_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_3.enableFlag = dataItem_2_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_3);
	
	local dataItem_2_4 = {};
	dataItem_2_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_4/DataInfo").transform;
	dataItem_2_4.normalTipRoot = dataItem_2_4.rootTrans:Find("NormalTip");
	dataItem_2_4.normalTipNameLabel = dataItem_2_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_4.timTipRoot = dataItem_2_4.rootTrans:Find("TimeTip");
	dataItem_2_4.timeTipNameLabel = dataItem_2_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_4.timeTipTimeLabel = dataItem_2_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_4.todayFlag = dataItem_2_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_4.enableFlag = dataItem_2_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_4);
	
	local dataItem_2_5 = {};
	dataItem_2_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_5/DataInfo").transform;
	dataItem_2_5.normalTipRoot = dataItem_2_5.rootTrans:Find("NormalTip");
	dataItem_2_5.normalTipNameLabel = dataItem_2_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_5.timTipRoot = dataItem_2_5.rootTrans:Find("TimeTip");
	dataItem_2_5.timeTipNameLabel = dataItem_2_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_5.timeTipTimeLabel = dataItem_2_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_5.todayFlag = dataItem_2_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_5.enableFlag = dataItem_2_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_5);
	
	local dataItem_2_6 = {};
	dataItem_2_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week02_6/DataInfo").transform;
	dataItem_2_6.normalTipRoot = dataItem_2_6.rootTrans:Find("NormalTip");
	dataItem_2_6.normalTipNameLabel = dataItem_2_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_6.timTipRoot = dataItem_2_6.rootTrans:Find("TimeTip");
	dataItem_2_6.timeTipNameLabel = dataItem_2_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_2_6.timeTipTimeLabel = dataItem_2_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_2_6.todayFlag = dataItem_2_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_2_6.enableFlag = dataItem_2_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_2, dataItem_2_6);
	
	table.insert(mCalendarList, week_2);
	
	local week_3 = {};
	
	local dataItem_3_1 = {};
	dataItem_3_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_1/DataInfo").transform;
	dataItem_3_1.normalTipRoot = dataItem_3_1.rootTrans:Find("NormalTip");
	dataItem_3_1.normalTipNameLabel = dataItem_3_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_1.timTipRoot = dataItem_3_1.rootTrans:Find("TimeTip");
	dataItem_3_1.timeTipNameLabel = dataItem_3_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_1.timeTipTimeLabel = dataItem_3_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_1.todayFlag = dataItem_3_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_1.enableFlag = dataItem_3_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_1);
	
	local dataItem_3_2 = {};
	dataItem_3_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_2/DataInfo").transform;
	dataItem_3_2.normalTipRoot = dataItem_3_2.rootTrans:Find("NormalTip");
	dataItem_3_2.normalTipNameLabel = dataItem_3_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_2.timTipRoot = dataItem_3_2.rootTrans:Find("TimeTip");
	dataItem_3_2.timeTipNameLabel = dataItem_3_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_2.timeTipTimeLabel = dataItem_3_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_2.todayFlag = dataItem_3_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_2.enableFlag = dataItem_3_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_2);
	
	local dataItem_3_3 = {};
	dataItem_3_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_3/DataInfo").transform;
	dataItem_3_3.normalTipRoot = dataItem_3_3.rootTrans:Find("NormalTip");
	dataItem_3_3.normalTipNameLabel = dataItem_3_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_3.timTipRoot = dataItem_3_3.rootTrans:Find("TimeTip");
	dataItem_3_3.timeTipNameLabel = dataItem_3_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_3.timeTipTimeLabel = dataItem_3_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_3.todayFlag = dataItem_3_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_3.enableFlag = dataItem_3_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_3);
	
	local dataItem_3_4 = {};
	dataItem_3_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_4/DataInfo").transform;
	dataItem_3_4.normalTipRoot = dataItem_3_4.rootTrans:Find("NormalTip");
	dataItem_3_4.normalTipNameLabel = dataItem_3_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_4.timTipRoot = dataItem_3_4.rootTrans:Find("TimeTip");
	dataItem_3_4.timeTipNameLabel = dataItem_3_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_4.timeTipTimeLabel = dataItem_3_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_4.todayFlag = dataItem_3_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_4.enableFlag = dataItem_3_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_4);
	
	local dataItem_3_5 = {};
	dataItem_3_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_5/DataInfo").transform;
	dataItem_3_5.normalTipRoot = dataItem_3_5.rootTrans:Find("NormalTip");
	dataItem_3_5.normalTipNameLabel = dataItem_3_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_5.timTipRoot = dataItem_3_5.rootTrans:Find("TimeTip");
	dataItem_3_5.timeTipNameLabel = dataItem_3_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_5.timeTipTimeLabel = dataItem_3_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_5.todayFlag = dataItem_3_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_5.enableFlag = dataItem_3_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_5);
	
	local dataItem_3_6 = {};
	dataItem_3_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week03_6/DataInfo").transform;
	dataItem_3_6.normalTipRoot = dataItem_3_6.rootTrans:Find("NormalTip");
	dataItem_3_6.normalTipNameLabel = dataItem_3_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_6.timTipRoot = dataItem_3_6.rootTrans:Find("TimeTip");
	dataItem_3_6.timeTipNameLabel = dataItem_3_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_3_6.timeTipTimeLabel = dataItem_3_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_3_6.todayFlag = dataItem_3_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_3_6.enableFlag = dataItem_3_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_3, dataItem_3_6);
	
	table.insert(mCalendarList, week_3);
	
	local week_4 = {};
	
	local dataItem_4_1 = {};
	dataItem_4_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_1/DataInfo").transform;
	dataItem_4_1.normalTipRoot = dataItem_4_1.rootTrans:Find("NormalTip");
	dataItem_4_1.normalTipNameLabel = dataItem_4_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_1.timTipRoot = dataItem_4_1.rootTrans:Find("TimeTip");
	dataItem_4_1.timeTipNameLabel = dataItem_4_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_1.timeTipTimeLabel = dataItem_4_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_1.todayFlag = dataItem_4_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_1.enableFlag = dataItem_4_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_1);
	
	local dataItem_4_2 = {};
	dataItem_4_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_2/DataInfo").transform;
	dataItem_4_2.normalTipRoot = dataItem_4_2.rootTrans:Find("NormalTip");
	dataItem_4_2.normalTipNameLabel = dataItem_4_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_2.timTipRoot = dataItem_4_2.rootTrans:Find("TimeTip");
	dataItem_4_2.timeTipNameLabel = dataItem_4_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_2.timeTipTimeLabel = dataItem_4_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_2.todayFlag = dataItem_4_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_2.enableFlag = dataItem_4_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_2);
	
	local dataItem_4_3 = {};
	dataItem_4_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_3/DataInfo").transform;
	dataItem_4_3.normalTipRoot = dataItem_4_3.rootTrans:Find("NormalTip");
	dataItem_4_3.normalTipNameLabel = dataItem_4_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_3.timTipRoot = dataItem_4_3.rootTrans:Find("TimeTip");
	dataItem_4_3.timeTipNameLabel = dataItem_4_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_3.timeTipTimeLabel = dataItem_4_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_3.todayFlag = dataItem_4_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_3.enableFlag = dataItem_4_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_3);
	
	local dataItem_4_4 = {};
	dataItem_4_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_4/DataInfo").transform;
	dataItem_4_4.normalTipRoot = dataItem_4_4.rootTrans:Find("NormalTip");
	dataItem_4_4.normalTipNameLabel = dataItem_4_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_4.timTipRoot = dataItem_4_4.rootTrans:Find("TimeTip");
	dataItem_4_4.timeTipNameLabel = dataItem_4_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_4.timeTipTimeLabel = dataItem_4_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_4.todayFlag = dataItem_4_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_4.enableFlag = dataItem_4_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_4);
	
	local dataItem_4_5 = {};
	dataItem_4_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_5/DataInfo").transform;
	dataItem_4_5.normalTipRoot = dataItem_4_5.rootTrans:Find("NormalTip");
	dataItem_4_5.normalTipNameLabel = dataItem_4_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_5.timTipRoot = dataItem_4_5.rootTrans:Find("TimeTip");
	dataItem_4_5.timeTipNameLabel = dataItem_4_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_5.timeTipTimeLabel = dataItem_4_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_5.todayFlag = dataItem_4_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_5.enableFlag = dataItem_4_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_5);
	
	local dataItem_4_6 = {};
	dataItem_4_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week04_6/DataInfo").transform;
	dataItem_4_6.normalTipRoot = dataItem_4_6.rootTrans:Find("NormalTip");
	dataItem_4_6.normalTipNameLabel = dataItem_4_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_6.timTipRoot = dataItem_4_6.rootTrans:Find("TimeTip");
	dataItem_4_6.timeTipNameLabel = dataItem_4_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_4_6.timeTipTimeLabel = dataItem_4_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_4_6.todayFlag = dataItem_4_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_4_6.enableFlag = dataItem_4_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_4, dataItem_4_6);
	
	table.insert(mCalendarList, week_4);
	
	local week_5 = {};
	
	local dataItem_5_1 = {};
	dataItem_5_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_1/DataInfo").transform;
	dataItem_5_1.normalTipRoot = dataItem_5_1.rootTrans:Find("NormalTip");
	dataItem_5_1.normalTipNameLabel = dataItem_5_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_1.timTipRoot = dataItem_5_1.rootTrans:Find("TimeTip");
	dataItem_5_1.timeTipNameLabel = dataItem_5_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_1.timeTipTimeLabel = dataItem_5_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_1.todayFlag = dataItem_5_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_1.enableFlag = dataItem_5_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_1);
	
	local dataItem_5_2 = {};
	dataItem_5_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_2/DataInfo").transform;
	dataItem_5_2.normalTipRoot = dataItem_5_2.rootTrans:Find("NormalTip");
	dataItem_5_2.normalTipNameLabel = dataItem_5_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_2.timTipRoot = dataItem_5_2.rootTrans:Find("TimeTip");
	dataItem_5_2.timeTipNameLabel = dataItem_5_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_2.timeTipTimeLabel = dataItem_5_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_2.todayFlag = dataItem_5_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_2.enableFlag = dataItem_5_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_2);
	
	local dataItem_5_3 = {};
	dataItem_5_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_3/DataInfo").transform;
	dataItem_5_3.normalTipRoot = dataItem_5_3.rootTrans:Find("NormalTip");
	dataItem_5_3.normalTipNameLabel = dataItem_5_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_3.timTipRoot = dataItem_5_3.rootTrans:Find("TimeTip");
	dataItem_5_3.timeTipNameLabel = dataItem_5_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_3.timeTipTimeLabel = dataItem_5_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_3.todayFlag = dataItem_5_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_3.enableFlag = dataItem_5_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_3);
	
	local dataItem_5_4 = {};
	dataItem_5_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_4/DataInfo").transform;
	dataItem_5_4.normalTipRoot = dataItem_5_4.rootTrans:Find("NormalTip");
	dataItem_5_4.normalTipNameLabel = dataItem_5_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_4.timTipRoot = dataItem_5_4.rootTrans:Find("TimeTip");
	dataItem_5_4.timeTipNameLabel = dataItem_5_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_4.timeTipTimeLabel = dataItem_5_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_4.todayFlag = dataItem_5_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_4.enableFlag = dataItem_5_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_4);
	
	local dataItem_5_5 = {};
	dataItem_5_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_5/DataInfo").transform;
	dataItem_5_5.normalTipRoot = dataItem_5_5.rootTrans:Find("NormalTip");
	dataItem_5_5.normalTipNameLabel = dataItem_5_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_5.timTipRoot = dataItem_5_5.rootTrans:Find("TimeTip");
	dataItem_5_5.timeTipNameLabel = dataItem_5_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_5.timeTipTimeLabel = dataItem_5_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_5.todayFlag = dataItem_5_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_5.enableFlag = dataItem_5_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_5);
	
	local dataItem_5_6 = {};
	dataItem_5_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week05_6/DataInfo").transform;
	dataItem_5_6.normalTipRoot = dataItem_5_6.rootTrans:Find("NormalTip");
	dataItem_5_6.normalTipNameLabel = dataItem_5_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_6.timTipRoot = dataItem_5_6.rootTrans:Find("TimeTip");
	dataItem_5_6.timeTipNameLabel = dataItem_5_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_5_6.timeTipTimeLabel = dataItem_5_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_5_6.todayFlag = dataItem_5_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_5_6.enableFlag = dataItem_5_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_5, dataItem_5_6);
	
	table.insert(mCalendarList, week_5);
	
	local week_6 = {};
	
	local dataItem_6_1 = {};
	dataItem_6_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_1/DataInfo").transform;
	dataItem_6_1.normalTipRoot = dataItem_6_1.rootTrans:Find("NormalTip");
	dataItem_6_1.normalTipNameLabel = dataItem_6_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_1.timTipRoot = dataItem_6_1.rootTrans:Find("TimeTip");
	dataItem_6_1.timeTipNameLabel = dataItem_6_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_1.timeTipTimeLabel = dataItem_6_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_1.todayFlag = dataItem_6_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_1.enableFlag = dataItem_6_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_1);
	
	local dataItem_6_2 = {};
	dataItem_6_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_2/DataInfo").transform;
	dataItem_6_2.normalTipRoot = dataItem_6_2.rootTrans:Find("NormalTip");
	dataItem_6_2.normalTipNameLabel = dataItem_6_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_2.timTipRoot = dataItem_6_2.rootTrans:Find("TimeTip");
	dataItem_6_2.timeTipNameLabel = dataItem_6_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_2.timeTipTimeLabel = dataItem_6_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_2.todayFlag = dataItem_6_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_2.enableFlag = dataItem_6_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_2);
	
	local dataItem_6_3 = {};
	dataItem_6_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_3/DataInfo").transform;
	dataItem_6_3.normalTipRoot = dataItem_6_3.rootTrans:Find("NormalTip");
	dataItem_6_3.normalTipNameLabel = dataItem_6_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_3.timTipRoot = dataItem_6_3.rootTrans:Find("TimeTip");
	dataItem_6_3.timeTipNameLabel = dataItem_6_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_3.timeTipTimeLabel = dataItem_6_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_3.todayFlag = dataItem_6_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_3.enableFlag = dataItem_6_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_3);
	
	local dataItem_6_4 = {};
	dataItem_6_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_4/DataInfo").transform;
	dataItem_6_4.normalTipRoot = dataItem_6_4.rootTrans:Find("NormalTip");
	dataItem_6_4.normalTipNameLabel = dataItem_6_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_4.timTipRoot = dataItem_6_4.rootTrans:Find("TimeTip");
	dataItem_6_4.timeTipNameLabel = dataItem_6_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_4.timeTipTimeLabel = dataItem_6_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_4.todayFlag = dataItem_6_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_4.enableFlag = dataItem_6_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_4);
	
	local dataItem_6_5 = {};
	dataItem_6_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_5/DataInfo").transform;
	dataItem_6_5.normalTipRoot = dataItem_6_5.rootTrans:Find("NormalTip");
	dataItem_6_5.normalTipNameLabel = dataItem_6_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_5.timTipRoot = dataItem_6_5.rootTrans:Find("TimeTip");
	dataItem_6_5.timeTipNameLabel = dataItem_6_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_5.timeTipTimeLabel = dataItem_6_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_5.todayFlag = dataItem_6_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_5.enableFlag = dataItem_6_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_5);
	
	local dataItem_6_6 = {};
	dataItem_6_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week06_6/DataInfo").transform;
	dataItem_6_6.normalTipRoot = dataItem_6_6.rootTrans:Find("NormalTip");
	dataItem_6_6.normalTipNameLabel = dataItem_6_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_6.timTipRoot = dataItem_6_6.rootTrans:Find("TimeTip");
	dataItem_6_6.timeTipNameLabel = dataItem_6_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_6_6.timeTipTimeLabel = dataItem_6_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_6_6.todayFlag = dataItem_6_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_6_6.enableFlag = dataItem_6_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_6, dataItem_6_6);
	
	table.insert(mCalendarList, week_6);
	
	local week_7 = {};
	
	local dataItem_7_1 = {};
	dataItem_7_1.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_1/DataInfo").transform;
	dataItem_7_1.normalTipRoot = dataItem_7_1.rootTrans:Find("NormalTip");
	dataItem_7_1.normalTipNameLabel = dataItem_7_1.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_1.timTipRoot = dataItem_7_1.rootTrans:Find("TimeTip");
	dataItem_7_1.timeTipNameLabel = dataItem_7_1.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_1.timeTipTimeLabel = dataItem_7_1.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_1.todayFlag = dataItem_7_1.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_1.enableFlag = dataItem_7_1.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_1);
	
	local dataItem_7_2 = {};
	dataItem_7_2.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_2/DataInfo").transform;
	dataItem_7_2.normalTipRoot = dataItem_7_2.rootTrans:Find("NormalTip");
	dataItem_7_2.normalTipNameLabel = dataItem_7_2.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_2.timTipRoot = dataItem_7_2.rootTrans:Find("TimeTip");
	dataItem_7_2.timeTipNameLabel = dataItem_7_2.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_2.timeTipTimeLabel = dataItem_7_2.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_2.todayFlag = dataItem_7_2.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_2.enableFlag = dataItem_7_2.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_2);
	
	local dataItem_7_3 = {};
	dataItem_7_3.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_3/DataInfo").transform;
	dataItem_7_3.normalTipRoot = dataItem_7_3.rootTrans:Find("NormalTip");
	dataItem_7_3.normalTipNameLabel = dataItem_7_3.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_3.timTipRoot = dataItem_7_3.rootTrans:Find("TimeTip");
	dataItem_7_3.timeTipNameLabel = dataItem_7_3.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_3.timeTipTimeLabel = dataItem_7_3.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_3.todayFlag = dataItem_7_3.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_3.enableFlag = dataItem_7_3.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_3);
	
	local dataItem_7_4 = {};
	dataItem_7_4.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_4/DataInfo").transform;
	dataItem_7_4.normalTipRoot = dataItem_7_4.rootTrans:Find("NormalTip");
	dataItem_7_4.normalTipNameLabel = dataItem_7_4.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_4.timTipRoot = dataItem_7_4.rootTrans:Find("TimeTip");
	dataItem_7_4.timeTipNameLabel = dataItem_7_4.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_4.timeTipTimeLabel = dataItem_7_4.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_4.todayFlag = dataItem_7_4.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_4.enableFlag = dataItem_7_4.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_4);
	
	local dataItem_7_5 = {};
	dataItem_7_5.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_5/DataInfo").transform;
	dataItem_7_5.normalTipRoot = dataItem_7_5.rootTrans:Find("NormalTip");
	dataItem_7_5.normalTipNameLabel = dataItem_7_5.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_5.timTipRoot = dataItem_7_5.rootTrans:Find("TimeTip");
	dataItem_7_5.timeTipNameLabel = dataItem_7_5.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_5.timeTipTimeLabel = dataItem_7_5.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_5.todayFlag = dataItem_7_5.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_5.enableFlag = dataItem_7_5.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_5);
	
	local dataItem_7_6 = {};
	dataItem_7_6.rootTrans = self:Find("Offset/DataItem/BgFrame_Week07_6/DataInfo").transform;
	dataItem_7_6.normalTipRoot = dataItem_7_6.rootTrans:Find("NormalTip");
	dataItem_7_6.normalTipNameLabel = dataItem_7_6.rootTrans:Find("NormalTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_6.timTipRoot = dataItem_7_6.rootTrans:Find("TimeTip");
	dataItem_7_6.timeTipNameLabel = dataItem_7_6.rootTrans:Find("TimeTip/AcitivityNameLabel"):GetComponent("UILabel");
	dataItem_7_6.timeTipTimeLabel = dataItem_7_6.rootTrans:Find("TimeTip/TimeBg/TimeLabel"):GetComponent("UILabel");
	dataItem_7_6.todayFlag = dataItem_7_6.rootTrans:Find("TodayFlag"):GetComponent("UISprite");
	dataItem_7_6.enableFlag = dataItem_7_6.rootTrans:Find("EnableFlag"):GetComponent("UISprite");
	table.insert(week_7, dataItem_7_6);
	
	table.insert(mCalendarList, week_7);
end

function OnEnable(self)
	ResetCalendar();
	UpdateMonth();
	UpdateWeek();
	UpdateDateItem();
end

function OnDisable(self)
	-- body
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Vitality_Calendar);
	end
end

function ResetCalendar()
	for k, v in ipairs(mCalendarList) do
		for r, m in ipairs(v) do
			m.rootTrans.gameObject:SetActive(false);
		end
	end
end

function UpdateMonth()
	mCurrentMonth = tonumber(os.date("%m"));
	mMonthLabel.text = mCurrentMonth;
end

function UpdateWeek()
	mCurrentWeekDay = 5;
	local weekDayTrans = nil;
	if mCurrentWeekDay == 1 then
		weekDayTrans = mMondayTrans;
	elseif mCurrentWeekDay == 2 then
		weekDayTrans = mTuesdayTrans;
	elseif mCurrentWeekDay == 3 then
		weekDayTrans = mWednesdayTrans;
	elseif mCurrentWeekDay == 4 then
		weekDayTrans = mThursdayTrans;
	elseif mCurrentWeekDay == 5 then
		weekDayTrans = mFridayTrans;
	elseif mCurrentWeekDay == 6 then
		weekDayTrans = mSatrudayTrans;
	elseif mCurrentWeekDay == 7 then
		weekDayTrans = mSundayTrans;
	end
	mTodayFlagTrans.parent = weekDayTrans;
	mTodayFlagTrans.localPosition = Vector3.New(0, 0, 0);
	
	local weekList = mCalendarList[mCurrentWeekDay];
	for k, v in ipairs(weekList) do
		v.rootTrans.gameObject:SetActive(true);
		v.todayFlag.gameObject:SetActive(true);
		v.normalTipRoot.gameObject:SetActive(false);
		v.timTipRoot.gameObject:SetActive(false);
		v.enableFlag.gameObject:SetActive(false);
	end
end

function UpdateDateItem()
	local activityItemInfos = VitalityMgr.GetActivityItemInfos();
	for k, v in ipairs(activityItemInfos) do
		if v.calendar_show == true then
			for r, m in ipairs(v.week_show) do
				if m == true then
					local weekList = mCalendarList[r];
					local dateItem = weekList[v.time_index];
					dateItem.rootTrans.gameObject:SetActive(true);
					if v.time_detail == -1 then
						dateItem.normalTipRoot.gameObject:SetActive(true);
						dateItem.normalTipNameLabel.text = v.name;
						dateItem.timTipRoot.gameObject:SetActive(false);
					else
						dateItem.timTipRoot.gameObject:SetActive(true);
						dateItem.timeTipNameLabel.text = v.name;
						dateItem.timeTipTimeLabel.text = tostring(v.time_detail) .. ":00";
						dateItem.normalTipRoot.gameObject:SetActive(false);
					end
					
					if r < mCurrentWeekDay then
						dateItem.enableFlag.gameObject:SetActive(true);
						dateItem.enableFlag.spriteName = "icon_huoyuedu_03";
					elseif r == mCurrentWeekDay then
						dateItem.enableFlag.gameObject:SetActive(true);
						dateItem.enableFlag.spriteName = "icon_huoyuedu_02";
					else
						dateItem.enableFlag.gameObject:SetActive(false);
					end
				end
			end
		end
	end
end

