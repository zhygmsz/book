module("ChatMgr",package.seeall);
local ChatManager = ldj.sdk.cyou.chat.ChatManager;

--mPaintMessages = {};
local mChatMsgProtoTable = {};
local mChatMsgProcessTable = {};
local mOfflineMessages = {};
local function RegMsgProto(msgType,proto)
    mChatMsgProtoTable[msgType] = proto;
end

local function ParseRawMsg(data)
    local msg = Chat_pb.ChatMsg();
    local flag,result = xpcall(msg.ParseFromString,traceback,msg,string.FromBase64(data));
    if not flag then
        GameLog.LogError(result);
        return;
    end

    local msgType = msg.msgType;
    --local typeName = Chat_pb.values[msgType].name;
    local realInfo = nil
    if mChatMsgProtoTable[msgType] then
        realInfo = mChatMsgProtoTable[msgType]();
        flag, result = xpcall(realInfo.ParseFromString,traceback,realInfo,msg.msgData);
        if not flag then
            GameLog.LogError(result);
        end
    else
        GameLog.Log("Not Found Proto for ChatMsgType %s ",msgType);
        realInfo = msg.msgData;
    end
    return msgType, realInfo;
end

--注册了的proto将会用调用相应的ParseFromString来处理结果，否则不做任何处理
function InitChatMsg()

    RegMsgProto(Chat_pb.CHATMSG_BULLET_ADD,Chat_pb.ChatMsgBulletAdd);--添加弹幕
    RegMsgProto(Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT,Chat_pb.ChatMsgBulletThumbUpTransmit);--弹幕点赞通知
    RegMsgProto(Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT,Chat_pb.ChatMsgBulletCommentTransmit);--弹幕评论通知
    RegMsgProto(Chat_pb.CHATMSG_COMMON,Chat_pb.ChatMsgCommon);--通用房间消息
    RegMsgProto(Chat_pb.CHATMSG_FRIEND_PRIVATE,Chat_pb.ChatMsgOnebyOne);--一对一私聊
    RegMsgProto(Chat_pb.CHATMSG_FRIEND_QUN,Chat_pb.ChatMsgFriendQun);--好友群聊
    RegMsgProto(Chat_pb.CHATMSG_TEAM_PRIVATE,Chat_pb.ChatMsgCommon);--队伍私聊
    RegMsgProto(Chat_pb.CHATMSG_COMMON_SYS,Chat_pb.SysMsgCommon);--聊天系统频道内，系统类型通知
end



--Chat_pb.ChatMsgType类型,回调方法, 调用方法的类(不可以是bool,这是一个trick)--重复注册直接替换
function RegListener(msgType,msgFunction,caller)
    if type(caller) == "boolean" then
        GameLog.LogError("caller can't be boolean");
        return;
    end
    mChatMsgProcessTable[msgType] = mChatMsgProcessTable[msgType] or {};
    mChatMsgProcessTable[msgType][msgFunction] = caller or false;
end
--注销
function UnRegListener(msgType,msgFunction)
    if mChatMsgProcessTable[msgType] then
        mChatMsgProcessTable[msgType][msgFunction] = nil;
    end
end

function DispatchRealtimeMsg(data)

    local msgType, realInfo = ParseRawMsg(data);
    if not msgType then  return;  end

    --通知监听的方法
    local callBacks = mChatMsgProcessTable[msgType];
    if not callBacks then GameLog.LogError("Not Found Listener for ChatMsgType %s",msgType); return; end
    local hasCall = false;
    for call,caller in pairs(callBacks) do
        hasCall = true;
        GameUtils.TryInvokeCallback(call,caller,realInfo,msgType);
    end
    if not hasCall then
        GameLog.LogError("Not Found Listener for ChatMsgType %s",msgType);
    end
end

function OnReceiveOfflineMsg(data)
    local msgType,realMsg = ParseRawMsg(data);
    if msgType and realMsg then
        mOfflineMessages[msgType] = mOfflineMessages[msgType] or {};
        table.insert(mOfflineMessages[msgType],realMsg);
    end
    if not mOfflineMessages.hasMsg then
        mOfflineMessages.hasMsg = true;
    end
end

function GetOfflineMsg(msgType)
    return mOfflineMessages[msgType] or table.emptyTable;
end

--获取离线消息
function RequestGetPlayerOfflineMessage()
    if IsInited() then
        if mOfflineMessages.hasMsg then
            --MessageSub.SendMessage(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_OFFLINE_MSG);
            GameEvent.Trigger(EVT.CHAT,EVT.CHAT_OFFLINE_MSG);
        else
            ChatManager.Instance:SendGetPlayerOfflineMsg();
        end
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--发送房间消息
function RequestSendRoomMessage(roomType,roomName,msgType,msgContent)
    if IsInited() then
        if IsEmptyContent(msgContent) then return; end
        local chatMsg = Chat_pb.ChatMsg();
        chatMsg.msgID = -1;
        chatMsg.msgType = msgType;
        chatMsg.msgData = msgContent;

        local msg = NetCW_pb.CWChatRoomSay();
        msg.info = string.ToBase64(chatMsg:SerializeToString());
        msg.roomType = roomType;
        msg.roomKey = roomName;
        GameNet.SendToGate(msg);  
        --GameLog.Log("chat send room msg success roomType %s  roomName %s  msgType %s",roomType,roomName,msgType);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--发送私聊消息
function RequestSendPrivateMessage(msgType,msgContent,receivers)
    if IsInited() then
        if IsEmptyContent(msgContent) then return; end
        local chatMsg = Chat_pb.ChatMsg();
        chatMsg.msgID = -1;
        chatMsg.msgType = msgType;
        chatMsg.msgData = msgContent;

        ChatManager.Instance:SendChatMsg(string.ToBase64(chatMsg:SerializeToString()),receivers);

        GameLog.Log("chat send private msg success msgType %s  receivers %s",msgType,receivers);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--请求进入或者退出弹幕房间
function RequestJoinRoom(storyName,join)
    if IsInited() then
        local msg = NetCW_pb.CWChatJoinRoom();
        msg.state = join and 0 or 1;
        msg.roomKey = storyName;
        GameNet.SendToGate(msg);  
        GameLog.Log("chat request join room %s %s",storyName,join);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end


return ChatMgr;