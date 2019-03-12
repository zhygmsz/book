module("ChatMgr",package.seeall);
ChatManager = ldj.sdk.cyou.chat.ChatManager;
mModuleInit = {};
mChatPHPCommonParam = nil;
mChatPHPAddr = nil;
CHAT_DEBUG = true;

function IsInited()
    if not mModuleInit.InitClient then
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
    return mModuleInit.InitClient;
end

function IsChannelFiltered(channel)
    return false;
end

function IsBulletEnabled()
    return UserData.ReadBoolConfig("bullet_enable",true);
end

function IsBulletTipEnabled()
    return UserData.ReadBoolConfig("bullet_tip_enable",true);
end

function IsEmptyContent(content)
    if content == nil or content == "" then
        TipsMgr.TipByKey("bullet_empty_content");
        return true;
    else
        return false;
    end
end

function SetBulletEnabled(enable)
    UserData.WriteBoolConfig("bullet_enable", enable);
end

function SetBulletTipEnabled(enable)
    UserData.WriteBoolConfig("bullet_tip_enable", enable);
end

function SetSenderInfo(msgSender)
    msgSender.senderID = tostring(UserData.PlayerID);
    msgSender.senderLevel = UserData.GetLevel();
    msgSender.senderName = UserData.GetName();
end

function InitSocket(msg)

end

function InitModule()
    --聊天辅助工具
	require("Logic/System/Chat/TextHelper");
	require("Logic/System/Chat/TextChatData");
    require("Logic/System/Chat/MsgLinkHelper").InitModule();
    --聊天模块拆分
    require("Logic/System/Chat/ChatMgr_Bullet");
    --require("Logic/System/Chat/ChatMgr_EmojiCustom");
    require("Logic/System/Chat/SNSCustomEmojiMgr")
    require("Logic/System/Chat/ChatMgr_Msg");
    require("Logic/System/Chat/ChatMgr_Paint");

    require("Logic/System/SocialNetwork/System/SocialNotifyMgr").Init();

    require("Logic/System/Chat/ChatMgr_Qun");
    require("Logic/System/Chat/ChatMgr_Main").InitMain();
    require("Logic/System/Chat/CustomEmojiMgr").Init();
    require("Logic/System/Chat/EmojiUploadMgr").Init()
    --聊天UI
	require("Logic/Presenter/UI/Chat/Main/UI_Chat_Main");
    require("Logic/Presenter/UI/Chat/UI_Chat_Bullet")
    require("Logic/Presenter/UI/Chat/UI_Chat_Bullet_Tip");
    require("Logic/Presenter/UI/Chat/UI_Chat_Paint");
    --聊天链接
    require("Logic/Presenter/UI/Chat/ChatCommonPaint");
    require("Logic/Presenter/UI/Chat/ChatCommonRepaint");
    require("Logic/Presenter/UI/Chat/ChatCommonEmojiCustom");
end

function InitOfflineMsg()
    ChatMgr.RequestGetPlayerOfflineMessage();
end


function OnChatEvent(evtID,...)
    local args = {...};
    local arg1 = args[1];
    local arg2 = args[2];
    local arg3 = args[3];
    if evtID == 10 then
        -- 10收到新的聊天消息
        ChatMgr.DispatchRealtimeMsg(arg2);
    elseif evtID == 14 then
        -- 14 登录聊天服成功
        if arg1 ~= "end" then--arg2: string group_name; long latest_msgid; string miss_msg_num; string owner_accid; string[] usr_list;
            ChatMgr.OnQunInit(args);
        else
            local msg = NetCW_pb.CWLoginSDKEnd();
            GameNet.SendToGate(msg);
            InitOfflineMsg();
            SocialChatMgr.InitFriendChat();
            ChatMgr.OnQunInitEnd();
            ChatMgr.InitChatMsg();
        end
    elseif evtID == 15 then
        --聊天服断开连接
        TipsMgr.TipByKey("chat_server_disconnect");
        ChatManager.Instance:ReConnectClient(2);
    elseif evtID == 16 then
    elseif evtID == 17 then
        --TODO 房间历史消息 房间近期消息
    elseif evtID == 18 then
        --离线消息
        if arg1 ~= "end" then
            ChatMgr.OnReceiveOfflineMsg(arg2);
        else
            --MessageSub.SendMessage(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_OFFLINE_MSG);
            GameEvent.Trigger(EVT.CHAT,EVT.CHAT_OFFLINE_MSG);
        end
    elseif evtID == 19 then
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_RECEIVE_SPEECH_TEXT,arg1);
    elseif evtID >= 20 and evtID < 40 then
        ChatMgr.OnChatQunEvent(evtID,args)
    elseif evtID == 50 then
        GameEvent.Trigger(EVT.CHAT,EVT.FRIEND_ONLINE_OFFLINE, arg1, arg2);
    end

end

function OnReceiveToken(msg)
    if not mModuleInit.InitEventFunc then
        mModuleInit.InitEventFunc = true;
        ChatManager.Instance:InitEventFunc(OnChatEvent);
    end
    if not mModuleInit.InitClient then
        mModuleInit.InitClient = true;
        --聊天服地址
        local ip = msg.chatServerIp;
        local port = tonumber(msg.chatServerPort);
        local token = msg.sdkToken;
        local version = msg.version;
        local authsalt = msg.authsalt;
        local sign = msg.sign;
        --弹幕服务参数
        mChatPHPAddr = string.format("http://%s:8080/index.php",ip);
        mChatPHPCommonParam = string.format("authsalt=%s&sign=%s&accid=%s&token=%s",authsalt,sign,UserData.PlayerID,token);
        --网络连接初始化参数
        ChatManager.Instance:InitClientParam(ip,port,UserData.PlayerID,tostring(UserData.PlayerID),"com.cyou.ldj",token,version);
        ChatManager.Instance:InitClient(CHAT_DEBUG);
        ChatManager.Instance:CreateClient();
    end
end

function OnLoginSDKEnd(msg)
end

function OnChatRoomSay(msg)
end

function OnJoinRoom(msg)
    if msg.state == 0 then
        GameLog.Log("chat join room success %s",msg.roomID);
        GameEvent.Trigger(EVT.BULLET, EVT.BULLET_ONJOINROOM, msg.roomID)
    else
        GameLog.Log("chat quit room success %s",msg.roomID);
    end
end

function OnSystemInfo(msg)
	TipsMgr.TipTop(msg.info);
end

function OnErrorInfo(msg)
end

return ChatMgr;

