local ChatRecordComponent = class("ChatRecordComponent")

--SocialPlayer，拥有这个数据的玩家
function ChatRecordComponent:ctor(listener)
    self._listener = listener;
    self._msgList = {};
end

function ChatRecordComponent:GetAllMsg()
    return self._msgList;
end

function ChatRecordComponent:GetLastChatTime()
    if #self._msgList == 0 then
        return 0;
    end
    for i = #self._msgList,1,-1 do
        local msg = self._msgList[i];
        local cname = msg.__cname;
        if msg:IsPlayerMsg() then
            return msg:GetSendTime();
        end
    end
    return 0;
end

function ChatRecordComponent:RecordMsg(content,notify)
    table.insert(self._msgList,content);
    SocialChatMgr.AddChater(self._listener);
    if notify then
        GameEvent.Trigger(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_MESSAGE,self._listener);
    end
end

function ChatRecordComponent:HasNoneMessage()
    return #self._msgList == 0;
end

function ChatRecordComponent:GetListener()
    return self._listener;
end

--播放下一个未播语音
function ChatRecordComponent:PlayNextUnplayedVoice(voiceData)
    local targetVoice;
    local nextUnread;

    for i= #self._msgList, 1 do
        local data = self._msgList[i];
        if data.__cname == "FriendChatVoiceData" then
            if not data:IsPlayed() then--找到未播的新的语音
                nextUnread = data;
            elseif data == voiceData then--找到目标
                if nextUnread then nextUnread:PlayVoice(); end
                return;
            end
        end
    end
    
end

function ChatRecordComponent:ClearMemory(tips)
    self._msgList = {};
    if tips then
        TipsMgr.TipByKey("friend_chat_clear_record_sucess");--清空与该玩家之间的聊天记录，聊天界面清空，弹出tips【聊天记录清除成功】；
    end
    GameEvent.Trigger(EVT.FRIENDCHAT,EVT.FRIENDCHAT_CLEAR_MESSAGE,self._listener);
end

return ChatRecordComponent;



