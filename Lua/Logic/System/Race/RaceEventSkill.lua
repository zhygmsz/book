local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventSkill = class("RaceEventSpeedUp",RaceEventEffect);

function RaceEventSkill:ctor() 
    self._iconName = "icon_zuoqisaipao_02";
end

function RaceEventSkill:OnExecute(target) 
    if target:IsJumping() then
        target:AddSkill();
        if target:IsSelf() then
            
        end   
        return true;
    end
    return false;
end

return RaceEventSkill;