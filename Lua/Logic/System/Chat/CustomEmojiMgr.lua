module("CustomEmojiMgr", package.seeall)

local EmojiInfo = require("Logic/System/Chat/EmojiInfo")
local PkgInfo = require("Logic/System/Chat/PkgInfo")

--我添加的表情，包括有名字和没名字
local mMyAddEmojiList = {}
--我添加的表情，只是带有名字的，用于显示在表情库 - 我的单品分页里
local mMyAddEmojiListWithName = {}

--我添加的系列
local mMyAddPkgList = {}

--我收藏的表情包 - 自定义表情界面
local mMyCollectPkgForCustom = {}
--我收藏的表情包 - 收藏管理界面
local mMyCollectPkgForCollect = {}
--自定义表情包内，每分页包数量
local mCustomPkgNumPerPage = 13
--添加界面内，每分页表情包数量
local mCollectPkgNumPerPage = 18

--加载到内存的表情图片最大尺寸不超过256，防止表情原图过大，算是加一层过滤
local mEmojiSize = {compressRatio = 100, width = 256, height = 256}
local mPkgSize = {compressRatio = 100, width = 88, height = 88}
--从原图到表情图，压缩参数
local mTakeSize = {compressRatio = 70, width = 256, height = 256}

--我收藏的单品 - 自定义表情界面
local mMyCollectEmojiForCustom = {}
--我收藏的单品 - 收藏管理界面
local mMyCollectEmojiForCollect = {}
--自定义表情内，每分页表情数量
local mCustomEmojiNumPerPage = 14
--收藏界面内，每分页表情数量
local mCollectEmojiNumPerPage = 18

local mAddEmojiDes = "上传表情单品"
local mAddSerieDes = "上传表情系列"

--表情库界面打开时，选中的页签
local mEmojiLibraryOpenIdx = { rightIdx = 1, topIdx = 1 }

--收藏界面打开时，选中的页签
local mMyCollectOpenIdx = 1

--界面关闭时需要执行的回调信息，按需往里注册，生效一次，自动清理
local mInvokeDataOnClose = {}

--UIEmojiInfo界面当前数据
local mShowingEmojiInfo =nil

--UIPkgInfo界面当前数据，可能是pkgId，也可能是pkgInfo
local mShowingPkgInfoData = nil

--单品库，最火列表
local mHotEmojiList = {}
--单品库，最新列表
local mTimeEmojiList = {}

--系列库，最火列表
local mHotPkgList = {}
--系列库，最新列表
local mTimePkgList = {}

--来自聊天框内的EmojiInfo字典
local mEmojiForChatMain = {}

--表情操作列表功能按钮集合
local mChatAddBtnList = 
{
    [1] = { id = 1, name = "拍摄" },
    [2] = { id = 2, name = "相册" },
    [3] = { id = 3, name = "表情库" },
    [4] = { id = 4, name = "表情包" },

}

ChatAddBtnType = {}
ChatAddBtnType.None = -1
ChatAddBtnType.AddEmoji = 1
ChatAddBtnType.AddPkg = 2

local mChatAddBtnDataDic = 
{
    [ChatAddBtnType.AddEmoji] = { 1, 2, 3 },
    [ChatAddBtnType.AddPkg] = { 2, 4 },
}

--添加表情系列界面，上次未完成表情集合
local mAddingPkgInfoList = {}
local mAddingPkgInfoName = { name = "", des = "" }

--单品 - 我的收藏辅助界面数据，回调和可选择剩余数量
local mMyCollectHelpData = { func = nil, remainedNum = 0 }

--local方法
--[[
    @desc: 通用方法，判断list内是否存在picId的表情
]]
local function CheckExistInEmojiListByPicId(list, picId)
    local existIdx = nil
    local existInfo = nil
    for idx, info in ipairs(list) do
        --循环内调用方法，可以直接info._xxx，省去一步方法的查询工作
        --也许可以作为CPU优化的点
        if info:GetPicId() == picId then
            existIdx = idx
            existInfo = info
            break
        end
    end
    return existIdx, existInfo
end

--[[
    @desc: 通用方法，判断list内是否存在pkgId的系列
]]
local function CheckExistInPkgListByPkgId(list, pkgId)
    local existIdx = nil
    local existInfo = nil
    for idx, info in ipairs(list) do
        --循环内调用方法，可以直接info._xxx，省去一步方法的查询工作
        --也许可以作为CPU优化的点
        if info:GetPkgId() == pkgId then
            existIdx = idx
            existInfo = info
            break
        end
    end
    return existIdx, existInfo
end

local function DoAddEmoji2MyAddList(emojiInfo, sendMsg)
    local existIdx, _ = CheckExistInEmojiListByPicId(mMyAddEmojiList, emojiInfo:GetPicId())
    --上传单品可以从我收藏的界面里选择，本质上是我上传的未命名的单品
    --所以有覆盖逻辑
    if existIdx then
        mMyAddEmojiList[existIdx] = emojiInfo
    else
        table.insert(mMyAddEmojiList, emojiInfo)
    end

    if emojiInfo:GetName() ~= "" then
        table.insert(mMyAddEmojiListWithName, emojiInfo)
        if sendMsg then
            MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEEMOJIWITHNAME)
        end
    end
end

local function DoAddEmoji2MyCollectList(emojiInfo, sendMsg)
    table.insert(mMyCollectEmojiForCustom, emojiInfo)
    table.insert(mMyCollectEmojiForCollect, #mMyCollectEmojiForCollect, emojiInfo)

    if sendMsg then
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_COLLECTONEEMOJI)
    end
end

local function DoAddPkg2MyAddList(pkgInfo, sendMsg)
    table.insert(mMyAddPkgList, pkgInfo)

    if sendMsg then
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEPKG)
    end
end

local function DoAddPkg2MyCollectList(pkgInfo, sendMsg)
    table.insert(mMyCollectPkgForCustom, pkgInfo)
    table.insert(mMyCollectPkgForCollect, #mMyCollectPkgForCollect, pkgInfo)

    if sendMsg then
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_COLLECTONEPKG)
    end
end

local function InitMyAddEmojiListWithName()
    local emojiInfo = EmojiInfo.new()
    emojiInfo:SetAdd(true)
    table.insert(mMyAddEmojiListWithName, emojiInfo)
end

local function InitMyAddPkgList()
    local pkgInfo = PkgInfo.new()
    pkgInfo:SetAdd(true)
    table.insert(mMyAddPkgList, pkgInfo)
end

local function InitMyCollectEmojiList()
    local emojiInfo = EmojiInfo.new()
    emojiInfo:SetAdd(true)
    table.insert(mMyCollectEmojiForCustom, emojiInfo)
    table.insert(mMyCollectEmojiForCollect, emojiInfo)
end

local function InitMyCollectPkgList()
    local pkgInfo = PkgInfo.new()
    pkgInfo:SetAdd(true)
    table.insert(mMyCollectPkgForCustom, pkgInfo)
    table.insert(mMyCollectPkgForCollect, pkgInfo)
end

local function InitData()
    InitMyAddEmojiListWithName()
    InitMyCollectEmojiList()

    InitMyAddPkgList()
    InitMyCollectPkgList()
end

function Init()
    InitData()
end

function GetMyCollectEmojiListForCustom()
    return mMyCollectEmojiForCustom
end

function GetMyCollectEmojiListForCollect()
    return mMyCollectEmojiForCollect
end

function GetMyCollectPkgListForCustom()
    return mMyCollectPkgForCustom
end

function GetMyCollectPkgListForCollect()
    return mMyCollectPkgForCollect
end

function GetMyAddEmojiList()
    return mMyAddEmojiList
end

function GetMyAddEmojiListWithName()
    return mMyAddEmojiListWithName
end

--[[
    @desc: 查看表情是否在我的单品收藏列表里
]]
function CheckExistInMyCollectEmojiList(picId)
    local existIdx, _ = CheckExistInEmojiListByPicId(mMyCollectEmojiForCustom, picId)
    return existIdx ~= nil
end

function GetCustomEmojiNumPerPage()
    return mCustomEmojiNumPerPage
end

function GetCollectEmojiNumPerPage()
    return mCollectEmojiNumPerPage
end

function GetCustomPkgNumPerPage()
    return mCustomPkgNumPerPage
end

function GetCollectPkgNumPerPage()
    return mCollectPkgNumPerPage
end

--[[
    @desc: 查看系列是否在我的系列收藏列表里
    --@pkgId: 
]]
function CheckExistInMyCollectPkgList(pkgId)
    local existIdx, _ = CheckExistInPkgListByPkgId(mMyCollectPkgForCustom, pkgId)
    return existIdx ~= nil
end

function GetEmojiSize()
    return mEmojiSize
end

function GetPkgSize()
    return mPkgSize
end

function GetTakeSize()
    return mTakeSize
end

function AddEmoji2MyAddListByJson(json)
    local emojiInfo = EmojiInfo.new()
    emojiInfo:InitByJson(json)
    DoAddEmoji2MyAddList(emojiInfo, false)
end

function AddEmoji2MyAddListByPicId(picId, url, name)
    local emojiInfo = EmojiInfo.new()
    --新创建的EmojiInfo，其playerid自行填充
    emojiInfo:InitByPicId(picId, url, name, UserData.PlayerID)
    DoAddEmoji2MyAddList(emojiInfo, true)
end

function AddEmoji2MyCollectListByJson(json)
    local emojiInfo = EmojiInfo.new()
    emojiInfo:InitByJson(json)
    DoAddEmoji2MyCollectList(emojiInfo, false)
end

--[[
    @desc: 该方法只允许在收藏请求的返回里调用
    
]]
function AddEmoji2MyCollectListByPicId(picId)
    --该picId一定在mMyAddEmojiList里
    local _, existInfo = CheckExistInEmojiListByPicId(mMyAddEmojiList, picId)
    if existInfo then
        DoAddEmoji2MyCollectList(existInfo, true)
    else
        GameLog.LogError("CustomEmojiMgr.AddEmoji2MyCollectListByPicId -> existInfo is nil, picId = %s", picId)
    end
end

function AddEmoji2MyCollectListByEmojiInfo(emojiInfo)
    DoAddEmoji2MyCollectList(emojiInfo, true)
end

function AddPkg2MyCollectListByJson(json)
    local pkgInfo = PkgInfo.new()
    pkgInfo:InitByJson(json)
    DoAddPkg2MyCollectList(pkgInfo, false)
end

function AddPkg2MyCollectListByPkgInfo(pkgInfo)
    DoAddPkg2MyCollectList(pkgInfo, true)
end

function GetAddEmojiDes()
    return mAddEmojiDes
end

function GetAddSerieDes()
    return mAddSerieDes
end

function OpenEmojiLibraryUI(rightIdx, topIdx)
    mEmojiLibraryOpenIdx.rightIdx = rightIdx or 1
    mEmojiLibraryOpenIdx.topIdx = topIdx or 1

    UIMgr.ShowUI(AllUI.UI_EmojiLibrary)
end

function OpenMyCollectUI(topIdx)
    mMyCollectOpenIdx = topIdx or 1

    UIMgr.ShowUI(AllUI.UI_Chat_MyCollect)
end

function GetEmojiLibraryOpenIdx()
    return mEmojiLibraryOpenIdx
end

function GetMyCollectOpenIdx()
    return mMyCollectOpenIdx
end

--[[
    @desc: 注册界面关闭回调，执行一次，自动清理
    --@uiData:
	--@func:
	--@obj: 
]]
function RegInvokeData(uiData, func, obj)
    if not mInvokeDataOnClose[uiData] then
        mInvokeDataOnClose[uiData] = {}
    end
    mInvokeDataOnClose[uiData].func = func
    mInvokeDataOnClose[uiData].obj = obj
end

--[[
    @desc: 界面关闭时，试探性的调用，没有则不处理，有则执行回调
    执行完回调后，自动清理
    --@uiData: 
]]
function DoInvokeFunc(uiData)
    if uiData then
        local invokeData = mInvokeDataOnClose[uiData]
        if not invokeData then
            return
        end
        if invokeData.func then
            if invokeData.obj then
                invokeData.func(invokeData.obj)
            else
                invokeData.func()
            end
        end

        --清理
        invokeData.func = nil
        invokeData.obj = nil
    end
end

--[[
    @desc: 
    --@emojiInfo:
	--@openType: 1从表情库，2从聊天频道
]]
function OpenEmojiInfoUI(emojiInfo)
    mShowingEmojiInfo = emojiInfo
    UIMgr.ShowUI(AllUI.UI_EmojiInfo)
end

function GetShowingEmojiInfo()
    return mShowingEmojiInfo
end

--[[
    @desc: 
    --@data: 可能是pkgId，也可能是pkgInfo
]]
function OpenPkgInfoUI(data)
    mShowingPkgInfoData = data
    UIMgr.ShowUI(AllUI.UI_PkgInfo)
end

function GetShowingPkgInfoData()
    return mShowingPkgInfoData
end

function AddEmoji2HotListByJson(json)
    local emojiInfo = EmojiInfo.new()
    emojiInfo:InitByJson(json)
    table.insert(mHotEmojiList, emojiInfo)
end

function AddEmoji2TimeListByJson(json)
    local emojiInfo = EmojiInfo.new()
    emojiInfo:InitByJson(json)
    table.insert(mTimeEmojiList, emojiInfo)
end

function GetHotEmojiList()
    return mHotEmojiList
end

function GetTimeEmojiList()
    return mTimeEmojiList
end

function GetHotEmojiListCount()
    return #mHotEmojiList
end

function GetTimeEmojiListCount()
    return #mTimeEmojiList
end

function AddEmoji2ChatMain(emojiInfo)
    if not emojiInfo then
        return
    end
    local picId = emojiInfo:GetPicId()
    if picId then
        if not mEmojiForChatMain[picId] then
            mEmojiForChatMain[picId] = emojiInfo
        end
    end
end

function GetEmojiFromChatMainByPicId(picId)
    if picId then
        return mEmojiForChatMain[picId]
    end
end

function GetEmojiFromChatMainByUrl(url)
    local existInfo = nil
    for _, emojiInfo in pairs(mEmojiForChatMain) do
        if emojiInfo:GetUrl() == url then
            existInfo = emojiInfo
            break
        end
    end
    return existInfo
end

function GetChatAddBtnData(showType)
    if showType then
        return mChatAddBtnDataDic[showType]
    else
        return nil
    end
end

function GetChatAddBtnList()
    return mChatAddBtnList
end

function ClearAddingPkgInfoList()
    local len = #mAddingPkgInfoList
    for idx = 1, len do
        table.remove(mAddingPkgInfoList)
    end
end

function ClearAddingPkgInfoName()
    mAddingPkgInfoName.name = ""
    mAddingPkgInfoName.des = ""
end

function SetAddingPkgInfoName(name, des)
    mAddingPkgInfoName.name = name
    mAddingPkgInfoName.des = des
end

function GetAddingPkgInfoList()
    return mAddingPkgInfoList
end

function GetAddingPkgInfoName()
    return mAddingPkgInfoName
end

--[[
    @desc: 登录后请求服务器，只有系列信息
    不包含表情图列表，需要单独请求
    --@json: 
]]
function AddPkg2MyAddListByJson(json)
    local pkgInfo = PkgInfo.new()
    pkgInfo:InitByJson(json)
    GameLog.LogError("------------------------------------pkgId = %s", pkgInfo:GetPkgId())
    DoAddPkg2MyAddList(pkgInfo, false)
end

--[[
    @desc: 该方法，在上传完表情系列后调用
    --@pkgInfo: 完整的表情系列结构，已经包含了表情图列表
]]
function AddPkg2MyAddListByPkgInfo(pkgInfo)
    DoAddPkg2MyAddList(pkgInfo, true)
end

function GetMyAddPkgList()
    return mMyAddPkgList
end

function AddPkg2HotListByJson(json)
    local pkgInfo = PkgInfo.new()
    pkgInfo:InitByJson(json)
    table.insert(mHotPkgList, pkgInfo)
end

function AddPkg2TimeListByJson(json)
    local pkgInfo = PkgInfo.new()
    pkgInfo:InitByJson(json)
    table.insert(mTimePkgList, pkgInfo)
end

function GetHotPkgList()
    return mHotPkgList
end

function GetTimePkgList()
    return mTimePkgList
end

function GetHotPkgListCount()
    return #mHotPkgList
end

function GetTimePkgListCount()
    return #mTimePkgList
end

--[[
    @desc: 每次调用都需要赋值
    --@myCollectHelpCB: 
]]
function SetMyCollectHelpData(func, remainedNum)
    mMyCollectHelpData.func = func
    mMyCollectHelpData.remainedNum = remainedNum
end

function GetMyCollectHelpData()
    return mMyCollectHelpData
end

function ClearMyCollectHelpData()
    mMyCollectHelpData.func = nil
    mMyCollectHelpData.remainedNum = 0
end

return CustomEmojiMgr
