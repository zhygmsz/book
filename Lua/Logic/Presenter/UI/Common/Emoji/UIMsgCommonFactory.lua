--构造ChatMsgCommon的工厂
module("UIMsgCommonFactory",package.seeall);

function CreateMsgCommon()
    return Chat_pb.ChatMsgCommon();
end

function CreateMsgCommonWithDefaultText(text)
    local ret = Chat_pb.ChatMsgCommon();
    ret.content = text;
    return ret;
end

function CreateMsgCommonFromString(str)
    local ret = Chat_pb.ChatMsgCommon();
    ret:ParseFromString(str);
    return ret;
end
