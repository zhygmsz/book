--sns - 自定义表情相关
--请求与数据初步处理

module("SNSCustomEmojiMgr", package.seeall)

local EmojiInfo = require("Logic/System/Chat/EmojiInfo")

local xpcall = xpcall
local traceback = traceback

--变量

--单品最火列表，每次请求数量
local mHotEmojiStep = 50
--单品最新列表，每次请求数量
local mTimeEmojiStep = 50
--系列最火列表，每次请求数量
local mHotPkgStep = 50
--系列最新列表，每次请求数量
local mTimePkgStep = 50

local function TipErrorCode(code)
end

--[[
    @desc: 获取到我添加的表情集合
]]
local function OnGetMyAddEmoji(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddEmoji2MyAddListByJson(info)
            end
        end
    end

    MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDEMOJI)
end

--[[
    @desc: 请求我添加的表情集合
]]
local function RequestMyAddEmoji()
    SocialNetworkMgr.RequestAction("GetEmoticonMyPicture",nil, OnGetMyAddEmoji);
end

--[[
    @desc: 获取到我收藏的表情集合
]]
local function OnGetMyCollectEmoji(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddEmoji2MyCollectListByJson(info)
            end
        end
    end

    MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYCOLLECTEMOJI)
end

--[[
    @desc: 请求我收藏的表情集合
]]
local function RequestMyCollectEmoji()

    local arg = {}
    table.insert(arg, "id=" .. UserData.PlayerID)
    table.insert(arg, "start=0")
    --sns服务器那边需要一个边界参数，可以设置的很大
    --收藏单品列表在玩法上也应该有上限，目前暂定100
    table.insert(arg, "cnt=100")
    SocialNetworkMgr.RequestAction("GetEmoticonPictureCollect",arg, OnGetMyCollectEmoji);
end

--[[
    @desc: 获取到我添加的系列集合
    --@jsonData: 
]]
local function OnGetMyAddPkg(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddPkg2MyAddListByJson(info)
                --测试，把我上传的系列，都存入我收藏的系列里，开展我收藏的系列功能
                CustomEmojiMgr.AddPkg2MyCollectListByJson(info)
            end
        end
    end

    --发送事件
    MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDPKG)
end

--[[
    @desc: 请求我添加的系列集合
]]
local function RequestMyAddPkg()
    SocialNetworkMgr.RequestAction("GetEmoticonMySerie",arg, OnGetMyAddPkg);
end

--[[
    @desc: 获取到我收藏的系列集合
]]
local function OnGetMyCollectPkg(jsonData)
    
end

--[[
    @desc: 请求我收藏的系列集合，sns未实现
]]
local function RequestMyCollectPkg()
    local arg = {}
    table.insert(arg, "id=" .. UserData.PlayerID)
    table.insert(arg, "start=0")
    --sns服务器那边需要一个边界参数，可以设置的很大
    --收藏单品列表在玩法上也应该有上限，目前暂定100
    table.insert(arg, "cnt=100")
    SocialNetworkMgr.RequestAction("xxx",arg, OnGetMyCollectEmoji);
end

--[[
    @desc: 获取到更多最火单品
]]
local function OnGetMoreHotEmoji(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddEmoji2HotListByJson(info)
            end
        end
        --发送获取到新数据事件
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMOREHOTEMOJI)
    end
end

--[[
    @desc: 获取到更多最新单品
]]
local function OnGetMoreTimeEmoji(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddEmoji2TimeListByJson(info)
            end
        end
        --发送获取到新数据事件
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMORETIMEEMOJI)
    end
end

local function OnGetMoreHotPkg(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddPkg2HotListByJson(info)
            end
        end
        --发送事件
    end
end

local function OnGetMoreTimePkg(jsonData)
    if jsonData then
        if type(jsonData.result) == "table" then
            for idx, info in ipairs(jsonData.result) do
                CustomEmojiMgr.AddPkg2TimeListByJson(info)
            end
        end
        --发送事件
    end
end

--[[
    @desc: 请求所有表情相关数据，并构建数据结构
]]
function InitSNS()
    RequestMyAddEmoji()
    RequestMyCollectEmoji()
    RequestMoreHotEmoji()
    RequestMoreTimeEmoji()

    RequestMyAddPkg()
    RequestMoreHotPkg()
    RequestMoreTimePkg()
end

--[[
    @desc: 请求添加表情
]]
function RequestAddEmoji(picId, url, name, callback, obj)
    --callback和obj注册到回调池，local方法写在外面
    local function OnAdd(jsonData)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, picId, url, name)
    end

    local arg = {}
    table.insert(arg, "pic_id=" .. picId)
    table.insert(arg, "path=" .. url)
    table.insert(arg, "name=" .. name)
    SocialNetworkMgr.RequestAction("AddEmoticonPicture",arg, OnAdd);
end

--[[
    @desc: 请求收藏表情
]]
function RequestCollectEmoji(picId, callback, obj)
    --先判断该表情是否已经在收藏列表里
    if CustomEmojiMgr.CheckExistInMyCollectEmojiList(picId) then
        TipsMgr.TipByFormat("该表情已经存在!")
        return
    end
    local function OnCollect(jsonData)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, picId)
    end

    local arg = "pic_id=" .. picId;
    SocialNetworkMgr.RequestAction("CollectEmoticonPicture",arg, OnCollect);
end

--[[
    @desc: 请求更多最火单品，每次请求固定数量
]]
function RequestMoreHotEmoji()

    local arg = {}
    --start的起始索引是从0开始
    table.insert(arg, "start=" .. CustomEmojiMgr.GetHotEmojiListCount())
    table.insert(arg, "cnt=" .. mHotEmojiStep)

    SocialNetworkMgr.RequestAction("GetEmoticonPictureHot",arg, OnGetMoreHotEmoji);
end

--[[
    @desc: 请求更多最新单品，每次请求固定数量
]]
function RequestMoreTimeEmoji()

    local arg = {}
    --start的起始索引是从0开始
    table.insert(arg, "start=" .. CustomEmojiMgr.GetTimeEmojiListCount())
    table.insert(arg, "cnt=" .. mTimeEmojiStep)

    SocialNetworkMgr.RequestAction("GetEmoticonPictureNew",arg, OnGetMoreTimeEmoji);
end

--[[
    @desc: 请求一个表情的详细信息
    --@picId:
	--@callback:
	--@obj: 
]]
function RequestOneEmojiInfo(picId, callback, obj)
    local function OnGet(jsonData)
        --缓存数据
        if jsonData then
            local emojiInfo = EmojiInfo.new()
            emojiInfo:InitByJson(jsonData.result)
            CustomEmojiMgr.AddEmoji2ChatMain(emojiInfo)
        end
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, picId)
    end

    local arg = "pic_id=" .. picId
    SocialNetworkMgr.RequestAction("GetEmoticonPicture",arg, OnGet);
end

--[[
    @desc: 举报一张表情图片
    --@picId:
	--@callback:
	--@obj: 
]]
function RequestReportEmoji(picId, callback, obj)
    local function OnReport(jsonData)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, picId)
    end

    local arg = "pic_id=" .. picId
    SocialNetworkMgr.RequestAction("ReportEmoticonPicture",arg, OnReport);
end

--[[
    @desc: 检测是否已经存在指定id的表情图
    --@picId: 
]]
function RequestCheckOneEmoji(picId, callback, obj)
    local function OnCheck(jsonData, errorCode)
        GameUtils.TryInvokeCallback(callback, obj, jsonData == nil)
    end

    local arg = "pic_id=" .. picId;
    SocialNetworkMgr.RequestAction("CheckEmoticonPicture",arg, OnCheck);
end

--------------------------------------------单品/系列分割线

--[[
    @desc: 请求添加一个表情系列
    @picInfo: json格式串
]]
function RequestAddPkg(name, desc, picInfo, callback, obj)
    local function OnAdd(jsonData, errorCode)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, jsonData ~= nil and jsonData.result.serie_id or -1)
    end

    local arg = {}
    table.insert(arg, "name=" .. name)
    table.insert(arg, "desc=" .. desc)
    table.insert(arg, "pic_info=" .. picInfo)
    SocialNetworkMgr.RequestAction("AddEmoticonSeries",arg, OnAdd);
end

--[[
    @desc: 请求一个系列包含的全部表情列表
    --@pkgId: 
]]
function RequestEmojiListByPkgId(pkgId, callback, obj)
    local function OnGet(jsonData)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, jsonData ~= nil and jsonData.result or -1)
    end
    local arg = "sid=" .. pkgId;
    SocialNetworkMgr.RequestAction("GetEmoticonSeriePicture",arg, OnGet);
end

--[[
    @desc: 请求更多最火系列，每次请求固定数量
]]
function RequestMoreHotPkg()
    local arg = {}
    --start的起始索引是从0开始
    table.insert(arg, "start=" .. CustomEmojiMgr.GetHotPkgListCount())
    table.insert(arg, "cnt=" .. mHotPkgStep)
    SocialNetworkMgr.RequestAction("GetEmoticonSerieHot",arg, OnGetMoreHotPkg);
end

--[[
    @desc: 请求更多最新系列，每次请求固定数量
]]
function RequestMoreTimePkg()
    local arg = {}
    --start的起始索引是从0开始
    table.insert(arg, "start=" .. CustomEmojiMgr.GetTimePkgListCount())
    table.insert(arg, "cnt=" .. mTimePkgStep)
    SocialNetworkMgr.RequestAction("GetEmoticonSerieNew",arg, OnGetMoreTimePkg);
end

--[[
    @desc: 请求收藏系列
]]
function RequestCollectPkg(pkgId, callback, obj)
    --先判断该表情是否已经在收藏列表里
    if CustomEmojiMgr.CheckExistInMyCollectPkgList(pkgId) then
        TipsMgr.TipByFormat("该系列已经存在!")
        return
    end
    local function OnCollect(jsonData)
        GameUtils.TryInvokeCallback(callback, obj, jsonData ~= nil, jsonData)
    end

    local arg = "sid=" .. pkgId;
    SocialNetworkMgr.RequestAction("CollectEmoticonSerie",arg, OnCollect);
end

return SNSCustomEmojiMgr
