local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")

local RaceEventSlowDown = class("RaceEventSpeedUp",RaceEventEffect);

function RaceEventSlowDown:ctor() 
    self._iconName = "bg_zuoqisaipao_02"; 
    self._moveDistance = 2;
    self._moveSpeed = 2;
end

function RaceEventSlowDown:OnShow(target) 
    if self._icon then
        self._position = self._icon.transform.position;
        self._offset = Vector3(0,0,0); 
        self._offsetX = 0;
    end   
end

function RaceEventSlowDown:OnUpdate2(target) 
    if self._icon then
        self._offsetX = self._offsetX + UnityEngine.Time.deltaTime * self._moveSpeed;
        self._offsetX = self._offsetX % self._moveDistance;
        self._offset.x = self._moveDistance - self._offsetX;
        self._icon.transform.position = self._position + self._offset;
    end
end 

function RaceEventSlowDown:OnExecute(target)
    if not target:IsJumping() then
        if target:IsSelf() then
            TipsMgr.TipByFormat("被减速了！");
        end
        target:SlowDown(4,0.2);
        return true;
    end    
    return false;
end

return RaceEventSlowDown;