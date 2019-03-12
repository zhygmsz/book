local FriendChatDataChatTime = class("FriendChatDataChatTime",BaseWrapData);

function FriendChatDataChatTime:ctor(msg)
    self._content = msg;
end

function FriendChatDataChatTime:IsPlayerMsg( )
    return false;
end

return FriendChatDataChatTime;