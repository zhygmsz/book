module("ChatMgr",package.seeall);
local FriendChatQun = require("Logic/System/SocialNetwork/Entity/FriendChatQun");
local ChatManager = ldj.sdk.cyou.chat.ChatManager;

-- 好友群组信息
local mID_FriendQuns = {};

function RemoveQun(qun)
    local qid = qun:GetID();
    mID_FriendQuns[qid] = nil;
    FriendMgr.RemoveChater(qun);
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN, qun);
end

function GetFriendQunByID(qid)
    return mID_FriendQuns[qid];
end

function GetFriendQuns()
    local list = {};
    for _,qun in pairs(mID_FriendQuns) do
        table.insert(list, qun);
    end
    return list;
end

function GetFriendQunCountInfo()
    local count = 0;
    for id, qun in pairs(mID_FriendQuns) do
        if qun:IsMyQun() then
            count = count +1;
        end
    end
    return count, GetFriendQunMaxCount();
end

function GetFriendQunMaxCount()
    return ConfigData.GetIntValue("friend_qun_max_count") or 5; --最大数量限制为100;
end

--默认容量 500
function GetQunCapacity()
    return ConfigData.GetIntValue("friend_qun_capacity") or 500;--群成员的最大数量
end

--创建群的等级判断
function CheckCreateQunCondition()
    local limitLevel = ConfigData.GetIntValue("friend_qun_level_limit") or 0;--创建群的等级限制

    if UserData.GetLevel() < limitLevel then
        TipsMgr.TipByKey("friend_qun_create_level_fail");--等级达到{0}才可以创建群聊
        return false;
    end
    local count, limit = GetFriendQunCountInfo();
    if count >= limit then
        TipsMgr.TipByKey("friend_qun_create_count_fail");--对不起，最多只能创建100个聊天群，请解散一个后再创建新的。
        return false;
    end
    return true;
end

--------------ChatMgr分发消息----------
--需要拉取群详细信息
function OnQunInit(args)

    local arg1 = args[1];
    local arg2 = args[2];-- string group_name; long latest_msgid; string miss_msg_num; string owner_accid; string[] usr_list;
    local qunID = tonumber(arg1);
    if not mID_FriendQuns[qunID] then
        mID_FriendQuns[qunID] = FriendChatQun.new(qunID);
    end
    RequestGetCligroupDetailInfo(mID_FriendQuns[qunID]);
end

function OnQunInitEnd()
    GameLog.Log("Init Friend Qun Client End");
end

function OnChatQunEvent(evtID,args)
    local arg1 = args[1];
    local arg2 = args[2];
    local arg3 = args[3];
    if evtID == 20 then --创建聊天群 string group_type;string group_id, string group_name, string owner_id, List<string> player_list
        local qunID = tonumber(arg2);
        TipsMgr.TipByKey("friend_qun_create_sucess_%s",arg3);-- {群聊名}创建成功。
        if not mID_FriendQuns[qunID] then
            mID_FriendQuns[qunID] = FriendChatQun.new(qunID);
        end
        mID_FriendQuns[qunID]:OnNewQunInfo(args);

    --被邀请的玩家同时也会受到群相信信息
    elseif evtID == 21 then --邀请加入群,不需要审核 string group_id, string player_id, string owner_id; string inviter, string time
                                                --int current_num; int max_num; int group_type;
        local qunID = tonumber(arg1);
        local pid = tonumber(arg2);
        mID_FriendQuns[qunID]:OnAddPlayer(pid);

    elseif evtID == 22 then --需要审核 string group_id, string player_id, string inviter, string time
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnAskFriendSucess(args);
    elseif evtID == 23 then --离开群组\请离群组返回 string group_id;string player_id;string time;int current_num; int max_num; int group_type;
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnRemovePlayer(args);
        
    elseif evtID == 24 then --销毁群组返回 string group_id; string time;
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnDestroy();
        mID_FriendQuns[qunID] = nil;
    elseif evtID == 25 then --获取群组信息   string group_id; string group_name; string time; string owner_id;
                                            -- int max_num; int current_num; int group_type; int latest_msgid;
                                            --  List<string> player_list;List<string> admin_list;
        local qunID = tonumber(arg1);
        if not mID_FriendQuns[qunID] then
            mID_FriendQuns[qunID] = FriendChatQun.new(qunID);
        end
        mID_FriendQuns[qunID]:OnInitInfo(args);   
    elseif evtID == 26 then --群聊天消息  string group_id, string msg_id, string chat_info, string time
        GameLog.LogError("---------qun chat message %s, %s ",arg1,arg2);
        local qunID = arg1;
        if arg2 ~= "end" then
            mID_FriendQuns[qunID]:OnReceiveMessageList(args);
        else
            mID_FriendQuns[qunID]:OnReceiveMessageListEnd(args);
        end
    elseif evtID == 27 then --修改群组名称 string group_id; string group_name; string time;
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnRename(args);
    elseif evtID == 28 then --设置管理员  string group_id;string player_id;string operator_id;string time;int set;
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnReviseAdmin(args);
    elseif evtID == 29 then --获取加群申请列表 string group_id, string player_id, string inviter, string time
        local qunID = tonumber(arg1);
        if arg2 ~= "end" then
            mID_FriendQuns[qunID]:OnAddApplyItem(args);
        else
            mID_FriendQuns[qunID]:OnAddApplyItemEnd();
        end
    elseif evtID == 30 then --审批加群申请 string group_id; string player_id; string time;
        local qunID = tonumber(arg1);
        mID_FriendQuns[qunID]:OnApplyReply(args);
    end
end

--Region:好友群聊SDK接入
--1.创建群组
function RequestCreateCligroup(playerIDs,groupName)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendCreateCligroup(playerIDs,groupName);

        GameLog.Log("chat send Create Client group %s ",groupName);
    end
end
--2.客户端请求加入群组\邀请加入群组
function SendJoinCligroup( qun, player)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendJoinCligroup(qun:GetID(), player:GetID());

        GameLog.Log("chat group SendJoinCligroup %s, %s ",qun:GetName(), player:GetID());
    end
end

--3.	客户端离开群组\请离群组
function RequestLeaveCligroup(qun, player)
    if ChatMgr.IsInited() then
        local pid = player and player:GetID() or UserData.PlayerID;
        ChatManager.Instance:SendLeaveCligroup(qun:GetID(), pid);
        GameLog.Log("chat group SendLeaveCligroup %s, %s ",qun:GetName(), pid);
    end
end
--4.	客户端在群组发言： 
function RequestSayCligroup( msgType,msgContent, qid)
    if ChatMgr.IsInited() then
        if IsEmptyContent(msgContent) then return; end
        local chatMsg = Chat_pb.ChatMsg();
        chatMsg.msgID = -1;
        chatMsg.msgType = msgType;
        chatMsg.msgData = msgContent;

        ChatManager.Instance:SendSayCligroup(qid, string.ToBase64(chatMsg:SerializeToString()));

        GameLog.Log("chat group SendSayCligroup %s, %s",msgType,msgContent);
    end
end
-- 5.	客户端销毁群组： 
function RequestDestoryCligroup(qun)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendDestoryCligroup(qun:GetID());

        GameLog.Log("chat group SendDestoryCligroup %s",qun:GetName());
    end
end
--6.	客户端获取群组信息 
function RequestGetCligroupDetailInfo(qun)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendGetCligroupInfo(qun:GetID());

        GameLog.Log("chat group SendGetCliqunInfo %s",qun:GetName());
    end
end
-- 7.	客户端获取消息列表：
function RequestGetCligroupMsgList(qun,start_msgid, end_msgid)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendGetCligroupMsgList(qun:GetID(),start_msgid, end_msgid);

        GameLog.Log("chat group SendGetCliqunInfo %s，%s, %s",qun:GetName(),start_msgid, end_msgid);
    end
end
--8.	客户端修改群组名称：
function RequestChangeCligroupName( qun, group_name)
    if ChatMgr.IsInited() then

        ChatManager.Instance:SendChangeCligroupName( qun:GetID(), group_name);

        GameLog.Log("chat group SendChangeCligroupName %s，%s",qun:GetName(),group_name);
    end
end
-- 9.	客户端任命管理员：set=true表示任命玩家为管理员，false表示取消玩家的管理员
function RequestSetCligroupAdmin( qun, player,set)
    if ChatMgr.IsInited() then
        set = set and 1 or 0;
        ChatManager.Instance:SendSetCligroupAdmin( qun:GetID(), player:GetID(),set);
        GameLog.Log("chat group SendSetCligroupAdmin %s, %s, %s",qun:GetName(), player:GetID(),set);
    end
end
--/ 10.	客户端获取加群申请列表： 
function RequestGetCligroupApply(qun)
    if ChatMgr.IsInited() then
        ChatManager.Instance:SendGetCligroupApply(qun:GetID());
        GameLog.Log("chat group SendGetCligroupApply %s",qun:GetName());
    end
end
--/ 玩家自定义群组 11.	客户端审批加群申请：1表示通过，0表示拒绝
--string qunID, string playerID, int agree
function RequestReplyCligroupJoin(qun, applyItem, agree)
    if ChatMgr.IsInited() then
        agree = agree and 1 or 0;
        ChatManager.Instance:SendReplyCligroupJoin(qun:GetID(), applyItem.applier:GetID(), agree);
    end
end
--end region群聊
return ChatMgr;