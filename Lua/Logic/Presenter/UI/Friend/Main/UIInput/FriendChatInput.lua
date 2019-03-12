local FriendChatInput = class("FriendChatInput",nil);
local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap");


local function _SendMsg(self, msgWrap)
    if self._receiver.IsInBlackList and self._receiver:IsInBlackList() then
        TipsMgr.TipByKey("friend_chat_blacklist_error");--对方被您加入了黑名单
        return false;
    end


    msgWrap:CheckAllLinkIsValid();

    local msgContent = Chat_pb.ChatMsgOnebyOne();
    local time = TimeUtils.SystemTimeStamp(true);
    msgContent.sendTime = tostring(time);

    local msgCommonStr = msgWrap:GetMsgCommonStr();
    msgContent.sendContent:ParseFromString(msgCommonStr);
    local rid = tostring(self._receiver:GetID());
    msgContent.receiverID = rid;
    local receivers = rid;
    self._sendFunction(self._msgProto,msgContent:SerializeToString(),receivers);
    return true;
end

local function SendVoiceMsg(self)
    self._voiceWrap:ResetContentStyle(Chat_pb.ChatContentStyle_Voice);
    _SendMsg(self, self._voiceWrap);
    GameLog.Log("chat send friend voice chat success");
end
--contentStyle == Chat_pb.ChatContentStyle_Voice
local function SendTextMsg(self)
    self._chatInputWrap:ResetContentStyle(Chat_pb.ChatContentStyle_Common);
    if self._input:GetValueLength() < 1 then
        TipsMgr.TipByKey("input_error_length_zero");--聊天输入为空，应该是通用设置
        return false;
    end
    _SendMsg(self, self._chatInputWrap);
    self._chatInputWrap:ResetInput();
    GameLog.Log("chat send friend text chat success");
end 

function FriendChatInput:ctor(ui,path)
    local input = ui:FindComponent("LuaUIInput",path.."/CanInput/InputRoot/Input");
    self._input = input;
    local maxInputCount = ConfigData.GetIntValue("friend_chat_input_limit") or 50;--聊天最大输入
    self._chatInputWrap = ChatInputWrap.new(input, ChatMgr.CommonLinkOpenType.FromFrient);
    self._chatInputWrap:ResetMsgCommon()
    self._chatInputWrap:ResetLimitCount(maxInputCount)
    self._chatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_GROUP_FRIEND);

    self._voiceWrap = MsgCommonWrap.new();
    self._voiceWrap:ResetMsgCommon();
    self._voiceWrap:ResetRoomType(Chat_pb.CHAT_ROOM_GROUP_FRIEND);

    self._recordGuid = -1;
    self._uploading = false;
end

function FriendChatInput:SetTarget(receiver,qunOrPrivate)
    if qunOrPrivate then
        self._chatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_GROUP_FRIEND);
        self._voiceWrap:ResetRoomType(Chat_pb.CHAT_ROOM_GROUP_FRIEND);
        --self._inputData:SetRoom(Chat_pb.CHAT_ROOM_GROUP_FRIEND);

        self._msgProto = Chat_pb.CHATMSG_FRIEND_QUN
        self._sendFunction = ChatMgr.RequestSayCligroup;
    else
        self._chatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_NONE);
        self._voiceWrap:ResetRoomType(Chat_pb.CHAT_ROOM_NONE);
        --self._inputData:SetRoom(0);--私聊不用房间类型信息

        self._msgProto = Chat_pb.CHATMSG_FRIEND_PRIVATE;
        self._sendFunction = ChatMgr.RequestSendPrivateMessage;
    end
    self._receiver = receiver;
end

function FriendChatInput:OnClick(id)
    if id == 35 then -- 输入框扩展
    elseif id == 36 then -- 表情
        self._chatInputWrap:OnLinkBtnClick();
    elseif id == 37 then -- 发送聊天内容
        SendTextMsg(self);
    end
end

function FriendChatInput:OnPress(press,id)
	if id == 38 then
        if press then
            if self._uploading then TipsMgr.TipByKey("Speech_too_often"); return; end--上传时不能再次录音
			self._recordGuid = SpeechMgr.StartRecord(self.OnRecordOver, self);
        elseif self._recordGuid ~= -1 then
            SpeechMgr.StopRecord(self._recordGuid);
		end
	end
end


function FriendChatInput:OnDragOver(id)
	if id == 38 and (self._recordGuid ~= -1) then
		SpeechMgr.PrepareCancel(self._recordGuid, false)
	end
end

function FriendChatInput:OnDragOut(id)
	if id == 38 and (self._recordGuid ~= -1) then
		SpeechMgr.PrepareCancel(self._recordGuid, true)
	end
end

--text 表示录音识别出的文本
--length 表示录音识别出的长度,秒
--localPath 表示录音文件本地相对路径
function FriendChatInput:OnRecordOver(text, length, localPath,guid)
    if guid ~= self._recordGuid then GameLog.LogError("Wrong guid %s ~= recordGuid %s", guid, self._recordGuid); return; end
    local msgCommon = self._voiceWrap:GetMsgCommon();
    
    msgCommon.content = text ~="" and text or WordData.GetWordStringByKey("friend_voice_null_notice");
    msgCommon.contentPostfix = localPath;
    msgCommon.sysMsgType = length;
    self._uploading = true;
    self._recordGuid = -1;
    CosMgr.UploadFile(localPath, ChatMgr.GetChatVoiceRemoteDir() .. UserData.PlayerID, self.OnVoiceUpload, self)
end

function FriendChatInput:OnVoiceUpload(localPath,remotePath,sucess)
    self._uploading = false;
    if not sucess then return; end
    
    local msgCommon = self._voiceWrap:GetMsgCommon();
    if localPath ~= msgCommon.contentPostfix then GameLog.LogError("Conflict Voice msg %s, %s", localPath, msgCommon.contentPostfix);end
    msgCommon.contentPrefix = remotePath;
    SendVoiceMsg(self);
end

return FriendChatInput;