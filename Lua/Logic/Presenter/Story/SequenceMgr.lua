module("SequenceMgr",package.seeall)
SequenceData = TimelineTools.SequenceData;

mSequenceOverCall = nil;
mSequenceOverCallObj = nil;
mSequenceOverCallParam = nil;
mCurrentResId = nil
mIsPlaying = false;
mSequenceType=0 --播放 类型 0 剧情 1 视频
--数据存储变量
mSequenceResTabel  = {}
mIsFade = false
mIsFadeOver = false
mFadeTime = 0.75
mReady = false

mStoryData = nil
--剧情对象的根节点
mSequenceRoot = nil

--模块初始化
function InitModule()
    mSequenceRoot = UnityEngine.GameObject.New("SEQUENCE_ROOT").transform;
    UnityEngine.GameObject.DontDestroyOnLoad(mSequenceRoot.gameObject);
	require("Logic/Presenter/UI/Story/UI_Story_Sequence");
	require("Logic/Presenter/Story/SequenceMgr_Load");
	require("Logic/Presenter/Story/SequenceMgr_Func");
	GameEvent.Reg(EVT.STORY,EVT.STORY_SETTIME,OnSetTime);
	GameEvent.Reg(EVT.STORY,EVT.STORY_RESUME,OnResume);
	GameEvent.Reg(EVT.STORY,EVT.STORY_PAUSE,OnPause);
end

--==============================--
--desc:剧情控制函数
--==============================-----
-- 播放的入口 根据类型播放视频还是传统剧情
function PlaySequenceWithType(storyData)
	mStoryData = storyData
	local seqType = storyData.seqType
	local skip = storyData.skip
	local askTip = storyData.askTip
	local tipText = storyData.tipText
	local delaySkip = storyData.delaySkip
	mSequenceType = seqType
	mCurrentResId = storyData.resID
	local name = storyData.name
	if seqType == 0 then
		mIsFade = true
		UI_Story_Sequence.SetSkipShow(skip,askTip,tipText,delaySkip)
		SetUp(mCurrentResId)
		local flag,msg = xpcall(PlaySequence,traceback,mCurrentResId,nil,nil,nil)
		if not flag then
			OnFinished(mCurrentResId)
		end
		--PlaySequence(mCurrentResId,nil,nil,nil)
	elseif seqType == 1 then
		mIsFade = false
		VideoMgr.InitPlayer()
		VideoMgr.SetLuaCallBack(nil,OnFinished,nil,nil,nil)
		VideoMgr.SetSkipShow(skip,askTip,tipText)
		SetUp(name)
		local flag,msg = xpcall(VideoMgr.PlayVideo,traceback,name)
		if not flag then
			OnFinished(name)
		end
		--VideoMgr.PlayVideo(name)
	end
end

--是否播放中
function IsPlaying()
	return mIsPlaying;
end

--资源是否加载
function isLoaded(resID)
	if GetSequenceTable(resID).go then
		return true
	end
	return false
end

--获取当前取经的名称
function GetCurrentResId()
	return mCurrentResId
end

--跳过
function Skip()
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then sequenceData:Skip(); end
	elseif mSequenceType == 1 then--视频
		VideoMgr.Skip()
	end
end

--播放
function Play()
	GameLog.Log("Play")
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then  sequenceData:Play(); end
	elseif mSequenceType == 1 then--视频
		VideoMgr.Play()
	end
end

--暂停
function Pause()
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then
			sequenceData:Pause();
		end
	elseif mSequenceType == 1 then--视频
		VideoMgr.Pause()
	end
end

--继续
function Resume()
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then  sequenceData:Resume(); end
	elseif mSequenceType == 1 then--视频
		VideoMgr.Play()
	end
end

--周期
function Duration()
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then  return sequenceData.Duration; end
	elseif mSequenceType == 1 then--视频
		VideoMgr.Duration()
	end
	return -1;
end

--当前播放时间
function RunningTime()
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then return sequenceData:RunningTime(); end
	elseif mSequenceType == 1 then--视频
		VideoMgr.RunningTime()
	end
	return -1;
end

--设置播放时间
function SetCurrentTime(t)
	if mSequenceType == 0 then
		local sequenceData = GetSequenceController(mCurrentResId)
		if sequenceData then sequenceData:SetCurrentTime(t); end
	elseif mSequenceType == 1 then--视频
		VideoMgr.SetTime(t)
	end
end

--设置回调函数
function SetCallBack(overcall, overobj, overparam)
	mSequenceOverCall = overcall;
	mSequenceOverCallObj = overobj;
	mSequenceOverCallParam = overparam;
end

--剧情的消息回调
function OnMessage(funcName,funcParam,strArray,objArray)
	GameLog.Log("lua recv sequence OnMessage->%s %s", funcName , funcParam);
	if funcName == "mapeventmsg" then
		local eventID = funcParam;
	elseif funcName == "UIMSG" then
		GameEvent.Trigger(EVT.STORY,EVT.STORY_TEXT,strArray[0],strArray);
	elseif funcName == "DialogueMsg" then
		local dialogData = {};
		dialogData.dialogGroupID = tonumber(strArray[0]);
		dialogData.npcID = tonumber(strArray[1]);
		dialogData.transform = objArray[0].transform
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,dialogData);
	elseif funcName == "QTE" then
		local groupid = funcParam;
		QTEMgr.PlayQTEGroup(groupid)
	end
end

--设置时间消息
function OnSetTime(param)
	local time = param.time
	local back = param.isBack
	if back then
		SetCurrentTime(RunningTime()-time)
	else
		SetCurrentTime(time)
	end
end

function OnResume()
	Resume()
end

function OnPause()
	Pause()
end

--剧情结束回调
function OnFinished(resID)
	GameLog.Log("lua recv sequence finished->%s", mCurrentResId);
	SequenceMgr.FadeResetBack(mCurrentResId)
end

return SequenceMgr;