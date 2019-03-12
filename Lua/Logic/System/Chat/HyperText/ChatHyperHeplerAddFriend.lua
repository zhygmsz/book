
local ChatHyperHelperBase = require("Logic/System/Chat/HyperText/ChatHyperHelperBase");
local ChatHyperHeplerAddFriend = class("ChatHyperHeplerAddFriend",ChatHyperHelperBase);

--Chat_pb.ChatMsgLink, ChatHyperTextMgr里的枚举类型，显示的内容，颜色
function ChatHyperHeplerAddFriend:ctor()
    self._textType = MsgLinkHelper.HYPER_ADD_FRIEND;
end

function ChatHyperHeplerAddFriend:SetViewInfo(msgLink,content,color)
    self.super.SetViewInfo(self,msgLink,content,color or "[1A00FB]");
end

function ChatHyperHeplerAddFriend:SetCommandInfo(msgLink,id)
    msgLink.intParams:append(id);
end

function ChatHyperHeplerAddFriend:OnClick(msgLink)
    local id = msgLink.intParams[2];
    local friend = FriendMgr.FindMemberByID(id);
    FriendMgr.RequestAskAddFriend(friend);
end

return ChatHyperHeplerAddFriend;
