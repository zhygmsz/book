module("DialogMgr", package.seeall)

--立绘对话，npc转向
local mLastNpcForward
local mLastPlayerForward

--立绘对话数据
local mOutputData

local mDialogIsShowed =
{
	[Dialog_pb.DialogData.NPC] = false,
	[Dialog_pb.DialogData.BUBBLE] = false,
	[Dialog_pb.DialogData.COMMON] = false,
	[Dialog_pb.DialogData.MODEL] = false,
	[Dialog_pb.DialogData.SHORT] = false,
	[Dialog_pb.DialogData.BOSS_SHOUT] = false,
	[Dialog_pb.DialogData.STORY] = false,
	[Dialog_pb.DialogData.SELECT] = false,
	[Dialog_pb.DialogData.GUIDE] = false
}

--local方法
local function CheckNeedYaw()
	if mOutputData and mOutputData.dialogType == Dialog_pb.DialogData.MODEL then
		local dialogDatas = DialogData.GetDialogGroupDataByGroupID(mOutputData.groupID)
		if dialogDatas then
			local data = dialogDatas[1]
			if data and data.modelNpcID then
				return data.modelNpcID ~= "0"
			end
		end
	else
		return false;
	end
end

local function SendCloseEvent()
	if mOutputData and(not mOutputData.hasSend) and mOutputData.needSendEvent then
		if mOutputData.dialogType == Dialog_pb.DialogData.MODEL then
			GameLog.Log("UI_Story_NPC_Painting.OnTalkOver -> dialogID = %s", mOutputData.dialogID)
		elseif mOutputData.dialogType == Dialog_pb.DialogData.SELECT then
			GameLog.Log("UI_Story_NPC_Select.OnSelectOver -> dialogID = %s", mOutputData.dialogID)
		end
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_FALSE_FINISH,mOutputData);
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_FINISH,mOutputData);
		mOutputData.hasSend = true
	end
end

local function DoOpenDialog(param)
	local dialogDatas = DialogData.GetDialogGroupDataByGroupID(param.dialogGroupID)
	local firstData = dialogDatas[1]

	local paramData = {}
	paramData.dialogDatas = dialogDatas
	--引导
	paramData.pos = param.pos  --引导的位置
	--剧情内显示气泡
	paramData.transform = param.transform
	paramData.npcID = param.npcID  --npc表的id
	--动态设置npc
	paramData.entityID = param.entityID  --entity的动态id
	--多选择传入分支字符串，长度为3的表，1：左，2：右，3：中
	paramData.contentList = param.contentList

	if firstData.dialogType == Dialog_pb.DialogData.MODEL then
		--立绘对话框，如果对话正在播放，则不接受新对话，以免污染paramData
		if not CheckDialogIsShowed(Dialog_pb.DialogData.MODEL) then
			require("Logic/Presenter/UI/Dialog/UI_Story_NPC_Painting")
			UI_Story_NPC_Painting.paramData = paramData
			UIMgr.ShowUI(AllUI.UI_Story_NPC_Painting)
		else
			GameLog.LogError("DialogMgr.OnEnterStory -> UI_Story_NPC_Painting is showing")
		end
	elseif firstData.dialogType == Dialog_pb.DialogData.SHORT then
		--短对话框
		require("Logic/Presenter/UI/Dialog/UI_Story_NPC_Short")
		UI_Story_NPC_Short.SetData(paramData)
		if CheckDialogIsShowed(Dialog_pb.DialogData.SHORT) then
			UI_Story_NPC_Short.ShowShort()
		else
			UIMgr.ShowUI(AllUI.UI_Story_NPC_Short)
		end
	elseif firstData.dialogType == Dialog_pb.DialogData.BUBBLE then
		--气泡对话框
		require("Logic/Presenter/UI/Dialog/UI_Story_NPC_Bubble")
		UI_Story_NPC_Bubble.SetData(paramData)
		if CheckDialogIsShowed(Dialog_pb.DialogData.BUBBLE) then
			UI_Story_NPC_Bubble.ShowBubble()
		else
			UIMgr.ShowUI(AllUI.UI_Story_NPC_Bubble)
		end
	elseif firstData.dialogType == Dialog_pb.DialogData.SELECT then
		--多选择对话框，如果对话正在播放，则不接受新对话，以免污染paramData
		if not CheckDialogIsShowed(Dialog_pb.DialogData.SELECT) then
			require("Logic/Presenter/UI/Dialog/UI_Story_NPC_Select")
			UI_Story_NPC_Select.SetData(paramData)
			UIMgr.ShowUI(AllUI.UI_Story_NPC_Select)
		else
			GameLog.LogError("DialogMgr.OnEnterStory -> UI_Story_NPC_Select is showing")
		end
	elseif firstData.dialogType == Dialog_pb.DialogData.GUIDE then
		--引导对话框
		require("Logic/Presenter/UI/Dialog/UI_Story_NPC_Guide")
		UI_Story_NPC_Guide.SetData(paramData)
		if CheckDialogIsShowed(Dialog_pb.DialogData.GUIDE) then
			UI_Story_NPC_Guide.ShowGuide()
		else
			UIMgr.ShowUI(AllUI.UI_Story_NPC_Guide)
		end
	elseif firstData.dialogType == Dialog_pb.DialogData.BOSS_SHOUT then
		--boss喊话
		require("Logic/Presenter/UI/Dialog/UI_Story_NPC_BossShout")
		UI_Story_NPC_BossShout.SetData(paramData)
		if CheckDialogIsShowed(Dialog_pb.DialogData.BOSS_SHOUT) then
			UI_Story_NPC_BossShout.ShowShout()
		else
			UIMgr.ShowUI(AllUI.UI_Story_NPC_BossShout)
		end
	end
end

local function OnOpenDialog(param)
	local dialogDatas = DialogData.GetDialogGroupDataByGroupID(param.dialogGroupID)
	if not dialogDatas then
		GameLog.LogError("DialogMgr.OnOpenDialog -> dialogDatas is nil, groupId = %s", param.dialogGroupID)
		return
	end

	local firstData = dialogDatas[1]
	
	if firstData.delayTime > 0 then
		--延迟执行
		GameTimer.AddTimer(firstData.delayTime / 1000, 1, DoOpenDialog, nil, param)
	else
		--立即执行
		DoOpenDialog(param)
	end
end

--强制关闭某一个气泡对话
local function HideBubble(dialogGroupID)
	if CheckDialogIsShowed(Dialog_pb.DialogData.BUBBLE) then
		UI_Story_NPC_Bubble.HideBubbleByID(dialogGroupID)
	else
		GameLog.LogError("DialogMgr.HideBubble -> UI_Story_NPC_Bubble is not show")
	end
end

--强制关闭某一个引导对话
local function HideGuide(dialogGroupID)
	if CheckDialogIsShowed(Dialog_pb.DialogData.GUIDE) then
		UI_Story_NPC_Guide.HideGuideByID(dialogGroupID)
	else
		GameLog.LogError("DialogMgr.HideGuide -> UI_Story_NPC_Guide is not show")
	end
end

--强制关闭某一个boss喊话对话
local function HideBossShout(dialogGroupID)
	if CheckDialogIsShowed(Dialog_pb.DialogData.BOSS_SHOUT) then
		UI_Story_NPC_BossShout.HideShoutByID(dialogGroupID)
	else
		GameLog.LogError("DialogMgr.HideBossShout -> UI_Story_NPC_BossShout is not show")
	end
end

local function HideShort(dialogGroupID)
	if CheckDialogIsShowed(Dialog_pb.DialogData.SHORT) then
		UI_Story_NPC_Short.HideShortById(dialogGroupID)
	else
		GameLog.LogError("DialogMgr.HideShort -> UI_Story_NPC_Short is not show")
	end
end

local function OnForceCloseDialog(param)
	local dialogDatas = DialogData.GetDialogGroupDataByGroupID(param.dialogGroupID)
	if dialogDatas and dialogDatas[1] then
		local firstData = dialogDatas[1]
		if firstData.dialogType == Dialog_pb.DialogData.SHORT then
			HideShort(param.dialogGroupID)
		elseif firstData.dialogType == Dialog_pb.DialogData.MODEL then
			if CheckDialogIsShowed(Dialog_pb.DialogData.MODEL) then
				UIMgr.UnShowUI(AllUI.UI_Story_NPC_Painting)
			end
		elseif firstData.dialogType == Dialog_pb.DialogData.BUBBLE then
			HideBubble(param.dialogGroupID)
		elseif firstData.dialogType == Dialog_pb.DialogData.SELECT then
			if CheckDialogIsShowed(Dialog_pb.DialogData.SELECT) then
				UIMgr.UnShowUI(AllUI.UI_Story_NPC_Select)
			end
		elseif firstData.dialogType == Dialog_pb.DialogData.GUIDE then
			HideGuide(param.dialogGroupID)
		elseif firstData.dialogType == Dialog_pb.DialogData.BOSS_SHOUT then
			HideBossShout(param.dialogGroupID)
		end
	end
end

local function GetContent(match)
	local params = string.split(match, ",")
	--当前主玩家名字
	if tonumber(params[1]) == 0 then
		return UserData.GetName()
	end
	return "no content"
end

function FormatContent(dialogData)
	if not dialogData or not dialogData.content then
		return
	end
	
	local srcStr = dialogData.content[1].data
	if dialogData.needMatch == 0 then
		return srcStr
	end
	
	local matchs = {}
	local contents = {}
	for s in string.gmatch(srcStr, "{(.-)}") do
		table.insert(matchs, s)
	end
	
	if #matchs == 0 then
		GameLog.LogError("DialogMgr.FormatContent -> matchs's len is 0, dialogid = %s", dialogData.id)
		return srcStr
	end
	
	for i = 1, #matchs do
		local content = GetContent(matchs[i])
		table.insert(contents, content)
	end
	
	for i = 1, #matchs do
		srcStr = srcStr:gsub("{" .. matchs[i] .. "}", contents[i])
	end
	
	return srcStr
end

function SetDialogIsShowed(dialogType, isShowed)
	if dialogType then
		mDialogIsShowed[dialogType] = isShowed
	end
end

function CheckDialogIsShowed(dialogType)
	if dialogType then
		return mDialogIsShowed[dialogType]
	else
		return false
	end
end

function CloseDialog()
	SendCloseEvent()
end

function SetOutputData(outData)
	mOutputData = outData
	mOutputData.hasSend = false
end

function SetNpcLookAtMe(paramData)
	if not paramData then
		GameLog.LogError("DialogMgr.SetNpcLookAtMe -> paramData is nil")
		return
	end
	local npcID = paramData.dialogDatas[1].modelNpcID
	local entityID = paramData.entityID

	local npc = nil
	if entityID then
		npc = MapMgr.GetEntityByID(tonumber(entityID))
	else
		if not npcID then
			GameLog.LogError("DialogMgr.SetNpcLookAtMe -> npcID is nil, groupID = %s", paramData.dialogDatas[1].dialogID)
		end
		if npcID == "0" then
			--npc为自己，不需要调整npc朝向
			return
		end
		npc = MapMgr.GetNPCByUnitID(tonumber(npcID))
	end
	local player = MapMgr.GetMainPlayer()
	if npc and player then
		local npcProperty = npc:GetPropertyComponent();
		local playerProperty = player:GetPropertyComponent();
		mLastNpcForward = npcProperty:GetForward();
		mLastPlayerForward = playerProperty:GetForward()
		local npcPos = npcProperty:GetPosition()
		local playerPos = playerProperty:GetPosition()
		playerProperty:LookTarget(npcPos);
		npcProperty:LookTarget(playerPos);
	else
		GameLog.LogError("DialogMgr.SetNpcLookAtMe -> npc or player is nil, groupID = %s", paramData.dialogDatas[1].dialogID)
	end
end

function ResetNpcLook(paramData)
	if not paramData then
		GameLog.LogError("DialogMgr.ResetNpcLook -> paramData is nil")
		return
	end
	local npcID = paramData.dialogDatas[1].modelNpcID
	local entityID = paramData.entityID

	local npc = nil
	if entityID then
		npc = MapMgr.GetEntityByID(tonumber(entityID))
	else
		if not npcID then
			GameLog.LogError("DialogMgr.ResetNpcLook -> npcID is nil")
			return
		end
		if npcID == "0" then
			return
		end
		npc = MapMgr.GetNPCByUnitID(tonumber(npcID))
	end
	local player = MapMgr.GetMainPlayer()
	if npc and player then
		npc:GetPropertyComponent():SetForward(mLastNpcForward)
		player:GetPropertyComponent():SetForward(mLastPlayerForward)
	else
		GameLog.LogError("DialogMgr.ResetNpcLook -> npc or player is nil, npcID = %s", npcID)
	end
end

--[[
    @desc: 根据表情类型返回当前玩家对应的种族的表情图资源id
    --@emojiType: 
]]
function GetRacialEmojiPicResId(emojiType)
	return DialogData.GetRacialEmojiPicData(UserData.GetRacial(), emojiType)
end

--[[
    @desc: 获取对话涉及到的立绘资源id
    --@resId: 
]]
function GetPicResId(resId, dialogData)
	if resId > 0 then
		--普通立绘的资源id
		return resId
	else
		--为负数时，判断是主角的，还是宠物的
		if resId == -1 then
			return GetRacialEmojiPicResId(dialogData.emojiType)
		elseif resId == -2 then
			--宠物
		end
	end
end

function InitModule()
	GameEvent.Reg(EVT.STORY,EVT.DIALOG_OPEN,OnOpenDialog);
	GameEvent.Reg(EVT.STORY,EVT.DIALOG_CLOSE, OnForceCloseDialog);
end

return DialogMgr
