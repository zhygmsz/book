local RaceEventEffect = class("RaceEventEffect");

RaceEventEffect.EFFECT_SPEEDUP = 1;
RaceEventEffect.EFFECT_SLOW = 2;
RaceEventEffect.EFFECT_SHIELD = 3;
RaceEventEffect.EFFECT_STOP = 4;
RaceEventEffect.EFFECT_SLEEP = 5;
RaceEventEffect.EFFECT_SKILL = 6;

RaceEventEffect.itemPool = {}

function RaceEventEffect:ctor()
    self._effect = nil
    self._startPoint = 0
end

function RaceEventEffect:Update(target)
    self:OnUpdate(target)
end

function RaceEventEffect:Execute(target)
    local executed = self:OnExecute(target) 
    if executed then
        if self._effect then
        end

        if self._icon then
        end
    end    
end

function RaceEventEffect:CreateAndShowEvent(pos, index)
    GameEvent.Trigger(EVT.RACE, EVT.RACE_CREATEICON, self._iconName. pos, index)
end

function RaceEventEffect:Show(target)
    local transform = target:GetTransform()
    local parent = transform.parent
    local pos = target:GetStartPos()
    GameLog.Log("show pos X : "..tostring(pos.x).."   --- start point is : "..tostring(self._startPoint))
    pos.x = pos.x + self._startPoint + 800

    local index = target:GetTrack()

    if self._effectName then

    elseif self._iconName then
        self:CreateAndShowEvent(pos, index)
    end
    self:OnShow(target)
end

function RaceEventEffect:ShowEffect(effectName,parent,pos)
end

function RaceEventEffect:OnExecute(target)
end

function RaceEventEffect:OnShow(target)
end

function RaceEventEffect:OnUpdate(target)
    --这里可以写道具图标生成事件
end 

return RaceEventEffect;