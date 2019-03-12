Skill = class("Skill")

function Skill:ctor(skillComponent,skillIndex,skillUnitID)
    --技能表现基本信息
    self._skillComponent = skillComponent;
    self._skillIndex = skillIndex or -1;
    self._skillLevel = nil;
    self._skillUnitID = skillUnitID;
    self._skillUnitData = SkillData.GetSkillUnitData(skillUnitID);
    --技能释放状态信息
    self._skillPassedTime = 0;
    self._skillCasting = false;
    self._skillComboAction = nil;
    self._skillMoveLimitAction = nil;
    self._skillMoveRotateLimitAction = nil;
    --技能表现行为信息
    self._skillActions = {};
    for _,actionAtt in ipairs(self._skillUnitData.actions) do
        local action = SkillActionFactory.CreateAction(self,actionAtt);
        if action then  
            self._skillActions[#self._skillActions + 1] = action; 
            if actionAtt.actionType == Skill_pb.SkillAction.SKILL_COMBO then
                self._skillComboAction = action;
            elseif actionAtt.actionType == Skill_pb.SkillAction.LIMIT_MOVE then
                self._skillMoveLimitAction = action;
            elseif actionAtt.actionType == Skill_pb.SkillAction.LIMIT_MOVE_ROTATE then
                self._skillMoveRotateLimitAction = action;
            end
        else
            GameLog.LogError("undefine skill action %s",actionAtt.actionType);
        end
    end
end

function Skill:dtor()
    --删除当前技能的action
    for _,action in ipairs(self._skillActions) do
        SkillActionFactory.DestroyAction(action);
    end
    self._skillActions = nil;
end

function Skill:UpdateCD(deltaTime,passedTime)
    if self._skillUnitData.skillCDTime <= 0 then return end
    if not self._skillComponent._entity:IsSelf() then return end
    if self._skillCDStart then return end
    if self._skillUnitData.skillCDStartTime > passedTime then return end
    self._skillCDStart = true;
    UserData.SetSkillCD(self._skillUnitID,self._skillUnitData.skillCDTime);
end

function Skill:UpdateAction(deltaTime,passedTime)
    for _,action in ipairs(self._skillActions) do 
        if self._skillCasting then
            action:OnUpdate(deltaTime,passedTime); 
        end
    end
end

function Skill:UpdateBullet(deltaTime,passedTime)
    if self._skillCasting then
        for i = 1,#self._skillUnitData.emitters do
            local emitter = self._skillUnitData.emitters[i];
            --检查是否需要创建粒子
            for j = 1,#emitter.particles do
                local particle = emitter.particles[j];
                --当前帧内生效
                if particle.effectID ~= "" and particle.startTime >= self._skillPassedTime and particle.startTime < passedTime then
                    local bulletAtt = table.tmpEmptyTable();
                    bulletAtt.skill = self;
                    bulletAtt.emitter = emitter;
                    bulletAtt.particle = particle;
                    bulletAtt.target = self._skillTarget;
                    MapMgr.CreateEntity(EntityDefine.ENTITY_TYPE.BULLET,nil,bulletAtt);
                end
            end
        end
    end
end

function Skill:UpdateTime(deltaTime,passedTime)
    if self._skillCasting then
        self._skillPassedTime = passedTime;
        self._skillCasting = passedTime <= self._skillUnitData.skillTotalTime;
    end
end

function Skill:OnUpdate(deltaTime)
    if self._skillCasting then
        local passedTime = self._skillPassedTime + deltaTime;
        --更新技能CD状态
        self:UpdateCD(deltaTime,passedTime);
        --更新技能ACTION
        self:UpdateAction(deltaTime,passedTime);
        --更新粒子发射器
        self:UpdateBullet(deltaTime,passedTime);
        --修改已持续时间
        self:UpdateTime(deltaTime,passedTime);
    end
end

function Skill:OnModelLoad()
    if self._skillCasting then
        for _,action in ipairs(self._skillActions) do action:OnModelLoad(); end
    end
end

function Skill:OnModelReplace()
    if self._skillCasting then
        for _,action in ipairs(self._skillActions) do action:OnModelReplace(); end
    end
end

function Skill:UpdateCombo(comboTarget)
    if self._skillComboAction then
        self._skillComboAction:UpdateTarget(comboTarget);
    end
end

function Skill:CastCombo()
    if self._skillComboAction then
        self._skillComboAction:CastSkill();
    end
end

function Skill:CastSkill(skillLevel,skillTarget)
    if self:HasMoveLimit() then
        self._skillComponent._entity:GetMoveComponent():StopMove(0);
        self._skillComponent._entity:GetPropertyComponent():LookTarget(skillTarget);
    end
    self._skillCasting = true;
    self._skillCDStart = false;
    self._skillPassedTime = 0;
    self._skillLevel = skillLevel;
    self._skillTarget = skillTarget;
    self:OnUpdate(0);
end

function Skill:CancelSkill(cancelType)
    if self._skillCasting then
        local cancelMask = self._skillUnitData.cancelMask;
        local stateComponent = self._skillComponent._entity:GetStateComponent();
        if stateComponent:CanCancelSkill(self._skillUnitID,cancelType,cancelMask) then
            self._skillCasting = false;
            for _,action in ipairs(self._skillActions) do action:OnCancel(); end
        end
    end
end

function Skill:GetComboSkill(comboSkillID)
    local skillLevelData = SkillData.GetSkillLevelInfo(comboSkillID,self._skillLevel);
    if not skillLevelData then
        GameLog.LogError("combo skill level data is null skillID:%s skillLevel:%s",comboSkillID,self._skillLevel); 
        return;
    end
    local skillUnitData = SkillData.GetSkillUnitData(skillLevelData.unit);
    if not skillUnitData then
        GameLog.LogError("combo skill unit data is null skillID:%s skillLevel:%s skillUnit:%s",comboSkillID,self._skillLevel,skillLevelData.unit); 
        return;
    end
    return self._skillIndex,skillLevelData.unit,self._skillLevel;
end

--技能是否正在释放
function Skill:IsSkillCasting()
    return self._skillCasting;
end

--连击是否已被激活
function Skill:IsComboActive()
    return self._skillComboAction and self._skillComboAction._autoCastSkill;
end

--是否为连击技能
function Skill:HasComboSkill()
    return self._skillComboAction ~= nil;
end

--是否为站桩技能
function Skill:HasMoveLimit()
    return self._skillMoveRotateLimitAction ~= nil or self._skillMoveLimitAction ~= nil;
end