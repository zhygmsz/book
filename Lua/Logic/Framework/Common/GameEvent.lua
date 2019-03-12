module("GameEvent",package.seeall);

local mEvents = {};
local mEventSID = 0;
local mEventEID = 0;
local xpcall = xpcall;
local traceback = traceback;
local mAllListeners = {}
local mFuncPool = {};

local function AllocFuncData(func,obj)
    local funcData = mFuncPool[#mFuncPool];
    if funcData then
        mFuncPool[#mFuncPool] = nil;
    else
        funcData = {};
    end
    funcData.func = func;
    funcData.obj = obj;
    return funcData;
end

local function FreeFuncData(funcData)
    funcData.func = nil;
    funcData.obj = nil;
    mFuncPool[#mFuncPool + 1] = funcData;
end

function InitModule()
    _G.EVT = mEvents;
end

--[[
定义事件组
--]]
function GEN_GROUP(sysName)
    if mEvents[sysName] then GameLog.LogError("%s already has been registered!", sysName) end
    mEventSID = mEventSID + 1;
    mEvents[sysName] = mEventSID;
end

--[[
定义事件
--]]
function GEN_EVENT(evtName)
    if mEvents[evtName] then GameLog.LogError("%s already has been registered!", evtName) end
    mEventEID = mEventEID + 1;
    mEvents[evtName] = mEventEID;
end

--[[
注册事件监听函数
sysID   int      事件所属系统ID,使用 EVT.XX
evtID   int      事件ID,使用 EVT.XX
func    function 事件触发回调
obj     class    事件回调所属类对象
--]]
function Reg(sysID,evtID,func,obj)
    if sysID ~= nil and evtID ~= nil and func ~= nil then
        --某个系统的监听表
        local systemListeners = mAllListeners[sysID] or {};
        mAllListeners[sysID] = systemListeners;
        --某个系统某个事件的监听表
        local eventListeners = systemListeners[evtID] or {};
        systemListeners[evtID] = eventListeners;
        --新建一个回调对象
        local funcData = AllocFuncData(func,obj);
        eventListeners[#eventListeners + 1] = funcData;
    else
        GameLog.LogError("can't reg nil event %s %s %s",sysID,evtID,func);
    end
end

--[[
注销事件监听函数
sysID   int      事件所属系统ID,使用 EVT.XX
evtID   int      事件ID,使用        EVT.XX
func    function 事件触发回调
obj     class    事件回调所属类对象
--]]
function UnReg(sysID,evtID,func,obj)
    if sysID ~= nil and evtID ~= nil and func ~= nil then
        --某个系统的监听表
        local systemListeners = mAllListeners[sysID] or {};
        mAllListeners[sysID] = systemListeners;
        --某个系统某个事件的监听表
        local eventListeners = systemListeners[evtID] or {};
        systemListeners[evtID] = eventListeners;
        --移除对应的监听对象
        for key,funcData in pairs(eventListeners) do
            if funcData.func == func then
                if (funcData.obj == nil and obj == nil) or (funcData.obj ~= nil and obj ~= nil and funcData.obj == obj) then
                    FreeFuncData(funcData);
                    eventListeners[key] = nil;
                    return;
                end
            end
        end
    else
        GameLog.LogError("can't unreg nil event %s %s %s",sysID,evtID,func);
    end
end

--[[
触发某个事件
sysID   int      事件所属系统ID,使用 GameEvent.XX
evtID   int      事件ID,使用GameEvent.XX
...              事件额外参数
--]]
function Trigger(sysID,evtID,...)
    if sysID ~= nil and evtID ~= nil then
        --某个系统的监听表
        local systemListeners = mAllListeners[sysID] or {};
        mAllListeners[sysID] = systemListeners;
        --某个系统某个事件的监听表
        local eventListeners = systemListeners[evtID] or {};
        systemListeners[evtID] = eventListeners;
        --执行事件回调
        local listenerCount = table.maxn(eventListeners);
        for i = 1,listenerCount do
            local listener = eventListeners[i];
            if listener then
                if listener.obj then            
                    local flag,msg = xpcall(listener.func,traceback,listener.obj,...);
                    if not flag then
                        GameLog.LogError("call func error-> %s",msg);
                    end
                else
                    local flag,msg = xpcall(listener.func,traceback,...);
                    if not flag then
                        GameLog.LogError("call func error-> %s",msg);
                    end
                end
            end
        end
    else
        GameLog.LogError("can't trigger nil event %s %s",sysID,evtID);
    end
end

return GameEvent;