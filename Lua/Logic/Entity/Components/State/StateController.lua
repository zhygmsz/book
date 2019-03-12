StateController = class("StateController",AnimController)

function StateController:ctor(...)
    AnimController.ctor(self,...);
end

function StateController:OnModelLoad(modelObject)
    self._modelObject = modelObject;
    local animData = self._entity._entityAtt.stateData.client.animData;
    if self._moveComponent:IsMoving() then
        --移动状态
        animData.animUpdateFlag = true;
        self:EnterState(EntityDefine.ANIM_NAME.ANIM_MOVE);
        animData.animUpdateFlag = false;
    else
        --待机状态
        animData.animUpdateFlag = true;
        self:EnterState(EntityDefine.ANIM_NAME.ANIM_IDLE);
        animData.animUpdateFlag = false;
    end
end

function StateController:OnUpdate(deltaTime)
    if self._entity:IsPlayer() then
        --自动退出战斗状态
        local animData = self._entity._entityAtt.stateData.client.animData;
        if animData.autoExitCombat and animData.autoExitTime <= GameTime.time_L then
            self._stateComponent:SyncClientState(Common_pb.ESOE_UPDATE,EntityDefine.CLIENT_STATE_TYPE.COMBAT,false);
            self:EnterIdle(animData);
            self:UpdateAnim(animData);
        end
    end
end

function StateController:EnterState(animName,autoExit,exitName,forcePlay)
    local animData = self._entity._entityAtt.stateData.client.animData;
    animData.newAnimName = animName;
    animData.newAutoExit = autoExit;
    animData.newExitName = exitName;
    animData.newForcePlay = forcePlay;
    self:UpdateState();
end

--更新动画状态
function StateController:UpdateMoveAnim()
    if self._entity:IsPlayer() and self._moveComponent:IsMoving() then
        local animData = self._entity._entityAtt.stateData.client.animData;
        self:EnterMove(animData);
        self:UpdateAnim(animData);
    end
end

--更新动画状态
function StateController:UpdateState(forceUpdate)
    local animData = self._entity._entityAtt.stateData.client.animData;
    if not animData.newAnimName and not forceUpdate then return end
    local newAnimName = animData.newAnimName;
    if self:IsActionAnim(newAnimName) then
        --视觉表现动作
        self:EnterAction(animData);
    elseif self._stateComponent:HasServerState(Common_pb.ESE_CT_DEAD) then
        --进入躺尸状态
        self:EnterDead(animData);
    elseif self._stateComponent:HasServerState(Common_pb.ESE_CT_VERTIGO) then
        --进入眩晕状态
        self:EnterDizzy(animData);
    elseif self:IsIdleAnim(newAnimName) then
        --进入待机状态(有过渡)
        self:EnterIdle(animData);
    elseif self:IsMoveAnim(newAnimName) then
        --进入移动状态
        self:EnterMove(animData);
    elseif self:IsSkillAnim(newAnimName) then
        --进入技能状态
        self:EnterSkill(animData);
    elseif self:IsHitAnim(newAnimName) then
        --进入受击状态
        self:EnterHit(animData);
    elseif self:IsDizzyAnim(animData.curAnimName) then
        --退出眩晕状态
        self:LeaveDizzy(animData);
    else
        GameLog.LogError("invalid anim state");
        return;
    end
    self:UpdateAnim(animData);
end

--动画状态切换前处理,重置动画状态
function StateController:OnBeginEnterAnim(animData)
    animData.fadeInTime = 0;
    
    animData.animName = "";
    animData.animSpeed = 1;
    animData.exitName = "";

    animData.autoExit = false;
    animData.autoExitCombat = false;
    animData.autoExitTime = 0;

    animData.needTransmitAnim = false;
    animData.transmitAnimName = "";
    animData.transmitFadeInTime = 0;

    animData.enterFailFlag = false;
end

--动画状态切换后处理,重置新动画信息
function StateController:OnEndEnterAnim(animData)
    animData.newAnimName = nil;
    animData.newAutoExit = nil;
    animData.newExitName = nil;
    animData.newForcePlay = nil;
end

function StateController:EnterAction(animData)
    --TODO 无法播放表现动画
    self:OnBeginEnterAnim(animData);
    animData.animName = animData.newAnimName;
    animData.autoExit = animData.newAutoExit;
    animData.exitName = animData.newExitName;
    self:OnEndEnterAnim(animData);
end

function StateController:EnterDead(animData)
    --TODO 无法播放死亡动画
    self:OnBeginEnterAnim(animData);
    animData.animName = EntityDefine.ANIM_NAME.ANIM_DIE;
    self:OnEndEnterAnim(animData);
end

function StateController:EnterDizzy(animData)
    --TODO 无法播放眩晕动画
    self:OnBeginEnterAnim(animData);
    animData.animName = EntityDefine.ANIM_NAME.ANIM_DIZZY;
    self:OnEndEnterAnim(animData);
end

function StateController:EnterIdle(animData)
    --TODO 无法播放待机动画
    self:OnBeginEnterAnim(animData);
    if self._entity:IsPlayer() then
        if self._stateComponent:HasServerState(Common_pb.ESE_CT_INCOMBAT) then
            --战斗待机
            animData.animName = EntityDefine.ANIM_NAME.ANIM_ATTACK_IDLE;
            if animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_IDLE then
                --普通待机->战斗待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_ATTACK_IN;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_MOVE_FAST then
                --加速移动->战斗待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_MOVE_FAST_STOP;
            elseif not self._stateComponent:HasServerState(Common_pb.ESE_CT_INCOMBAT,true) then
                --客户端战斗待机自动退出
                animData.autoExitCombat = true;
                animData.autoExitTime = GameTime.time_L + animData.AUTO_EXIT_ATTACK_TIME;
            end
        elseif self._stateComponent:HasServerState(Common_pb.ESE_CT_BIND) then
            --坐骑待机
            animData.animName = EntityDefine.ANIM_NAME.ANIM_RIDE_IDLE;
            if animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_MOVE then
                --坐骑移动->坐骑待机
                animData.fadeInTime = 0.1;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_IDLE then
                --坐骑待机->坐骑待机
                animData.enterFailFlag = true;
            else
                --其它状态->坐骑待机
                if not self._entity:IsNewEntity() then
                    animData.needTransmitAnim = true;
                    animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_RIDE_ON;
                end
            end
        else
            --普通待机
            animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
            if animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_ATTACK_IDLE then
                --战斗待机->普通待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_ATTACK_OUT;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_MOVE then
                --普通移动->普通待机
                animData.fadeInTime = 0.3;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_MOVE_FAST then
                --加速移动->普通待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_MOVE_FAST_STOP;
                animData.fadeInTime = 0.3;
                animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_MOVE then
                --坐骑移动->普通待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_RIDE_OFF;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_MOVE_FAST_STOP then
                --加速急停->普通待机
                animData.fadeInTime = 0.3;
                animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_IDLE then
                --坐骑待机->普通待机
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_RIDE_OFF;
            elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_IDLE then
                --普通待机->普通待机
                animData.enterFailFlag = true;
            else
                --其它状态->普通待机
                animData.fadeInTime = 0.3;
                animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
            end
        end   
    else
        animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
        if animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_MOVE then
            --普通移动->普通待机
            animData.fadeInTime = 0.3;
        end
    end
    self:OnEndEnterAnim(animData);
end

function StateController:EnterMove(animData)
    --TODO 无法播放移动动画
    self:OnBeginEnterAnim(animData);
    local moveSpeed = self._propertyComponent:GetMoveSpeed();
    local moveStandardSpeed,runStandardSpeed,rideStandardSpeed = self._propertyComponent:GetStandardSpeed();
    if self._stateComponent:HasServerState(Common_pb.ESE_CT_BIND) then
        --坐骑移动
        animData.animName = EntityDefine.ANIM_NAME.ANIM_RIDE_MOVE;
        animData.animSpeed = moveSpeed / rideStandardSpeed;
        if animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_MOVE then
            --坐骑移动->坐骑移动
            animData.enterFailFlag = true;
        elseif animData.curAnimName == EntityDefine.ANIM_NAME.ANIM_RIDE_IDLE then
            --坐骑待机->坐骑移动
            animData.fadeInTime = 0.1;
        else
            --其它状态->坐骑移动
            if not self._entity:IsNewEntity() then
                animData.needTransmitAnim = true;
                animData.transmitAnimName = EntityDefine.ANIM_NAME.ANIM_RIDE_ON;
            end
        end
    elseif self._stateComponent:CanMoveQuick() then
        --加速移动
        animData.animName = EntityDefine.ANIM_NAME.ANIM_MOVE_FAST;
        animData.animSpeed = moveSpeed / runStandardSpeed;
    else
        --普通移动
        animData.animName = EntityDefine.ANIM_NAME.ANIM_MOVE;
        animData.animSpeed = moveSpeed / moveStandardSpeed;
    end
    self:OnEndEnterAnim(animData);
end

function StateController:EnterSkill(animData)
    --无法播放技能动画
    if self:IsSkillAnim(animData.curAnimName) and not animData.newForcePlay then return end
    self:OnBeginEnterAnim(animData);
    animData.animName = animData.newAnimName;
    animData.exitName = EntityDefine.ANIM_NAME.ANIM_IDLE;
    animData.autoExit = animData.newAutoExit;
    self:OnEndEnterAnim(animData);
end

function StateController:EnterHit(animData)
    --TODO 无法播放受击动画
    self:OnBeginEnterAnim(animData);
    animData.animName = animData.newAnimName;
    animData.exitName = EntityDefine.ANIM_NAME.ANIM_IDLE;
    animData.autoExit = true;
    self:OnEndEnterAnim(animData);
end

function StateController:LeaveDizzy(animData)
    --TODO 无法退出眩晕动画
    self:OnBeginEnterAnim(animData);
    animData.animName = EntityDefine.ANIM_NAME.ANIM_IDLE;
    animData.fadeInTime = 0.3;
    self:OnEndEnterAnim(animData);
end