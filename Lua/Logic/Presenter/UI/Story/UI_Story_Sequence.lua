module("UI_Story_Sequence",package.seeall);
local mTipRoot;
local mTipContent;
local mSkipPanel;
local SKIP_DEPTH = 1299;
local mIsShowed = false
local mShowSkip=true

local tipLayer;
local tipDepth;
local tipShow=false

local askTip = false
local tipText = ""
local delaySkip = 0

local beforeSkipAction = nil

local mTimeLabel=nil
local mSlider = nil
local mSkipBtn = nil

function OnCreate(self)	
	mTipRoot = self:Find("Offset/Tip").gameObject;
	mTipContent = self:FindComponent("UILabel","Offset/Tip/Text");
	mSkipPanel = self:FindComponent("UIPanel","Offset/TopRight/SkipPanel");
	mSlider = self:FindComponent("UISlider","Offset/TopRight/SkipPanel/Slider");
	mTimeLabel = self:FindComponent("UILabel","Offset/TopRight/SkipPanel/Time");
	mSkipBtn = self:Find("Offset/TopRight/SkipPanel/SkipBtn");
	mTipRoot:SetActive(false);
end

function OnEnable(self)
	mIsShowed = true
	mTipContent.text =tiptext;
	if mSkipPanel then mSkipPanel.gameObject:SetActive(mShowSkip) end
	SetTimeLabelAndSlider(0,1)
	UpdateBeat:Add(Update,self);
	GameEvent.Reg(EVT.STORY,EVT.STORY_TEXT,OnRecvMsg);
	if mShowSkip and delaySkip>=0 then
		mSkipBtn.gameObject:SetActive(false)
		GameTimer.AddTimer(delaySkip/1000,1,ShowSkipBtn,nil)
	end
end

function OnDisable(self)
	GameEvent.UnReg(EVT.STORY,EVT.STORY_TEXT,OnRecvMsg);
	mTipContent.text = "";
	mIsShowed = false
	mShowSkip =true
	delaySkip = 0
	if tipShow then
        TipsMgr.TipConfirmOnClose()
		tipShow=false
	end
	UpdateBeat:Remove(Update,self);
end

function ShowSkipBtn()
	mSkipBtn.gameObject:SetActive(true)
end

function Update()
	SetTimeLabelAndSlider(SequenceMgr.RunningTime(),SequenceMgr.Duration())
end

function SetTimeLabelAndSlider(runtime,duration)
	mSlider.value =1- runtime/duration
	local f = duration/60
	local f11 = f/10
	local f12 = f%10
	local s = duration%60
	local s11 = s/10
	local s12 = s%10
	local f1 = runtime/60
	local s1 = runtime%60
	local f21 = f1/10
	local f22 = f1%10
	local s21 = s1/10
	local s22 = s1%10
	mTimeLabel.text = string.format("%d%d:%d%d/%d%d:%d%d",f21,f22,s21,s22,f11,f12,s11,s12)
end

--设置跳过之前的操作
function SetBeforeSkipAction(action)
	beforeSkipAction=action
end

local function okFunc( ... )
	if beforeSkipAction then
		beforeSkipAction()
	end
	if mSkipPanel then mSkipPanel.gameObject:SetActive(false) end
	SequenceMgr.Skip();
end

function OnClick(go,id)
	if id == 0 then
		if askTip then
			tipShow=true
			TipsMgr.TipConfirmByStrWithOrder(tipText,okFunc,nil,SKIP_DEPTH,SKIP_DEPTH)
		else
			okFunc()
		end
	end
end

function SetSkipShow(skip,asktip,tiptext,delay)
	mShowSkip = (skip==0)
	if mSkipPanel then mSkipPanel.gameObject:SetActive(mShowSkip) end
	askTip = not(asktip==0)
	tipText = tiptext
	delaySkip = delay and delay or 0
end

function OnRecvMsg(funcName,strArray)
	if funcName == "UnShowBlackWithText" or not strArray then
		mTipRoot:SetActive(false);
		mTipContent.text = "";
	elseif funcName == "ShowBlackWithText" then
		mTipRoot:SetActive(true);
		mTipContent.text = string.gsub(strArray[1],"\\n","\n");
	end
end

function CheckIsShowed()
	return mIsShowed
end