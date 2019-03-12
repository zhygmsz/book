--帮派管理
module("QTEMgr",package.seeall);

--当前的qte id
local mCurrentQTEId=nil
--当前的qte 组 id
local mCurrentQTEGroupId=nil
--当前播放队列
local mQTEQueue ={}
--当前播放的队列索引
local mCurrentQTEQueueIndex=1
--效果函数map
local mActionTable={}


--剧情回溯 time 单位秒
local function SequenceBackToTime(actionParams)
    if actionParams and actionParams[1] then
        local time = tonumber(actionParams[1])/1000
        SequenceMgr.SetCurrentTime(time)
    end
end

--角色播放动画 funcID功能组ID
local function PlayerDoAction(actionParams)
    if actionParams and actionParams[1] then
        local funcID = tonumber(actionParams[1])
        if funcID then
            ActionMgr.ExecuteActionGroup(funcID)
        end
    end
end

mActionTable[QTE_pb.QTEData.NONE]=nil
mActionTable[QTE_pb.QTEData.BACKTOTIME]=SequenceBackToTime
mActionTable[QTE_pb.QTEData.DOACTION]=PlayerDoAction

function InitModule()
    require("Logic/Presenter/UI/Story/UI_QTE");
end

--根据组id得到组列表
function GetQTEGroup(id)
   local temp= QTEData.GetGroupData(id)
   return temp
end

--根据id得到数据
function GetQTEData(id)
    local temp={}
    temp= QTEData.GetData(id)
    return temp
end

--开始一个QTE
function PlayQTEGroup(groupid)
    mQTEQueue ={}
    local group = GetQTEGroup(groupid)
    if group then 
        for i=1,#group do
            local qte = group[i]
            mQTEQueue[i]={}
            mQTEQueue[i].data = qte
            mQTEQueue[i].index = i
            mQTEQueue[i].result = 0 --0是默认 1 是成功 2是失败
        end
        PlayQTE(1)
    end
end

function PlayQTE(index)
    if mQTEQueue and mQTEQueue[index] and mQTEQueue[index].data then
        mCurrentQTEQueueIndex=index
        local data =mQTEQueue[index].data
        PlayQTEForceDelay(index,data.delayTime/1000)
    end
end

function PlayQTEForceDelay(index,delay)
    if mQTEQueue and mQTEQueue[index] and mQTEQueue[index].data then
        mCurrentQTEQueueIndex=index
        local data =mQTEQueue[index].data
        --设置回调
        UI_QTE.SetCallBack(BeforPlay,ActionSuccess,ActionFail,AfterPlay)
        --设置模式
        UI_QTE.SetData(data)
        GameTimer.AddTimer(delay,1,ShowUIQTE,nil)
    end
end
--打开UI
function ShowUIQTE()
    UIMgr.ShowUI(AllUI.UI_QTE)
end

function BeforPlay()
    
end

function AfterPlay()
    
end

--交互成功 执行actionType
function ActionSuccess()
    local index = mCurrentQTEQueueIndex
    local data = mQTEQueue[index].data
    mQTEQueue[index].result=1
    local Func = mActionTable[data.actionType]
    if Func then Func(data.actionParams) end
    if mCurrentQTEQueueIndex < table.getn(mQTEQueue) then
        PlayQTE(mCurrentQTEQueueIndex+1)
    else
        End()
    end
end
--失败的方法
function ActionFail()
    local index = mCurrentQTEQueueIndex
    local data = mQTEQueue[index].data
    mQTEQueue[index].result=2
    local Func = mActionTable[data.missType]
    if Func then Func(data.missParams) end
    local delay = data.delayTime/1000
    if data.missType == QTE_pb.QTEData.BACKTOTIME then
        local backtime = tonumber(data.missParams[1])/1000
        PlayQTEForceDelay(mCurrentQTEQueueIndex, delay-backtime)
        GameEvent.Trigger(EVT.STORY,EVT.SETTIME,{time=backtime,isBack =true});
    end
end

--结束
function End()

end

return QTEMgr