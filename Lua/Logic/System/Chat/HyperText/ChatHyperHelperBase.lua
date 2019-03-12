

local ChatHyperHelperBase = class("ChatHyperHelperBase");
function ChatHyperHelperBase:ctor()
    
end

function ChatHyperHelperBase:CreateLinker(msgCommon)
    local msgLink = msgCommon:CreateMsgLink();
    msgLink.linkType = Chat_pb.ChatMsgLink.HYPER_TEXT;
    msgLink.isValid = true
    msgLink.isLimitOnlyOne = false
    msgLink.isNeedAutoId = true
    msgLink.intParams:append(self._textType);

    return msgLink;
end

--Chat_pb.ChatMsgLink, ChatHyperTextMgr里的枚举类型，显示的内容，颜色
function ChatHyperHelperBase:SetViewInfo(msgLink,content,color)
    msgLink.content = content;
    msgLink.linkDesc.textDesc.color = color or "";
end

--设置点击回调时的参数,请放在msgLink.intParams[1]已经被系统占用
function ChatHyperHelperBase:SetCommandInfo(msgLink)
    -- msgLink.intParams[2~]=;
    -- msgLink.strParams[1~]=;
    -- msgLink.byteParams[1~];
    -- msgLink.strParams:set(1, picId)
    -- msgLink.strParams:append(itemSlot:SerializeToString())
end

function ChatHyperHelperBase:OnClick(msgLink)

end

return ChatHyperHelperBase;