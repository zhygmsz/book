local HpNameItem_FalseHpAndBuff = require("Logic/Presenter/UI/HP/HpNameItem_FalseHpAndBuff")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_Monster = class("HpNameItem_Monster", HpNameItem_FalseHpAndBuff)

function HpNameItem_Monster:ctor(ui, path, hpNameType)
	HpNameItem_FalseHpAndBuff.ctor(self, ui, path, hpNameType)
	
	path = path .. "/"
	self._table = ui:FindComponent("UITable", path .. "Table")
	
	--占坑，最后赋值时用
	self._trueHp = nil
	self._hpSprite = ui:FindComponent("UISprite", path .. "Table/1_HP/HP/FG")
	self._trueHpSp = ui:FindComponent("UIProgressBar", path .. "Table/1_HP/HP")
	self._trueHpNor = ui:FindComponent("UIProgressBar", path .. "Table/2_HP/HP")
	self._trueHpSpGo = ui:FindGo(path .. "Table/1_HP")
	self._trueHpNorGo = ui:FindGo(path .. "Table/2_HP")
	
	self._falseHp = ui:FindComponent("UIProgressBar", path .. "Table/1_HP/TempHPPanel/TempHP")
	self._falsePanel = ui:FindComponent("UIPanel", path .. "Table/1_HP/TempHPPanel")
	
	self._name = ui:FindComponent("UILabel", path .. "Table/3_MonsterName/MonsterName")
	self._nameGo = ui:FindGo(path .. "Table/3_MonsterName")
	
	self._skillName = ui:FindComponent("UILabel", path .. "Table/4_SkillName/SkillName")
	self._skillGo = ui:FindGo(path .. "Table/4_SkillName")
	
	self._level = ui:FindComponent("UILabel", path .. "MonsLevelBg/MonsLevel")
	self._levelGo = ui:FindGo(path .. "MonsLevelBg")
end

function HpNameItem_Monster:SetHp(hpPer)
	HpNameItem_FalseHpAndBuff.SetHp(self, hpPer)
end

function HpNameItem_Monster:SetSkillName(skillName)
	self._skillName.text = skillName
	self._skillName:Update()
end

function HpNameItem_Monster:SetSkillColor(color)
	self._skillName.color = color
end

function HpNameItem_Monster:SetLevel(level)
	self._level.text = tostring(level)
end

function HpNameItem_Monster:SetBuffVisible(isShow)
	self._levelGo:SetActive(not isShow)
	
	HpNameItem_FalseHpAndBuff.SetBuffVisible(self, isShow)
end

function HpNameItem_Monster:Reposition()
	self._table:Reposition()
end

function HpNameItem_Monster:ResetTarget(target)
	if target then
		HpNameItem_FalseHpAndBuff.ResetTarget(self, target)
		
		self._isSpecial = HpNameItem_Helper.MonsterIsSpecial(self._target)
		if self._isSpecial then
			self._trueHp = self._trueHpSp
		else
			self._trueHp = self._trueHpNor
		end
		
		self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
		self:SetSkillColor(HpNameItem_Helper.EnemyHpColor)
		self:SetName(self._target:GetName())
		--判断是否有特殊技能
		if self._isSpecial then
			self._skillGo:SetActive(true)
			self:SetSkillName("眩晕，定身，加血")
			
			self._trueHpSpGo:SetActive(true)
			self._trueHpNorGo:SetActive(false)
			
			self._levelGo:SetActive(true)
			self._localOffset.y = 60
		else
			self._skillGo:SetActive(false)
			
			self._trueHpSpGo:SetActive(false)
			self._trueHpNorGo:SetActive(true)
			
			self._levelGo:SetActive(false)
			self._localOffset.y = 40
		end
		
		self:ResetFollow()

		self:Reposition()
		
		--如果血量为0，在SetHp里会调用OnDie，直接置_target为nil,后面的逻辑不需要继续
		--把SetHp调用放到最后
		self:SetHpValue(self._target:GetPropertyComponent():GetHP(), self._target:GetPropertyComponent():GetHPMax())
	else
		self:OnDie()
	end
end

return HpNameItem_Monster 