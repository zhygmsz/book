module("SequenceMgr",package.seeall)

--初始化列表
function InitSequenceTable(resID)
	if mSequenceResTabel[resID] == nil then
		mSequenceResTabel[resID] = {}
		mSequenceResTabel[resID].sequenceLoading = false
		mSequenceResTabel[resID].sequenceLoad = false
		mSequenceResTabel[resID].go = nil
		mSequenceResTabel[resID].loader = nil
		mSequenceResTabel[resID].initObjs = {}
		mSequenceResTabel[resID].resTbale = {}
		mSequenceResTabel[resID].sequenceData = nil;
	end
end

--获取剧情数据
function GetSequenceTable(resID)
	return mSequenceResTabel[resID]
end

--获取剧情控制器
function GetSequenceController(resID)
	local data = GetSequenceTable(resID)
	if data == nil then return nil end
	if data.sequenceData == nil or tolua.isnull(data.sequenceData) then
		if data.sequenceLoad then
			if data.go then
				data.sequenceData = data.go:GetComponent("TimelineTools.SequenceData");
				data.sequenceData:SetLuaCallBack(SequenceMgr.OnMessage,SequenceMgr.OnFinished)
			end
		end
	end
	return data.sequenceData
end

--添加到剧情根节点下
function AddToRoot(go)
	go.transform.parent = mSequenceRoot
end

--清空资源table
function Clear()
	for k,v in pairs(mSequenceResTabel) do
		DestoryObjRemoveAsset(k)
	end
	mSequenceResTabel = {}
end

--==============================--
--desc:播放开始前设置 与结束后复位
--time:2018-09-18 08:09:17
--@resID:
--@return 
--==============================---
local function OnFadeOver(resID)
	CameraMgr.EnableMainCamera(false)
	mIsFadeOver = true
	TryPlay()
end

--播放开始的设置
function SetUp(resID)
	GameUtil.GameFunc.CreateEmptyCamera();
	local cameraEffect = CameraEffect.Brightness(OnFadeOver, resID)
	cameraEffect:PlayEnter(mFadeTime,1,0);
	if mSequenceType == 0 then
		UIMgr.ShowUI(AllUI.UI_Story_Sequence)
	end
	GameEvent.Trigger(EVT.STORY,EVT.STORY_ENTER,mStoryData);
end

--播放结束后 恢复设置
function FadeResetBack(resID)
	CameraMgr.EnableMainCamera(true)
	GameLog.Log("FadeResetBack")
	GameEvent.Trigger(EVT.STORY,EVT.STORY_TEXT);
	GameEvent.Trigger(EVT.STORY,EVT.BULLET_FINISH,mStoryData.bulletID);
	if mIsFade then
		local cameraEffect = CameraEffect.BrightnessWithCamGO(UIMgr.GetCamera().gameObject,Resetback,resID);
		cameraEffect:PlayExit(mFadeTime,0,1);
	else
		Resetback(resID)
	end
end

--播放结束后 恢复设置
function Resetback(resID)
	GameLog.Log("Resetback")
	mReady = false
	mIsFadeOver = false
	mIsPlaying = false
	GameLog.Log("begin reset sequence asset");
	CameraMgr.EnableMainCamera(true)
	GameUtil.GameFunc.HiddenEmptyCamera()
	if mSequenceType == 0 then UIMgr.UnShowUI(AllUI.UI_Story_Sequence) end
	UnityEngine.Time.timeScale = 1;
	if mSequenceOverCall ~= nil then
		if mSequenceOverCallObj == nil then
			mSequenceOverCall(resID, mSequenceOverCallParam);
		else
			mSequenceOverCall(mSequenceOverCallObj, resID, mSequenceOverCallParam);
		end
	end
	mSequenceOverCall = nil;
	mSequenceOverCallObj = nil;
	mSequenceOverCallParam = nil;
	DestoryObjRemoveAsset(resID)
	if mSequenceResTabel[resID] then mSequenceResTabel[resID] = nil end
	mCurrentResId = nil
	--发送剧情结束消息
	GameEvent.Trigger(EVT.STORY,EVT.STORY_FINISH,mStoryData);
	--GameEvent.Trigger(EVT.STORY,EVT.BULLET_FINISH,mStoryData.bulletID);
end

--加载完毕播放
function ReadToPlay()
	local data = GetSequenceTable(mCurrentResId)
	data.go:SetActive(true);
	mReady = true
	TryPlay()
end

--资源均被完毕 相机过渡结束之后播放
function TryPlay()
	GameLog.Log("TryPlay")
	if mReady then
		if mIsFade then
			if mIsFadeOver then
				Play()
			end
		else
			Play()
		end
	end
end

--==============================--
--desc:加载实例化部分
--==============================--
--加载实例化剧情
function LoadSequence(resID)
	GameLog.Log("LoadSequence")
	InitSequenceTable(resID)
	mReady = false
	LoadAndInitSequenceObj(resID,ReadToPlay)
end

--==============================--
--desc:传统剧情播放调用函数
--==============================--
--传统剧情默认播放方法
function PlaySequence(resID, overcall, overobj, overparam)
	GameLog.Log("PlaySequence")
	mIsPlaying = true
	mCurrentResId = resID
	LoadSequence(resID)
	SetCallBack(overcall, overobj, overparam)
end