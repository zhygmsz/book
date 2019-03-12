module("UI_MindLink",package.seeall);

--自己的私有变量
local _self=nil
--左右视图的UI
local allUIItems ={}
--点的预制体
local pointPrefab = nil
--自动移动的球的预制体
local ballPrefab = nil
--手的预制体
local handPrefab = nil
--左右视图根节点 
local leftRoot = nil
local rightRoot = nil
local offsetRoot=nil

--起始点的停留时间
local stopTime = 3
--当前状态 -1未开始 0游戏中 1成功 2失败 
local gameState = -1
--定时器
local timerTable = {}

local failEffectLoader = nil
local successEffectLoader = nil
local posintSize = Vector2(50,50)

local successResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_chuping_eff01.prefab")
local failResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_chuping_eff02.prefab")

--点的位置信息
local pointPositions = {}
pointPositions[1] = {Vector3(-222,-192,0),Vector3(-351,-192,0),Vector3(-383,-75,0)}
pointPositions[2] = {Vector3(222,-192,0),Vector3(351,-192,0),Vector3(383,-75,0)}

function OnCreate(self)
    _self=self
    offsetRoot = self:Find("Offset");
    pointPrefab = self:Find("Offset/Prefab/Point").gameObject;
    ballPrefab = self:Find("Offset/Prefab/BallRoot").gameObject;
    handPrefab = self:Find("Offset/Prefab/HandRoot").gameObject;

    pointPrefab:SetActive(false)
    ballPrefab:SetActive(false)
    handPrefab:SetActive(false)

    leftRoot = self:Find("Offset/Left").gameObject;
    rightRoot = self:Find("Offset/Right").gameObject;
    InitPointPan()
end

--初始化点位
function InitPointPan()
   for i=1,#pointPositions do
       local pointPos = pointPositions[i]
       if allUIItems[i]==nil then allUIItems[i]={} end
       local parent =allUIItems[i]
       local root = (i==1) and leftRoot or rightRoot
       for j=1,#pointPos do
            if parent.pointPans==nil then allUIItems[i].pointPans={} end
            if parent.pointPans[j]==nil then allUIItems[i].pointPans[j]={} end
            parent.pointPans[j].transform = _self:DuplicateAndAdd(pointPrefab.transform,root.transform,j);
            parent.pointPans[j].gameObject =  parent.pointPans[j].transform.gameObject
            parent.pointPans[j].gameObject:SetActive(true)
            parent.pointPans[j].gameObject.name =string.format("Point%d",j)
            parent.pointPans[j].transform.localPosition = pointPos[j]
            parent.pointPans[j].tag = i
            parent.pointPans[j].index = j
       end
       parent.panRect={}
       parent.panRect.transform =  root.transform:Find("PanRect");
       parent.panRect.widget =  parent.panRect.transform:GetComponent("UIWidget");

       parent.handRoot={}
       parent.handRoot.tag = i
       parent.handRoot.step = 1
       parent.handRoot.finsh = 0
       parent.handRoot.transform = _self:DuplicateAndAdd(handPrefab.transform,root.transform,i);
       parent.handRoot.gameObject = parent.handRoot.transform.gameObject
       parent.handRoot.sprite = parent.handRoot.transform:GetComponent("UISprite");
       parent.handRoot.transform.gameObject:SetActive(true)

       parent.ballRoot={}
       parent.ballRoot.tag = i
       parent.ballRoot.step = 1
       parent.ballRoot.finsh = 0
       parent.ballRoot.transform = _self:DuplicateAndAdd(ballPrefab.transform,root.transform,i);
       parent.ballRoot.gameObject = parent.ballRoot.transform.gameObject
       parent.ballRoot.sprite = parent.handRoot.transform:GetComponent("UISprite");
       parent.ballRoot.transform.gameObject:SetActive(true)
   end
end

function OnEnable(self)
    TouchMgr.SetEnableNGUIMode(false)
    TouchMgr.SetEnableCameraOperate(false)
    TouchMgr.SetListenOnTouch(UI_MindLink,true);
    UpdateBeat:Add(Update,self);
    UpdateView()
end

function OnDisable(self)
    TouchMgr.SetTouchEventEnable(false)
    TouchMgr.SetEnableNGUIMode(true)
    TouchMgr.SetEnableCameraOperate(true)
    TouchMgr.SetListenOnTouch(UI_MindLink,false);
    UpdateBeat:Remove(Update,self);
    for i,v in ipairs(timerTable) do
        GameTimer.DeleteTimer(v)
    end
    timerTable={}
end

--更新显示
function UpdateView()
    ShowBalls()
    BeginMoveBalls()
end

--隐藏球
function HideBalls()
    for i=1,#allUIItems do
        local ball = allUIItems[i].ballRoot
        ball.gameObject:SetActive(false)
    end
end

--显示球
function ShowBalls()
    for i=1,#allUIItems do
        local ball = allUIItems[i].ballRoot
        ball.gameObject:SetActive(true)
    end
end

--开始移动
function BeginMoveBalls()
    for i=1,#allUIItems do
        local ball = allUIItems[i].ballRoot
        ball.step=1
        ball.finish=0
        DoMoveBall(ball)
    end
end

--球移动
function DoMoveBall(ball)
    local index = ball.tag
    local step = ball.step
    local pointPos = pointPositions[index]
    local count = table.getn(pointPos)
    local point1 = pointPos[step]
    local next = step%count+1
    local point2 = pointPos[next]
    --起始点位置 停留一定时间
    if step == 1 and gameState==-1 then
        ball.transform.localPosition = point1
        ball.timer = GameTimer.AddTimer(stopTime, 1, MoveBallOneParam,nil,{ball,point1,point2,1});
        table.insert(timerTable,ball.timer)
    else
        MoveBall(ball,point1,point2,1)
    end
end

--结束移动回调
local function OnTweenFinish(ball)
    local index = ball.tag
    local step = ball.step
    --到达点 记录数字
    if gameState==0 then
        ball.finish = step
    end
    local pointPos = pointPositions[index]
    local count = table.getn(pointPos)
    local next = step%count+1
    ball.step=next
    DoMoveBall(ball)
end

--求开始在点位之间移动
--[[Method
	{
		Linear,
		EaseIn,
		EaseOut,
		EaseInOut,
		BounceIn,
		BounceOut,
	}]]
function MoveBall(ball,point1,point2,t)
    if not ball.tween then
        ball.finish_func = EventDelegate.Callback(OnTweenFinish,ball);
        ball.tween = ball.gameObject:AddComponent(typeof(TweenPosition));
        ball.tween.ignoreTimeScale = false;
        EventDelegate.Set(ball.tween.onFinished,ball.finish_func);
    end
    ball.tween.enabled = true
    ball.tween.from =point1
    ball.tween.to = point2
    ball.tween.method = UITweener.Method.EaseIn
    ball.tween.duration = t
	ball.tween:ResetToBeginning()
    ball.tween:PlayForward()
end

--参数合为一个table
function MoveBallOneParam(param)
    local ball = param[1]
    local point1 = param[2]
    local point2 = param[3]
    local t = param[4]
    MoveBall(ball,point1,point2,t)
end

--链接点位和点位
function LinkPointAndHand(point1,point2)
    
end

--检测是否进入开始状态
function CheckBegin()
    if gameState==-1 then
        local begin=true
        for i=1,#allUIItems do
            local hand = allUIItems[i].handRoot
            hand.finish=0
            hand.step=1
            local index = hand.tag
            local step = hand.step
            local pointPos = pointPositions[index]
            local point = pointPos[1]
            begin = begin and CheckHandInPoint(hand,point)
        end
        if begin then
            GameLog.Log("begin")
            gameState=0
            OnLinkBegin()
        end
    end
end

--开始游戏
function OnLinkBegin()
    for i=1,#allUIItems do
        local ball = allUIItems[i].ballRoot
        if ball.timer then
            GameTimer.DeleteTimer(ball.timer)
        end
        HideBalls()
    end
end

--检查手是否到了点位
function CheckHandInPoint(hand,point)
    local x =point.x
    local y =point.y
    local w = posintSize.x
    local h = posintSize.y
    local cx = hand.transform.localPosition.x
    local cy = hand.transform.localPosition.y
    local result = false
    if cx>=(x-w/2) and cx<=(x+w/2) and (cy>=y-h/2) and (cy<=y+h/2) then
        result = true
    end
    return result
end

--当球到达点位手检查手指是否在点位
function CheckHandInBall(ball)
    local index = ball.tag
    local step = ball.step
    local pointPos = pointPositions[index]
    local count = table.getn(pointPos)
    local next = step%count+1
    local point = pointPos[step]
    local hand = allUIItems[index].handRoot
    local x =ball.transform.localPosition.x
    local y =ball.transform.localPosition.y
    local w = ball.sprite.width
    local h = ball.sprite.height
    local cx = hand.transform.localPosition.x
    local cy = hand.transform.localPosition.y
    local result = false
    if cx>=(x-w/2) and cx<=(x+w/2) and (cy>=y-h/2) and (cy<=y+h/2) then
        result = true
    end
    return result
end

--检查是否连上了所有点
function CheckHandFinish(hand)
    if gameState==0 then
        local index = hand.tag
        local step = hand.step
        local pointPos = pointPositions[index]
        local count = table.getn(pointPos)
        return hand.finish==count
    end
    return false
end

--检查手是否是按顺序 到达点位的 不是返回false 是返回true 还未到达返回nil
function CheckHandReachCorrect(hand)
    local index = hand.tag
    local step = hand.step
    local pointPos = pointPositions[index]
    local count = table.getn(pointPos)
    local next = step%count+1
    for j=1,count-1 do
        local pindex = (step+j-1)%count+1
        local point = pointPos[pindex]
        if CheckHandInPoint(hand,point) then
            if pindex == next then
                hand.finish = step
                hand.step=next
                return true
            else
                hand.finish = 0
                hand.step=1
                return false
            end
        end
    end
    return nil
end

--检查状态
function CheckLinkState()
    if gameState==-1 then
        CheckBegin()
    elseif gameState==0 then
        local failed=true
        local finished=true
        for i=1,#allUIItems do
            local hand = allUIItems[i].handRoot
            local r = CheckHandReachCorrect(hand)
            if r ~=nil then failed = failed and r end
            finished = finished and CheckHandFinish(hand)
        end
        if not failed then--失败
            gameState=2
            LinkFailed()
        end
        if finished then--成功
            gameState=1
            LinkSucceed()
        end
    end
end

--任务失败
function  LinkFailed()
    GameLog.Log("LinkFailed!!!!")
    if failEffectLoader then
        failEffectLoader:SetActive(true,true);
    else
        failEffectLoader = LoaderMgr.CreateEffectLoader();
        failEffectLoader:LoadObject(failResId);
        failEffectLoader:SetParent(UIMgr.GetUIRootTransform());
        failEffectLoader:SetLocalScale(Vector3(2,2,2));
        failEffectLoader:SetSortOrder(700);
    end
    local function OnFailTimeFinish()
        gameState = -1
        ShowBalls()
        BeginMoveBalls()
    end
    GameTimer.AddTimer(2, 1, OnFailTimeFinish);
end

--完成任务
function  LinkSucceed()
    GameLog.Log("bravo!!!!")
    if successEffectLoader then
        successEffectLoader:SetActive(true,true);
    else
        successEffectLoader = LoaderMgr.CreateEffectLoader();
        successEffectLoader:LoadObject(successResId);
        successEffectLoader:SetParent(UIMgr.GetUIRootTransform());
        successEffectLoader:SetLocalScale(Vector3(2,2,2));
        successEffectLoader:SetSortOrder(700);
    end
    local function OnSuccessTimeFinish()
        gameState = -1
        ShowBalls()
        BeginMoveBalls()
    end
    GameTimer.AddTimer(2, 1, OnSuccessTimeFinish);
end

function OnTouchStart(gesture)
    -- body
end

function OnTouchDown(gesture)
    local finger = gesture.fingerIndex+1;
    local wp = UIMgr.GetCamera():ScreenToWorldPoint(Vector3(gesture.position.x,gesture.position.y,0));
    wp = Vector3(wp.x,wp.y,0)
    local localpos = UIMgr.GetCamera().transform:InverseTransformPoint(wp);
    localpos.z=0
    local index = (localpos.x>=0) and 2 or 1 
    local root = allUIItems[index]
    local x =root.panRect.transform.localPosition.x
    local y =root.panRect.transform.localPosition.y
    local w = root.panRect.widget.width
    local h = root.panRect.widget.height
    localpos.x=Mathf.Clamp(localpos.x, x-w/2, x+w/2)
    localpos.y=Mathf.Clamp(localpos.y, y-h/2, y+h/2)
    root.handRoot.transform.localPosition = localpos
    CheckHandInBall(root.ballRoot)
end

function OnTouchUp(gesture)
    if gameState==0 then
        gameState=2
        LinkFailed()
    end
end

function OnClick(go,id)
	if id == 0 then
       UIMgr.UnShowUI(AllUI.UI_MindLink)
	end
end

function Update()
    CheckLinkState()
end
