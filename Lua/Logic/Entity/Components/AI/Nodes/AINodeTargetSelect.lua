AINodeTargetSelect = class("AINodeTargetSelect",AINodeBase);

function AINodeTargetSelect:ctor()
    AINodeBase.ctor(self);
end

function AINodeTargetSelect:dtor()
    AINodeBase.dtor(self);
end

function AINodeTargetSelect:OnStart(aiData)
    self:SelectTarget(aiData);
end

function AINodeTargetSelect:OnUpdate(deltaTime,aiData)
    if aiData.skillTarget == nil and aiData.skillData.castType == SkillInfo_pb.SkillInfo.FORCE_TARGET then
        self:OnFail("entity_skill_no_target",aiData);
        return BTDefine.NODE_STATUS.FAILURE;
    else
        return BTDefine.NODE_STATUS.SUCCESS;
    end
end

function AINodeTargetSelect:OnAbort(aiData)
    BTNodeLeaf.OnAbort(self,aiData);
    aiData.skillTarget = nil;
    aiData.skillTargetDistance = nil;
    aiData.entityDistance = nil;
end

function AINodeTargetSelect:SelectTarget(aiData)
    --连击技能直接继承技能目标,不再进行筛选
    if aiData.skillData.castType == SkillInfo_pb.SkillInfo.FORCE_TARGET then
        --目标
        self:FindTarget(aiData);
    elseif aiData.skillData.castType == SkillInfo_pb.SkillInfo.FORCE_POINT then
        --目标点
        self:FindTarget(aiData);
        if not aiData.skillTarget then
            aiData.skillTarget = aiData.propertyComponent:GetPosition() + aiData.propertyComponent:GetForward() * aiData.skillUnitData.castingDistance;
        end
    elseif aiData.skillData.castType == SkillInfo_pb.SkillInfo.FORCE_SELF then
        --自己
        aiData.skillTarget = aiData.attacker;
    elseif aiData.skillData.castType == SkillInfo_pb.SkillInfo.FORCE_NONE then
        --空放
        aiData.skillTarget = nil;
    end
end

function AINodeTargetSelect:FindTarget(aiData)
    local selfPosition = aiData.attacker:GetPropertyComponent():GetPosition();
    if aiData.autoFightTargetID then aiData.autoFightTarget = MapMgr.GetEntityByID(aiData.autoFightTargetID); end
    aiData.skillTarget = nil;
    aiData.skillTargetDistance = nil;
    if not self:IsValid(aiData,aiData.autoFightTarget,selfPosition) then
        --自动目标
        for _,entity in ipairs(MapMgr.GetAllCharactor()) do
            if self:IsValid(aiData,entity,selfPosition) then
                aiData.skillTarget = entity;
                aiData.skillTargetDistance = aiData.entityDistance;
            end
        end
    else
        --手选目标
        aiData.skillTarget = aiData.autoFightTarget;
    end
end

function AINodeTargetSelect:IsValid(aiData,entity,selfPosition)
    --跳过无效或死亡目标
    if not entity or not entity:IsValid() then return false; end
    --检查阵营是否符合技能需求
    if not aiData.campComponent:IsValidSkillTarget(entity,aiData.skillUnitData) then return false; end
    --检查目标是否在索敌范围内
    aiData.entityDistance = math.DistanceXZ(entity:GetPropertyComponent():GetPosition(),selfPosition);
    if aiData.entityDistance > aiData.SEARCH_DISTANCE then return false; end
    --检查攻击目标优先级
    if aiData.skillTarget then
        if aiData.skillTarget:GetType() ~= entity:GetType() then
            --指定类型
            local limitETType = UserData.GetAutoSkillLimitType();
            if limitETType == EntityDefine.SKILL_PRIORITY_TYPE.NONE then
                --没有限制
            elseif limitETType == EntityDefine.SKILL_PRIORITY_TYPE.PLAYER then
                --优先玩家
                return entity:GetServerType() == Common_pb.PLAYER;
            elseif limitETType == EntityDefine.SKILL_PRIORITY_TYPE.OTHER then
                --优先非玩家
                return entity:GetServerType() ~= Common_pb.PLAYER;
            end
        end
        --距离最近
        if aiData.entityDistance < aiData.skillTargetDistance then return true; end
    else
        return true;
    end
end