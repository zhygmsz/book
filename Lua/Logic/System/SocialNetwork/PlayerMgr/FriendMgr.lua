--[[
    des:所有的社交玩家信息管理
    author:{hesinian}
    time:2019-01-21 19:42:14
]]
module("FriendMgr", package.seeall)

require("Logic/System/SocialNetwork/Group/FriendGroupBase");
local JSON = require("cjson")
FRIENDTYPE = {FRIEND = "Friend", FOLLOW = "Follow", FAN = "Fan",BLACK = "Black", STRANGER = "Stranger", NPCFRIEND = "NPCFriend", NPCSTRANGER = "NPCStranger"};
FRIENDGROUP = {START = 0, LASTFRIEND =9, FOLLOW = 10, FAN = 11, BLACK = 12, STRANGER = 13, END = 13};

local mBasicFriendInfoParam = "detailparams=playerid&usrdata_fields=level";

local mGroups = {};--自定义分组信息-id 0~9:我的好友,10~12: 我的关注，我的粉丝，黑名单
local mGroupFollow;
local mGroupFan;
local mGroupStranger;
local mFriendAddRecord = {};

local mSettings = {};


local function InitFriendGroups()
    local path = "Logic/System/SocialNetwork/Group/FriendGroup";
    local FriendGroupFriend = require(path..FRIENDTYPE.FRIEND);
    local FriendGroupFollow = require(path..FRIENDTYPE.FOLLOW);
    local FriendGroupFan = require(path..FRIENDTYPE.FAN);
    local FriendGroupBlack = require(path..FRIENDTYPE.BLACK);
    local FriendGroupStranger = require(path..FRIENDTYPE.STRANGER);

    for i = 0, 9 do
        mGroups[i] = FriendGroupFriend.new(i);
    end
    mGroups[10] = FriendGroupFollow.new(10);
    mGroups[11] = FriendGroupFan.new(11);
    mGroups[12] = FriendGroupBlack.new(12);
    mGroups[13] = FriendGroupStranger.new(13);
    mGroups[14] = FriendGroupStranger.new(14);

    mGroupFollow = mGroups[10];
    mGroupFan = mGroups[11];
    mGroupBlack = mGroups[12];
    mGroupStranger = mGroups[13];
end

--根据code解码好友关系
--1040015 好友关系
--1040016 我的粉丝
--1040018 我的关注
--1040019 没有关系
local function ParseRelationship(player, relationCode)
    if player:IsInBlackList() then return; end--黑名单
    if relationCode == 1040015 then--好友
        Move2GroupFriend(player);
    elseif relationCode == 1040016 then--我的粉丝
        Move2Group(player,mGroupFan);
    elseif relationCode == 1040018 then--我的关注
        Move2Group(player,mGroupFollow);
    elseif relationCode == 1040019 then--陌生人
        Move2Group(player,mGroupStranger);
        SocialChatMgr.DeleteChatter(player);
    end
end

--限制加好友不能太频繁
local function CheckRepeatAdd(player)
    local current = TimeUtils.SystemTimeStamp(true);
    local repeatTimeLimit = ConfigData.GetIntValue("friend_add_repeat_time_limit") or 30;--重复添加时间间隔 秒

    --把所有的申请记录都清理一遍
    for pid, time in pairs(mFriendAddRecord) do
        if time + repeatTimeLimit < current then
            mFriendAddRecord[pid] = nil;
        end
    end

    local pid = player:GetID();
    if not mFriendAddRecord[pid] then
        mFriendAddRecord[pid] = current;
        return true;
    end

    --mFriendAddRecord[player] = current;
    return false;
end

function InitSNS()
    InitFriendGroups();
    RequestInitGroupNames();
    
    RequestAllRelationships();--获取所有好友关系
    RequestGetFriendSettings();
end

function FindMemberByID(id)
    return SocialPlayerMgr.FindMemberByID(id);
end

function GetSelf()
    return SocialPlayerMgr.GetSelf();
end

function GetMembersBySearchStr(str)
    if not str then return table.emptyTable; end
    if str == "" then return table.emptyTable; end
    local list = {};
    for i=FRIENDGROUP.START, FRIENDGROUP.FAN do
        for _,member in ipairs(mGroups[i]:GetAllMembers()) do
            if member:FullfillSearch(str) then
                table.insert(list,member);
            end
        end
    end
    return list;
end

--获得所有好友
function GetMembersWithCondition(Condition)
    local list = {};
    for i=FRIENDGROUP.START, FRIENDGROUP.LASTFRIEND do
        for _,member in ipairs(mGroups[i]:GetAllMembers()) do
            if (not Condition) or (Condition(member)) then
                table.insert(list,member);
            end
        end
    end
    return list;
end

--改变分组
function Move2Group(member,targetGroup,quiet)
    local sourceGroup = member:GetFriendAttr():GetGroup();
    if sourceGroup == targetGroup then return; end
    if sourceGroup then sourceGroup:RemoveMember(member,quiet); end
    targetGroup:AddMember(member,quiet);
    
    if not quiet then
        GameEvent.Trigger(EVT.FRIEND, EVT.FRIEND_RELATION_CHANGE,member);
    end
    if sourceGroup:IsGroupFriend() and (not targetGroup:IsGroupFriend()) then
        GameEvent.Trigger(EVT.FRIEND, EVT.FRIEND_DELETE_FRIEND,member);--解除好友关系
    end
end

--变为好友关系
function Move2GroupFriend(member)
    local sourceGroup = member:GetFriendAttr():GetGroup();
    if sourceGroup:GetID() <=9 then return; end--已经在好友分组中
    Move2Group(member, mGroups[0]);
end

--获得所有好友
function GetAllFriends()
    local list = {};
    for i=FRIENDGROUP.START, FRIENDGROUP.END do
        for _,member in ipairs(mGroups[i]:GetAllMembers()) do
            if member:IsFriend() then
                table.insert(list,member);
            end
        end
    end
    return list;
end

function GetAllFriendCount()
    local count = 0;
    for i=FRIENDGROUP.START, FRIENDGROUP.LASTFRIEND do
        count = count + mGroups[i]:GetMemberCount();
    end
    return count;
end

function GetAllNPCFriends()
    return table.emptyTable;
end

function GetAllFriendsUngrouped()
    return mGroups[0]:GetAllMembers();
end

------Group相关
function GetGroupFriends()
    local list = {};
    for i = FRIENDGROUP.START, FRIENDGROUP.LASTFRIEND do
        if mGroups[i]:IsInUse() then
            table.insert(list,mGroups[i]);
        end
    end
    return list;
end

function GetGroupFollow()
    return mGroupFollow;
end

function GetGroupFan()
    return mGroupFan;
end

function GetGroupBlack()
    return mGroupBlack;
end

function GetGroupStranger()
    return mGroupStranger;
end

function GetUsed_AllGroupFriendCount()
    local count = 0;
    for i = 1, 9 do
        if mGroups[i] and mGroups[i]:IsInUse() then
            count = count + 1;
        end
    end
    return count, 9;
end

function GetOneUnuseGroupFriend()
    for i = 1, 9 do
        if not mGroups[i]:IsInUse() then
            return mGroups[i];
        end
    end
    TipsMgr.TipByFormat(WordData.GetWordStringByKey("friend_add_group_fail"));--只能创建9个分组，分组创建失败提示
end

function GetDefaultGroupName()
    local defaultName = WordData.GetWordStringByKey("friend_group_default_name");--分组默认名字
    local index = 1;
    local candidateName = defaultName..tonumber(index);
    while true do
        local sucess = true;
        for i = 1,9 do
            local gname = mGroups[i]:GetName();
            if gname == candidateName then
                index = index + 1;
                candidateName = defaultName..tonumber(index);
                sucess = false;
                break;
            end
        end
        if sucess then 
            break;
        end
    end
    return candidateName;
end

function CheckFriendCapacity()
    local count = GetAllFriendCount() + mGroupFollow:GetMemberCount();
    local friendCountLimit = ConfigData.GetIntValue("friend_capacity_limit") or 500;--好友和关注的人数总限制
    if count >= friendCountLimit then return false; end
    return true;
end

function CheckRepeatName(candidateName)
    for i = 1,9 do
        local gname = mGroups[i]:GetName();
        if gname == candidateName then
            return true;
        end
    end
    return false;
end

--------------好友设置-----------
function GetSettings()
    return mSettings;
end
function GetLeaveState()
    return mSettings.leaveStatus;
end
function GetLeaveMsg()
    return mSettings.msg;
end
--==============================---------------------------

--在开发阶段，需要调试服务器信息，所以每次有好友关系改变就拉取服务器信息，到服务器稳定时，可以在确认回复后修改本地数据而不是拉取全部
--同步关系数据
function RequestAllRelationships()
    local count = 0;
    local loalcallback = function()
        count = count +1;
        if count == 4 then
            GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_SYNC_ALL_RELATION);
        end
    end
    for i =0,11 do
        mGroups[i]:ClearMembers();
    end
    RequestAllFriendList(loalcallback);
    RequestAskFollowList(loalcallback);
    RequestAskFanList(loalcallback);
    RequestAskBlackList(loalcallback);--获取黑名单
end

--1. 查询好友列表--NPC好友默认在 group0
--[{"group_id":"0","intimacy":"0","heat":"0","heat_mtime":"0","isnpc":"0","tpid":"10000055","playerid":"10000055","device_id":"10000055"}]
function RequestAllFriendList(callback,caller)
    local function OnReceiveAllFriendList(data)    
        for i,v in ipairs(data) do
            local roleID = tonumber(v.tpid);
            local gId = tonumber(v.group_id);
            local player = FindMemberByID(roleID);

            player:GetVolatileAttr():Refresh(v);
            player:GetFriendAttr():Refresh(v);
            mGroups[gId]:AddMember(player);
        end
        GameUtils.TryInvokeCallback(callback,caller);
    end

    local params = mBasicFriendInfoParam .."&start=0&cnt=500";
    SocialNetworkMgr.RequestAction("AskFriendList",params,OnReceiveAllFriendList);
end

--2. 申请添加好友,添加好友成功后不能确定加入Follow列表，还是好友列表，所以需要重新获取好友关系数据
--error: 40002	已经是好友; 40003	不能申请添加自己为好友
function RequestAskAddFriend(member,callback,caller)

    local friendLevelLimit = ConfigData.GetIntValue("friend_add_level_limit") or 0;--加好友等级限制
    local level = UserData.GetLevel();
    if UserData.GetLevel() < friendLevelLimit then TipsMgr.TipByKey("friend_add_level_%s_limit",friendLevelLimit); return; end --您等级不足{0}级，无法添加好友”
    if not CheckFriendCapacity() then TipsMgr.TipByKey("friend_capacity_limit_tips");return;end --“好友已满，请清理后再行添加”
    if member:IsSelf() then TipsMgr.TipByKey("friend_add_self_tips");return;end --"无法添加自己为好友"
    if member:IsFriend() then TipsMgr.TipByKey("friend_add_already_friend_tips");return;end --"对方是你好友，无法重复添加"
    if member:IsFollow() then TipsMgr.TipByKey("friend_add_already_follow_tips");return;end --"您已经关注了对方，无法重复关注"
    if member:IsInBlackList() then TipsMgr.TipByKey("friend_add_black_tips");return;end --"对方处于您的黑名单中，请释放后添加"
    if not CheckRepeatAdd(member) then TipsMgr.TipByKey("friend_add_repeat_tips");return;end --"重复添加好友"
    local fid = member:GetID();
    local isNPC = member:GetFriendAttr():IsNPC();
    isNPC = isNPC and 1 or 0;

    local function OnReceiveAskAddFriend(relationCode)
        ParseRelationship(member, relationCode);
        if member:IsFriend() then
            SocialNotifyMgr.NotifyFriendAgree(fid);
            --服务器弹出tips
            TipsMgr.TipByKey("friend_ask_success");--添加好友成功
        elseif member:IsFollow() then
            SocialNotifyMgr.NotifyFriendAsk(fid);
            TipsMgr.TipByKey("friend_add_follow_success");--关注好友成功
        end
        

        if not member:GetVolatileAttr():IsOnline() then
            TipsMgr.TipByKey("friend_ask_offline");--对方不在线提醒
        end
        GameUtils.TryInvokeCallback(callback,caller);
    end
    
    local params = string.format("tpid=%s&isNPC=%s",fid,isNPC);
    SocialNetworkMgr.RequestAction("AskAddFriend",params,OnReceiveAskAddFriend);
end

--7.	删除好友：会把对方从自己关注列表删除，把自己从对方粉丝列表删除，如果是双向好友，把双方从自己的好友列表删除。如果是单向，把自己从对方的申请列表里删除
function RequestDelFriend(member,callback,caller)
    if not member:IsFriend() then TipsMgr.TipByKey("friend_delete_not_friend_limit_%s",member:GetRemark()); return end--“删除失败，对方不是你好友”
    if member:IsHusbandWife() then TipsMgr.TipByKey("friend_delete_husband_limit_%s",member:GetRemark()); return;end--你与玩家XXX是夫妻关系，需先解除该关系后才能删除好友。”
    if member:IsBrothers() then TipsMgr.TipByKey("friend_delete_brother_limit_%s",member:GetRemark()); return;end--你与玩家XXX是结拜关系，需先解除该关系后才能删除好友。”
    if (member:IsMaster() or member:IsApprentice()) then TipsMgr.TipByKey("friend_delete_master_limit_%s",member:GetRemark()); return;end--你与玩家XXX是师徒关系，需先解除该关系后才能删除好友。”
    if member:IsUnrequitedLover() then TipsMgr.TipByKey("friend_delete_love_limit_%s",member:GetRemark()); return;end--你与玩家XXX是暗恋关系，需先解除该关系后才能删除好友。”

    local function OnReceiveDelFriend(relationCode)
        ParseRelationship(member,relationCode);
        SocialNotifyMgr.NotifyFriendDeleteRelation(member:GetID(),relationCode);
        GameUtils.TryInvokeCallback(callback,caller);
    end
    local params = string.format("tpid=%s",member:GetID());
    SocialNetworkMgr.RequestAction("DelFriend",params,OnReceiveDelFriend);
end

--9.	取消关注（删除单向好友）：
-- 会把对方从自己关注列表删除，把自己从对方粉丝列表删除，如果是双向好友，把双方从自己的好友列表删除。如果是单向，把自己从对方的申请列表里删除
-- i.	action=DelFollow
-- ii.	tpid=好友id
function RequestDelFollow(member,callback,caller)
    local function OnReceiveDelFollow(relationCode)
        ParseRelationship(member,relationCode);
        if not member:IsFollow() then
            TipsMgr.TipByKey("friend_delete_follow_success");--删除成功后弹出提示【取消关注成功】
            member:ClearChatRecord();
        end
        GameUtils.TryInvokeCallback(callback,caller);
        SocialNotifyMgr.NotifyFriendDeleteRelation(member:GetID(),relationCode);
    end
    local params = string.format("tpid=%s",member:GetID());
    SocialNetworkMgr.RequestAction("DelFollow",params,OnReceiveDelFollow);
end

--10.	删除粉丝：
-- i.	action=DelFan
-- ii.	tpid=粉丝id
function RequestDelFan(fan,callback,caller)
    local function OnReceiveDelFan(relationCode)
        ParseRelationship(fan,relationCode);
        if not fan:IsFan() then
            TipsMgr.TipByKey("friend_delete_fan_success");--删除成功后弹出提示【移除粉丝成功】
            fan:ClearChatRecord();
        end
        GameUtils.TryInvokeCallback(callback,caller);
        SocialNotifyMgr.NotifyFriendDeleteRelation(fan:GetID(),relationCode);
    end

    local params = string.format("tpid=%s",fan:GetID());
    SocialNetworkMgr.RequestAction("DelFan",params,OnReceiveDelFan);
end

--11.	查询关注列表：
-- i.	action=AskFollowList
-- ii.	detailparams=玩家基本信息字段列表，按需求填写。具体字段请参照基本信息字段表。
-- iii.	usrdata_fields=玩家自定义信息字段列表，按需求填写。具体字段请参照自定义数据字段表。
-- iv.	start=开始索引
-- v.	cnt=查询数量
--{"5":{"nickname":"Run5","icon":"","icon_verify":0,"device_id":"213","playerid":5,"time":1530014903}}
function RequestAskFollowList(callback,caller)
    local function OnReceiveAskFollowList(data)
        for k,v in pairs(data) do
            v.playerid = tonumber(v.playerid);
            local roleID = v.playerid;
            local friend = FindMemberByID(roleID);
            friend:GetFriendAttr():SetGroup(mGroupFollow);
        end
        GameUtils.TryInvokeCallback(callback,caller);
    end
    local start = 0;
    local count = 500;
    local params = string.format("%s&start=%s&cnt=%s",mBasicFriendInfoParam,start,count);
    SocialNetworkMgr.RequestAction("AskFollowList",params,OnReceiveAskFollowList);
end

--12.	查询粉丝列表：
-- i.	action=AskFanList
-- ii.	detailparams=玩家基本信息字段列表，按需求填写。具体字段请参照基本信息字段表。
-- iii.	usrdata_fields=玩家自定义信息字段列表，按需求填写。具体字段请参照自定义数据字段表。
-- iv.	start=开始索引
-- v.	cnt=查询数量
--{"1":{"nickname":"dd","icon":"aaa.jpg","icon_verify":2,"device_id":"111","playerid":1,"time":1530014903}}
function RequestAskFanList(callback,caller)
    local function OnReceiveAskFanList(data)
        for k,v in pairs(data) do
            v.playerid = tonumber(v.playerid);
            local roleID = v.playerid;
            local friend = FindMemberByID(roleID);
            friend:GetFriendAttr():SetGroup(mGroupFan);
        end
        GameUtils.TryInvokeCallback(callback,caller);
    end
    local start = 0;
    local count = 500;
    local params = string.format("%s&start=%s&cnt=%s",mBasicFriendInfoParam,start,count);
    SocialNetworkMgr.RequestAction("AskFanList",params,OnReceiveAskFanList);
end

--13.	查询联系人分组列表：
-- i.	action=AskFriendGroupNames
--{"group0":"","group1":"","group2":"","group3":"ddd","group4":"dafd","group5":"","group6":"","group7":"","group8":"","group9":""}
function RequestInitGroupNames()
    local function OnReceiveAskFriendGroupNames(data,error)
        if data then
            for k,v in pairs(data) do
                local name = string.sub(k,1,5);
                if name == "group" then
                    k = tonumber(string.sub(k,6,-1));
                    mGroups[k]:SetName(v);
                end
            end
        end
        local firstGroupName = WordData.GetWordStringByKey("friend_group_friend_name");--联系人窗口，我的好友
        mGroups[0]:SetName(firstGroupName);--第一个分组默认为我的好友

        local followName = WordData.GetWordStringByKey("friend_group_follow_name");--联系人窗口，我的关注
        mGroupFollow:SetName(followName);

        local fanName = WordData.GetWordStringByKey("friend_group_fan_name");--联系人窗口，我的粉丝
        mGroupFan:SetName(fanName);

        local blackName = WordData.GetWordStringByKey("friend_group_black_name");--联系人窗口，黑名单
        mGroupBlack:SetName(blackName);

        mGroupStranger:SetName("Stranger");
    end
    --local data = {group0="g0",group1="g1",group2="g2",group3="ddd",group4="dafd",group5="g5",group6="g6",group7="g7",group8="g8",group9="g9"};
    --OnReceiveAskFriendGroupNames(data);
    local params = string.format("start=%s&cnt=%s",1,9);
    SocialNetworkMgr.RequestAction("AskFriendGroupNames",params,OnReceiveAskFriendGroupNames);
end

--14.	设置联系人分组名称：
-- i.	action=ModifyFriendGroupName
-- ii.	group_id=组id，从0到9
-- iii.	group_name=组名称
-- 40009	group_id不正确
function RequestModifyFriendGroupName(group,group_name,callback,caller)
    local function OnReceiveModifyFriendGroupName(data, error)
        group:SetName(group_name,true);
        GameUtils.TryInvokeCallback(callback,caller,data);
    end
    local params = string.format("group_id=%s&group_name=%s",group:GetID(),group_name);
    SocialNetworkMgr.RequestAction("ModifyFriendGroupName",params,OnReceiveModifyFriendGroupName);
end

--17.	将好友添加到联系人分组：
-- i.	action=SetFriend2Group 
-- ii.	tpid=好友id
-- iii.	group_id=组id，从0到9
--40009	group_id不正确	{"errcode":40009}  40005	不是好友关系	{"errcode":40005}
function RequestSetFriend2Group(member,targetGroup,callback,caller)
    local sourceGroup = member:GetFriendAttr():GetGroup();

    if targetGroup == sourceGroup then
        return;
    end
    local gid = sourceGroup:GetID();
    if gid >= 9 then 
        GameLog.LogError("Error Operation: Try to change group for non-friend player");
        return; 
    end

    local function OnReceiveSetFriend2Group(data, error)
        sourceGroup:RemoveMember(member);
        targetGroup:AddMember(member);      
    end
    local params = string.format("tpid=%s&group_id=%s",member:GetID(),targetGroup:GetID());
    SocialNetworkMgr.RequestAction("SetFriend2Group",params,OnReceiveSetFriend2Group);
end

--18.	批量将一个group的好友转移到另一个分组：
-- i.	action=SetFriend2Group 
-- ii.	tpid=好友id
-- iii.	group_id=组id，从0到9
--40009	group_id不正确	{"errcode":40009}  40005	不是好友关系	{"errcode":40005}
function RequestBatchSetFriends2Group(members,targetGroup,callback,caller)
    local ids = {};
    local sourceGroup = nil;
    for i, player in ipairs(members) do
        table.insert(ids, player:GetID());
        
        if not sourceGroup then 
            sourceGroup = player:GetFriendAttr():GetGroup(); 
        elseif sourceGroup ~= player:GetFriendAttr():GetGroup() then
            GameLog.LogError("Batch Set Friends Error");--批量设置的好友必须来自同一个group
            return;
        end
    end
    
    local function OnReceiveBatchSetFriend2Group(data, error)
        for i, player in ipairs(members) do
            Move2Group(player,targetGroup,true);
        end
        GameEvent.Trigger(EVT.FRIEND,EVT.FRIEND_REGROUP_MEMBERCOUNT,sourceGroup,targetGroup);
    end

    local params = string.format("tpid=%s&group_id=%s",table.concat(ids,","),targetGroup:GetID());
    SocialNetworkMgr.RequestAction("SetFriend2Group",params,OnReceiveBatchSetFriend2Group);
end

--19.	添加黑名单：
-- i.	action=AddBlackList
-- ii.	tpid=玩家id 
function RequestAddBlackList(member,callback,caller)
    if member:IsHusbandWife() then TipsMgr.TipByKey("friend_black_husband_limit_%s",member:GetRemark()); return;end--你与玩家XXX是夫妻关系，需先解除该关系后才能拉黑。”
    if member:IsBrothers() then TipsMgr.TipByKey("friend_black_brother_limit_%s",member:GetRemark()); return;end--你与玩家XXX是结拜关系，需先解除该关系后才能拉黑。”
    if (member:IsMaster() or member:IsApprentice()) then TipsMgr.TipByKey("friend_black_master_limit_%s",member:GetRemark()); return;end--你与玩家XXX是师徒关系，需先解除该关系后才能拉黑。”
    if member:IsUnrequitedLover() then TipsMgr.TipByKey("friend_black_love_limit_%s",member:GetRemark()); return;end--你与玩家XXX是暗恋关系，需先解除该关系后才能拉黑。”
    local function OnReceiveAddBlackList(data,error)
        Move2Group(member,mGroupBlack);
        member:ClearChatRecord();
        SocialNotifyMgr.NotifyAddInBlackList(member);
        GameUtils.TryInvokeCallback(callback,caller,data);    
        TipsMgr.TipByKey("friend_add_blacklist_success",member:GetRemark());--成功加入黑名单提醒
    end
    local params = string.format("tpid=%s",member:GetID());
    SocialNetworkMgr.RequestAction("AddBlackList",params,OnReceiveAddBlackList);
end

--20.	删除黑名单：
-- i.	action=DelBlackList
-- ii.	tpid=玩家id 
function RequestDelBlackList(member,callback,caller)
    local function OnReceiveDelBlackList(data, error)
        Move2Group(member,mGroupStranger);
        GameUtils.TryInvokeCallback(callback,caller,data);
        TipsMgr.TipByKey("friend_remove_blacklist_success",member:GetRemark());--成功移除黑名单提醒
    end
    local params = string.format("tpid=%s",member:GetID());
    SocialNetworkMgr.RequestAction("DelBlackList",params,OnReceiveDelBlackList);
end


--21.	获得黑名单：
-- i.	action=AskBlackList
-- ii.	detailparams=玩家基本信息字段列表，按需求填写。具体字段请参照基本信息字段表。
-- iii.	usrdata_fields=玩家自定义信息字段列表，按需求填写。具体字段请参照自定义数据字段表。
--{"2":{"nickname":"fdfd","icon":"aaa.jpg","icon_verify":2,"device_id":"222","playerid":2,"time":1530004759}}
function RequestAskBlackList(callback,caller)
    local function OnReceiveAskBlackList(data,error)
        for k,v in pairs(data) do
            local id = tonumber(k);
            local member = FindMemberByID(id);
            Move2Group(member,mGroupBlack,true);
        end
        GameUtils.TryInvokeCallback(callback,caller);
    end
    SocialNetworkMgr.RequestAction("AskBlackList",mBasicFriendInfoParam,OnReceiveAskBlackList);
end


--4.	修改好友备注：
--i.	action=ModifyGameFriendData
--ii.	fid=好友id ,int
--iii.	data=备注信息
--{"errcode":44003}与该id不存在好友关系
function RequestModifyGameFriendRemark(member, reName,callbak,caller)
    local function OnReceiveModifyGameFriendRemark(data)
        member:GetFriendAttr():SetRemark(reName);
        GameUtils.TryInvokeCallback(callback,caller);
        TipsMgr.TipByKey("friend_remark_sucess");--好友备注编辑成功
    end
    local params = string.format("tpid=%s&optype=%s&value=%s",member:GetID(), "remark",reName);
    SocialNetworkMgr.RequestAction("ModifyFriendDetail",params,OnReceiveModifyGameFriendRemark);
end

--==============================--
--desc:刪除好友group,此功能并没有显示支持，客户端通过把groupname改为""来标识group被删除，同时把已有的group的好友都移到group0当中
--time:2018-12-01 01:21:48
--@return 
--==============================-----
function RequestDeleteGroup(group,callback,caller)
    local friends = group:GetAllMembersWithBlack()
    for i,friend in ipairs(friends) do
        FriendMgr.RequestSetFriend2Group(friend, mGroups[0]);
    end
    FriendMgr.RequestModifyFriendGroupName(group,"",callback,caller)
end

--把好友从自定义组中移除，进入默认好友分组
function RequestMoveOutFromCustomGroup(member,callback,caller)
    FriendMgr.RequestSetFriend2Group(member, mGroups[0], callback,caller);
end

function RequestGetRelationship(player,callback, caller)
    local function OnGetRelationship(relationCode,error)
        ParseRelationship(player, relationCode);
        GameUtils.TryInvokeCallback(callback,caller,data);
    end
    if not player then return; end
    local params = string.format("tpid=%s",player:GetID());
    SocialNetworkMgr.RequestAction("GetRelation",params,OnGetRelationship);
end

-- iii.	config={"refuseAddFriend":"1","leaveStatus":"1","msg":"","autoClearFriends":"1"}
-- iv.	refuseAddFriend: 0未设置或设置为不拒绝 1设置为拒绝加陌生人好友
-- v.	leaveStatus: 0 未设置或设置为在线 1 设置为离开
-- vi.	msg:离开时的留言
-- vii.	autoClearFriends: 0未设置或设置为不自动清除好友 1 设置为自动清除好友
function RequestGetFriendSettings()
    local function OnGetFriendConfig(data)
        --mSettings = data;
        mSettings.refuseAddFriend = data.refuseAddFriend and tonumber(data.refuseAddFriend)==1 or false;
        mSettings.leaveStatus = data.leaveStatus and tonumber(data.leaveStatus)==1 or false;
        mSettings.msg = data.msg or "";
        mSettings.autoClearFriends = data.autoClearFriends and tonumber(data.autoClearFriends)==1 or false;
    end
    SocialNetworkMgr.RequestAction("GetFriendConfig",nil,OnGetFriendConfig);
end

function RequestSetFriendSettings()
    local settings = {};
    settings.refuseAddFriend = mSettings.refuseAddFriend and 1 or 0;
    settings.leaveStatus = mSettings.leaveStatus and 1 or 0;
    settings.msg = mSettings.msg or "";
    settings.autoClearFriends = mSettings.autoClearFriends and 1 or 0;

    local function OnSetFriendConfig(data)

    end
    local param = string.format("config=%s",JSON.encode(settings));
    SocialNetworkMgr.RequestAction("SetFriendConfig",param,OnSetFriendConfig);
end

return FriendMgr;