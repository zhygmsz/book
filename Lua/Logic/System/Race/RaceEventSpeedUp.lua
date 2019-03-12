local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventSpeedUp = class("RaceEventSpeedUp",RaceEventEffect);

function RaceEventSpeedUp:ctor() 
    self._iconName = "num_zuoqisaipao_02";
end

function RaceEventSpeedUp:OnExecute(target)
    if target:IsJumping() or true then
        if target:IsSelf() then
            TipsMgr.TipByFormat("获得加速");
        end
        target:SpeedUp(3);
        return true;
    end    
    return false;
end

return RaceEventSpeedUp;