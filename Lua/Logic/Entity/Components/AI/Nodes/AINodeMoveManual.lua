AINodeMoveManual = class("AINodeMoveManual",AINodeBase);

function AINodeMoveManual:ctor()
    AINodeBase.ctor(self);
end

function AINodeMoveManual:dtor()
    AINodeBase.dtor(self);
end

function AINodeMoveManual:OnStart(aiData)
    aiData.manualMoveFlag = false;
    --当前没有移动操作
    if (not aiData.manualMoveDx) and (not aiData.manualMoveDy) and (not aiData.manualMoveDest) then return end
    --控制状态不可移动
    if UserData.IsInControl() then return end
    --不可移动状态
    local canMove,canRotate = aiData.stateComponent:CanMove(),aiData.stateComponent:CanRotate();
    if not canMove and not canRotate then return end
    if aiData.manualMoveDx and aiData.manualMoveDy then
        --摇杆移动
        aiData.moveComponent:MoveWithJoystick(aiData.manualMoveDx,aiData.manualMoveDy);
        aiData.manualMoveDx = nil;
        aiData.manualMoveDy = nil;
        aiData.manualMoveFlag = true;
    elseif aiData.manualMoveDest and canMove then
        --点地移动
        aiData.moveComponent:MoveWithDest(aiData.manualMoveDest);
        aiData.manualMoveDest = nil;
        aiData.manualMoveFlag = true;
    else
        
    end
end

function AINodeMoveManual:OnUpdate(deltaTime,aiData)
    if aiData.manualMoveFlag and aiData.moveComponent:IsMoving() then return BTDefine.NODE_STATUS.RUNNING; end
    return BTDefine.NODE_STATUS.FAILURE;
end

function AINodeMoveManual:OnAbort(aiData)
    AINodeBase.OnAbort(self);
    aiData.manualMoveFlag = false;
    aiData.manualMoveDx = nil;
    aiData.manualMoveDy = nil;
    aiData.manualMoveDest = nil;
end