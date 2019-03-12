FriendChatVoiceData = class("FriendChatVoiceData",FriendChatDataBase);

--[[
    @desc: 语音数据
    author:{author}
    time:2019-03-06 14:56:58
    --@args: recorder, sender,msg,type
    @return:
]]
function FriendChatVoiceData:ctor(...)
    self.super.ctor(self,...);
    local itemData = self:GetSendContent();--Chat_pb.ChatMsgCommon类型
    self._text = itemData.content;--识别文字内容
    self._length = itemData.sysMsgType;--语音长度，秒
    self._remoteURL = itemData.contentPrefix;
    self._localPath = nil;
    self._guid = -1;--文件播放guid,-1表示没有播放
    self._played =false;
end

function FriendChatVoiceData:SetLocalPath(dir)
    self._localPath = dir;
end

function FriendChatVoiceData:GetTextContent()
    return self._text;
end

function FriendChatVoiceData:GetLength()
    return self._length;
end

function FriendChatVoiceData:GetRemoteURL()
    return self._remoteURL;
end

function FriendChatVoiceData:PlayVoice()
    if not self._localPath then GameLog.LogError("localpath is nil"); return; end
    local guid = SpeechMgr.StartAudio(self._localPath,self.OnPlayEnd,self);
    self._guid = guid;
    self._played = true;
    GameEvent.Trigger(EVT.SPEECH, EVT.SPEECH_VOICE_START,self);
end

function FriendChatVoiceData:OnPlayEnd(param)

    self._guid = -1;
    GameEvent.Trigger(EVT.SPEECH, EVT.SPEECH_VOICE_STOP,self,param == 0);--param == 0:正常结束, ==1:被打断
end

--是否播放过
function FriendChatVoiceData:IsPlayed( )
    return self._played;
end
return FriendChatVoiceData;
