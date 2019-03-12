local CommonSkillData = class("CommonSkillData")

function CommonSkillData:ctor(id)
    self._id = id;
    self._source = "";
    self._skillList = {};
end

function CommonSkillData:SetGroupSource(sourceStr)
    self._source = sourceStr;
end

function CommonSkillData:SetSkillList(skillList)
    self._skillList = skillList;
end

return CommonSkillData;