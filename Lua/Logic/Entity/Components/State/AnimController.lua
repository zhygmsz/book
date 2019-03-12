AnimController = class("AnimController")

local mAnimType = {};

local function IsTargetAnim(animName,animPrefix)
    if animName == nil or animName == "" then return false; end 
    local targetAnims = mAnimType[animPrefix];
    if not targetAnims then
        targetAnims = {};
        mAnimType[animPrefix] = targetAnims;
    end
    if targetAnims[animName] then return true; end
    if string.find(animName,animPrefix) then
        targetAnims[animName] = true;
        return true;
    else
        return false;
    end
end

function AnimController:ctor(stateComponent)
    self._entity = stateComponent._entity;
    self._stateComponent = stateComponent;
    self._propertyComponent = self._entity:GetPropertyComponent();
    self._moveComponent = self._entity:GetMoveComponent();
    self._modelObject = nil;
	self._onAnimFinishDelagate = self._onAnimFinishDelagate or GameCore.EntityModel.OnAnimPlayFinish(self.class.OnAnimFinish,self);
end

function AnimController:IsActionAnim(animName) return IsTargetAnim(animName,"Die") or IsTargetAnim(animName,"Action"); end
function AnimController:IsSkillAnim(animName) return IsTargetAnim(animName,"Skill"); end
function AnimController:IsHitAnim(animName) return IsTargetAnim(animName,"Hit"); end
function AnimController:IsIdleAnim(animName) return IsTargetAnim(animName,"Stand"); end
function AnimController:IsMoveAnim(animName) return IsTargetAnim(animName,"Run"); end
function AnimController:IsDizzyAnim(animName) return IsTargetAnim(animName,"Vertigo"); end
function AnimController:IsRepeatAnim(curAnimName,nextAnimName)
    if curAnimName == nextAnimName then return not self:IsHitAnim(nextAnimName) and not self:IsSkillAnim(nextAnimName); end
end
function AnimController:IsCombatAnim(animName)
    if IsTargetAnim(animName,"Skill") then return true; end
    if IsTargetAnim(animName,"Hit") then return true; end
    if IsTargetAnim(animName,"Die") then return true; end
    if IsTargetAnim(animName,"Action") then return true; end
end

function AnimController:OnUpdate(deltaTime)
end

function AnimController:OnAnimFinish()
    local animData = self._entity._entityAtt.stateData.client.animData;
    if animData.needTransmitAnim then 
        animData.needTransmitAnim = false;
        self:UpdateAnim(animData);
    elseif animData.autoExit then
        self:EnterState(animData.exitName);
    end
end

--[[
播放指定动画
animName        string          动画名称
fadeInTime      float           淡入时间(秒)
animSpeed       float           动画播放速度
hasAnimFinish      bool        动画播放完成是否需要回调,用于过渡动画
--]]
function AnimController:PlayAnim(animName,fadeInTime,animSpeed,hasAnimFinish)
	if self._modelObject then
		if hasAnimFinish then
            self._modelObject._loadScript:PlayAnimation(animName,fadeInTime or 0,animSpeed or 1,self._onAnimFinishDelagate);
		else
            self._modelObject._loadScript:PlayAnimation(animName,fadeInTime or 0,animSpeed or 1);
        end
        if self._entity:IsPlayer() then
            --刷新战斗状态
            self._stateComponent:SyncClientState(Common_pb.ESOE_UPDATE,EntityDefine.CLIENT_STATE_TYPE.COMBAT,self:IsCombatAnim(animName));
        end
	end
end

--[[
播放坐骑动画
--]]
function AnimController:PlayRideAnim(animData)
    if not self._entity:IsPlayer() then return end
    local EANM = EntityDefine.ANIM_NAME;
    if animData.animName == EANM.ANIM_RIDE_IDLE then
        --当前角色处于坐骑待机状态
        self._modelObject._loadScript:PlayRideAnimation(EANM.ANIM_IDLE,animData.fadeInTime or 0,animData.animSpeed or 1);
    elseif animData.animName == EANM.ANIM_RIDE_MOVE then
        --当前角色处于坐骑移动状态
        self._modelObject._loadScript:PlayRideAnimation(EANM.ANIM_MOVE,animData.fadeInTime or 0,animData.animSpeed or 1);
    end
end

--[[
修改指定动画播放速度
animName    string      动画名称(如果不传,则强制修改当前动画速度)
animSpeed   float       动画速度
--]]
function AnimController:UpdateSpeed(animName,animSpeed)
    if not self._modelObject then return end
    local animData = self._entity._entityAtt.stateData.client.animData;
    if not animName or animData.curAnimName == animName then 
        self._modelObject._loadScript:SetAnimationSpeed(animSpeed);
    end
end

--更新动画
function AnimController:UpdateAnim(animData,forceUpdate)
    if animData.animUpdateFlag then
        --模型替换结束强制刷新动画
        forceUpdate = true;
        animData.enterFailFlag = false; 
    end
    if animData.enterFailFlag then
        --动画不做处理
        animData.enterFailFlag = false;
    elseif animData.needTransmitAnim then
        --中间过渡状态
        if not forceUpdate and self:IsRepeatAnim(animData.curAnimName,animData.transmitAnimName) then 
            self:UpdateSpeed(animData.curAnimName,animData.animSpeed); return;
        end
        animData.curAnimName = animData.transmitAnimName;
        self:PlayAnim(animData.transmitAnimName,animData.transmitFadeInTime,animData.animSpeed,true);
        self:PlayRideAnim(animData);
    elseif animData.autoExit then
        --自动退出到某个状态
        if not forceUpdate and self:IsRepeatAnim(animData.curAnimName,animData.animName) then 
            self:UpdateSpeed(animData.curAnimName,animData.animSpeed); return;
        end
        animData.curAnimName = animData.animName;
        self:PlayAnim(animData.animName,animData.fadeInTime,animData.animSpeed,true);
        self:PlayRideAnim(animData);
    else
        --直接播放某个动画
        if not forceUpdate and self:IsRepeatAnim(animData.curAnimName,animData.animName) then 
            self:UpdateSpeed(animData.curAnimName,animData.animSpeed); return;
        end
        animData.curAnimName = animData.animName;
        self:PlayAnim(animData.animName,animData.fadeInTime,animData.animSpeed);
        self:PlayRideAnim(animData);
    end
end