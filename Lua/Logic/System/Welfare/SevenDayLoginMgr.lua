module("SevenDayLoginMgr", package.seeall)

--测试
DebugMode = false

MiddleItemState = {}
MiddleItemState.None = -1
--未解锁
MiddleItemState.Lock = 1
--未领取
MiddleItemState.NoGot = 2
--已领取
MiddleItemState.Got = 3
--已许愿
MiddleItemState.Wished = 4

local mMaxDayIdx = 7
local mSignData = {}
local mGotState = {}
local mWishAward = {}
local mFashionClothesNum = 3
local mFashionClothesKeyList = { "seven_fashion_clothes1", "seven_fashion_clothes2", "seven_fashion_clothes3" }
local mMaxWishItemNum = 6
local mGiftHasGot = false  --终极奖励是否已领取
--本次请求界面数据，检测是否已全部许愿
--用来判断是否显示修改许愿按钮
local mIsAllWished = false

local day2Str ={}

--保证测试数据只初始化一次
local mDebugDataIsInited = false

--local方法
local function GetStrByDay(day)
    if day then
        return day2Str[day] or ""
    else
        return ""
    end
end

--初始化数据
local function InitData()
    for idx = 1, mMaxDayIdx do
        mSignData[idx] = 0
    end

    for idx = 1, mMaxDayIdx do
        mGotState[idx] = 0
    end

    for idx = 1, mMaxDayIdx do
        --0代表没有许愿
        mWishAward[idx] = 0
    end

    for i=1,7 do
        day2Str[i] = WordData.GetWordStringByKey("welfare_sevenday_num"..i)
    end
end

local function InitIsAllWished()
mIsAllWished = true
    for idx = 2, mMaxDayIdx do
        if not CheckHasWished(idx) then
            mIsAllWished = false
            break
        end
    end
end

--检查区间
local function CheckRange(dayIdx)
    if type(dayIdx) == "number" then
        return 1 <= dayIdx and dayIdx <= mMaxDayIdx
    else
        return false
    end
end

--设置领取状态
local function SetGotState(dayIdx)
    if CheckRange(dayIdx) then
        if mGotState[dayIdx] == 0 then
            mGotState[dayIdx] = 1
        else
            GameLog.LogError("SevenDayLoginMgr.SetGotState -> mGotState is 1, dayIdx = %s", dayIdx)
        end
    else
        GameLog.LogError("SevenDayLoginMgr.SetGotState -> dayIdx is not in range")
    end
end

--获取许愿出来的物品id
local function GetWishedTempId(dayIdx)
    local tempId = 0
    if CheckRange(dayIdx) then
        tempId = mWishAward[dayIdx]
    end
    return tempId
end

--获取MiddleItem的状态
local function GetState(dayIdx)
    local state = MiddleItemState.None
    if CheckRange(dayIdx) then
        if CheckHasSign(dayIdx) then
            if CheckHasGotItem(dayIdx) then
                state = MiddleItemState.Got
            else
                state = MiddleItemState.NoGot
            end
        else
            if CheckHasWished(dayIdx) then
                state = MiddleItemState.Wished
            else
                state = MiddleItemState.Lock
            end
        end
    end
    return state
end

--获取固定奖励id
local function GetFixedTempId(dayIdx)
    local tempId = 0
    if CheckRange(dayIdx) then
        local sevenDayData = WelfareData.GetSevenDayData(dayIdx)
        if sevenDayData then
            tempId = sevenDayData.fixedId
        end
    end
    return tempId
end

--获取默认的物品id，用于未许愿时自动给的
local function GetDefaultTempId(dayIdx)
    local tempId = 0
    if CheckRange(dayIdx) then
        if dayIdx ~= 1 then
            local sevenDayData = WelfareData.GetSevenDayData(dayIdx)
            if sevenDayData then
                tempId = sevenDayData.idNums[1].id
            end
        end
    end
    return tempId
end

--获取指定天对应的物品id
local function GetTempId(dayIdx)
    local tempId = 0
    if CheckRange(dayIdx) then
        local state = GetState(dayIdx)
        if state == MiddleItemState.NoGot 
            or state == MiddleItemState.Got 
            or state == MiddleItemState.Wished then
            if dayIdx == 1 then
                tempId = GetFixedTempId(dayIdx)
            else
                tempId = GetWishedTempId(dayIdx)
                if tempId == 0 then
                    --0表示没许愿
                    tempId = GetDefaultTempId(dayIdx)
                end
            end
        end
    end
    return tempId
end

--设置大奖领取状态
local function SetGiftGot()
    if not mGiftHasGot then
        mGiftHasGot = true
    else
        GameLog.LogError("SevenDayLoginMgr.SetGiftGot -> mGiftHasGot is true")
    end
end

--设置已许愿的记录
local function SetWishAward(dayIdx, tempId)
    if CheckRange(dayIdx) and tempId then
        mWishAward[dayIdx] = tempId
    end
end

--消息处理
--请求界面数据
function SendGetSevenDayData()
    local msg = NetCS_pb.CSGetDaysSignInfo()
    GameNet.SendToGate(msg)
    GameLog.LogProto(msg)

    if DebugMode then
        local data = {}
        if not mDebugDataIsInited then
            mDebugDataIsInited = true
            data.signData = {}
            local signedDayIdx = 1
            for idx = 1, signedDayIdx do
                data.signData[idx] = 1
            end
            for idx = signedDayIdx + 1, mMaxDayIdx do
                data.signData[idx] = 0
            end
    
            for idx = 1, mMaxDayIdx do
                data.signData[mMaxDayIdx + idx] = 0
            end
            --data.signData[mMaxDayIdx + 2] = 1
            --data.signData[mMaxDayIdx + 4] = 1
    
            data.signData[2 * mMaxDayIdx + 1] = 0
            
            data.awardItem = {}
            ---[[
            --data.awardItem[2] = 400000003
            --data.awardItem[3] = 400000004
            --data.awardItem[4] = 400000005
            --data.awardItem[5] = 400000006
            --data.awardItem[6] = 400000007
            --data.awardItem[7] = 000000003
            --]]
        else
            --测试数据已经初始化，再次组装data从已有数据里读取
            data.signData = {}
            data.awardItem = {}
            for idx = 1, mMaxDayIdx do
                data.signData[idx] = mSignData[idx]
                data.signData[idx + mMaxDayIdx] = mGotState[idx]
                data.awardItem[idx] = mWishAward[idx]
            end
            data.signData[2 * mMaxDayIdx + 1] = mGiftHasGot and 1 or 0
        end
        OnGetSevenDayData(data)
    end
end

if DebugMode then
    function GotoNextDayOnline()
        local curDayIdx = GetCurDayIdx()
        local maxDayIdx = GetMaxDayIdx()
        if curDayIdx < maxDayIdx then
            mSignData[curDayIdx + 1] = 1
            GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETDATA)
        end
    end
end

--界面数据返回
function OnGetSevenDayData(data)
    local len = 2 * mMaxDayIdx + 1
    if #data.signData ~= len then
        GameLog.LogError("SevenDayLoginMgr.OnGetSevenDayData -> #signData is illegal")
        return
    end
    local signData = data.signData
    local awardItem = data.awardItem
    for idx = 1, mMaxDayIdx do
        mSignData[idx] = signData[idx]
        mGotState[idx] = signData[idx + mMaxDayIdx]
        if awardItem[idx] then
            mWishAward[idx] = awardItem[idx]
        end
    end

    --设置大礼包领取状态
    mGiftHasGot = signData[len] == 1

    --初始化mIsAllWished字段
    InitIsAllWished()

    GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETDATA)
end

--发送领取奖励
function SendGetAward(dayIdx)
    local msg = NetCS_pb.CSGetDaysSignAward()
    msg.dayIndex = dayIdx
    GameNet.SendToGate(msg)
    GameLog.LogProto(msg)

    if DebugMode then
        local data = {}
        data.ret = 0
        data.dayIndex = dayIdx
        OnGetAward(data)
    end
end

--领取奖励返回
function OnGetAward(data)
    if data.ret == 0 then
        SetGotState(data.dayIndex)
        GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETAWARD, data.dayIndex)
    else
        GameLog.LogError("SevenDayLoginMgr.OnGetAward -> data.ret is not 0")
    end
end

--发送许愿
function SendWish(dayIdx, awardIdx, awardItemId)
    local msg = NetCS_pb.CSDoDaysSignWish()
    msg.wishInfo.dayIndex = dayIdx
    msg.wishInfo.awardIndex = awardIdx
    msg.wishInfo.awardItemID = awardItemId
    GameNet.SendToGate(msg)
    GameLog.LogProto(msg)

    if DebugMode then
        local data = {}
        data.wishRet = {}
        data.wishRet.ret = 0
        data.wishRet.dayIndex = dayIdx
        data.wishRet.awardIndex = awardIdx
        OnWish(data)
    end
end

--许愿返回
function OnWish(data)
    if data.wishRet.ret == 0 then
        local wishedTempId = GetWishingTempId(data.wishRet.dayIndex, data.wishRet.awardIndex)
        if wishedTempId ~= -1 then
            local allWishedPre = CheckAllWished()
            SetWishAward(data.wishRet.dayIndex, wishedTempId)
            local allWishedNext = CheckAllWished()
            GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ONWISH, data.wishRet.dayIndex)
            --判断是否是许愿全部，做UI表现
            if not allWishedPre and allWishedNext then
                mIsAllWished = true
                GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ALLWISHED)
            end
            TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_wishSuccess"))
        else
            GameLog.LogError("SevenDayLoginMgr.OnWish -> wishedTempId is -1")
        end
    else
        GameLog.LogError("SevenDayLoginMgr.OnWish -> data.ret is not 0")
    end
end

--发送领取终极奖励
function SendGetGift(itemId)
    if CheckHasGotGift() then
        GameLog.LogError("SevenDayLoginMgr.SendGetGift -> gift has got")
        return
    end
    local msg = NetCS_pb.CSGetSignGiftPacks()
    msg.itemID = itemId
    GameNet.SendToGate(msg)
    GameLog.LogProto(msg)

    if DebugMode then
        local data = {}
        data.ret = 0
        OnGetGift(data)
    end
end

--领取终极奖励返回
function OnGetGift(data)
    if data.ret == 0 then
        --签到终极奖励，领取成功
        SetGiftGot()
        GameEvent.Trigger(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETGIFT)
        TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_finalGift_got"))
    end
end

--服务UI
--返回界面数据
function GetSevenDayLoginData()
    local data = {}
    for idx = 1, mMaxDayIdx do
        local state = GetState(idx)
        local tempId = GetTempId(idx)
        data[idx] = { dayIdx = idx, state = state, tempId = tempId }
    end
    return data
end

--获取时装id列表
function GetFashionClothesId()
    local ids = {}
    for idx = 1, mFashionClothesNum do
        local value = ConfigData.GetStringValue(mFashionClothesKeyList[idx])
        value = string.sub(value, 5, string.len(value))
        value = tonumber(value)
        table.insert(ids, value) 
    end
    return ids
end

--获取许愿物品id列表
function GetWishItemIdList(dayIdx)
    local ids = {}
    if CheckRange(dayIdx) then
        local sevenDayData = WelfareData.GetSevenDayData(dayIdx)
        if sevenDayData then
            for idx = 1, mMaxWishItemNum do
                local idNum = sevenDayData.idNums[idx]
                if idNum then
                    table.insert(ids, idNum.id)
                end
            end
        end
    end
    return ids
end

--获取当前登录天数
function GetCurDayIdx()
    local dayIdx = 1
    for idx = mMaxDayIdx, 1, -1 do
        local state = GetState(idx)
        if state == MiddleItemState.NoGot or state == MiddleItemState.Got then
            dayIdx = idx
            break
        end
    end
    return dayIdx
end

--获取被许愿的物品索引对应的配置表id
function GetWishingTempId(dayIdx, awardIdx)
    local tempId = -1
    if CheckRange(dayIdx) and awardIdx then
        local sevenDayData = WelfareData.GetSevenDayData(dayIdx)
        if sevenDayData then
            local idNum = sevenDayData.idNums[awardIdx]
            if idNum then
                tempId = idNum.id
            end
        end
    end
    return tempId
end

--获取时装数量
function GetFashionClothesNum()
    return mFashionClothesNum
end

--获取最大天数
function GetMaxDayIdx()
    return mMaxDayIdx
end

--获取最大可许愿物品数量
function GetMaxWishItemNum()
    return mMaxWishItemNum
end

--检测是否是最后一天
function CheckIsLastDay()
    local curDayIdx = GetCurDayIdx()
    return curDayIdx == mMaxDayIdx
end

--检测是否可以领取终极奖励
--最后一天登录，即可领取
function CheckCanGetGift()
    local state = GetState(mMaxDayIdx)
    if state == MiddleItemState.Got or state == MiddleItemState.NoGot then
        return true
    else
        return false
    end
end

--检测是否已经领取了大礼包
function CheckHasGotGift()
    return mGiftHasGot
end

--检测是否全部由许愿记录
function CheckAllWished()
    local isAll = true
    for idx = 2, mMaxDayIdx do
        if not CheckHasWished(idx) then
            isAll = false
            break
        end
    end
    return isAll
end

--获取第一个未许愿的天数
function GetFirstUnWishedDayIdx()
    local firstDayIdx = -1
    local curDayIdx = GetCurDayIdx()
    for idx = curDayIdx + 1, mMaxDayIdx do
        if not CheckHasWished(idx) then
            firstDayIdx = idx
            break
        end
    end
    return firstDayIdx
end

--检测领取状态是否为已领取
function CheckHasGotItem(dayIdx)
    if CheckRange(dayIdx) then
        return mGotState[dayIdx] == 1
    else
        return false
    end
end

--检测是否已签到
function CheckHasSign(dayIdx)
    if CheckRange(dayIdx) then
        return mSignData[dayIdx] == 1
    else
        return false
    end
end

--检测是否有许愿记录
function CheckHasWished(dayIdx)
    if dayIdx == 1 then
        --第一天默认是已许愿
        return true
    else
        local tempId = GetWishedTempId(dayIdx)
        return tempId and tempId > 0
    end
end

--返回mIsAllWished字段
function CheckIsAllWished()
    return mIsAllWished
end

function GetTopDesStr()
    local curDayIdx = GetCurDayIdx()
    local maxDayIdx = GetMaxDayIdx()
    local diffDay = maxDayIdx - curDayIdx
    return string.format(WordData.GetWordStringByKey("welfare_sevenday_day_later"),GetStrByDay(diffDay)) --str .. "天后可领取"
end

function GetMiddleTitleStr(day)
    if not day then
        return ""
    end
    return string.format(WordData.GetWordStringByKey("welfare_sevenday_day"),GetStrByDay(day))
end

function GetBottomWishDesStr(day)
    if not day then
        return ""
    end
    return string.format(WordData.GetWordStringByKey("welfare_sevenday_wishmsg"),GetStrByDay(day))
end

function GetBottomChangeWishDesStr(day)
    if not day then
        return ""
    end
    return string.format(WordData.GetWordStringByKey("welfare_sevenday_changemsg"),GetStrByDay(day))
end

function GetWillGetDesStr(day)
    if not day then
        return ""
    end
    return string.format(WordData.GetWordStringByKey("welfare_sevenday_countday_rewards"),GetStrByDay(day))
end

function InitModule()
    InitData()
end

return SevenDayLoginMgr