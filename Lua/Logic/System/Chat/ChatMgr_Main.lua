--该文件用于UI_Chat_Main界面的数据维护与管理
module("ChatMgr", package.seeall)

--通用房间消息
local mChatRoomMsgList = {
    [Chat_pb.CHAT_ROOM_WORLD] = {},
    [Chat_pb.CHAT_ROOM_TEAM] = {},
    [Chat_pb.CHAT_ROOM_GANG] = {},
    [Chat_pb.CHAT_ROOM_PROFESSION] = {},
    [Chat_pb.CHAT_ROOM_SCENE] = {},
    [Chat_pb.CHAT_ROOM_NEW] = {},
    [Chat_pb.CHAT_ROOM_CITY] = {},
    [Chat_pb.CHAT_ROOM_SYSTEM] = {}
}

--聊天系统频道内，个人类型信息
local mChatRoomSysOfPersionList = {}

--聊天系统频道内，系统类型信息
local mChatRoomSysOfSysList = {}

--系统表情数据列表，游戏启动初始化
local mSysEmojiDataList = {}

--系统表情内，每分页表情数量
local mSysEmojiNumPerPage = 70

--功能按钮，每页按钮数量
local mFuncNumPerPage = 9

--物品分页内，每页物品数量
local mItemNumPerPage = 24

--输入历史分页内，每页数量
local mInputHistoryNumPerPage = 12

--便捷用语分页内，每页数量
local mEasyWordNumPerPage = 12

--聊天系统频道消息类型字典
local mSysMsgCreateDataDic = {}

--聊天系统频道里，系统类型消息解析字典
local mSysMsgParseDataDic = {}

--自定义表情存储网盘目录
local mCustomEmojiRemoteDir = "emojiCustom/"
--聊天语音存储网盘目录
local mChatVoiceRemoteDir = "ChatVoice/"

--所有的功能按钮，根据不同的情景选取子集合并排序放到功能列表UI内
local mAllFuncDataList = {
    [1] = {id = 1, name = "表情", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"},
    [2] = {id = 2, name = "便捷用语", norSpName = "icon_liaotian_bianjieyongyu01", specSpName = "icon_liaotian_bianjieyongyu01"},
    [3] = {id = 3, name = "输入历史", norSpName = "icon_liaotian_shurulishi01", specSpName = "icon_liaotian_shurulishi01"},
    [4] = {id = 4, name = "表情包", norSpName = "icon_liaotian_biaoqingbao01", specSpName = "icon_liaotian_biaoqingbao01"},
    [5] = {id = 5, name = "画图", norSpName = "icon_liaotian_chengjiu01", specSpName = "icon_liaotian_chengjiu01"},
    [6] = {id = 6, name = "摊位", norSpName = "icon_liaotian_tanwei01", specSpName = "icon_liaotian_tanwei01"},
    [7] = {id = 7, name = "道具", norSpName = "icon_liaotian_daojv01", specSpName = "icon_liaotian_daojv01"},
    [8] = {id = 8, name = "宠物", norSpName = "icon_liaotian_chongwu01", specSpName = "icon_liaotian_chongwu01"},
    [9] = {id = 9, name = "任务", norSpName = "icon_liaotian_renwu01", specSpName = "icon_liaotian_renwu01"},
    [10] = {id = 10, name = "每日问候", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"},
    [11] = {id = 11, name = "测试1", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"},
    [12] = {id = 12, name = "测试2", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"},
    [13] = {id = 13, name = "测试3", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"},
    [14] = {id = 14, name = "测试4", norSpName = "icon_liaotian_biaoqing01", specSpName = "icon_liaotian_biaoqing01"}
}

--CommonLink界面打开途径枚举
CommonLinkOpenType = {}
CommonLinkOpenType.None = -1
CommonLinkOpenType.FromChat = 1
CommonLinkOpenType.FromFrient = 2
CommonLinkOpenType.FromPersonSpace = 3

--本次打开CommonLink界面时的类型
local mCommonLinkOpenType = CommonLinkOpenType.None
--上次打开CommonLink界面时，记录下的功能按钮，按打开类型记录
local mLastFuncIdxDic = {}

--不同打开途径的功能按钮配置项
local mFuncDataDic = {
    [CommonLinkOpenType.None] = {},
    [CommonLinkOpenType.FromChat] = {1, 2, 3, 4, 5, 6, 7, 8, 9},
    [CommonLinkOpenType.FromFrient] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
    [CommonLinkOpenType.FromPersonSpace] = {1, 2, 3, 4, 5, 6}
}

--每个类型对应的list
local mAllFuncDataType2List = {}

--ChatInputWrap组件的append新link回调，CommonLink界面打开时获取该回调
local mFuncOnNewMsgLink = nil
--ChatInputWrap组件的创建新link回调，CommonLink界面打开时获取该回调
local mFuncCreateMsgLink = nil
--打开CommonLink界面时，ChatMain所处的房间类型
local mChatMainRoomType = Chat_pb.CHAT_ROOM_WORLD
--打开CommonLink界面时，添加msgcommon回调
local mFuncAppendMsgCommon = nil

--聊天框里的表情消息缓存
local mPicId2MsgDic = {}

--聊天框里的语音消息缓存
local mVoiceUrl2MsgDir = {}

--聊天界面打开时，要跳转到的房间类型
local mTargetRoomType = nil

--聊天界面内，系统频道界面下，个人和系统toggle是否被选中，默认都选中
--本次登录有效，不保存网络
local mPersonToggleValue = true
local mSysToggleValue = true

--登录时从网络读取设置，并在本次登录期间，动态修改，并同步到网络
--设置界面的文本显示设置，false代表该房间类型不显示在主界面底部聊天栏内
--text为显示在主界面聊天栏
--voice为自动播放语音
local mSettingDataList = 
{
    [Chat_pb.CHAT_ROOM_WORLD] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_TEAM] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_GANG] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_PROFESSION] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_SCENE] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_NEW] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_CITY] = { text = true, voice = true },
    [Chat_pb.CHAT_ROOM_SYSTEM] = { text = true, voice = true },
}

--自动播放语音选择
--1：仅在wifi下，2：全环境
local mWifiOrAll = 1

--发送语音转文字（不发送语音）
local mVoice2Text = false

--聊天语音最长录音 秒
local mChatVoiceMaxLen = 30

--聊天配置远程存取key
TextSettingKey = "chat_setting_text_"
VoiceSettingKey = "chat_setting_voice_"
WifiSettingKey = "chat_setting_wifi"
AllSettingKey = "chat_setting_all"
Text2VoiceSettingKey = "chat_setting_text2voice"

local mCurAutoChatVoiceGuid = -1
local mCurChatVoiceGuid = -1

--当前正在自动播放的mChatRoomMsgList[roomType]里索引，还有roomType
--在停止自动播放时，重置该结构
local mCurAutoPlayChatVoiceData = { idx = -1, roomType = Chat_pb.CHAT_ROOM_WORLD }

--输入历史列表
local mInputHistoryMaxNum = 12
local mInputHistoryList = {}

--便捷用语
local mEasyWordMaxNum = 12
local mEasyWordList = {}
--便捷用语列表里，没有add数据
local mEasyWordListNoAdd = {}

--ChatCommonLink界面是否需要检测屏幕点击来关闭UI
--在某些情况下关闭该开关
local mChatCommonLinkNeedCheckPress = true

--录音guid
local mVoiceGUID = -1

--聊天语音发送专用msgcommon
local mChatVoiceMsgCommon = Chat_pb.ChatMsgCommon()
mChatVoiceMsgCommon.contentStyle = Chat_pb.ChatContentStyle_Voice
local mVoiceLink = mChatVoiceMsgCommon.links:add()

--语音消息的房间类型
local mChatRoomTypeForVoice = nil

--存储每个语音消息的房间类型和文本内容，应对多个语音排队上传
local mVoiceDataWaitList = {}

--local方法
local function AddPicId2MsgDic(picId, msgCommon)
    mPicId2MsgDic[picId] = mPicId2MsgDic[picId] or {}
    table.insert(mPicId2MsgDic[picId], msgCommon)
end

--[[
    @desc: 判断该picId是否在当前的表情消息缓存里
    --@picId: 
]]
local function CheckPicIdExistInMsgDic(picId)
    if mPicId2MsgDic[picId] then
        return true
    else
        return false
    end
end

local function GetMsgCommonListByPicId(picId)
    return picId and mPicId2MsgDic[picId]
end

--[[
    @desc: 删除picId对应的等待列表
    --@picId: 
]]
local function RemoveMsgCommonByPicId(picId)
    mPicId2MsgDic[picId] = nil
end

local function InitSysEmojiDataList()
    mSysEmojiDataList = ChatData.GetSysEmojiList()
end

local function GetFuncDataListByType(openType)
    local dataList = {}

    if not openType then
        return dataList
    end

    local dataIdxList = mFuncDataDic[openType]
    if dataIdxList then
        for _, dataIdx in ipairs(dataIdxList) do
            if mAllFuncDataList[dataIdx] then
                table.insert(dataList, mAllFuncDataList[dataIdx])
            end
        end
    end

    return dataList
end

local function AddFuncDataType2List(openType)
    local dataList = GetFuncDataListByType(openType)
    if #dataList > 0 then
        mAllFuncDataType2List[openType] = dataList
    end
end

--[[
    @desc: 根据mFuncDataDic配置，初始化mFuncDataType2Dic数据结构
]]
local function InitFuncDataType2List()
    for idx = CommonLinkOpenType.FromChat, CommonLinkOpenType.FromPersonSpace do
        AddFuncDataType2List(idx)
    end
end

local function InitLastFuncIdxDic()
    for idx = CommonLinkOpenType.FromChat, CommonLinkOpenType.FromPersonSpace do
        --不同的打开来源，都默认选中表情
        mLastFuncIdxDic[idx] = 1
    end
end

--[[
    @desc: 表情图片下载到本地后，再发出消息事件
    --@localPath:
	--@remotePath:
	--@successFlag: 
]]
local function OnDownLoadEmojiFinish(localPath, remotePath, successFlag)
    if successFlag then
        local emojiInfo = CustomEmojiMgr.GetEmojiFromChatMainByUrl(remotePath)
        if emojiInfo then
            local picId = emojiInfo:GetPicId()
            local msgCommonList = GetMsgCommonListByPicId(picId)
            RemoveMsgCommonByPicId(picId)
            if msgCommonList then
                for _, msgCommon in pairs(msgCommonList) do
                    table.insert(mChatRoomMsgList[msgCommon.roomType], msgCommon)
                    GameEvent.Trigger(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, msgCommon)
                end
            end
        end
    end
end

--[[
    @desc: 聊天语音文件下载到本地后，再发出新房间消息事件
    --@localPath:
	--@remotePath:
	--@successFlag: 
]]
local function OnDownLoadVoiceFinish(localPath, remotePath, successFlag)
    if successFlag then
        local msgCommon = mVoiceUrl2MsgDir[remotePath]
        if msgCommon then
            mVoiceUrl2MsgDir[remotePath] = nil
            --把语音文件的本地下载路径存在url的后面
            msgCommon.links[1].strParams:append(localPath)
            table.insert(mChatRoomMsgList[msgCommon.roomType], msgCommon)
            GameEvent.Trigger(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, msgCommon)
        end
    end
end

--[[
    @desc: 请求一个表情详细信息回调
    --@state:
	--@picId: 
]]
local function OnGetEmojiInfo(state, picId)
    if state then
        local emojiInfo = CustomEmojiMgr.GetEmojiFromChatMainByPicId(picId)
        if emojiInfo then
            CosMgr.DownloadFile(emojiInfo:GetUrl(), UIUtil.mDownloadPicLocalPath, OnDownLoadEmojiFinish)
        end
    end
end

local function CreateMsgCommonWrap(sysMsgType, content, ...)
    local sysIconName = ""
    if IsPersonMsg(sysMsgType) then
        --个人
        sysIconName = "[909]"
    elseif IsSysMsg(sysMsgType) then
        --系统
        sysIconName = "[908]"
    end
    local content = sysIconName .. string.format(content, ...)

    local msgWrap = MsgCommonWrap.new()
    msgWrap:ResetMsgCommonWithDefaultText(content)
    msgWrap:ResetRoomType(Chat_pb.CHAT_ROOM_SYSTEM)

    --填充【系统】或【个人】标识，当做一个系统表情超链接
    local link = msgWrap:CreateMsgLink()
    MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI, link, "908", -1)
    msgWrap:GenContentWithId(link)

    local msg = msgWrap:GetMsgCommon()
    msg.sysMsgType = sysMsgType

    return msgWrap
end

--[[
    @desc: 获得经验
    --@exp: 经验值
]]
local function CreateSysMsg_GetExp(sysMsgType, content, exp)
    local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, exp)

    return msgCommonWrap
end

--[[
    @desc: 获得银币
    --@num: 银币数量
]]
local function CreateSysMsg_GetSilver(sysMsgType, content, num)
    local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, num)

    return msgCommonWrap
end

--[[
    @desc: 获得金币
    --@num: 金币数量
]]
local function CreateSysMsg_GetGold(sysMsgType, content, num)
    local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, num)

    return msgCommonWrap
end

--[[
    @desc: 获得元宝
    --@num: 元宝数量
]]
local function CreateSysMsg_GetIngot(sysMsgType, content, num)
    local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, num)

    return msgCommonWrap
end

--[[
    @desc: 获得道具
    --@itemId: 
    --@num: 道具数量
    --@itemSlot: Bag_pb.BagItemSlot
]]
local function CreateSysMsg_GetItem(sysMsgType, content, itemId, num, itemSlot)
    local itemData = ItemData.GetItemInfo(itemId)
    --货币（经验，银币等）类型通过其他途径获取数量信息
    if itemData.itemInfoType ~= Item_pb.ItemInfo.ITEMINFO_CURRENCY then
        local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, itemData.name, num)
    
        --创建links
        local link = msgCommonWrap:CreateMsgLink()
        MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.ITEM, link, itemSlot, false)
        msgCommonWrap:GenContentWithId(link)
    
        return msgCommonWrap
    end
end

--[[
    @desc: 玩家升级
    --@sysMsgType:
	--@content:
	--@playerId:
	--@playerName:
	--@level: 
]]
local function CreateSysMsg_LevelUp(sysMsgType, content, playerId, playerName, level)
    local msgCommonWrap = CreateMsgCommonWrap(sysMsgType, content, playerName, level)

    --添加PlayerInfo超链接
    local link = msgCommonWrap:CreateMsgLink()
    MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.PLAYER, link, playerId, playerName)
    msgCommonWrap:GenContentWithId(link)

    return msgCommonWrap
end

--[[
    @desc: 
    --@sysMsgType:
	--@funcCreate:
	--@wordKey: 字符表的key
]]
local function RegSysMsgCreateData(sysMsgType, funcCreate, wordKey)
    mSysMsgCreateDataDic[sysMsgType] = { create = funcCreate, wordKey = wordKey }
end

local function InitSysMsgCreateDic()
    --个人
    RegSysMsgCreateData(Chat_pb.SysMsg_GetExp, CreateSysMsg_GetExp, "chat_info_22")
    RegSysMsgCreateData(Chat_pb.SysMsg_GetSilver, CreateSysMsg_GetSilver, "chat_info_19")
    RegSysMsgCreateData(Chat_pb.SysMsg_GetGold, CreateSysMsg_GetGold, "chat_info_20")
    RegSysMsgCreateData(Chat_pb.SysMsg_GetIngot, CreateSysMsg_GetIngot, "chat_info_21")
    RegSysMsgCreateData(Chat_pb.SysMsg_GetItem, CreateSysMsg_GetItem, "chat_info_18")

    --系统
    RegSysMsgCreateData(Chat_pb.SysMsg_LevelUp, CreateSysMsg_LevelUp, "chat_info_23")
end

--[[
    @desc: 玩家升级
    --@sysMsg: 
]]
local function ParseSysMsg_LevelUp(sysMsg)
    local playerId = tonumber(sysMsg.links[1].int64Params[1])
    local level = sysMsg.links[1].intParams[1]
    local playerName = sysMsg.links[1].strParams[1]
    return playerId, playerName, level
end

local function RegSysMsgParseData(sysMsgType, funcParse)
    mSysMsgParseDataDic[sysMsgType] = { parse = funcParse }
end

local function InitSysMsgParseDic()
    RegSysMsgParseData(Chat_pb.SysMsg_LevelUp, ParseSysMsg_LevelUp)
end

--[[
    @desc: 货币变化
    --@coinType: 货币类型
	--@difNum: 数值有正有负
]]
local function OnSyncCoin(coinType, difNum)
    if difNum <= 0 then
        return
    end
    if coinType == Coin_pb.SILVER then
        CreateSysMsg(Chat_pb.SysMsg_GetSilver, difNum)
    elseif coinType == Coin_pb.GOLD then
        CreateSysMsg(Chat_pb.SysMsg_GetGold, difNum)
    elseif coinType == Coin_pb.INGOT then
        CreateSysMsg(Chat_pb.SysMsg_GetIngot, difNum)
    end
end

local function OnExpAdd(addNum)
    CreateSysMsg(Chat_pb.SysMsg_GetExp, addNum)
end

--[[
    @desc: 背包内物品变化
    --@tempId:
	--@changeNum:
	--@reason:
	--@slot: 
]]
local function OnGetItem(tempId, changeNum, reason, slot)
    if changeNum > 0 then
        CreateSysMsg(Chat_pb.SysMsg_GetItem, tempId, changeNum, slot)
    end
end


local function RegEvent()
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_SYNCCOIN, OnSyncCoin)
    GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_EXP_ADD, OnExpAdd)
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_BAG_NORMALITEMCHANGE, OnGetItem)
end

--[[
    @desc: 判断是否是自己发送出去的消息
    --@msgCommon: 
]]
local function IsSelfMsgCommon(msgCommon)
    return msgCommon.sender.senderID == tostring(UserData.PlayerID)
end

--[[
    @desc: 检测是否在输入历史里存在同样的，content相同即为相同
    --@msgCommon: 
]]
local function CheckExistInInputHistoryList(msgCommon)
    local existIn = false
    local existIdx = -1

    for idx, msg in ipairs(mInputHistoryList) do
        if msg.content == msgCommon.content then
            existIn = true
            existIdx = idx
            break
        end
    end

    return existIn, existIdx
end

--[[
    @desc: 聊天房间内接收到的消息
    --@msgCommon: 
]]
local function OnReceiveChatRoomCommon(msgCommon)
    if not mChatRoomMsgList[msgCommon.roomType] then
        return
    end

    if MsgLinkHelper.CheckIsCustomEmoji(msgCommon) then
        --自定义表情消息，多走一步逻辑
        local picId = msgCommon.links[1].strParams[1]
        AddPicId2MsgDic(picId, msgCommon)
        --以后可以不局限于从ChatMain里找，可以先判断senderid是否是自己
        --如果是的话，就从我的收藏里找，肯定能找到，算是个优化
        local emojiInfo = CustomEmojiMgr.GetEmojiFromChatMainByPicId(picId)
        if emojiInfo then
            OnGetEmojiInfo(true, picId)
        else
            SNSCustomEmojiMgr.RequestOneEmojiInfo(picId, OnGetEmojiInfo, nil)
        end
    elseif MsgLinkHelper.CheckIsChatVoice(msgCommon) then
        --聊天语音
        local voiceUrl = msgCommon.links[1].strParams[1]
        mVoiceUrl2MsgDir[voiceUrl] = msgCommon
        CosMgr.DownloadFile(voiceUrl, UIUtil.mDownloadVoiceLocalPath, OnDownLoadVoiceFinish)
    else
        table.insert(mChatRoomMsgList[msgCommon.roomType], msgCommon)
        --系统消息的个人和系统两个类型，都单独存储一份
        if msgCommon.roomType == Chat_pb.CHAT_ROOM_SYSTEM then
            if IsPersonMsg(msgCommon.sysMsgType) then
                table.insert(mChatRoomSysOfPersionList, msgCommon)
            elseif IsSysMsg(msgCommon.sysMsgType) then
                table.insert(mChatRoomSysOfSysList, msgCommon)
            end
        end
        GameEvent.Trigger(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, msgCommon)
    end

    --更新输入历史
    if IsSelfMsgCommon(msgCommon) then
        if msgCommon.contentStyle == Chat_pb.ChatContentStyle_Common then
            AddInputHistroy(msgCommon)
        end
    end
end

--[[
    @desc: 聊天系统频道内的系统类型消息，客户端需要转换成msgcommon
    --@sysMsg: 
]]
local function OnReceiveChatRoomSys(sysMsg)
    local data = mSysMsgParseDataDic[sysMsg.sysMsgType]
    if data then
        CreateSysMsg(sysMsg.sysMsgType, data.parse(sysMsg))
    end
end

--[[
    @desc: 接收新消息
    --@msgType:
	--@realInfo: 
]]
local function OnReceiveMsg(realInfo, msgType)
    if not msgType or not realInfo then
        return
    end
    if msgType == Chat_pb.CHATMSG_COMMON or msgType == Chat_pb.CHATMSG_PAINT then
        OnReceiveChatRoomCommon(realInfo)
    elseif msgType == Chat_pb.CHATMSG_COMMON_SYS then
        OnReceiveChatRoomSys(realInfo)
    end
end

--[[
    @desc: 获取msgcommon所在idx，在roomType房间消息列表内
    --@msgCommon:
	--@roomType: 
]]
local function MsgCommon2Idx(msgCommon)
    local list = mChatRoomMsgList[msgCommon.roomType]
    for idx, msg in ipairs(list) do
        if msg == msgCommon then
            return idx
        end
    end
    return -1
end

--[[
    @desc: 获取下一个未播语音消息
    --@idx: 当前索引
]]
local function GetNextNotPlayChatVoice(idx)
    if idx <= 0 then
        return -1
    end
    local list = mChatRoomMsgList[mCurAutoPlayChatVoiceData.roomType]
    for i = idx + 1, #list do
        if list[i].links[1].intParams[1] == 0 then
            return i
        end
    end
    return -1
end

--[[
    @desc: 初始化便捷用语，考虑是否跨设备同步
]]
local function InitEasyWordList()
    --本次登录有效
    table.insert(mEasyWordList, { isAdd = true, content = "点击添加便捷用语" })
end

--[[
    @desc: 初始化输入历史，考虑是否跨设备同步
]]
local function InitInputHistoryList()

end

--[[
    @desc: 语音文件上传网盘成功
]]
local function OnUploadChatVoice(localPath, url, state)
    if state then
        local voiceData = mVoiceDataWaitList[localPath]
        if voiceData then
            mVoiceDataWaitList[localPath] = nil
            --兼容pc
            if voiceData.text == "" then
                voiceData.text = "外面阳光明媚，风和日丽"
            end
            mChatVoiceMsgCommon.content = voiceData.text
            ChatMgr.SetSenderInfo(mChatVoiceMsgCommon.sender)
            mChatVoiceMsgCommon.roomType = voiceData.roomType
            MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.VOICE, mVoiceLink, url, voiceData.len)
            ChatMgr.RequestSendRoomMessage(mChatVoiceMsgCommon.roomType, "", Chat_pb.CHATMSG_COMMON, mChatVoiceMsgCommon:SerializeToString())
        end
	else
		GameLog.LogError("UI_Chat_Main.OnUploadChatVoice -> state is false")
	end
end

--[[
    @desc: 录音成功，等待发送
    --@text:
	--@len:
	--@localPath:
	--@guid: 
]]
local function OnGetChatVoice(text, len, localPath, guid)
	if guid ~= mVoiceGUID then
		return
	end
	mVoiceDataWaitList[localPath] = { roomType = mChatRoomTypeForVoice, text = text, len = len }
	CosMgr.UploadFile(localPath, mChatVoiceRemoteDir, OnUploadChatVoice, nil)
end

function InitMain()
    InitSysEmojiDataList()
    InitFuncDataType2List()
    InitLastFuncIdxDic()

    ChatMgr.RegListener(Chat_pb.CHATMSG_COMMON,OnReceiveMsg);
    ChatMgr.RegListener(Chat_pb.CHATMSG_PAINT,OnReceiveMsg);
    ChatMgr.RegListener(Chat_pb.CHATMSG_COMMON_SYS,OnReceiveMsg);

    RegEvent()

    InitSysMsgCreateDic()
    InitSysMsgParseDic()

    InitEasyWordList()
    InitInputHistoryList()
end

--[[
    @desc: 读取聊天配置
    最好在登录有一次同步数据，之后设置界面的修改都只从该结构里存取，退出游戏前集中推送到远程
]]
function InitClientData()
    local flag = nil
    for roomType, _ in pairs(mSettingDataList) do
        flag = UserData.GetChatSetting(TextSettingKey .. roomType)
        SetSettingText(roomType, flag)
        flag = UserData.GetChatSetting(VoiceSettingKey .. roomType)
        SetSettingVoice(roomType, flag)
    end

    flag = UserData.GetChatSetting(WifiSettingKey)
    if flag then
        SetWifiOrAll(1)
    end
    flag = UserData.GetChatSetting(AllSettingKey)
    if flag then
        SetWifiOrAll(2)
    end
    flag = UserData.GetChatSetting(Text2VoiceSettingKey)
    SetVoice2Text(flag)
end

--[[
    @desc: 根据房间类型，获取消息列表
    --@roomType: 
]]
function GetRoomMsgList(roomType)
    if roomType then
        return mChatRoomMsgList[roomType] or {} 
    end
end

function GetPersonSysMsgList()
    return mChatRoomSysOfPersionList
end

function GetSystomSysMsgList()
    return mChatRoomSysOfSysList
end

function GetSysEmojiDataList()
    return mSysEmojiDataList
end

function GetSysEmojiNumPerPage()
    return mSysEmojiNumPerPage
end

--[[
    @desc: 只能通过该方法打开CommonLink界面
    --@openType: 详见ChatMgr_Main的CommonLinkOpenType枚举类型
	--@funcOnNew:
	--@funcCreate:
    --@roomType: 
    --@chatInputWrap: ChatInputWrap自身
]]
function OpenCommonLinkByType(openType, funcOnNew, funcCreate, roomType, funcOnAppendMsgCommon)
    --赋值仅此一处
    mCommonLinkOpenType = openType
    mFuncOnNewMsgLink = funcOnNew
    mFuncCreateMsgLink = funcCreate
    mChatMainRoomType = roomType
    mFuncAppendMsgCommon = funcOnAppendMsgCommon

    --打开CommonLink界面，在该方法里判断界面是否已经打开
    UIMgr.ShowUI(AllUI.UI_Chat_CommonLink)
end

--[[
    @desc: 返回该次打开CommonLink时，UI的OnEnable方法里调用该方法，获取功能按钮列表
    --@openType: 
]]
function GetFuncDataListByOpenType(openType)
    if not openType then
        return
    end
    return mAllFuncDataType2List[openType]
end

function GetFuncOnNewMsgLink()
    return mFuncOnNewMsgLink
end

function GetFuncCreateMsgLink()
    return mFuncCreateMsgLink
end

function GetChatMainRoomType()
    return mChatMainRoomType
end

function GetFuncOnAppendMsgCommon()
    return mFuncAppendMsgCommon
end

function GetCommonLinkOpenType()
    return mCommonLinkOpenType
end

function SetLastFuncIdx(funcIdx)
    mLastFuncIdxDic[mCommonLinkOpenType] = funcIdx
end

function GetLastFuncIdx()
    return mLastFuncIdxDic[mCommonLinkOpenType]
end

function GetCustomEmojiRemoteDir()
    return mCustomEmojiRemoteDir
end

function GetChatVoiceRemoteDir()
    return mChatVoiceRemoteDir
end

--[[
    @desc: 获取物品数据字典
]]
function GetItemDataList()
    local dataList = {}

    local bagData = BagMgr.BagData[Bag_pb.NORMAL]

    if not bagData or type(bagData) ~= "table" then
        return dataList
    end

    for idx, itemSlot in ipairs(bagData.items) do
        --可能有一层过滤，是否能够分享到聊天框
        table.insert(dataList, {id = idx, itemSlot = itemSlot})
    end

    return dataList
end

function GetItemNumPerPage()
    return mItemNumPerPage
end

--[[
    @desc: 聊天系统频道内，个人消息入口
    --@sysMsgType: Chat_pb.SysMsgType
	--@args: 具体消息，具体参数
]]
function CreateSysMsg(sysMsgType, ...)
    local data = mSysMsgCreateDataDic[sysMsgType]
    if data then
        local content = WordData.GetWordDataByKey(data.wordKey).value
        local msgCommonWrap = data.create(sysMsgType, content, ...)
        if msgCommonWrap then
            OnReceiveMsg(msgCommonWrap:GetMsgCommon(),Chat_pb.CHATMSG_COMMON)
        end
    end
end

function IsSysMsg(sysMsgType)
    return 1001 <= sysMsgType and sysMsgType <= 2000
end

function IsPersonMsg(sysMsgType)
    return 1 <= sysMsgType and sysMsgType <= 1000
end

function TestChatRoomSys(sysMsg)
    OnReceiveChatRoomSys(sysMsg)
end

function OpenChatUI(targetRoomType)
    mTargetRoomType = targetRoomType or Chat_pb.CHAT_ROOM_WORLD
    UIMgr.ShowUI(AllUI.UI_Chat_Main)
end

function GetTargetRoomType()
    return mTargetRoomType
end

function SetPersonToggleValue(value)
    mPersonToggleValue = value
end

function GetPersonToggleValue()
    return mPersonToggleValue
end

function SetSysToggleValue(value)
    mSysToggleValue = value
end

function GetSysToggleValue()
    return mSysToggleValue
end

function SetSettingText(roomType, flag)
    mSettingDataList[roomType].text = flag
end

function GetSettingText(roomType)
    return mSettingDataList[roomType].text
end

function SetSettingVoice(roomType, flag)
    mSettingDataList[roomType].voice = flag
end

function GetSettingVoice(roomType)
    return mSettingDataList[roomType].voice
end

function SetWifiOrAll(wifiOrAll)
    mWifiOrAll = wifiOrAll
end

function GetWifiOrAll()
    return mWifiOrAll
end

function SetVoice2Text(flag)
    mVoice2Text = flag
end

function GetVoice2Text()
    return mVoice2Text
end

function GetChatVoiceMaxLen()
    return mChatVoiceMaxLen
end

--[[
    @desc: 检测是否满足自动播放语音条件
    --@roomType: 
]]
function CheckMeetAutoPlayVoice(roomType)
    local meet = true

    repeat
        --房间类型检查
        if roomType ~= Chat_pb.CHAT_ROOM_WORLD and roomType ~= Chat_pb.CHAT_ROOM_TEAM 
        and roomType ~= Chat_pb.CHAT_ROOM_GANG and roomType ~= Chat_pb.CHAT_ROOM_SCENE then
            meet = false
            break
        end
        --设置检查
        if not mSettingDataList[roomType].voice then
            meet = false
            break
        end
        --网络状况检查
        if mWifiOrAll == 1 and SystemInfo.GetNetState() ~= SystemInfo.NetState.Wifi then
            meet = false
            break
        end
    until true

    return meet
end

--[[
    @desc: 播放语音结束回调
    --@flag:
	--@guid: 
]]
function OnAutoPlayVoiceFinish(flag, guid)
    if mCurAutoChatVoiceGuid ~= guid then
        return
    end
    if flag then
        local nextIdx = GetNextNotPlayChatVoice(mCurAutoPlayChatVoiceData.idx)
        if nextIdx > 0 then
            --找到下一个
            AutoPlayChatVoice(nextIdx)
        else
            --自动播放流程结束
            StopAutoPlayChatVoice()
        end
    else
        --说明正在自动播放的被打断了，重置自动播放状态，清空等待列表
        StopAutoPlayChatVoice()
    end
end

--[[
    @desc: 自动播放语音
    --@idx: 可以保证idx是合法有效的
]]
function AutoPlayChatVoice(idx)
    mCurAutoPlayChatVoiceData.idx = idx

    local msgCommon = mChatRoomMsgList[mCurAutoPlayChatVoiceData.roomType][idx]
    --设置已经播放标识
    msgCommon.links[1].intParams[1] = 1
    --开始播放，抛出事件，刷新UI红点
    GameEvent.Trigger(EVT.CHAT, EVT.CHAT_PLAYVOICE, msgCommon)
    mCurAutoChatVoiceGuid = SpeechMgr.StartAudio(msgCommon.links[1].strParams[2], OnAutoPlayVoiceFinish, nil)
end

--[[
    @desc: 开启自动播放语音流程
    --@msgCommon: 
]]
function StartAutoPlayChatVoice(msgCommon)
    --判断当前是否满足自动播放语音条件
    if CheckMeetAutoPlayVoice(msgCommon.roomType) then
        local idx = MsgCommon2Idx(msgCommon)
        if idx > 0 then
            mCurAutoPlayChatVoiceData.idx = idx
            mCurAutoPlayChatVoiceData.roomType = msgCommon.roomType
    
            AutoPlayChatVoice(idx)
        else
            --未找到msg，报错
        end
    else
        PlayChatVoice(msgCommon)
    end
end

--[[
    @desc: 界面关闭时调用，打断自动播放
]]
function StopAutoPlayChatVoice()
    SpeechMgr.StopAudio(mCurAutoChatVoiceGuid)
    mCurAutoPlayChatVoiceData.idx = -1
    mCurAutoPlayChatVoiceData.roomType = Chat_pb.CHAT_ROOM_WORLD
end

--[[
    @desc: 单个播放语音结束
    --@flag:
	--@guid: 
]]
function OnPlayChatVoiceFinish(flag, guid)
    if mCurChatVoiceGuid ~= guid then
        return
    end
end

--[[
    @desc: 播放单个语音
    --@msgCommon: 
]]
function PlayChatVoice(msgCommon)
    mCurChatVoiceGuid = SpeechMgr.StartAudio(msgCommon.links[1].strParams[2], OnPlayChatVoiceFinish, nil)
end

--[[
    @desc: 停止单个语音
]]
function StopChatVoice()
    SpeechMgr.StopAudio(mCurChatVoiceGuid)
end

--[[
    @desc: 添加一条新的输入历史，队列形式处理list
    如果和输入历史列表的内容，则移动位置
    --@msgCommon: 
]]
function AddInputHistroy(msgCommon)
    --过滤各种非文本类型
    if msgCommon.contentStyle ~= Chat_pb.ChatContentStyle_Common then
        return
    end
    --如果新消息和输入历史列表里的某个消息完全一致，则不更新输入历史
    local existIn, existIdx = CheckExistInInputHistoryList(msgCommon)
    if existIn then
        local oldMsgCommon = table.remove(mInputHistoryList, existIdx)
        table.insert(mInputHistoryList, 1, oldMsgCommon)
    else
        if #mInputHistoryList == mInputHistoryMaxNum then
            table.remove(mInputHistoryList)
        end
        table.insert(mInputHistoryList, 1, msgCommon)
    end

    --抛出事件
    GameEvent.Trigger(EVT.CHAT, EVT.CHAT_ADDINPUTHISTORY)
end

--[[
    @desc: 获取输入历史列表，该列表被UI引用，只改table里的内容
]]
function GetInputHistoryList()
    return mInputHistoryList
end

function GetInputHistoryNumPerPage()
    return mInputHistoryNumPerPage
end

--[[
    @desc: 添加便捷用语
    --@content: 
]]
function AddEasyWord(content)
    local len = #mEasyWordList
    if len <= mEasyWordMaxNum then
        if len < mEasyWordMaxNum then
            local newData = { isAdd = false, content = content }
            table.insert(mEasyWordList, #mEasyWordList, newData)
            table.insert(mEasyWordListNoAdd, newData)
        elseif len == mEasyWordMaxNum then
            local data = mEasyWordList[len]
            data.isAdd = false
            data.content = content
            table.insert(mEasyWordListNoAdd, data)
        end

        --抛出事件
        GameEvent.Trigger(EVT.CHAT, EVT.CHAT_ADDEASYWORD)
    end
end

--[[
    @desc: 删除便捷用语
    --@dataIdx:
]]
function RemoveEasyWord(dataIdx)
    if not mEasyWordList[dataIdx] then
        return
    end

    local len = #mEasyWordList
    if len <= mEasyWordMaxNum then
        --先获取状态，再删除，再判断状态
        local needAppend = (len == mEasyWordMaxNum and not mEasyWordList[len].isAdd)
        table.remove(mEasyWordList, dataIdx)
        table.remove(mEasyWordListNoAdd, dataIdx)

        if needAppend then
            local newData = { isAdd = true, content = "点击添加便捷用语" }
            table.insert(mEasyWordList, newData)
        end
        --抛出事件
        GameEvent.Trigger(EVT.CHAT, EVT.CHAT_REMOVEEASYWORD)
    end
end

function GetEasyWordList()
    return mEasyWordList
end

function GetEasyWordListNoAdd()
    return mEasyWordListNoAdd
end

function GetEasyWordNumPerPage()
    return mEasyWordNumPerPage
end

function SetChatCommonLinkNeedCheckPress(isNeed)
    mChatCommonLinkNeedCheckPress = isNeed
end

function GetChatCommonLinkNeedCheckPress()
    return mChatCommonLinkNeedCheckPress
end

--[[
    @desc: 录音过程单步，语音上传过程是异步的。
    --@roomType: 
]]
function StartRecord(roomType)
    mChatRoomTypeForVoice = roomType
    mVoiceGUID = SpeechMgr.StartRecord(OnGetChatVoice, nil, mChatVoiceMaxLen)
end

function StopRecord()
    SpeechMgr.StopRecord(mVoiceGUID)
end

function PrepareCancel(state)
    SpeechMgr.PrepareCancel(mVoiceGUID, state)
end

return ChatMgr
