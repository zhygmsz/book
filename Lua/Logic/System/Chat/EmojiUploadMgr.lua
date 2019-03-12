--自定义表情上传管理，目前只支持同时上传一个，日后可以扩展为优先级上传队列

module("EmojiUploadMgr", package.seeall)

local UploadItem = class("UploadItem")
function UploadItem:ctor()
    self:SetIdle(true)
    self:Reset()
end

function UploadItem:Reset()
    self._localPath = ""
    self._uploadPath = ""
    self._url = ""
    self._uploading = false
    self._pornDetecting = false
end

function UploadItem:SetIdle(idle)
    self._idle = idle
end

function UploadItem:IsIdle()
    return self._idle
end

function UploadItem:Progress()
    if self._uploading then
        --[0, 1]
        return CosMgr.UploadProgress(self._localPath)
    elseif self._pornDetecting then
        return 2
    else
        --无意义
        return -1
    end
end

function UploadItem:InvokeForState(state)
    self:SetIdle(true)

    --UploadItem只对该Mgr负责，不需要注册回调，直接使用Mgr里的OnUpload方法
    OnUpload(state, self._localPath, self._url)
end

function UploadItem:OnPornDetect(remotePath, successFlag)
    --鉴黄返回，得看后续其sdk的返回值是什么，目前先假定成功失败（更有可能是一个标识黄色程度的数字）
    self._pornDetecting = false

    if successFlag then
        TipsMgr.TipByKey("chat_emoji_upload_success")
    else
        TipsMgr.TipByKey("chat_emoji_porndetect_fail")
    end

    self:InvokeForState(successFlag)
end

function UploadItem:OnUpload(localPath, remotePath, successFlag)
    self._uploading = false
    self._pornDetecting = successFlag

    if successFlag then
        self._url = remotePath

        --上传成功，继续鉴黄
        --PornDetectMgr.PornDetectSingleFile(remotePath, self.OnPornDetect, self)
        self:OnPornDetect(remotePath, true)
    else
        --整个上传过程失败，直接返回
        TipsMgr.TipByKey("chat_emoji_upload_fail")

        self:InvokeForState(false)
    end
end

function UploadItem:Start(localPath, uploadPath)
    self:Reset()
    self:SetIdle(false)

    self._localPath = localPath
    self._uploadPath = uploadPath

    self._uploading = true
    self._pornDetecting = false

    CosMgr.UploadFile(localPath, uploadPath .. UserData.PlayerID, self.OnUpload, self)
end

---------------------------------------------------------------

local RequestItem = class("RequestItem")
function RequestItem:ctor()
    self:Reset()
end

function RequestItem:Reset()
    self._localPath = ""
    self._uploadPath = ""
    self._callback = nil
    self._obj = nil

    self:SetIdle(true)
end

function RequestItem:Init(localPath, uploadPath, callback, obj)
    self._localPath = localPath
    self._uploadPath = uploadPath
    self._callback = callback
    self._obj = obj

    self:SetIdle(false)
end

function RequestItem:SetIdle(idle)
    self._idle = idle
end

function RequestItem:IsIdle()
    return self._idle
end

function RequestItem:GetLocalPath()
    return self._localPath
end

function RequestItem:GetUploadPath()
    return self._uploadPath
end

function RequestItem:Invoke(state, localaPath, url)
    if self._callback then
        if self._obj then
            self._callback(self._obj, state, localaPath, url)
        else
            self._callback(state, localaPath, url)
        end
    end

    self:SetIdle(true)
end

---------------------------------------------------------------



--目前同时上传数量最大为1
local mUploadMaxCount = 1
local mUploadItemList = {}

--请求数量没有限制，但做一个缓存池，减少不必要的table创建
local mRequestItemList = {}

local mCallbackDic = {}
local mWaitList = {}

local function GetIdleUploadItem()
    for _, item in ipairs(mUploadItemList) do
        if item:IsIdle() then
            return item
        end
    end
    return nil
end

local function GetIdleRequestItem()
    for _, item in ipairs(mRequestItemList) do
        if item:IsIdle() then
            return item
        end
    end

    mRequestItemList[#mRequestItemList + 1] = RequestItem.new()
    return mRequestItemList[#mRequestItemList]
end

local function AddCallback(localPath, requestItem)
    mCallbackDic[localPath] = requestItem
end

local function RemoveCallback(localPath)
    mCallbackDic[localPath] = nil
end

local function GetCallback(localPath)
    return mCallbackDic[localPath]
end

local function AddWait(requestItem)
    table.insert(mWaitList, requestItem)
end

local function RemoveWait(localPath)
    local existIdx = nil
    for idx, item in ipairs(mWaitList) do
        if item:GetLocalPath() == localPath then
            existIdx = idx
            break
        end
    end
    if existIdx then
        table.remove(mWaitList, existIdx)
    end
end

local function GetWait()
    local waitItem = mWaitList[1]
    if waitItem then
        table.remove(mWaitList, 1)
    end
    return waitItem
end

function Init()
    for idx = 1, mUploadMaxCount do
        mUploadItemList[idx] = UploadItem.new()
    end

    --一次性初始化10个请求数据，供以后循环使用
    for idx = 1, 10 do
        mRequestItemList[idx] = RequestItem.new()
    end
end

--[[
    @desc: 请求上传
    --@localPath:
    --@uploadPath:
	--@callback:
	--@obj: 
]]
function Upload(localPath, uploadPath, callback, obj)
    local idleRequestItem = GetIdleRequestItem()
    idleRequestItem:Init(localPath, uploadPath, callback, obj)

    local idleUploadItem = GetIdleUploadItem()
    if idleUploadItem then
        AddCallback(localPath, idleRequestItem)
        idleUploadItem:Start(localPath, uploadPath)
    else
        --排队
        AddWait(idleRequestItem)
    end
end

--[[
    @desc: 取消上传请求，只能取消等待队列里的
    --@localPath: 
]]
function CancelUpload(localPath)
    RemoveWait(localPath)
end

--[[
    @desc: UploadItem的统一回调
]]
function OnUpload(state, localPath, url)
    local callback = GetCallback(localPath)
    if callback then
        callback:Invoke(state, localPath, url)
        RemoveCallback(localPath)
    end

    --检查排队
    --理论上，肯定能获取到一个空闲的UploadItem
    local idleUploadItem = GetIdleUploadItem()
    if idleUploadItem then
        local waitItem = GetWait()
        if waitItem then
            AddCallback(waitItem:GetLocalPath(), waitItem)
            idleUploadItem:Start(waitItem:GetLocalPath(), waitItem:GetUploadPath())
        end
    end
end

return EmojiUploadMgr