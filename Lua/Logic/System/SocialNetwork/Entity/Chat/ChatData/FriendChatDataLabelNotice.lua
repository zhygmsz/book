local FriendChatDataLabelNotice = class("FriendChatDataLabelNotice",BaseWrapData);

function FriendChatDataLabelNotice:ctor(msg)
    self._content = msg;
end

function FriendChatDataLabelNotice:IsPlayerMsg( )
    return false;
end

return FriendChatDataLabelNotice;