
local ChatHyperHelperBase = require("Logic/System/Chat/HyperText/ChatHyperHelperBase");
local ChatHyperOfflineAutoReply = class("ChatHyperOfflineAutoReply",ChatHyperHelperBase);

--Chat_pb.ChatMsgLink, ChatHyperTextMgr里的枚举类型，显示的内容，颜色
function ChatHyperOfflineAutoReply:ctor()
    self._textType = MsgLinkHelper.HYPER_AUTOREPLY_STOP;
end

function ChatHyperOfflineAutoReply:SetViewInfo(msgLink,content,color)
    self.super.SetViewInfo(self,msgLink,content,color or "[1A00FB]");
end

function ChatHyperOfflineAutoReply:SetCommandInfo(msgLink,id)
    msgLink.intParams:append(id);
end

function ChatHyperOfflineAutoReply:OnClick(msgLink)
    local id = msgLink.intParams[2];
    local friend = FriendMgr.FindMemberByID(id);
    SocialNotifyMgr.NotifyRefuseOfflineReply(friend);
    TipsMgr.TipByKey("friend_refuse_%s_auto_reply",friend:GetRemark());--设置成功，玩家{-}今日的自动回复不会再提醒
end

return ChatHyperOfflineAutoReply;
