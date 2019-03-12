local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventShield = class("RaceEventShield",RaceEventEffect);

function RaceEventShield:ctor() 
    self._iconName = "icon_zuoqisaipao_03";
end

function RaceEventShield:OnExecute(target)
    if target:IsJumping() or true then
        if target:IsSelf() then
            TipsMgr.TipByFormat("获得护盾");
        end
        target:AddShield(4);
        return true;
    end
    return false;    
end

return RaceEventShield;