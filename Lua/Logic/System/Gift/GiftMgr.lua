module("GiftMgr",package.seeall);
local mInited = false;

local mGiftList = {};
local mGiftByItem = {};
local mCoverCards = {};
local mCoverEnvelope = {};
local mSelectedFriend;

local mReceiveRecords ={};
local mSendRecords = {};

local function SelectItems(tableList, condition)
    local list = {};
    for _, value in ipairs(tableList) do
        local flag,re = xpcall(condition,traceback, value);
        if (not flag) then GameLog.LogError(re); end
        if re then
            table.insert(list,value);
        end
    end
    return list;
end

local function SelectGift(funcName)
    local condition = function(gift)
        return gift[funcName](gift);
    end
    return SelectItems(mGiftList, condition);
end

function InitModule()
    --require("Logic/System/Gift/GiftFreeMgr");
end

function Init()
    if mInited then return; end
    mInited = true;

    local giftClass = {};
    giftClass[1] = require("Logic/System/Gift/GiftItem/GiftItemBase");--免费
    giftClass[2] = require("Logic/System/Gift/GiftItem/GiftItemBase");--付费
    local allGifts = GiftData.GetAllGifts();
    for i,g in ipairs(allGifts) do
        local gift = giftClass[g.costType].new(g);
        mGiftList[#mGiftList + 1] = gift;
        local tid = gift:GetItemID();
        mGiftByItem[tid] = gift;
    end

    --local allCovers = GiftData.GetAllCovers();
    local allCovers = {};
    for i=1,10 do
        local item = {};
        item.isCard = true;
        item.id = i;
        item.iconName = "icon_zengsong_heka_01";
        table.insert(allCovers,item);
    end
    for i,cover in ipairs(allCovers) do
        if cover.isCard then
            table.insert(mCoverCards,cover);
        else
            table.insert(mCoverEnvelope,cover);
        end
    end
end

function GetAllFreeGifts()
    return SelectGift("IsFree");
end

function GetAllCostGifts()
    return SelectGift("IsCost");
end

function GetAllCustomGifts()
    return SelectGift("IsCustom");
end

function GetAllMemorialGifts()
    return SelectGift("IsMemorial");
end

function GetGiftByItem(tid)
    return mGiftByItem[tid];
end

function GetCategoryName(cid)
    return WordData.GetWordStringByKey("gift_cname_"..tostring(cid));
end

local function FriendSort(friend1,friend2)
    return friend1:GetIntimacy() > friend2:GetIntimacy();
end

local function NormalFriendCondition(member)
    if not member:IsFriend() then 
        return false;
    end
    local level = member:GetLevel();
    if level < (ConfigData.GetIntValue("gift_friend_level_limit") or 0) then
        return false;
    end
    return true;
end
--纪念日条件
local function MemorialFriendCondition(member)
    return NormalFriendCondition(member) and true;--
end

function GetAllFriendsOrderByIntimacy()
    local friends = FriendMgr.GetMembersWithCondition(NormalFriendCondition);
    table.sort(friends,FriendSort);
    return friends;
end

function GetFriendsForMemorial()
    local friends = FriendMgr.GetMembersWithCondition(MemorialFriendCondition);
    table.sort(friends,FriendSort);
    return friends;
end

function GetAllCoverCards()
    return mCoverCards;
end

--拥有的货币
function GetFortuneHave()
    return 10000;
end

function GetCostValueLimit()
    return 100;
end

function GetCostValueSent()
    return 10;
end

function GetFreeCountLimit()
    return 5;
end

function GetFreeCountSent()
    return 2;
end
--ret data need more info about witch type
function OnSCGiveGiftsRet(data)
    if data.ret == 0 then
        TipsMgr.TipByFormat("gift_send_success");
        GameEvent.Trigger(EVT.PACKAGE,EVT.GIFT_SEND_SUCCESS);
    end
end

function GetGiftSendRecord()
    return mSendRecords;
end

function DeleteSendRecord(record)
    for i,item in ipairs(mSendRecords) do
        if record == item then
            table.remove(mSendRecords,i);
        end
    end
    GameEvent.Trigger(EVT.GIFT,EVT.GIFT_SEND_RECORD_CHANGE);
end

function GetGiftReceiveRecord()
    return mReceiveRecords;
end

function DeleteReceiveRecord(record)
    for i,item in ipairs(mReceiveRecords) do
        if record == item then
            table.remove(mReceiveRecords,i);
        end
    end
    GameEvent.Trigger(EVT.GIFT,EVT.GIFT_RECEIVE_RECORD_CHANGE);
end

function RequestCSGiveGifts(giftInfo)

    local friend = giftInfo.friend;
    local itemTable = giftInfo.giftCountTable;
    local gType = giftInfo.gType;
    local content = giftInfo.text;
    local coverID = giftInfo.cover;
    local draw = giftInfo.draw;
    local texture = giftInfo.texture;

    if giftInfo.friends then
        TipsMgr.TipByFormat("多人送礼等待服务器");
        return;
    end
    if (giftInfo.friend == nil and giftInfo.friends == nil) then
        GameLog.LogError("None Friend Selected");
        return;
    end
    local isHorn = false;
    local affixItems = {};
    for gift,count in pairs(itemTable) do
        if count > 0 then
            local info = Friend_pb.GiftInfos();
            info.itemID = gift:GetID();
            info.itemNum = count;
            table.insert(affixItems,info);
            isHorn = isHorn and gift:IsWithHorn();
        end
    end
    if #affixItems ==0 then
        TipsMgr.TipByFormat("gift_select_none_item");
        return;
    end
        
    local function SendGift()
        local msg = NetCS_pb.CSGiveGifts();
        msg.friendID = friend:GetID();
        msg.giftType = gType;
        msg.customs.custom1 = coverID or 1;--包装信纸ID
        msg.contexts.context = content;--祝福语
        msg.affixItem:ParseFrom(affixItems);

        GameNet.SendToGate(msg)
        GameLog.LogProto(msg)
    end
    --您赠送了喇叭礼物，赠言将向全服广播，当前赠言内容为空，是否继续赠送?取消/赠送
    if isHorn and content == "" then
        TipsMgr.TipConfirmByKey("Gift_bless_none_notice",SendGift,nil);
    else
        SendGift();
    end
        
end

return GiftMgr;