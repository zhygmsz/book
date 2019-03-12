--[[
    des:所有的社交玩家信息管理
    author:{hesinian}
    time:2019-01-21 19:42:14
]]
module("SocialPlayerMgr", package.seeall)

local SocialPlayer = require("Logic/System/SocialNetwork/Entity/SocialPlayer");
local SocialPlayerSelf = require("Logic/System/SocialNetwork/Entity/SocialPlayerSelf");

local mID_PlayerTable = {};
local mSelfPlayer;

local function InitSelf()
    mSelfPlayer = SocialPlayerSelf.new();
    mID_PlayerTable[UserData.PlayerID] = mSelfPlayer;
end

local function OnClickEntity(tapEntity)
    if tapEntity:IsNPC() then
        --OpenFriendShortcut(entityID,true);
    elseif tapEntity:IsPlayer() and not tapEntity:IsSelf() then 
        local player = SocialPlayerMgr.FindMemberByID(tapEntity:GetID());
        local normalAttr = player:GetNormalAttr();
        normalAttr:SetName(tapEntity:GetName());
        normalAttr:SetRacialProfess(tapEntity:GetPropertyComponent():GetRacialProfess());
        UI_Shortcut_Player.ShowPlayer(player);
    end
end

local function OnOnOffline(id, status)

    status = (tonumber(status) == 0) and true or false;--0在线，1离线
    local player = FindMemberByID(tonumber(id));
    player:GetVolatileAttr():SetOnline(status);

end

function InitModule()
    require("Logic/System/SocialNetwork/PlayerMgr/SocialPlayerMgr_Self");
end

function InitSNS()
    InitSelf();
    GameEvent.Reg(EVT.COMMON,EVT.CLICK_ENTITY,OnClickEntity);
    GameEvent.Reg(EVT.CHAT,EVT.FRIEND_ONLINE_OFFLINE, OnOnOffline);
end

--查找或者创建关系数据，playid, 创建时需要的玩家数据
function FindMemberByID(pid)
    pid = tonumber(pid);
    if not mID_PlayerTable[pid] then
        local player = SocialPlayer.new(pid);
        mID_PlayerTable[pid] = player;
        GameLog.Log("--------Create a Social Stranger ID=%s",pid);
    end
    return mID_PlayerTable[pid];
end

function GetSelf()
    return mSelfPlayer;
end

--同步多个玩家的易变属性
function RequestSyncAllPlayers()
    local function OnSyncMultiPlayers(data)
        for _, item in pairs(data) do
            local pid = tonumber(item.playerid);
            local player = FindMemberByID(pid);
            player:GetVolatileAttr():Refresh(item);
        end
        GameEvent.Trigger(EVT.SOCIAL,EVT.ALL_PLAYERS_VOLATILE_ATTRS);
    end

    local ids = {};
    for i,player in pairs(mID_PlayerTable) do
        local volatileAttr = player:GetVolatileAttr();
        if volatileAttr:NeedSync() then
            table.insert(ids,player:GetID());
            volatileAttr:RefreshTime();
        end
    end
    if #ids == 0 then return; end
    ids = table.concat(ids,",");

    local params = string.format("ids=%s&%s",ids,mBasicFriendInfoParam);
    
    SocialNetworkMgr.RequestAskMultiPlayerIndex("AskMultiPlayerIndex",params,OnSyncMultiPlayers);
end

--18.	批量查询好友关系信息（亲密度等）：
-- i.	action=AskFriendDetail
-- ii.	ids=好友id列表，用逗号隔开，例如：1,3,7
--[{"group_id":"0","intimacy":"0","heat":"0","heat_mtime":"0","tpid":"1"}]
function RequestAskFriendDetails()
    local function OnSyncMultiPlayers(data)
        for _, item in ipairs(data) do
            local pid = tonumber(item.tpid);
            local player = FindMemberByID(pid);
            player:GetFriendAttr():Refresh(item);
        end
        GameEvent.Trigger(EVT.SOCIAL,EVT.ALL_PLAYERS_FRIEND_ATTRS);
    end

    local ids = {};
    for i,player in pairs(mID_PlayerTable) do
        local friendAttr = player:GetFriendAttr();
        if player:IsFriend() and friendAttr:NeedSync() then
            table.insert(ids,player:GetID());
            friendAttr:RefreshTime();
        end
    end
    if #ids == 0 then return; end
    ids = table.concat(ids,",");
    
    local params = string.format("ids=%s",table.concat(ids,','));
    SocialNetworkMgr.RequestAction("AskFriendDetail",params,OnSyncMultiPlayers);
end

return SocialPlayerMgr;