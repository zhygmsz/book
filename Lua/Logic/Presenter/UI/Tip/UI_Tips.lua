module("UI_Tips", package.seeall);

local BossBattleTipWidget = require("Logic/Presenter/UI/Tip/UITips_BossBattle")
local StoryGotTipWidget = require("Logic/Presenter/UI/Tip/UITips_StoryGot")
local TopTipWidget = require("Logic/Presenter/UI/Tip/UITips_Top")
local CommonTipWidget = require("Logic/Presenter/UI/Tip/UITips_Common")
local BottomTipWidget = require("Logic/Presenter/UI/Tip/UITips_Bottom")
local ProChangeWidget = require("Logic/Presenter/UI/Tip/UITips_ProChange")
local AISpiritTipWidget = require("Logic/Presenter/UI/Tip/UITips_AISpirit")


--属性变化面板
local mProChangeWidget

--底部渐隐消失tip
local mBottomTipWidget

--屏幕中间偏上通用提示
local mCommonTipWidget

--顶部跑马灯
local mTopTipWidget

--boss战提示
local mBossBattleTipWidget

--剧情达成
local mStoryGotTipWidget

--ai宠物
local mAISpiritTipWidget

local mEvents = {}

local mSelf

--local方法
--接收字符表数据，显示tips，统一的入口，根据数据类型再细分
local function OnShowTips(data)
	if not data then
		GameLog.LogError("UI_Tips.OnShowTips -> data is nil")
		return		
	end
	local tipData = WordData.GetWordDataByID(data.id)
	if not tipData then
		GameLog.LogError("UI_Tips.OnShowTips -> tipData is nil, data.id = %s", data.id)
		tipData = tipData or {id = id, key ="default key",value = "default value", tipTypeID = 1};
		--return
	end
	local tipTypeData = WordData.GetTipTypeData(tipData.tipTypeID)
	
	if not tipTypeData then
		GameLog.LogError("UI_Tips.OnShowTips -> tipTypeData is nil, data.tipTypeID = %s key = %s", tipData.tipTypeID,tipData.key)
		return
	end

	local ret, content = xpcall(string.format, traceback, tipData.value, unpack(data.args))
	if not ret then
		GameLog.LogError("UI_Tips.OnShowTips -> ret is false, err = %s", content)
		return
	end
	if tipTypeData.tipType == WordData_pb.TipTypeData.BOSSINFO then
		mBossBattleTipWidget:Show(content, tipTypeData)
	elseif tipTypeData.tipType == WordData_pb.TipTypeData.STORYGOT then
		mStoryGotTipWidget:Show(content)
	elseif tipTypeData.tipType == WordData_pb.TipTypeData.NOTICE then
		mTopTipWidget:Show(content)
	elseif tipTypeData.tipType == WordData_pb.TipTypeData.COMMON then
		mCommonTipWidget:Show(content, data.args[3])
	elseif tipTypeData.tipType == WordData_pb.TipTypeData.SYSMESSAGE then
		mBottomTipWidget:Show(content)
	elseif tipTypeData.tipType == WordData_pb.TipTypeData.SPIRIT then
		mAISpiritTipWidget:Show(content, tipTypeData)
	end
end

--属性变化
local function OnShowProChange(changes)
	if changes then
		mProChangeWidget:Show(changes)
	end
end

--主界面准备完毕，设置BottomTips的停靠锚点
local function OnSetBottomAnchor()
	local anchorTrs = UnityEngine.GameObject.Find("UI Root/UI_Main/Bottom/Chat/DragParent")
    if not tolua.isnull(anchorTrs) then
        anchorTrs = anchorTrs.transform
	end
	if not tolua.isnull(anchorTrs) then
		mBottomTipWidget:SetAnchor(anchorTrs)
	end
end

--以外部字符串方式显示滚屏
local function OnShowTopTipByStr(content)
	if content then
		mTopTipWidget:Show(content)
	end
end

--以外部字符串方式显示CommonTips
local function OnShowCommonTips(content, data)
	if content then
		mCommonTipWidget:Show(content, data)
	end
end

local function RegEvent(self)
	GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWTIPS, OnShowTips)
	GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWPROCHANGE, OnShowProChange)
	GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SETBOTTOMANCHOR, OnSetBottomAnchor)
	GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWTOPTIPBYSTR, OnShowTopTipByStr)
	GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWCOMMON, OnShowCommonTips)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWTIPS, OnShowTips)
	GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWPROCHANGE,OnShowProChange)
	GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SETBOTTOMANCHOR,OnSetBottomAnchor)
	GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWTOPTIPBYSTR,OnShowTopTipByStr)
	GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWCOMMON,OnShowCommonTips)
end

--全局方法
function OnCreate(self)
	mSelf = self
	
	mProChangeWidget = ProChangeWidget.new(self, "Offset/prochangeroot")
	mProChangeWidget:Hide()
	
	mBottomTipWidget = BottomTipWidget.new(self, "Offset/bottomtiproot")
	mBottomTipWidget:Hide()
	
	mCommonTipWidget = CommonTipWidget.new(self, "Offset/commontiproot")
	mCommonTipWidget:Hide()
	
	mTopTipWidget = TopTipWidget.new(self, "Offset/toptiproot")
	mTopTipWidget:Hide()

	mBossBattleTipWidget = BossBattleTipWidget.new(self, "Offset/bossbattleroot")
	mBossBattleTipWidget:Hide()

	mStoryGotTipWidget = StoryGotTipWidget.new(self, "Offset/storygotroot")
	mStoryGotTipWidget:Hide()

	mAISpiritTipWidget = AISpiritTipWidget.new()
end

function OnEnable(self)
	RegEvent(self)
end

function OnDisable(self)
	UnRegEvent(self)
end

function OnClick(go, id)
end

function OnDestroy(self)
	mBossBattleTipWidget:OnDestroy()
end
