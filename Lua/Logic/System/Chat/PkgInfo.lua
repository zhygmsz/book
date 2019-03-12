--自定义表情包信息
local EmojiInfo = require("Logic/System/Chat/EmojiInfo")

local PkgInfo = class("PkgInfo")
function PkgInfo:ctor()
    --http接口内数据
    self._playerId = 0
    --sns主导定义，int32范围内整数
    self._pkgId = 0
    self._pkgType = 0
    self._name = ""
    self._des = ""
    self._hot = 0
    self._addTime = 0
    self._updateTime = 0

    --额外的逻辑数据
    self._isAdd = false

    --该系列内包含的表情列表
    self._emojiInfoList = {}

    --用于请求该系列的异步回调
    self._curInvokeDataList = {}
    self._invokeDataPool = {}
    --请求过程中
    self._requesting = false
end

function PkgInfo:InitByJson(json)
    self._playerId = json.player_id
    self._pkgId = json.serie_id
    self._pkgType = json.type
    self._name = json.name
    self._des = json.description
    self._hot = json.hot
    self._updateTime = json.updatetime

    --不继续请求包含的表情图列表
    --真正用到的时候再异步请求
end

function PkgInfo:InitByPkgId(pkgId, name, des, playerId)
    self._pkgId = pkgId
    self._name = name
    self._des = des
    self._playerId = playerId
end

function PkgInfo:GetPlayerId()
    return self._playerId
end

function PkgInfo:GetPkgId()
    return self._pkgId
end

function PkgInfo:SetAdd(isAdd)
    self._isAdd = isAdd
end

function PkgInfo:CheckIsAdd()
    return self._isAdd
end

function PkgInfo:GetName()
    return self._name
end

function PkgInfo:GetDes()
    return self._des
end

function PkgInfo:SetHot(hot)
    self._hot = hot
end

function PkgInfo:GetHot()
    return self._hot
end

--[[
    @desc: 
    --@emojiInfoList: 新创建的table，不和其他代码共用
]]
function PkgInfo:AddEmojiInfoList(emojiInfoList)
    --该接口只调一次，没有append需求
    if #self._emojiInfoList > 0 then
        return
    end

    if not emojiInfoList then
        return
    end
    --二次保险，把table里的数据倒出来重新装在自己独有的table里
    for _, emojiInfo in ipairs(emojiInfoList) do
        table.insert(self._emojiInfoList, emojiInfo)
    end
end

function PkgInfo:AllocInvokeData(func, obj)
    local invokeData = self._invokeDataPool[#self._invokeDataPool]
    if invokeData then
        self._invokeDataPool[#self._invokeDataPool] = nil
    else
        invokeData = {}
    end
    invokeData.func = func
    invokeData.obj = obj
    return invokeData
end

function PkgInfo:FreeInvokeData(invokeData)
    invokeData.func = nil
    invokeData.obj = nil
    self._invokeDataPool[#self._invokeDataPool + 1] = invokeData
end

function PkgInfo:AddInvokeData(invokeData)
    table.insert(self._curInvokeDataList, invokeData)
end

function PkgInfo:DoInvokeForList()
    for idx, invokeData in ipairs(self._curInvokeDataList) do
        if invokeData.func then
            if invokeData.obj then
                invokeData.func(invokeData.obj, self._pkgId, self._emojiInfoList)
            else
                invokeData.func(self._pkgId, self._emojiInfoList)
            end
        end
        self:FreeInvokeData(invokeData)
    end
    --清空回调列表
    local len = #self._curInvokeDataList
    for idx = 1, len do
        table.remove(self._curInvokeDataList)
    end
end

function PkgInfo:OnGetEmojiList(state, jsonList)
    if not state then
        return
    end
    local emojiInfo = nil
    for _, info in ipairs(jsonList) do
        emojiInfo = EmojiInfo.new()
        emojiInfo:InitByJson(info)
        table.insert(self._emojiInfoList, emojiInfo)
    end
    
    self:DoInvokeForList()
end

--[[
    @desc: 请求系列的表情图列表，异步返回
    做法同上
]]
function PkgInfo:RequestEmojiInfoList(callback, obj)
    local invokeData = self:AllocInvokeData(callback, obj)
    self:AddInvokeData(invokeData)

    if #self._emojiInfoList > 0 then
        self:DoInvokeForList()
    else
        if not self._requesting then
            self._requesting = true
            --请求获取该系列的全部表情信息
            SNSCustomEmojiMgr.RequestEmojiListByPkgId(self._pkgId, self.OnGetEmojiList, self)
        end
    end
end

--[[
    @desc: 假定表情图列表已经请求下来
    --@idx: 
]]
function PkgInfo:GetEmojiInfoByIdx(idx)
    if idx then
        return self._emojiInfoList[idx]
    else
        return nil
    end
end

return PkgInfo