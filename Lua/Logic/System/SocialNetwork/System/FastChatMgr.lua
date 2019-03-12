--[[
    快捷聊天管理
    author:{hesinian}
    time:2019-01-28 20:33:45
]]

module("FastChatMgr",package.seeall)
local mFastChatterTable = {};

local function OnDeleteFriend(friend)
    for i=1,GetFastChatterLimit() do
        if GetFastChatter(i) == friend then
            SetFastChatter(i,nil);
        end
    end
end

-------快捷聊天
local function GetAvailableFastSlot()
    for i = 1,GetFastChatterLimit() do
        local friend = GetFastChatter(i);
        if not friend then return i; end
    end
end
local function GetSlotByFriend(friend)
    for i=1,GetFastChatterLimit() do
        if GetFastChatter(i) == friend then
            return i;
        end
    end
end

function InitSNS()
    GameEvent.Reg(EVT.FRIEND, EVT.FRIEND_DELETE_FRIEND,OnDeleteFriend);
end

function GetFastChatterLimit()
    return ConfigData.GetIntValue("friend_fast_chat_count_limit") or 4;--快捷聊天好友数量限制 
end

function GetFastChatter(index)

    if mFastChatterTable[index] then
        return mFastChatterTable[index]; 
    end
    local id = UserData.GetFastChatterID(index);
    local friend = id and SocialPlayerMgr.FindMemberByID(id) or nil;
    if friend and (not friend:IsFriend()) then--如果已经不是好友关系了，解除快捷聊天
        UserData.SetFastChatterID(index,nil);
        friend = nil;
    end
    mFastChatterTable[index] = friend;
    return friend;
end

function SetFastChatter(targetIndex,friend)
    local sourceIndex = friend and GetSlotByFriend(friend);
    local replacePlayer = targetIndex and mFastChatterTable[targetIndex];

    mFastChatterTable[targetIndex] = friend;
    UserData.SetFastChatterID(targetIndex,friend and friend:GetID());
    GameEvent.Trigger(EVT.FRIEND,EVT.FAST_CHAT_CHANGE,targetIndex);

    if sourceIndex then
        UserData.SetFastChatterID(sourceIndex,replacePlayer and replacePlayer:GetID() or nil);
        mFastChatterTable[sourceIndex] = replacePlayer;
        GameEvent.Trigger(EVT.FRIEND,EVT.FAST_CHAT_CHANGE,sourceIndex);
    end
end

function IsInFastChat(friend)
    return GetSlotByFriend(friend) ~= nil;
end
function RemoveFastChatter(friend)
    local slot = GetSlotByFriend(friend);
    if slot then
        SetFastChatter(slot,nil);
    end
end

function AddFastChatter(friend)
    if not friend:IsFriend() then return; end
    local targetIndex = GetAvailableFastSlot();
    if not targetIndex then TipsMgr.TipByKey("friend_fast_chat_unavailable"); return; end --"快捷聊天已满无法添加"

    mFastChatterTable[targetIndex] = friend;
    UserData.SetFastChatterID(targetIndex,friend:GetID());
    GameEvent.Trigger(EVT.FRIEND,EVT.FAST_CHAT_CHANGE,targetIndex);
end

return FastChatMgr;