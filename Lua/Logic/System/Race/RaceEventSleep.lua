local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventSleep = class("RaceEventSleep",RaceEventEffect);

function RaceEventSleep:ctor() 
    self._iconName = "icon_zuoqisaipao_01";
end

function RaceEventSleep:OnExecute(target)
    if not target:IsJumping() then
        if target:IsSelf() then
            TipsMgr.TipByFormat("被眩晕了！");
        end        
        target:SkillLimit(2);
        target:SlowDown(2,0);
        return true;
    end  
    return false;  
end

return RaceEventSleep;