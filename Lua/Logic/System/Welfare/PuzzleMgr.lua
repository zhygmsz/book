module("PuzzleMgr", package.seeall)

--变量
local mCurPuzzleId = 1  --当前活动阶段的拼图id
local mPieceIdNums = {}  --当前拼图的进度

local mSpecItemKey = "puzzle_magic_pieces"
local mSpecItemId = -1

local mEvents = {}

DebugMode = false

if DebugMode then
    local mItemList = {}
end

--lcoal方法
--获取当前拼图的所有碎片数据（表格数据）
local function GetPuzzleData()
    local list = PuzzleData.GetPuzzleData(mCurPuzzleId)
    return list or {}
end

--获取万能碎片表数据
local function GetSpecData()
    local data = Puzzle_pb.PuzzleData()
    data.itemId = mSpecItemId
    return data
end

--重置拼图进度
local function ResetPieceIdNums()
    for key, num in ipairs(mPieceIdNums) do
        mPieceIdNums[key] = 0
    end
end

--初始化数据
local function InitData()
    local value = ConfigData.GetStringValue(mSpecItemKey)
    if value then
        value = string.sub(value, 5, string.len(value))
        mSpecItemId = tonumber(value)
    end
    
    local list = GetPuzzleData()
    for _, data in ipairs(list) do
        if not mPieceIdNums[data.pieceId] then
            mPieceIdNums[data.pieceId] = 0
        else
            GameLog.LogError("PuzzleMgr.InitData -> data.pieceId is repeated, data.pieceId = %s", data.pieceId)
        end
    end

    if DebugMode then
        mItemList = 
        {
            [600200001] = 1, 
            [600200002] = 2,
            [600200003] = 2,
            [600200005] = 3,
            [600200007] = 4,
            [mSpecItemId] = 11,
        }
    end
end

--根据itemId获取pieceId
local function ItemId2PieceId(itemId)
    local pieceId = -1
    local list = GetPuzzleData()
    for _, data in ipairs(list) do
        if data.itemId == itemId then
            pieceId = data.pieceId
            break
        end
    end
    return pieceId
end

--更新mPuzzleItemIdList列表
local function DoUpdatePieceIdNums(type, pieceId)
    if not type or not pieceId then
        GameLog.LogError("PuzzleMgr.DoUpdatePieceIdNums -> type or pieceId is nil")
        return
    end
    if type == NetCS_pb.SCPuzzleOnOff.PUZZLE_ADD then
        mPieceIdNums[pieceId] = mPieceIdNums[pieceId] + 1
        GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_ADDPIECE, pieceId)
    elseif type == NetCS_pb.SCPuzzleOnOff.PUZZLE_DEL then
        mPieceIdNums[pieceId] = mPieceIdNums[pieceId] - 1
        GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_REMOVEPIECE, pieceId)
    end
end

--获取到拼图背包数据后回调
local function OnGetBagData(bagType)
    --GameLog.LogError("PuzzleMgr.OnGetBagData ->")
    if bagType == Bag_pb.PUZZLE then
        GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETBAGDATA)
    end
end

--拼图背包数据更新
local function OnBagUpdate(bagType, oper)
    --GameLog.LogError("PuzzleMgr.OnBagUpdate ->")
    if bagType == Bag_pb.PUZZLE then
        GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_UPDATEBAGDATA)
    end
end

--检测服务器返回的mapId是否和保存的一致
local function CheckIsCurMap(mapId)
    if mapId then
        return mapId == mCurPuzzleId
    else
        return false
    end
end

local function RegEvent()
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE, OnGetBagData)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, OnBagUpdate)
end

--消息处理
--请求拼图进度数据
local function SendGetPieceIdNums()
    local msg = NetCS_pb.CSPuzzleMapInit()
    GameNet.SendToGate(msg)

    if DebugMode then
        local data = {}
        data.mapId = 1
        data.piecesList = 
        {
            { pieceId = 1, num = 1 },
            { pieceId = 2, num = 0 },
            { pieceId = 3, num = 1 },
            { pieceId = 4, num = 0 },
            { pieceId = 5, num = 0 },
            { pieceId = 6, num = 0 },
            { pieceId = 7, num = 1 },
            { pieceId = 8, num = 0 },
        }
        OnGetPieceIdNums(data)
    end
end

--请求拼图背包数据
local function SendGetBagData()
    BagMgr.RequestBagData({ Bag_pb.PUZZLE })

    if DebugMode then
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_UPDATE_PACKAGE, Bag_pb.PUZZLE)
    end
end

--打开界面请求数据
function SendOnOpenUI()
    SendGetPieceIdNums()
    SendGetBagData()
end

--拼图进度数据返回
function OnGetPieceIdNums(data)
    GameLog.LogError("PuzzleMgr.OnGetPieceIdNums -> ")
    --存储数据
    if not data then
        return
    end
    mCurPuzzleId = data.mapId
    if data.piecesList then
        for _, idNum in ipairs(data.piecesList) do
            mPieceIdNums[idNum.pieceId] = idNum.num
        end
    end
    
    --发送事件
    GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETPUZZLEDATA)
end

--拼合操作
function SendInset(type, mapId, itemId, pieceId)
    if not CheckIsCurMap(mapId) then
        GameLog.LogError("PuzzleMgr.SendInset -> mapId is not curmap")
        return
    end
    if CheckIsInset(pieceId) then
        TipsMgr.TipByFormat("该碎片已镶嵌")
        GameLog.LogError("PuzzleMgr.SendInset -> itemId is inset, itemId = %s", itemId)
        return
    end
    local msg = NetCS_pb.CSPuzzleOnOff()
    msg.type = type
    msg.mapId = mapId
    msg.itemId = itemId
    msg.pieceId = pieceId
    GameNet.SendToGate(msg)

    if DebugMode then
        local data = {}
        data.ret = 0
        data.mapId = mCurPuzzleId
        data.updateType = 0
        data.pieceId = pieceId
        OnInset(data)

        if mItemList[itemId] then
            mItemList[itemId] = mItemList[itemId] - 1
            OnBagUpdate(Bag_pb.PUZZLE, nil)
        end
    end
end

--拼合操作返回
function OnInset(data)
    GameLog.LogError("PuzzleMgr.OnInset ->")
    if data.ret == 0 then
        if CheckIsCurMap(data.mapId) then
            DoUpdatePieceIdNums(data.updateType, data.pieceId)
        else
            GameLog.LogError("PuzzleMgr.OnInset -> data.mapId is not curmap, data.mapId = %s, curMapId = %s", data.mapId, mCurPuzzleId)
        end
    else
        --其他错误提示
    end
end

--请求奖励
function SendGetAward(mapId)
    local msg = NetCS_pb.CSPuzzleTakeReward()
    msg.mapId = mapId
    GameNet.SendToGate(msg)

    if DebugMode then
        OnGetAward(data)
    end
end

--请求奖励返回
function OnGetAward(data)
    GameLog.LogError("PuzzleMgr.OnGetAward ->")
    TipsMgr.TipByFormat("领取奖励成功")

    ResetPieceIdNums()
    GameEvent.Trigger(EVT.SUB_G_PUZZLE, EVT.SUB_G_PUZZLE_GETAWARD)
end

--选择奖励
function SendChoseAward(mapId, itemId)
    local msg = NetCS_pb.CSPuzzleChoseReward()
    msg.mapId = mapId
    msg.itemId = itemId
    GameNet.SendToGate(msg)
end

--选择奖励返回
function OnChoseAward(data)

end

--发送祈愿信息
function SendWish()
    TipsMgr.TipByFormat("祈愿成功")
end

--祈愿返回
function OnWish(data)

end

--服务UI
function GetCurPuzzleId()
    return mCurPuzzleId
end

--获取静态表数据
function GetStaticData()
    local staticData = {}
    local list = GetPuzzleData()
    for idx, data in ipairs(list) do
        table.insert(staticData, { spec = false, data = data })
    end
    local specData = GetSpecData()
    table.insert(staticData, { spec = true, data = specData })
    return staticData
end

--检测该itemId是否已经拼合
function CheckIsInset(pieceId)
    if pieceId then
        local num = mPieceIdNums[pieceId]
        return num and num > 0
    else
        return false
    end
end

--获取指定itemId的的碎片的数量
function GetItemNum(itemId)
    if not itemId then
        return 0
    end
    local num = 0
    local bagData = BagMgr.BagData[Bag_pb.PUZZLE]
    if bagData then
        for _, itemSlot in ipairs(bagData.items) do
            if itemSlot.item.tempId == itemId then
                num = num + itemSlot.item.count
            end
        end
    end

    if DebugMode then
        num = mItemList[itemId] or 0
    end
    
    return num
end

--检测是否全部拼合
function CheckInsetAll()
    local insetAll = true
    for _, num in ipairs(mPieceIdNums) do
        if num <= 0 then
            insetAll = false
            break
        end
    end
    return insetAll
end

--初始化
function InitModule()
    InitData()
    RegEvent()
end

return PuzzleMgr