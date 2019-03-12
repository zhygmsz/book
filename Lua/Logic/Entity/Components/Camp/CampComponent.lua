CampComponent = class("CampComponent",EntityComponent);

function CampComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function CampComponent:GetCampRelation(targetEntity)
    local selfCamps = self._entity._entityAtt.factions;
    local targetCamps = targetEntity._entityAtt.factions;
    for i = #selfCamps,1,-1 do
        local selfCamp = selfCamps[i];
        local targetCamp = targetCamps[i];
        if i == 1 then
            --初级阵营读表检查关系
            return CampData.GetCampRelation(selfCamp,targetCamp);
        elseif selfCamp ~= nil and targetCamp ~= nil then
            --高级阵营只有友好和敌对
            if selfCamp ~= targetCamp then return Common_pb.CRE_RED; end
        end
    end
end

function CampComponent:IsRed(targetEntity)
    return self:GetCampRelation(targetEntity) == Common_pb.CRE_RED;
end

function CampComponent:IsGreen(targetEntity)
    return self:GetCampRelation(targetEntity) == Common_pb.CRE_GREEN;
end

function CampComponent:IsValidSkillTarget(targetEntity,skillUnitData)
    local campRelation = self:GetCampRelation(targetEntity);
    local targetEnemy = math.ContainsBitMask(skillUnitData.targetMask,Skill_pb.Skill.TARGET_ENEMY);
    if targetEnemy then
        --攻击目标包含敌方类型,对敌方和中立关系生效
        if campRelation == Common_pb.CRE_RED or campRelation == Common_pb.CRE_YELLOW then return true; end
    end
    local targetFriend = math.ContainsBitMask(skillUnitData.targetMask,Skill_pb.Skill.TARGET_FRIEND);
    if targetFriend then
        --攻击目标包含友方类型,对友好关系生效
        if campRelation == Common_pb.CRE_GREEN then return true; end
    end
    local targetSelf = math.ContainsBitMask(skillUnitData.targetMask,Skill_pb.Skill.TARGET_SELF);
    if targetSelf then
        --攻击目标包含自己类型,对自己生效
        if targetEntity == self._entity then return true end
    end
    local targetOwner = math.ContainsBitMask(skillUnitData.targetMask,Skill_pb.Skill.TARGET_OWNER);
    if targetOwner then
        local masterID = self._entity:GetMasterID();
        if masterID and masterID == targetEntity:GetID() then return true end
    end
    --没有符合条件的目标
    return false;
end

return CampComponent;