module("UI_Story_Main", package.seeall)

local LuaObjs = GameBase.LuaObjs

--测试
local mOffset
local mPanel
local mInput
local mNpcLastEulerAngle
local mPlayerLastEulerAngle

local mSpeechToken = nil

function OnCreate(self)
	mOffset = self:Find("Offset")
	mPanel = mOffset.parent:GetComponent("UIPanel")
	mInput = self:FindComponent("UIInput", "Offset/Input")
	
	mOffset.gameObject:SetActive(false)
	--mPanel.sortingOrder = -10
end

function OnEnable(self)
end

function OnDisable(self)
end

function OnClick(go, id)
	if id == 0 then
		local arr = string.split(mInput.value, ",")
		local val1 = tonumber(arr[1])
		local val2 = tonumber(arr[2])
		local val3 = tonumber(arr[3])
		local param = {}
		if val1 == 1 then
			--关闭对话
			param.dialogGroupID = val2
			param.entityID = val3
			GameEvent.Trigger(EVT.STORY,EVT.DIALOG_CLOSE, param);
		elseif val1 == 2 then
			param.dialogGroupID = val2
			param.entityID = val3
			GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,param);
		elseif val1 == 15 then
			--掉落物品
			if val2 == 1 then
				local tempId = tonumber(val3)
				local itemData = ItemData.GetItemInfo(tempId)
				TipsMgr.TipByKey("drop_item", itemData.name, 111, itemData)
			else
				TipsMgr.TipByKey("equip_share_not_support")
			end
		elseif val1 == 16 then
			--属性变化
			local updateTable = {}
			for idx = 1, 5 do
				table.insert(updateTable, {_data = {name = idx}, _deltaValue = idx - 2.5})
			end
			TipsMgr.TipProChange(updateTable)
		elseif val1 == 17 then
			--底部渐隐提示
			
		elseif val1 == 18 then
			--通用TipByKey
			val2 = tostring(arr[2])
			TipsMgr.TipByKey(val2)
		elseif val1 == 19 then
			UIMgr.ShowUI(AllUI.UI_Bag_Main)
		elseif val1 == 20 then
			--发送剧情气泡
			local npc = MapMgr.GetEntityByID(38)
			local npcID = "006002"
			if npc then
				local trs = npc:GetModelComponent():GetEntityRoot()
				if not tolua.isnull(trs) then
					local data = {}
					data.transform = trs
					data.npcID = tonumber(npcID)
					data.dialogGroupID = 100011
					GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,param);
				end
			end
		elseif val1 == 21 then
			--打开剧情
			UI_Story_Sequence.mIsShowed = true
			GameEvent.Trigger(EVT.STORY,EVT.STORY_ENTER,"");
		elseif val1 == 22 then
			UI_Story_Sequence.mIsShowed = false
			GameEvent.Trigger(EVT.STORY,EVT.STORY_FINISH,"");
		elseif val1 == 23 then
			--掉落物品
			val2 = tonumber(arr[2])
			if val2 == 1 then
				local tempId = tonumber(arr[3])
				local itemData = ItemData.GetItemInfo(tempId)
				TipsMgr.TipByKey("drop_item", itemData.name, 111, itemData)
			else
				TipsMgr.TipByKey("equip_share_not_support")
			end
		elseif val1 == 24 then
			--顶部跑马灯
			val2 = tonumber(arr[2])
			if val2 == 1 then
				local content = "亲爱的小菜花，被偷了不管哈..."
				TipsMgr.TipTop(content)		
			elseif val2 == 2 then
				local content = "亲爱的小菜花，不要再游戏内发布微信账号，被偷了不管哈..."
				TipsMgr.TipTop(content)
			elseif val2 == 3 then
				local content = "亲爱的小菜花，不要再游戏内发布微信账号，被偷了不管哈...亲爱的小菜花，不要再游戏内发布微信账号，被偷了不管哈..."
				TipsMgr.TipTop(content)
			end
		elseif val1 == 25 then
			--测试短对话用于引导
			param.pos = Vector3(100, 100, 0)
			GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,param);
		elseif val1 == 26 then
			--测试撒石灰
		elseif val1 == 27 then
		elseif val1 == 28 then
		elseif val1 == 29 then
			--以tempId显示物品tips
			val2 = tonumber(arr[2])
			BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, val2)
		elseif val1 == 30 then
		elseif val1 == 31 then
		elseif val1 == 32 then
			--测试血条缓动
			local player = MapMgr.GetMainPlayer()
			local per = tonumber(val2)
			local maxHp = player:GetPropertyComponent():GetHPMax()
			local curHp = maxHp * per
			player._entityAtt.hp = curHp
			GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_HP_UPDATE,nil,player,111,false,nil);
		elseif val1 == 33 then
			--打开七天登录界面
			UIMgr.ShowUI(AllUI.UI_SevenDayLogin)
		elseif val1 == 34 then
			--关闭七天登录界面
			UIMgr.UnShowUI(AllUI.UI_SevenDayLogin)
		elseif val1 == 35 then
			--收到七天登录数据
			GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN,EVT.SUB_U_SEVENDAYLOGIN_GETDATA)
		elseif val1 == 36 then
			--多选择对话，传入字符串
			param.dialogGroupID = val2
			local c1 = tostring(arr[3])
			local c2 = tostring(arr[4])
			local c3 = tostring(arr[5])
			param.contentList = { c1, c2, c3 }
			GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,param);
		elseif val1 == 37 then
			--七天登录在线跨天
			GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN,EVT.SUB_U_SEVENDAYLOGIN_GETDATA)
		elseif val1 == 38 then
			--家园相机zoomin
			local gesture = {}
			gesture.deltaPinch = 10
			gesture.deltaTime = Time.deltaTime
			HomeMgr.OnPinchIn(gesture)
		elseif val1 == 39 then
			--家园相机zoomout
			local gesture = {}
			gesture.deltaPinch = -10
			gesture.deltaTime = Time.deltaTime
			HomeMgr.OnPinchOut(gesture)
		elseif val1 == 40 then
			UIMgr.UnShowAllExceptThese()
		elseif val1 == 41 then
			--测试boss战提示
		elseif val1 == 42 then
			--测试剧情达成
		elseif val1 == 43 then
			--测试在创建角色界面调用Tips
			TipsMgr.TipByFormat("login_account_len_invalid")
		elseif val1 == 44 then
			--测试AI精灵提示
		elseif val1 == 45 then
			--测试通用tips方式
			local key = tostring(arr[2])
			TipsMgr.TipByKey(key)
		elseif val1 == 46 then
			--测试撒石灰特效
		elseif val1 == 47 then
			--测试confirm框
			local okFunc = function()
				GameLog.LogError("----------------------------------okFunc")
			end
			local cancelFunc = function()
				GameLog.LogError("----------------------------------cancelFunc")
			end
			local content = "你们都是自寻死路"
			local okStr = "中"
			local cancelStr = "不中"
			local newLayer = 800
			local newDepth = 800
			--TipsMgr.TipConfirmByKey("tips_confirm_cancel")
			--TipsMgr.TipConfirmByStr(content)
			--TipsMgr.TipConfirmByCustomStr(content, okFunc, cancelFunc, okStr, cancelStr)
			--TipsMgr.TipConfirmByStrWithOrder(content, okFunc, cancelFunc, newLayer, newDepth)
			--TipsMgr.TipConfirmByCustomStrWithOrder(content, okFunc, cancelFunc, okStr, cancelStr, newLayer, newDepth)
			--TipsMgr.TipConfirmOkByStr(content, okFunc)
			--TipsMgr.TipConfirmOkByCustomStr(content, okFunc, okStr)
			--TipsMgr.TipConfirmOkByStrWithOrder(content, okFunc, newLayer, newDepth)
			TipsMgr.TipConfirmOkByCustomStrWithOrder(content, okFunc, okStr, newLayer, newDepth)
		elseif val1 == 48 then
			--测试七天登录在线跨天
			SevenDayLoginMgr.GotoNextDayOnline()
		elseif val1 == 49 then
			--打开新福利界面
			UIMgr.ShowUI(AllUI.UI_Welfare_Main)
		elseif val1 == 50 then
			--测试强制关闭确认框
			TipsMgr.TipConfirmOnClose()
		elseif val1 == 51 then
			--测试商店主界面
			UIMgr.ShowUI(AllUI.UI_Shop_Main)
		elseif val1 == 52 then
			--动态修改货币拥有数量
			local val2 = tonumber(arr[2])
			CommerceMgr.SetHaveNum(val2)
		elseif val1 == 53 then
			local slotId = tonumber(arr[2])
			local id = tonumber(arr[3])
			local itemId = tonumber(arr[4])
			local count = tonumber(arr[5])
			CommerceMgr.AddNewItem(slotId, id, itemId, count)
		elseif val1 == 54 then
			local slotId = tonumber(arr[2])
			local addCount = tonumber(arr[3])
			CommerceMgr.UpdateItem(slotId, addCount)
		elseif val1 == 55 then
			UIMgr.ShowUI(AllUI.UI_Intensify_Main)
		elseif val1 == 56 then
			UIMgr.ShowUI(AllUI.UI_Gang_Create)
		elseif val1 == 57 then
			UIMgr.ShowUI(AllUI.UI_Gang_List)
		elseif val1 == 58 then
			UIMgr.ShowUI(AllUI.UI_Gang_Main)
		elseif val1 == 59 then
			GangMgr.RequestSetGangCheck(val2)
		elseif val1 == 60 then
			storyData = StoryData.GetStoryDataByID(1003)
			SequenceMgr.PlaySequenceWithType(storyData)
		elseif val1 == 61 then
			--获得经验×%d
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_GetExp, 1111)
		elseif val1 == 62 then
			--获得银币×%d
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_GetSilver, 1111)
		elseif val1 == 63 then
			--获得金币×%d
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_GetGold, 1111)
		elseif val1 == 64 then
			--获得元宝×%d
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_GetIngot, 1111)
		elseif val1 == 65 then
			--获得道具[%s]×%d
			local val2 = tonumber(arr[2])
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_GetItem, val2, 111)
		elseif val1 == 66 then
			--恭喜玩家[%s]升到%d级
			local val2 = tonumber(arr[2])
			ChatMgr.CreateSysMsg(Chat_pb.SysMsg_LevelUp, 111111, "王八蛋", val2)
		elseif val1 == 67 then
			--测试系统频道内系统消息
			local val2 = tonumber(arr[2])
			local sysMsg = Chat_pb.SysMsgCommon()
			sysMsg.sysMsgType = Chat_pb.SysMsg_LevelUp
			local link = sysMsg.links:add()
			link.intParams:append(11111)
			link.intParams:append(val2)
			link.strParams:append("王八蛋")
			ChatMgr.TestChatRoomSys(sysMsg)
		elseif val1 == 68 then
			--测试跳转到聊天内的@条目处
			local val2 = tonumber(arr[2])
			GameEvent.Trigger(EVT.CHAT, EVT.CHAT_JUMPTOAT, val2)
		elseif val1 == 69 then
			--开始录音
			local function OnSpeechEnd()

			end
			mSpeechToken = SpeechMgr.StartRecord(OnSpeechEnd)
		elseif val1 == 70 then
			--停止录音
			SpeechMgr.StopRecord(mSpeechToken)
		elseif val1 == 71 then
			local val2 = tonumber(arr[2])
			val2 = val2 == 1
			SpeechMgr.PrepareCancel(mSpeechToken, val2)
		end
	end
end

function GetYawAngle()
	local mTempTrs = DialogMgr.GetTempTrs()
	local mTempGo = DialogMgr.GetTempGo()
	local camTrs = CameraMgr.GetMainCameraTransform()
	local selfGo = MapMgr.GetMainPlayer():GetRoot()
	local selfTrs = LuaObjs.GetTransform(selfGo)
	local selfEuler = LuaObjs.GetEulerAngle(selfGo)
	local selfPos = LuaObjs.GetPosition(selfGo)
	LuaObjs.SetPosition(mTempGo, selfPos.x, selfPos.y, selfPos.z, false)
	LuaObjs.SetEulerAngle(mTempGo, selfEuler.x, selfEuler.y + 60, selfEuler.z, false)
	local dir = camTrs.forward
	dir.y = 0
	dir:Normalize()
	local dirQua = UnityEngine.Quaternion.LookRotation(dir)
	local forwardAngle = UnityEngine.Quaternion.Angle(mTempTrs.rotation, dirQua)
	local dot = Vector3.Dot(mTempTrs.right, dir)
	if dot > 0 then
		forwardAngle = - forwardAngle
	elseif dot < 0 then
	end
	return forwardAngle
end

function ModityEulerAngle()
	local npc = MapMgr.GetEntityByID(38)
	local player = MapMgr.GetMainPlayer()
	if npc and player then
		mNpcLastEulerAngle = npc:GetEulerAngle()
		mPlayerLastEulerAngle = player:GetEulerAngle()
		local npcPos = npc:GetPropertyComponent():GetPosition()
		local playerPos = player:GetPropertyComponent():GetPosition()
		LuaObjs.TransformLookAt(player:GetRoot(), npcPos.x, npcPos.y, npcPos.z, 0, 1, 0)
		LuaObjs.TransformLookAt(npc:GetRoot(), playerPos.x, playerPos.y, playerPos.z, 0, 1, 0)
		
		local curEulerAngle = player:GetEulerAngle()
		local rotationY = 0
		if 0 <= curEulerAngle.y and curEulerAngle.y <= 180 then
			rotationY = curEulerAngle.y
		elseif 180 < curEulerAngle.y and curEulerAngle.y <= 360 then
			rotationY = curEulerAngle.y - 360
		end
		local targetEulerAngle = rotationY + 200
		targetEulerAngle = math.fmod(targetEulerAngle, 360)
		local yawAngle = FreeCamera.YawAngle
		local modYawAngle = math.fmod(math.abs(yawAngle), 360)
		if yawAngle < 0 then
			modYawAngle = 360 - modYawAngle
		end
		local deltaYawAngle = targetEulerAngle - modYawAngle
		if deltaYawAngle > 180 then
			deltaYawAngle = deltaYawAngle - 360
		elseif deltaYawAngle < - 180 then
			deltaYawAngle = deltaYawAngle + 360
		end
		
		FreeCamera.Distance = 6
		FreeCamera.YawAngle = yawAngle + deltaYawAngle
		FreeCamera.PitchAngle = 20
		
		GameLog.LogError("UI_Story_Main.ModityEulerAngle -> FreeCamera.Distance = %s", FreeCamera.Distance)
		GameLog.LogError("UI_Story_Main.ModityEulerAngle -> FreeCamera.YawAngle = %s", FreeCamera.YawAngle)
		GameLog.LogError("UI_Story_Main.ModityEulerAngle -> FreeCamera.PitchAngle = %s", FreeCamera.PitchAngle)
	end
end
