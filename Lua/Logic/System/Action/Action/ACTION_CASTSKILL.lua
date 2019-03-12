ACTION_CASTSKILL = class("ACTION_CASTSKILL",ACTION_BASE);

function ACTION_CASTSKILL:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._entity = MapMgr.GetMainPlayer();
    self._skillID = self._actionData.intParams[1];
    self._skillLevel = self._actionData.intParams[2];
    local skillLevelData = SkillData.GetSkillLevelInfo(self._skillID,self._skillLevel);
    self._skillUnitID = skillLevelData and skillLevelData.unit or -1;
end

function ACTION_CASTSKILL:OnUpdate()
    if self._skillUnitID ~= -1 then
        MapMgr.RequestCancelSkill(self._entity,EntityDefine.SKILL_CANCEL_TYPE.CAST_SKILL);
        MapMgr.RequestCastSkill(self._entity,-1,self._skillLevel,self._skillUnitID);
    end
    self._actionDone = true;
end

return ACTION_CASTSKILL;