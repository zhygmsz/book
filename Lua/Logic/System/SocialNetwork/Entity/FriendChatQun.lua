local FriendChatQun = class("FriendChatQun");
local ChatRecordComponent = require("Logic/System/SocialNetwork/Entity/Chat/ChatRecordComponent");

function FriendChatQun:ctor(id)
    self._id = id;
    self._applyTable = {};
    self._record = nil;
    self._playerTable = {};
    self._adminTable = {};
    self._owner = nil;
    self._blockMsg = false;--是否屏蔽消息
end

--------Get方法-------------------
function FriendChatQun:GetID()
    return self._id;
end
--聊天内容记录组件
function FriendChatQun:GetRecordCom()
    if not self._record then
        self._record = ChatRecordComponent.new(self);
    end
    return self._record;
end

function FriendChatQun:IsMyQun()
    return self._ownerID == UserData.PlayerID;
end

function FriendChatQun:IsOwner(player)
    return self._ownerID == player:GetID();
end

function FriendChatQun:IsAdmin(player)
    return self._adminTable[player:GetID()] and true or false; 
end
function FriendChatQun:IsAdminByID(pid)
    return self._adminTable[pid] and true or false; 
end
function FriendChatQun:GetName()
    return self._name;
end

function FriendChatQun:GetType()
    return self._type;
end

function FriendChatQun:GetIconID()
    return ResConfigData.GetResConfigID("img_chuangjue_zhiye_01");
end

function FriendChatQun:GetAllMembers()
    local list = {};
    for mid, mem in pairs(self._playerTable) do
        table.insert(list,mem);
    end
    return list;
end

function FriendChatQun:GetMemberCountInfo()
    local count = 0;
    local online = 0;
    for _,v in pairs(self._playerTable) do
        count = count + 1;
        if v:IsOnline() then
            online = online + 1;
        end
    end
    return online, count;
end

function FriendChatQun:GetCurrentMaxCapacity()
    local count = 0;
    for _,v in pairs(self._playerTable) do
        count = count + 1;
    end
    return count, self._maxN;
end

function FriendChatQun:GetMemberByID(mid)
    return self._playerTable[mid];
end
function FriendChatQun:IsMember(player)
    return self._playerTable[player:GetID()];
end

function FriendChatQun:GetAllApplyItems()
    local list = {};
    for id,applyItem in pairs(self._applyTable) do
        table.insert(list, applyItem);
    end
    return list;
end

function FriendChatQun:GetChatBlock()
    return self._blockMsg;
end

function FriendChatQun:SetChatBlock(value)
    self._blockMsg = value;
end

--------聊天服网络消息--------------
function FriendChatQun:OnInitInfo(args)
    self._name = args[2];
    self._time = args[3];
    self._ownerID = tonumber(args[4]);
    self._maxN = tonumber(args[5]);
    self._currentN = tonumber(args[6]);
    self._type = tonumber(args[7]);
    self._latestMsgID = args[8] and tonumber(args[8]) or nil;
    self._missMsgNum = 0;
    

    for i = 0, args[9].Count-1 do
        local pid = tonumber(args[9][i]);
        if pid then
            self._playerTable[pid] = SocialPlayerMgr.FindMemberByID(pid);
        end
    end
    
    for i = 0, args[10].Count-1 do
        self._adminTable[pid] = SocialPlayerMgr.FindMemberByID(pid);
    end
    self._owner = self._playerTable[self._ownerID];
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_NEW_QUN, self);
end
--创建聊天群 string group_type;string group_id, string group_name, string owner_id, List<string> player_list
function FriendChatQun:OnNewQunInfo(args)
    self._type = tonumber(args[1]);
    self._name = args[3];
    self._latestMsgID = nil;
    self._missMsgNum = 0;
    self._ownerID = tonumber(args[4]);
    self._time = TimeUtils.SystemTimeStamp()* 0.001;
    self._maxN = ChatMgr.GetQunCapacity();
    self._currentN = 1;

    local playerIDs = {};
    for i = 0, args[5].Count-1 do
        local pid = tonumber(args[5][i]);
        if pid then
            table.insert(playerIDs,pid);
            self._playerTable[pid] = SocialPlayerMgr.FindMemberByID(pid);
        end
    end
    self._owner = self._playerTable[self._ownerID];
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_NEW_QUN, self);
end

function FriendChatQun:OnAddPlayer(pid)
    self._playerTable[pid] = SocialPlayerMgr.FindMemberByID(pid);
    local notice = WordData.GetWordStringByKey("friend_qun_%_player_add",player:GetRemark());--玩家加入某群
    SocialChatMgr.InsertLabelNotice(self,notice);
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD, self, player);
end

--string group_id, string player_id, string inviter, string time
function FriendChatQun:OnAskFriendSucess(args)
    GameLog.Log("OnNewApplyer "..args[2]);
    local pid = tonumber(args[2]);
    if pid ~= tonumber(UserData.PlayerID) then--邀请别人进群，一般情况下，此时必定已经有了被邀请人的基本信息
        local player = player:GetRemark();
        TipsMgr.TipByKey("friend_qun_ask_apply_success_%s",player:GetRemark());--好友进群邀请提示
    else--自己被邀请入群
    end
end

--请求申请列表
function FriendChatQun:RequestApplyInfo()
    for pid,_ in pairs(self._applyTable) do
        self._applyTable[pid] = nil;
    end

    if self:IsAdminByID(UserData.PlayerID) or self:IsMyQun() then
        ChatMgr.RequestGetCligroupApply(self);
    end
end

--string group_id, string player_id, string inviter, string time
function FriendChatQun:OnAddApplyItem(args)
    GameLog.Log("OnNewApplyer "..args[2]);

    local pid = tonumber(args[2]);
    if self._playerTable[pid] then return; end--已经是成员了
    local iid = tonumber(args[3]);
    local time = tonumber(args[4]);
    self._applyTable[pid] = self._applyTable[pid] or {};
    self._applyTable[pid].time = time;
    self._applyTable[pid].inviter = SocialPlayerMgr.FindMemberByID(iid);
    self._applyTable[pid].applier = SocialPlayerMgr.FindMemberByID(pid);
end

function FriendChatQun:OnAddApplyItemEnd( )
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_INIT, self, self._applyTable);
end

--string group_id;string player_id;string time;int current_num; int max_num; int group_type;
function FriendChatQun:OnRemovePlayer(args)
    self._currentN = args[4];
    self._maxN = args[5];
    self._type = args[6];
    local pid = tonumber(args[2]);
    
    if pid == UserData.PlayerID then
        --走邮件，策划改文档
        ChatMgr.RemoveQun(self);
    else
        local player = self._playerTable[pid];
        self._playerTable[pid] = nil;
        self._adminTable[pid] = nil;
        
        local notice = WordData.GetWordStringByKey("friend_qun_player_%s_quit",player:GetRemark());--某个成员被管理员剔除的提醒
        SocialChatMgr.InsertLabelNotice(self,notice);
        GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE, self, player);
    end
end

function FriendChatQun:OnDestroy()
    if self:IsMyQun() then
        TipsMgr.TipByKey("friend_qun_%s_self_dismiss",self._name);--群主解散群成功提醒
    end
    ChatMgr.RemoveQun(self);
end
--string group_id, string msg_id, string chat_info, string time
function FriendChatQun:OnReceiveMessageList(args)
    local msgID = args[2];
    local chatInfo = args[3];
    local time = args[4];
    GameLog.Log("OnReceiveQunMsg "..chatInfo);
    local msgType,realMsg = ChatMgr.GetChatMsg(chatInfo);
    if msgType and realMsg then
        if msgType ~= Chat_pb.CHATMSG_FRIEND_QUN then
            GameLog.LogError("Error Qun Msg Type");
            return;
        end
        local msg = {id = msgID, content = realMsg, time = time};
        table.insert(self._MsgRecordList, 1, msg);
    end
end

function FriendChatQun:OnReceiveMessageListEnd()
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_MSGRECORD_ADD,self);
end

--string group_id; string group_name; string time;
function FriendChatQun:OnRename(args)
    if self._name == args[2] then return; end
    self._name = args[2];

    local notice = WordData.GetWordStringByKey("friend_qun_rename_%s",self._name);--群改名成功提醒
    SocialChatMgr.InsertLabelNotice(self,notice);

    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO, self);
end

--string group_id;string player_id;string operator_id;string time;int set;
function FriendChatQun:OnReviseAdmin(args)
    local pid = tonumber(args[2]);
    local player = self._playerTable[pid];
    local operator = self._playerTable[tonumber(args[3])];
    local set = args[5] == 1 and true or false;
    if set then
        self._adminTable[pid] = player;
        local notice = WordData.GetWordStringByKey("friend_qun_%s_admin",player:GetRemark());--玩家被任命为管理员
        SocialChatMgr.InsertLabelNotice(self,notice);
    else
        self._adminTable[pid] = nil;
    end
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_ADMIN,self, player);
end
--审批加群申请 string group_id; string player_id; string time;
function FriendChatQun:OnApplyReply(args)
    local pid = tonumber(args[2]);
    local applyItem = self._applyTable[pid];
    self._applyTable[pid] = nil;
    GameEvent.Trigger(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_REMOVE,self, applyItem);
end


return FriendChatQun;