module("AudioMgr",package.seeall)

local ProrityQueue = require("Logic/System/Sdk/ProrityQueue");

local SDKAudio = cyou.ldj.sdk.SDKAudio.Instance;
local mAudioCacheTabel = {};
local mMaxMemory = 10485760
local mBankQueue = nil
local mFMODListener = nil

function OnEventStarted(instance)  
end

function OnEventFinished(instance)
    GameLog.Log(string.format("OnAudioEventFinished %s",GetPath(instance)))
end

function InitModule()

    mBankQueue = ProrityQueue.new()
    LoadBank(1)
    LoadBank(2)
    -- LoadBank(3)
    -- LoadBank(4)
    -- LoadBank(5)
    -- LoadBank(6)
   
    SDKAudio:SetCallback(OnEventStarted,OnEventFinished)
    mFMODListener = UnityEngine.GameObject.New("FMODListener").transform;
    UnityEngine.GameObject.DontDestroyOnLoad(mFMODListener.gameObject);
    GameEvent.Reg(EVT.AUDIO,EVT.UI,AudioMgr.OnUISound);
end

function AddCacheToTable(bankid,bank,size)
    local item = mBankQueue:GetItemByKey(bankid)
    if item==nil or item.loaded==nil then
        local info = AudioConfigData.GetBankInfo(bankid)
        local data = {}
        data.bankid = bankid
        data.loaded = true
        data.bank = bank
        data.priority = info.priority
        data.size = size
        data.refCount = 1;
        mBankQueue:Enqueue(bankid,data,info.priority)
    end
end

function RemoveCacheToTable(bankid)
    local item = mBankQueue:DequeueByKey(bankid)
    if item then
        item.refCount = item.refCount-1
        if item.refCount==0 then
            if item.loader then
                LoaderMgr.DeleteLoader(item.loader)
            end
            item=nil
        end
    end
end

function MemorySize()
    local size = 0
    local N = mBankQueue:Count()
    for i=1,N do
        local v = mBankQueue:GetItemByIndex(i)
        if v.size then
            size =size+v.size
        end
    end
    GameLog.Log("SDKAudio MemorySize :%d ",size)
    if size >mMaxMemory then
        BankGC()
    end
    return size
end

function BankGC()
    local v = mBankQueue:GetItemByIndex(1)
    UnLoadBank(v.bankid)
end

--资源加载完毕
function EndLoadBank(loader,params)
    local callback = params and params[1] or nil
    local bankid = params and params[2] or nil
    local loadSamples = params and params[4] or false
    local bank = loader:GetObject()
    local resName = loader:GetResID()
    if bank then
        local size = SDKAudio:LoadBankWithTextAsset(bank,loadSamples)
        AddCacheToTable(bankid,bank,size)
        LoaderMgr.DeleteLoader(loader)
        if callback then callback(bankid) end
    else
        GameLog.LogError("load bank failed")
    end
end

--直接加载资源
function LoadBankFromAssetBundle(bankid,ResName,callback,loadSamples)
    local item = mBankQueue:GetItemByKey(bankid)
    if item == nil then item = {} end
    --已经加载了
    if item.loaded then
        if callback then callback(bankid) end
    else
        if item.loader == nil then item.loader = LoaderMgr.CreateAssetLoader(); end
        item.loader:LoadObject(ResName,EndLoadBank,false,{callback,bankid,loadSamples});
    end
end

--载入bank
function LoadBank(bankid,callback,loadSamples)
    local info = AudioConfigData.GetBankInfo(bankid)
    if info then
        LoadBankFromAssetBundle(bankid,info.resId,callback,loadSamples)
    end
end

--卸载bank
function UnLoadBank(bankid)
    local info = AudioConfigData.GetBankInfo(bankid)
    if info then
        SDKAudio:UnLoadBank(info.bank)
        RemoveCacheToTable(info.resId)
    end
end

--加载bytesbank文件
function LoadBankWithTextAsset(bankasset,loadSamples)
    SDKAudio:LoadBankWithTextAsset(bankasset,loadSamples)
end

function PlayAudio(audioId,transform)
    --local mainCamera =CameraMgr.GetMainCameraObj()
    EnableListener(0,true)
    SetListenerLocation(0,mFMODListener.gameObject)

    local audioinfo = AudioConfigData.GetAudio(audioId)
    local bankid = audioinfo.bankId
    local bank = mBankQueue:GetItemByKey(bankid)
    if bank and bank.loaded then
        local instance = GetAudioInstance(audioId)
        if transform then
            Set3DAttributes(instance,transform)
        end
        if audioinfo.oneShot then
            Play(instance)
            Release(instance)
        else
            Play(instance)
        end
    else
        LoadBank(bankid,function()
            PlayAudio(audioId)
        end)
    end
end

function StopAudio(audioId)
    local audioinfo = AudioConfigData.GetAudio(audioId)
    local instance = GetAudioInstance(audioId)
    Stop(instance,not audioinfo.allowFadeOut)
end

function GetAudioInstance(audioId)
    local audioinfo = AudioConfigData.GetAudio(audioId)
    local bankid = audioinfo.bankId
    local instance = mAudioCacheTabel[audioId]
    if mAudioCacheTabel[audioId] == nil then
        local bank = mBankQueue:GetItemByKey(bankid)
        if bank.loaded then
            instance = CreateInstance(audioinfo.event)
            if audioinfo.volume then
                SetVolume(instance,audioinfo.volume)
            end
            if audioinfo.pitch>0 then
                SetPitch(instance,audioinfo.pitch)
            end
            if audioinfo.listenerMask then
                SetListenerMask(instance,audioinfo.listenerMask)
            end
            if audioinfo.minDistance then
                SetMinimumDistance(instance,audioinfo.minDistance)
            end
            if audioinfo.maxDistance then
                SetMaximumDistance(instance,audioinfo.maxDistance)
            end
            if audioinfo.priority then
                SetChannelPriority(instance,audioinfo.priority)
            end
            if audioinfo.parameterCount then
                local count = audioinfo.parameterCount or 0
                if count>0 then
                    for i=1,count do
                        local pname = audioinfo.parameterNames[i]
                        local pvalue = audioinfo.parameterValues[i]
                        if pname and pvalue then
                            SetParameterValue(instance,pname,pvalue)
                        end
                    end
                end
            end

            if audioinfo.category == Audio_pb.AudioDetail.SOUND then
                if not audioinfo.oneShot then
                    mAudioCacheTabel[audioId] = instance
                end
            elseif audioinfo.category == Audio_pb.AudioDetail.MUSIC then
                if mAudioCacheTabel.BgmId== nil then
                    mAudioCacheTabel.BgmId = audioId
                    mAudioCacheTabel[audioId] = instance
                elseif mAudioCacheTabel.BgmId ~= audioId then
                    local bgm=mAudioCacheTabel.BgmId
                    Stop(mAudioCacheTabel[bgm],not audioinfo.allowFadeOut)
                    Release(mAudioCacheTabel[bgm])
                    mAudioCacheTabel[bgm]= nil
                    mAudioCacheTabel.BgmId = audioId
                    mAudioCacheTabel[audioId] = instance
                end
            end
        end
    end
    return instance
end

--UI音效触发
function OnUISound(soundType)
    local audioId = soundType +1
    PlayAudio(audioId,nil)
end

--==============================--
--desc:原生方法
--==============================--
function AnyBankLoading()
    return SDKAudio:AnyBankLoading()
end

function EnableListener(listenerNumber,enable)
    SDKAudio:EnableListener(listenerNumber,enable)
end

function SetListenerLocation(listenerNumber,gameObject)
    SDKAudio:SetListenerLocation(listenerNumber,gameObject)
end

function PlayOneShot(event,position)
    SDKAudio:PlayOneShot(event,position)
end

function PlayOneShotAttached(event,gameObject)
    SDKAudio:PlayOneShotAttached(event,gameObject)
end

--EventInstance 创建和控制函数如下
function CreateInstance(event)
    return SDKAudio:CreateInstance(event)
end

--附着于
function AttachInstanceToGameObject(instance, transform)
    SDKAudio:AttachInstanceToGameObject(instance,transform)
end

--取消附着
function DetachInstanceFromGameObject(instance)
    SDKAudio:DetachInstanceFromGameObject(instance)
end

--暂停所有事件
function PauseAllEvents(paused)
    SDKAudio:PauseAllEvents(paused);
end

--静音
function MuteAllEvents(muted)
    SDKAudio:MuteAllEvents(muted);
end

--获得事件路径
function GetPath(instance)
    return SDKAudio:GetPath(instance);
end

--获得长度
function GetLength(instance)
    return SDKAudio:GetLength(instance);
end

--设置音量
function SetVolume(instance,volume)
    SDKAudio:SetVolume(instance,volume);
end

--获取音量
function GetVolume(instance)
    return SDKAudio:GetVolume(instance);
end

--设置音调
function SetPitch(instance,pitch)
    SDKAudio:SetPitch(instance,pitch);
end

--获取音调
function GetPitch(instance)
    return SDKAudio:GetPitch(instance);
end

function SetListenerMask(instance,mask)
    SDKAudio:SetListenerMask(instance,mask);
end

function GetListenerMask(instance)
    return SDKAudio:GetListenerMask(instance);
end

function SetChannelPriority(instance,value)
    return SDKAudio:SetChannelPriority(instance,value);
end

function SetMinimumDistance(instance,value)
    return SDKAudio:SetMinimumDistance(instance,value);
end

function SetMaximumDistance(instance,value)
    return SDKAudio:SetMaximumDistance(instance,value);
end

function SetScheduleDelay(instance,value)
    return SDKAudio:SetScheduleDelay(instance,value);
end

function SetScheduleLookAhead(instance,value)
    return SDKAudio:SetScheduleLookAhead(instance,value);
end

function SetParameterValue(instance,name,value)
    return SDKAudio:SetParameterValue(instance,name,value);
end

function SetParameterValueByIndex(instance,index,value)
    return SDKAudio:SetParameterValueByIndex(instance,index,value);
end

function Play(instance)
    SDKAudio:Play(instance)
end

function IsPaused(instance)
    return SDKAudio:IsPaused(instance)
end

function Pause(instance,pause)
    SDKAudio:Pause(instance,pause)
end

function Stop(instance,immediate)
    SDKAudio:Stop(instance,immediate)
end

--释放instance
function Release(instance)
    SDKAudio:Release(instance)
end

function LoadSampleData(instance)
    SDKAudio:LoadSampleData(instance)
end

function UnLoadSampleData(instance)
    SDKAudio:UnLoadSampleData(instance)
end

--释放handle
function ClearHandle(instance)
    SDKAudio:ClearHandle(instance)
end

--设置3D声音属性
function Set3DAttributes(instance,transform)
    SDKAudio:Set3DAttributes(instance,transform);
end

function AddEventToCallBack(instance)
    SDKAudio:AddEventToCallBack(instance)
end

function RemoveEventToCallBack(instance)
    SDKAudio:RemoveEventToCallBack(instance)
end

function SetStopCallback(instance,callback)
    SDKAudio:SetStopCallback(instance,callback)
end

return AudioMgr