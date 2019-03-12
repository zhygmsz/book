FACT_Fixed = class("FACT_Fixed",FACT_Base);

function FACT_Fixed:ctor(...)
    FACT_Base.ctor(self,...);
end

function FACT_Fixed:DoStartEffect()
    --定点相对目标
    if self._pathData.basePoint == Skill_pb.SkillPath.TARGET then
        self._alignTarget = self._actionEntity._entityAtt.target;
    elseif self._pathData.basePoint == Skill_pb.SkillPath.SELF then
        self._alignTarget = self._actionEntity._entityAtt.caster;
    end
    if self._alignTarget then
        --放在目标位置
        local startPosition = self._alignTarget:GetPropertyComponent():GetPosition();
        local startOffset = math.ConvertProtoV3(self._pathData.args[1].vector3Value);
        self._actionEntity:GetPropertyComponent():SetPosition(startPosition + startOffset);
        --跟随释放者朝向
        local propertyComponent = self._actionEntity._entityAtt.caster:GetPropertyComponent()
        self._actionEntity:GetPropertyComponent():SetForward(propertyComponent:GetForward());
    end
end

return FACT_Fixed;