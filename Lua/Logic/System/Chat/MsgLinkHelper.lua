module("MsgLinkHelper", package.seeall)

--变量
local mLinkCreateDic = {}
local mLinkOnClickDic = {}
local mHyperHelper = {};
local mSysMsgCreateDic = {}
local mSysMsgOnClickDic = {}
HYPER_ADD_FRIEND = 1;
HYPER_AUTOREPLY_STOP = 2;
--[[
    @desc: 填充物品超链接
    --@msgLink: 
    --@itemSlot: Bag_pb.BagItemSlot
    --@isLimitOnlyOne: 物品超链接在输入界面限制一个，但在历史界面没有限制
]]
local function FillItemLink(msgLink, itemSlot, isLimitOnlyOne)
    repeat
        if not itemSlot then
            break
        end
        local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
        if not itemData then
            break
        end
        msgLink.linkType = Chat_pb.ChatMsgLink.ITEM
        msgLink.isValid = true
        msgLink.isLimitOnlyOne = isLimitOnlyOne
        msgLink.isNeedAutoId = true
        local itemName = itemData.name
        --图文混排现在有bug，字符串内-不行
        itemName = string.gsub(itemName, "-", "")
        msgLink.content = itemName
        msgLink.linkDesc.textDesc.color = UIUtil.GetItemQualityColorStr(itemData.quality)
        --把显示所需数据序列化
        msgLink.byteParams:append(itemSlot:SerializeToString())
        msgLink.staticID = itemSlot.slotId
    until true
end

--[[
    @desc: 填充系统表情超链接
    --@msglink: 
    --@iconName: spriteName
	--@staticID: 静态id
]]
local function FillEmojiLink(msglink, iconName, staticID)
    repeat
        if not iconName or not staticID then
            break
        end
        msglink.linkType = Chat_pb.ChatMsgLink.EMOJI
        msglink.isValid = true
        msglink.isLimitOnlyOne = false
        msglink.isNeedAutoId = false
        msglink.content = iconName
        msglink.staticID = staticID
    until true
end

--[[
    @desc: 填充自定义表情超链接
    --@msgLink:
	--@picId: 表情id
]]
local function FillCustomEmojiLink(msgLink, picId)
    repeat
        if not picId then
            break
        end
        msgLink.linkType = Chat_pb.ChatMsgLink.EMOJI_CUSTOM
        msgLink.isValid = true
        --只存在于第一个Link
        if msgLink.strParams[1] then
            msgLink.strParams:set(1, picId)
        else
            msgLink.strParams:append(picId)
        end
    until true
end

--[[
    @desc: 
    --@playerId: 
]]
--[[
    @desc: 填充玩家信息超链接，目前只有玩家id，后续根据需求扩容
    --@msgLink:
	--@playerId:玩家id
	--@playerName: 
]]
local function FillPlayerInfoLink(msgLink, playerId, playerName)
    repeat
        msgLink.linkType = Chat_pb.ChatMsgLink.PLAYER
        msgLink.isValid = true
        msgLink.content = playerName
        msgLink.isLimitOnlyOne = false
        msgLink.isNeedAutoId = true
        --玩家名字暂定该颜色
        msgLink.linkDesc.textDesc.color = "[47e5e9]"
        msgLink.intParams:append(playerId) 

    until true
end

--[[
    @desc: 填充物品id超链接，仅适用于物品，不适合装备（因为装备有动态数据）
    该方法现在废弃
    --@msgLink:
	--@itemId: 
]]
local function FillItemIDLink(msgLink, itemId)
    repeat
        msgLink.linkType = Chat_pb.ChatMsgLink.ITEMID
        msgLink.isValid = true
        local itemData = ItemData.GetItemInfo(itemId)
        msgLink.content = itemData.name
        msgLink.linkDesc.textDesc.color = UIUtil.GetItemQualityColorStr(itemData.quality)
        msgLink.intParams:append(itemId)
    until true
end

local function FillVoiceLink(msgLink, url, len)
    repeat
        if not url then
            break
        end
        msgLink.linkType = Chat_pb.ChatMsgLink.VOICE
        msgLink.isValid = true
        --只存在于第一个link
        if msgLink.strParams[1] then
            msgLink.strParams:set(1, url)
        else
            msgLink.strParams:append(url)
        end
        --用第一个Int参数表示是否播放过该语音，控制红点显示逻辑
        --0表示没播放过，1表示播放过
        if msgLink.intParams[1] then
            msgLink.intParams:set(1, 0)
        else
            msgLink.intParams:append(0)
        end
        --用第二个Int参数表示语音长度
        if msgLink.intParams[2] then
            msgLink.intParams:set(2, len)
        else
            msgLink.intParams:append(len)
        end
    until true
end

local function OnClickItemLink(msgLink)
    if not msgLink then
        return
    end

    --可以考虑，把点击超链接的处理过程里创建出来的新对象，按超链接类型建立分类并缓存下来
    --针对聊天背后的数据，只解析一次，减少了table创建
    local itemSlot = Bag_pb.BagItemSlot()
    itemSlot:ParseFromString(msgLink.byteParams[1])
    --判断装备或物品
    local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
    if not itemData then
        return
    end
    if itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
        --装备
        EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromUseItem, itemSlot)
    else
        --物品
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, itemSlot.item.tempId)
    end
end

local function OnClickEmojiLink(msgLink)
    --不做处理
end

local function OnClickCustomEmojiLink(msgLink)
    GameLog.LogError("点击自定义表情")
end

local function OnClickPlayerInfoLink(msgLink)
    --根据玩家id，弹出通用界面
    local playerId = msgLink.intParams[1]
    UI_Shortcut_Player.ShowPlayerByID(playerId)
end

local function OnClickItemIDLink(msgLink)
    local itemId = msgLink.intParams[1]
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, itemId)
end

local function OnClickVoiceLink(msgLink)
    --点击播放语音代码不放在这，放在VoiceChatItem里
end

--点击超链接文本
local function OnClickHyperTextLink(msgLink)
    if not msgLink then
        return
    end

    local textType = msgLink.intParams[1];

    local hyperTexter = GetHyperHelper(textType);
    if not hyperTexter then
        GameLog.LogError("Not found hyperTexter by type %s",textType);
        return;
    end
    hyperTexter:OnClick(msgLink);
end

local function RegLink(fillFunc, onClickFunc, linkType)
    if linkType then
        mLinkCreateDic[linkType] = fillFunc
        mLinkOnClickDic[linkType] = onClickFunc
    end
end

local function RegHyper(hyperType,fileName)
    local file = require("Logic/System/Chat/HyperText/"..fileName);
    mHyperHelper[hyperType] = file.new();
end

function InitModule()
    RegLink(FillItemLink, OnClickItemLink, Chat_pb.ChatMsgLink.ITEM)
    RegLink(FillEmojiLink, OnClickEmojiLink, Chat_pb.ChatMsgLink.EMOJI)
    RegLink(FillCustomEmojiLink, OnClickCustomEmojiLink, Chat_pb.ChatMsgLink.EMOJI_CUSTOM)
    RegLink(FillPlayerInfoLink, OnClickPlayerInfoLink, Chat_pb.ChatMsgLink.PLAYER)
    RegLink(FillItemIDLink, OnClickItemIDLink, Chat_pb.ChatMsgLink.ITEMID)
    RegLink(FillVoiceLink, OnClickVoiceLink, Chat_pb.ChatMsgLink.VOICE)
    RegLink(nil, OnClickHyperTextLink, Chat_pb.ChatMsgLink.HYPER_TEXT)

    --注册文本超链接处理类型
    RegHyper(HYPER_ADD_FRIEND,"ChatHyperHeplerAddFriend");
    RegHyper(HYPER_AUTOREPLY_STOP, "ChatHyperOfflineAutoReply");
end

--[[
    @desc: 填充Chat_pb.ChatMsgLink
    --@linkType:
	--@args: 
]]
function FillMsgLink(linkType, ...)
    if linkType then
        local linkFill = mLinkCreateDic[linkType]
        if linkFill then
            return linkFill(...)
        end
    end
end

--[[
    @desc: 链接文本点击回调
    --@msgLink: 
]]
function OnClick(msgLink)
    if msgLink then
        local linkOnClick = mLinkOnClickDic[msgLink.linkType]
        if linkOnClick then
            linkOnClick(msgLink)
        end
    end
end

--[[
    @desc: 检测，该消息是否是自定义表情消息
    自定义表情消息单独发送，有且仅有一个link，并且linktype为EMOJI_CUSTOM
    --@msgCommon: 
]]
function CheckIsCustomEmoji(msgCommon)
    if msgCommon then
        local link = msgCommon.links[1]
        return link and link.linkType == Chat_pb.ChatMsgLink.EMOJI_CUSTOM
    else
        return false
    end
end

--[[
    @desc: 检测，该消息是否是聊天语音消息
    聊天语音消息，内部只有一个link，并且linkType为VOICE
    --@msgCommon: 
]]
function CheckIsChatVoice(msgCommon)
    if msgCommon then
        local link = msgCommon.links[1]
        return link and link.linkType == Chat_pb.ChatMsgLink.VOICE
    else
        return false
    end
end

--[[
    @desc: 返回该自定义表情消息的picId
    --@msgCommon: 
]]
function GetPicIdByCustomEmojiMsg(msgCommon)
    if msgCommon then
        return msgCommon.links[1].strParams[1]
    else
        return -1
    end
end

function GetHyperHelper(hyperType)
    return mHyperHelper[hyperType];
end

return MsgLinkHelper