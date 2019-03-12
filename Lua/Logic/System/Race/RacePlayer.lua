RacePlayer = class("RacePlayer")

local RACEGAMESTATE = 
{
	IDLE = 1,
	RUN = 2,
	OVER = 3,
}
RacePlayer.OMNIDISTANCE = 100

RacePlayer.bgSpeed = 2

function RacePlayer:ctor(obj)
	self._go = obj
	self._distance = 0
	self._state = RACEGAMESTATE.IDLE
	self._trackIndex = 0
	self._speed = 2
	self._skillLimitTimer = 0
	self._slowTimer = 0
	self._speedUpTimer = 0
	self._shieldTimer = 0
	self._jumpTimer = 0
	self._skillCount = 0
	self._jumpCDTimer = 0
	self._initPos = obj.transform.localPosition
end

function RacePlayer:Simulate(time)
	if self._state == RACEGAMESTATE.IDLE then
		self:OnStart()
		self._state = RACEGAMESTATE.RUN
	elseif self._state == RACEGAMESTATE.RUN then
		self:OnUpdate()
	end
end

function RacePlayer:SetTrack(trackIndex)
	self._trackIndex = trackIndex
end

function RacePlayer:OnStart()
	self.OMNIDISTANCE = 100
end

function RacePlayer:OnUpdate()
	local speed = 2
	local speedFactor = 1
	local deltaTime = UnityEngine.Time.deltaTime
	--技能CD时间
	if self._skillLimitTimer > 0 then
		self._skillLimitTimer = self._skillLimitTimer - deltaTime
	end

	--减速效果时间
	if self._slowTimer > 0 then
		speedFactor = 0.5 
		self._slowTimer = self._slowTimer - deltaTime

		speed = speed * speedFactor - self.bgSpeed
		if self._trackIndex ~= 3 then
			self._go.transform.localPosition = self._go.transform.localPosition + Vector3.right * speed
		end

		self._distance = self._distance + 1 * speed

		return
	end

	--加速效果时间
	if self._speedUpTimer > 0 then
		speedFactor = 2
		self._speedUpTimer = self._speedUpTimer - deltaTime

		speed = speed * speedFactor - self.bgSpeed
		if self._trackIndex ~= 3 then
			self._go.transform.localPosition = self._go.transform.localPosition + Vector3.left * speed
		end

		self._distance = self._distance + 1 * speed

		return 
	end

	--盾效果的时间
	if self._shieldTimer > 0 then
		self._shieldTimer = self._shieldTimer - deltaTime
	end

	speed = speed * speedFactor

	if self._jumpTimer > 0 and speedFactor > 0 then
		self._jumpTimer = self._jumpTimer - deltaTime
	end

	if self._jumpCDTimer > 0 then
		self._jumpCDTimer = self._jumpCDTimer - deltaTime
	end
	
	local delta = speed * deltaTime
	self._distance = self._distance + 1 * speed
end

function RacePlayer:GetProgress()
	return self._distance / self.OMNIDISTANCE
end

function RacePlayer:GetDistance()
	return self._distance
end

function RacePlayer:GetName()
	return self._name
end

function RacePlayer:GetTransform()
    return self._go.transform
end

function RacePlayer:GetStartPos()
    return self._initPos
end

function RacePlayer:GetTrack()
	return self._trackIndex
end

function RacePlayer:IsJumping()
	return self._jumpTimer > 0
end

function RacePlayer:Jump(time)
	--跳跃 playerAnimation()
end

function RacePlayer:SlowDown(time)
	if self._shieldTimer > 0 then
		return
	end

	if self._speedUpTimer > 0 then
		return
	end

	self._slowTimer = time
	self._speedUpTimer = 0
end

function RacePlayer:SpeedUp(time)
	self._speedUpTimer = time
	self._slowTimer = 0
end

--加护盾
function RacePlayer:AddShield(time)
	self._shieldTimer = time
	self._slowTimer = 0
end

function RacePlayer:HasSkill()
	return self._skillCount and self._skillCount > 0
end

function RacePlayer:AddSkill()
	if self._skillCount and self._skillCount > 3 then
		return false
	end

	self._skillCount =  self._skillCount + 1
	return true
end

function RacePlayer:IsOver()
	local dis = self.OMNIDISTANCE + 2
	return self._distance >= dis
end

function RacePlayer:UseSkill()

	if self._skillLimitTimer > 0 then
		return false
	end

	if self._skillCount > 0 and self:IsCanJump() then
		--释放技能

		self._skillCount = self._skillCount - 1
	end
end

function RacePlayer:SkillLimit(time)
	self._skillLimitTimer = time
end

function RacePlayer:IsSelf()
    return self._race._mainPlayer == self
end

return RacePlayer