local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventStop = class("RaceEventStop",RaceEventEffect);

function RaceEventStop:ctor() 
    self._iconName = "num_zuoqisaipao_03";
end

function RaceEventStop:OnExecute(target)
    if not target:IsJumping() then
        if target:IsSelf() then
            TipsMgr.TipByFormat("被定身了！");
        end
        target:SlowDown(2,0);
        return true;
    end    
    return false;
end

return RaceEventStop;