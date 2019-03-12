local RaceEvent = class("RaceEvent");


RaceEvent.STATE_IDLE = 0;
RaceEvent.STATE_STARTED = 1;
RaceEvent.STATE_OVER = 2;

function RaceEvent:ctor(target,point)
    self._target = target;
    self._point = point;
    self._effects = {}; 
    self._state = RaceEvent.STATE_IDLE;
end

function RaceEvent:Simulate(time,distance)
    if self._state == RaceEvent.STATE_IDLE then
        distance = self._target:GetDistance(); 
        if distance >= self._point - 100 then
            self:OnStart();
            self._state = RaceEvent.STATE_STARTED;
        end
    elseif self._state == RaceEvent.STATE_STARTED then
        -- distance = self._target:GetDistance(); 
        -- if distance >= self._point then
        --     --self:OnFire();
        --     self._state = RaceEvent.STATE_OVER;
        -- else
        --     self:OnUpdate();
        -- end 

        local index = self._target:GetTrack()
        for _, obj in ipairs(RaceController._iconList[index]) do
            if obj.gameObject.activeSelf == true then
                obj.localPosition = obj.localPosition - Vector3(0.1, 0, 0)
                if  obj.gameObject.transform.localPosition.x < self._target._go.gameObject.transform.localPosition.x then
                    self:OnFire()
                    obj.gameObject:SetActive(false)
                end
            end
        end
        
    end    
end

function RaceEvent:HasFired()
    return self._state == RaceEvent.STATE_OVER;
end

function RaceEvent:OnStart()
    for _,effect in ipairs(self._effects) do
        effect.id = self.id;
        effect:Show(self._target);
    end
end

function RaceEvent:OnUpdate()
    for _,effect in ipairs(self._effects) do
        effect:Update(self._target);
    end
end

function RaceEvent:OnFire()
    for _,effect in ipairs(self._effects) do
        effect:Execute(self._target);
    end
end 

function RaceEvent:Fire(player)
    for _,effect in ipairs(self._effects) do
        effect:Execute(player)
    end
end 

function RaceEvent:AddEffect(effect)
    effect._startPoint = self._point;
    table.insert(self._effects,effect);
end

return RaceEvent;