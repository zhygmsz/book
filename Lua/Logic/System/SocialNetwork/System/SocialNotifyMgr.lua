--发送私信通知，发送方和接收方都会收到这个私信，注意筛查
--加好友申请推送，同意、解除好友关系推送
module("SocialNotifyMgr",package.seeall);
local json = require "cjson";

function Init()
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_ASK,OnReceiveFriendAsk);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_AGREE,OnReceiveFriendAgree);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_DELETE_RELATION,OnReceiveDeleteRelation);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_OFFLINE_MSG,OnReceiveOfflineMsg);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_OFFLINE_NOMSG,OnReceiveRefuseOfflineReply);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_BLACKLIST,OnAddInBlackList);
end
--==============================--
--desc:--通知、接收好友申请
--time:2018-12-07 10:37:42
--@receiverID:
--@return 
--==============================--
function NotifyFriendAsk(receiverID)
    local receivers = tostring(receiverID);
    local selfTable = {id = UserData.PlayerID, name = UserData.GetName()};
    local content = tostring(json.encode(selfTable));
    local proto = Chat_pb.CHATMSG_FRIEND_ASK;
    ChatMgr.RequestSendPrivateMessage(proto,content,receivers);
end
function OnReceiveFriendAsk(content)
    local sendTable = json.decode(content);
    local senderID = tonumber(sendTable.id);
    if UserData.PlayerID == senderID then return; end
    local player = SocialPlayerMgr.FindMemberByID(senderID);
    player:SetName(sendTable.name);
    if player:IsInBlackList() then return; end
    TipsMgr.TipByKey("friend_add_by_player_%s",sendTable.name);--弹出屏幕上方信息“XXXX已加你为好友”
    FriendMgr.RequestGetRelationship(player);
    SocialChatMgr.TryInsertFriendAdd(player,true);
    FriendAskMgr.OnNewFriendAsk(player);
end

--==============================--
--desc:--通知、接收 成为好友
--time:2018-12-07 10:37:38
--@receiver:
--@return 
--==============================----
function NotifyFriendAgree(receiverID)
    local receivers = tostring(receiverID);
    local content = tostring(UserData.PlayerID);
    local proto = Chat_pb.CHATMSG_FRIEND_AGREE;
    ChatMgr.RequestSendPrivateMessage(proto,content,receivers);
end
function OnReceiveFriendAgree(content)
    local senderID = tonumber(content);
    if UserData.PlayerID == senderID then return; end
    --成为好友提醒
    local friend = SocialPlayerMgr.FindMemberByID(senderID);
    if not friend then return; end
    local function OnRelation(friend)
        if friend:IsFriend() then
            local recorder = friend;
            local text = WordData.GetWordStringByKey("friend_chat_friend_success_%s_notice",recorder:GetRemark());--聊天窗口的，加好友成功提醒
            SocialChatMgr.InsertLabelNotice(recorder,text);
            TipsMgr.TipByKey("friend_%s_friend_success",friend:GetRemark());--“XXXX已加你为好友”
        end
    end
    FriendMgr.RequestGetRelationship(friend,OnRelation,friend);
end

--==============================--
--desc:发出通知 删除好友，解除关注，删除粉丝
--time:2018-12-07 11:43:44
--@receiverID:
--@relationCode: 关系码，可能会有用途
--@return 
--==============================--
function NotifyFriendDeleteRelation(receiverID,relationCode)
    local receivers = tostring(receiverID);
    local content = json.encode({id=UserData.PlayerID,reCode = relationCode});
    local proto = Chat_pb.CHATMSG_FRIEND_DELETE_RELATION;
    ChatMgr.RequestSendPrivateMessage(proto,content,receivers);
end
--==============================--
--desc:接收通知 删除好友，解除关注，删除粉丝
--==============================--
function OnReceiveDeleteRelation(content)
    content = json.decode(content);
    local senderID = content.id;
    if UserData.PlayerID == senderID then return; end
    local friend = SocialPlayerMgr.FindMemberByID(senderID);
    FriendMgr.RequestGetRelationship(friend);
end

--[[
@desc: 通知接收 拉入黑名单
author:{author}
time:2019-02-27 17:23:49
--@player: 
@return:
]]
function NotifyAddInBlackList(player)
    local receivers = tostring(player:GetID());
    local content = tostring(UserData.PlayerID);
    local proto = Chat_pb.CHATMSG_FRIEND_BLACKLIST;
    ChatMgr.RequestSendPrivateMessage(proto,content,receivers);
end
function OnAddInBlackList(content)
    local senderID = tonumber(content);
    if UserData.PlayerID == senderID then return; end
    --成为好友提醒
    local friend = SocialPlayerMgr.FindMemberByID(senderID);
    FriendMgr.RequestGetRelationship(friend);
end
--==============================--
--desc:发送leaveState自动回复
--time:2018-12-07 11:43:44
--@receiverID:
--@return;
--==============================--
function NotifyFriendOfflineMsg(receiver)
    local recvID = receiver:GetID();
    local content = {sender = UserData.PlayerID,recvID = recvID; msg = FriendMgr.GetLeaveMsg()};
    local proto = Chat_pb.CHATMSG_FRIEND_OFFLINE_MSG;
    ChatMgr.RequestSendPrivateMessage(proto,json.encode(content),recvID);
end

function OnReceiveOfflineMsg(content)
    content = json.decode(content);
    local sender = SocialPlayerMgr.FindMemberByID(content.sender);
    if sender:IsSelf() then return; end
    local recevier = SocialPlayerMgr.FindMemberByID(content.recvID);
    SocialChatMgr.InsertOfflineReply(sender,sender,content.msg, true);
end

--[[
@desc: 通知不再接受离线自动消息
author:{hesinian}
time:2019-01-28 15:21:45
--@receiver: 
@return:
]]
function NotifyRefuseOfflineReply(receiver)
    local recvID = tostring(receiver:GetID());
    local content = UserData.PlayerID;
    local proto = Chat_pb.CHATMSG_FRIEND_OFFLINE_NOMSG;
    ChatMgr.RequestSendPrivateMessage(proto,tostring(content),recvID);
end
function OnReceiveRefuseOfflineReply(content)
    local sender = SocialPlayerMgr.FindMemberByID(tonumber(content));
    if sender:IsSelf() then return; end
    sender:GetFriendAttr():SetRecvOfflineAutoReply(false);
end

return SocialNotifyMgr;