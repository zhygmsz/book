local FriendChatDataSystemNotice = class("FriendChatDataSystemNotice",BaseWrapData);

function FriendChatDataSystemNotice:ctor(msg)
    self._content = msg;
end

function FriendChatDataSystemNotice:IsPlayerMsg( )
    return false;
end

return FriendChatDataSystemNotice;