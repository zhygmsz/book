module("FriendAskMgr",package.seeall);

local mBasicFriendInfoParam = "detailparams=playerid&usrdata_fields=level";
local SocialPlayerInfo = require("Logic/System/Social/SocialPlayerInfo");
local mAskTable = {};

--在线的排在后面，越新的排在后面
local function SortFunc(a,b)
    if (a.player:IsOnline() == b.player:IsOnline()) then return a.time<b.time; end
    return (not a.player:IsOnline());
end

local function FindOrCreateItem(player)
    for i,item in ipairs(mAskTable) do
        if item.player == player then
            return item;
        end
    end
    local newItem = {player = player, source = "Friend Source"};
    table.insert(mAskTable,newItem);
    return newItem;
end

function InitSNS()
    RequestFriendAskList();
end

function GetAskList()
    table.sort(mAskTable,SortFunc);
    return mAskTable;
end

--当有新的申请者时，不刷新UI，如果需要红点提示
function OnNewFriendAsk(player)
    if player:IsInBlackList() then return; end
    local item = FindOrCreateItem(player);
    item.time = TimeUtils.SystemTimeStamp(true);
    GameEvent.Trigger(EVT.FRIENDASK,EVT.FRIENDASK_NEW_APPLIER,player);
end


--3. 查询好友申请列表
--{"3":{"playerid":3,"device_id":"333","time":1524650220}}
function RequestFriendAskList(callback,caller)
    local function OnReceiveFriendAskList(data)
        GameLog.Log("ApplyList ：",tostring(data));

        mAskTable = {};
        if data then
            for k,v in pairs(data) do
                local pid = v.playerid;
                local player = SocialPlayerMgr.FindMemberByID(pid);
                if (not player:IsInBlackList()) then
                    table.insert(mAskTable, {time = tonumber(v.time),player = player,source = "Friend Source"});
                end
            end
        end
        GameUtils.TryInvokeCallback(callback,caller);
        GameEvent.Trigger(EVT.FRIENDASK,EVT.FRIENDASK_INIT_INFO);
    end
    local params = {"optype=detail",mBasicFriendInfoParam};
    SocialNetworkMgr.RequestAction("GetAskAddFriendList",params,OnReceiveFriendAskList);
end

--4.	获得未读的好友申请数量
function RequestGetAskAddFriendListCount(callback)
    local function OnReceiveAskAddFriendListCount(data,error)
        GameLog.Log("GetAskAddFriendList Count %d ",data);
        mFriendAskData.count = tonumber(data);
        if callback then callback(data); end
    end
    local params = "optype=count";
    SocialNetworkMgr.RequestAction("GetAskAddFriendList",params,OnReceiveAskAddFriendListCount);
end

--5.	处理好友申请：
function RequestReplyAskAddFriend(callback, item, agree)
    local pid = item.player:GetID();
    local intAgree = agree and 1 or 0;
    local function OnReceiveReplyAskAddFriend(data,error)
        if agree then
            --FriendMgr.RequestAllFriendData();
            --成功代表已经是好友关系
            
            SocialNotifyMgr.NotifyFriendAgree(pid);
        else
            local nickname = item.player:GetNickName();
            TipsMgr.TipByKey("friend_topmsg_005",nickname);--拒绝好友申请后的提示
        end
        mAskTable[pid] = nil;
        GameEvent.Trigger(EVT.FRIENDASK,EVT.FRIENDASK_ITEM_PROCESSED,item);
        if callback then callback(); end
    end
    local params = string.format("tpid=%s&agree=%s",pid,intAgree);
    SocialNetworkMgr.RequestAction("ReplyAskAddFriend",params,OnReceiveReplyAskAddFriend);
end


--6.	批量处理好友申请：
--[17,16,15]
function RequestBatchReplyAskAddFriend(agree)
    local function OnReceiveBatchReplyAskAddFriend(data,error)
        if not agree then
            TipsMgr.TipByKey("friend_topmsg_006");--批量拒绝好友申请好的提示
        end
        if agree then
            FriendMgr.RequestAllFriendData();
            for i,pid in ipairs(data) do
                SocialNotifyMgr.NotifyFriendAgree(pid);
            end
        end
        mAskTable = table.emptyTable;
        GameEvent.Trigger(EVT.FRIENDASK,EVT.FRIENDASK_BATCH_PROCESSED);
    end
    agree = agree and 1 or 0;
    local params = string.format("tpid=%s&agree=%s",-1,agree);
    SocialNetworkMgr.RequestAction("ReplyAskAddFriend",params,OnReceiveBatchReplyAskAddFriend);
end

