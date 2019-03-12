local RaceEvent = require("Logic/System/Race/RaceEvent")

local RaceEventEffectFactory = require("Logic/System/Race/RaceEventEffectFactory")

RaceController = class("RaceController")

RaceController._players = {}
RaceController._events = {}
RaceController._iconList = {}

function RaceController:ctor(callback)
	self._callback = callback
end

function RaceController:Start()
	self._startTime = UnityEngine.Time.time
	UpdateBeat:Add(self.Update, self)
end

function RaceController:Stop()
	UpdateBeat:Remove(self.Update, self)
end

function RaceController:Update()
	local now = UnityEngine.Time.time
    local passedTime = now - self._startTime
	passedTime = math.floor(passedTime + 0.5)
	
	for _, event in ipairs(self._events) do
		if not event:HasFired() then
			event:Simulate(passedTime)
		end
	end

    for _, player in ipairs(self._players) do
    	if not player:IsOver() then
    		player:Simulate(passedTime)
    	else

    	end
	end

    if self._callback then
    	self._callback(passedTime)
    end
end

function RaceController:AddPlayer(player, index, isMainPlayer)
	player:SetTrack(index)
	player._race = self
	table.insert(self._players, player)

	if isMainPlayer then
		self._mainPlayer = player
	end

	local startPoint = 5
	if index == 1 then
		startPoint = 3
	elseif index == 2 then
		startPoint = 2
	end

	self:CreateEvents(player, startPoint) 
end

function RaceController:CreateEvents(player, startPoint, endPoint, step)
	endPoint = endPoint or startPoint + 95
	step = step or 5
	local count = math.floor((endPoint - startPoint) / step + 0.5)

	local points = {}
	for i = 1, count do
		local point = {}
		local sortId = math.random(1, 1000)
		point.id = sortId
		if i < count / 3 then 
            point.type = RaceEventEffectFactory.CreateRandomEffect(true) 
        else
            point.type = RaceEventEffectFactory.CreateRandomEffect(false) 
        end
        points[i] = point
	end

	table.sort(points, function(a, b)
        return a.id < b.id
    end)

    for i = 1, count do  
		local effectType = points[i].type
        self:AddEvent(player, startPoint + (i - 1) * 5, effectType)
    end
end

function RaceController:AddEvent(player, point, effectType)
    local event = RaceEvent.new(player, point)
    local effect = RaceEventEffectFactory.CreateEffect(effectType)
    event:AddEffect(effect)
    table.insert(self._events, event)
    return event
end

function RaceController:GetPlayer(index)
	return self._players[index]
end

function RaceController:GetMainPlayer()
	return self._mainPlayer
end

return RaceController