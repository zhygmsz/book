ActionComponent = class("ActionComponent",EntityComponent);

function ActionComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._animActionGroup = self._animActionGroup or AActionGroup.new(self);
    self._effectActionGroup = self._effectActionGroup or AActionGroup.new(self);
    self._hitActionTime = 0;
    self._HIT_LIMIT_TIME = ConfigData.GetValue("fight_hit_limit_time") or 200;
end

function ActionComponent:OnEnable()
    --出生表现
    self._animActionGroup:OnStart(self._entity._entityAtt.bornAnimID,-1,false,true);
end

function ActionComponent:OnUpdate(deltaTime)
    self._animActionGroup:OnUpdate(deltaTime);
    self._effectActionGroup:OnUpdate(deltaTime);
end

function ActionComponent:OnDestroy()
    self._animActionGroup:OnDestroy();
    self._effectActionGroup:OnDestroy();
end

function ActionComponent:PlayDeadAction(animID,attacker)
    --清空技能
    self._entity:GetSkillComponent():CancelSkill(EntityDefine.SKILL_CANCEL_TYPE.DEAD);
    --停止移动
    self._entity:GetMoveComponent():StopMove(0);
    --死亡表现
    self._animActionGroup:OnStart(-animID,-1,true,attacker);
end

function ActionComponent:PlayReviveAction(animID)
    --复活表现
    self._animActionGroup:OnStart(-animID,-1,true);
end

function ActionComponent:PlayHitAction(skillID)
    --受击表现
    if self._entity:GetStateComponent():CanEnterHit() then
        --限制受击的间隔
        if (GameTime.time_L - self._hitActionTime) <= self._HIT_LIMIT_TIME then return end
        local hitGroupID = self._entity:GetPropertyComponent():GetHitGroupID();
        local skillData = SkillData.GetSkillInfo(skillID);
        self._hitActionTime = GameTime.time_L;
        self._animActionGroup:OnStart(hitGroupID,skillData and skillData.hitGroupID or -1,true);
    end
end

function ActionComponent:PlayAnimAction(actionGroupID,forceStart)
    --动作表现
    return self._animActionGroup:OnStart(actionGroupID,-1,forceStart);
end

function ActionComponent:PlayRepeatAction(actionGroupID,repeatCount,repeatDelta)
    --非动作类表现,可以指定重复次数和重复间隔
    self._effectActionGroup:OnStartRepeat(actionGroupID,repeatCount,repeatDelta);
end

function ActionComponent:CancelAnimAction(cancelType)
    --打断正在播放的表现
    self._animActionGroup:OnCancel(cancelType);
end

return ActionComponent;