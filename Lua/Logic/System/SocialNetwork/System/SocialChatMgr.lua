module("SocialChatMgr",package.seeall);
require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatDataBase");
local FriendChatDataSystemNotice = require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatDataSystemNotice");
local FriendChatDataChatTime = require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatDataChatTime");
local FriendChatDataLabelNotice = require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatDataLabelNotice");

--每天5点为界限，自动清空超过72小时的记录
local mLatestChat = {};--记录{type,ID,time,content}玩家Player或者Group;

local mMsgCommonWrap;

function InitFriendChat()
    GameLog.Log("-------------FriendMgr_Chat Inited");
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_PRIVATE,OnReceivePrivateMsg);
    ChatMgr.RegListener(Chat_pb.CHATMSG_FRIEND_QUN,OnReceiveQunMsg);
    GameEvent.Reg(EVT.CHAT,EVT.CHAT_OFFLINE_MSG,OnReceiveOfflineMsg);
    OnReceiveOfflineMsg();

    mMsgCommonWrap = MsgCommonWrap.new();
end

--------插入时间------------------------
local function TryInsertTimeMsg(recorder,msgTime)
    local lastRecordTime = recorder:GetRecordCom():GetLastChatTime();
    if ( msgTime - lastRecordTime > 60 * 10) then
        
        local content = FriendChatDataChatTime.new(msgTime);
        recorder:GetRecordCom():RecordMsg(content);
    end
end

--------插入普通系统消息------------------------
function InsertLabelNotice(recorder,text)
    local item = FriendChatDataLabelNotice.new(text);
    recorder:GetRecordCom():RecordMsg(item,true);
end

--------插入加好友提示------------------------
function TryInsertFriendAdd(recorder,notify)
    if recorder:IsStranger() or recorder:IsFan() then
        if recorder:GetRecordCom():HasNoneMessage() then
            local text = WordData.GetWordStringByKey("friend_chat_%s_add_friend_notice",recorder:GetRemark());--聊天窗口的，加好友提醒
            mMsgCommonWrap:ResetMsgCommonWithDefaultText(text);
            local helper = MsgLinkHelper.GetHyperHelper(MsgLinkHelper.HYPER_ADD_FRIEND);
            local msgLink = helper:CreateLinker(mMsgCommonWrap);
            local content = WordData.GetWordStringByKey("hyper_text_add_friend");
            helper:SetViewInfo(msgLink,content);
            local id = recorder:GetID();
            helper:SetCommandInfo(msgLink,id);
            mMsgCommonWrap:TryAppendMsgLink(msgLink);
            local item = FriendChatDataSystemNotice.new(mMsgCommonWrap:GetMsgCommon());
            recorder:GetRecordCom():RecordMsg(item,notify);
        end
    end
end

--[[
    @desc: 插入自动回复内容，文字最后追加【不再提示超链接】
    author:{hesinian}
    time:2019-01-28 15:26:27
    --@recorder:记录者
    --@sender: 发送者
	--@msg:回复内容
	--@notify: 是否抛出通知
    @return:
]]
function InsertOfflineReply(recorder,sender, content,notify)
    if (not content) or content == "" then
        content = WordData.GetWordStringByKey("friend_default_offline_auto_reply");--您好，我现在不在，稍后再和您联系
    end
    local msgContent = {};
    msgContent.sendTime = TimeUtils.SystemTimeStamp(true);
    msgContent.receiverID = UserData.PlayerID;

    mMsgCommonWrap:ResetMsgCommonWithDefaultText(content);
    local helper = MsgLinkHelper.GetHyperHelper(MsgLinkHelper.HYPER_AUTOREPLY_STOP);
    local msgLink = helper:CreateLinker(mMsgCommonWrap);
    local noMore = WordData.GetWordStringByKey("friend_offline_auto_reply");--今日不再提醒
    helper:SetViewInfo(msgLink,noMore);
    local id = sender:GetID();
    helper:SetCommandInfo(msgLink,id);
    mMsgCommonWrap:TryAppendMsgLink(msgLink);
    msgContent.sendContent = mMsgCommonWrap:GetMsgCommon();
    local msgCommon = nil;
    if sender:IsSelf() then
        msgCommon = FriendChatDataBase.new(recorder,sender,msgContent,"PrivateSelfData");
    else
        msgCommon = FriendChatDataBase.new(recorder,sender,msgContent,"PrivateOtherData");
    end
    recorder:GetRecordCom():RecordMsg(msgCommon,notify);
end

--[[
    @desc: 聊天语音文件下载到本地后,存入本地
    --@voiceData:语音Data文件
    --@localPath:
	--@remotePath:
	--@successFlag: 
]]
local function OnDownLoadVoiceFinish(voiceData, localPath, remotePath, successFlag)
    if not successFlag then TipsMgr.TipByKey("Chat_Voice_Download_Failed"); return; end--下载失败
    voiceData:SetLocalPath(localPath);
    voiceData:GetRecorder():GetRecordCom():RecordMsg(voiceData,true);
end

--处理私聊消息
local function ProcessPrivateChat(recorder, sender, msgData)
    
    if recorder:IsInBlackList() then --在黑名单中屏蔽消息
        return;
    end

    TryInsertFriendAdd(recorder);
    
    local msgTime = tonumber(msgData.sendTime);
    TryInsertTimeMsg(recorder, msgTime);

    local content = nil;

    if msgData.sendContent.contentStyle == Chat_pb.ChatContentStyle_Common then
        if sender:IsSelf() then
            content = FriendChatDataBase.new(recorder,sender,msgData,"PrivateTextSelfData");
        else
            content = FriendChatDataBase.new(recorder,recorder,msgData,"PrivateTextOtherData");
        end
        recorder:GetRecordCom():RecordMsg(content,true);
    elseif msgData.sendContent.contentStyle == Chat_pb.ChatContentStyle_Voice then
        if sender:IsSelf() then
            content = FriendChatVoiceData.new(recorder, sender, msgData, "PrivateVoiceSelfData");
        else
            content = FriendChatVoiceData.new(recorder, sender, msgData, "PrivateVoiceOtherData");
        end
        CosMgr.DownloadFile(content:GetRemoteURL(), UIUtil.mDownloadVoiceLocalPath, OnDownLoadVoiceFinish,content);
    end

    if (not sender:IsSelf()) and FriendMgr.GetLeaveState() and recorder:GetFriendAttr():GetRecvOfflineAutoReply() then
        SocialNotifyMgr.NotifyFriendOfflineMsg(recorder);
    end
end

--处理群聊消息
local function ProcessQunMessage(recorder,sender,msgData,selfMsg)
    if recorder:GetChatBlock() then return; end
    local msgTime = tonumber(msgData.sendTime);
    TryInsertTimeMsg(recorder, msgTime);
    local content;
    if msgData.contentStyle == Chat_pb.ChatContentStyle_Common then
        if selfMsg then
            content = FriendChatDataBase.new(recorder,sender,msgData,"QunTextSelfData");
        else
            content = FriendChatDataBase.new(recorder,sender,msgData,"QunTextOtherData");
        end
        recorder:GetRecordCom():RecordMsg(content,true);
    elseif msgData.contentStyle == Chat_pb.ChatContentStyle_Voice then
        if sender:IsSelf() then
            content = FriendChatVoiceData.new(recorder, sender, msgData, "QunVoiceSelfData");
        else
            content = FriendChatVoiceData.new(recorder, sender, msgData, "QunVoiceOtherData");
        end
        CosMgr.DownloadFile(content:GetRemoteURL(), UIUtil.mDownloadVoiceLocalPath, OnDownLoadVoiceFinish,content);
    end
end


--私聊--proto：ChatMsgOnebyOne
--{"left","right","systemNotice","time","leftQun","rightQun"};
function OnReceivePrivateMsg(msgData)
    GameLog.Log("---------OnReceivePrivateChatMsg "..tostring(msgData));
    local senderID = tonumber(msgData.sendContent.sender.senderID); 
    local receiverID = tonumber(msgData.receiverID);
    --私聊
    local recordID = nil;
    if senderID == UserData.PlayerID then--selfMsg
        recordID = receiverID;
    else
        recordID = senderID;
    end
    local recorder = SocialPlayerMgr.FindMemberByID(recordID);
    local sender = SocialPlayerMgr.FindMemberByID(senderID);
    ProcessPrivateChat(recorder,sender,msgData);
end

--群聊--proto: ChatMsgQunFriend
function OnReceiveQunMsg(msgData)
    GameLog.Log("---------OnReceiveQunMsg "..tostring(msgData));
    local senderID = tonumber(msgData.sendContent.sender.senderID); 
    local receiverID = tonumber(msgData.receiverID);
    local selfMsg = senderID == UserData.PlayerID;

    local qun = ChatMgr.GetFriendQunByID(receiverID);
    local sender = qun:GetMemberByID(senderID)
    ProcessQunMessage(qun,sender,msgData,selfMsg);
end

function OnReceiveOfflineMsg(msgs)
    local offlines = ChatMgr.GetOfflineMsg(Chat_pb.CHATMSG_FRIEND_PRIVATE);
    for i,msg in ipairs(offlines) do
        OnReceivePrivateMsg(msg);
    end

    offlines = ChatMgr.GetOfflineMsg(Chat_pb.CHATMSG_FRIEND_QUN);
    for i,msg in ipairs(offlines) do
        OnReceiveQunMsg(msg);
    end

end

------最近聊天-------
function AddChater(player)
    if player == mLatestChat[#mLatestChat] then return; end
    for i = #mLatestChat,1,-1 do
        if player == mLatestChat[i] then
            table.remove(mLatestChat,i);
            break;
        end
    end
    mLatestChat[#mLatestChat+1] = player;

    GameEvent.Trigger(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_ITEM,player);
end

function RemoveChater(item)
    for i = #mLatestChat,1,-1 do
        if item == mLatestChat[i] then
            table.remove(mLatestChat,i);
            GameEvent.Trigger(EVT.FRIENDCHAT,EVT.FRIENDCHAT_REMOVE_ITEM,item);
            break;
        end
    end
end

function GetAllChaters()
    return mLatestChat;
end

function ClearOverdueData()

end
--清除聊天记录
function DeleteChatter(player)
end

return SocialChatMgr;