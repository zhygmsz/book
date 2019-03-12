FriendChatDataBase = class("FriendChatDataBase",BaseWrapData);

function FriendChatDataBase:ctor(recorder, sender,msg,type)
    self._recorder = recorder;
    self._sender = sender or recorder;
    self._data = msg;
    self._type = type;
end

function FriendChatDataBase:GetRecorder()
    return self._recorder;
end

function FriendChatDataBase:GetSender()
    return self._sender;
end

function FriendChatDataBase:GetSendContent()
    return self._data.sendContent;
end

function FriendChatDataBase:GetSendTime()
    return self._data.sendTime;
end

function FriendChatDataBase:IsPlayerMsg( )
    return true;
end

return FriendChatDataBase;


-- function MakeChatMsg()
--     local msgData = {};
--     msgData.sendContent = {};
--     msgData.sendContent.sender = {};
--     msgData.sendContent.sender.senderName = "test";
--     msgData.sendContent.sender.senderLevel = "222";
--     msgData.sendContent.sender.senderFaction == "button_common_head02";
-- end