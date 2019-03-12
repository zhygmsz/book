local HpNameItem = require("Logic/Presenter/UI/HP/HpNameItem")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_Monster = class("HpNameItem_Monster", HpNameItem)

function HpNameItem_Monster:ctor(ui, path, hpNameType)
    HpNameItem.ctor(self, ui, path, hpNameType)

    self._name = NGUITools.FindComponent(self._transform, "SuperTextMesh", "Name")

    self._skillGo = NGUITools.FindGo(self._transform, "Skill")
    self._skillGo:SetActive(false)

    self._level = NGUITools.FindComponent(self._transform, "SuperTextMesh", "Level")
    self._levelGo = NGUITools.FindGo(self._transform, "Level")
    self._levelTrs = self._transform:Find("Level")

    self._localOffset.y = 20

    self._isSpecial = false

    self._levelPos = Vector3.zero
end

function HpNameItem_Monster:SetName(name)
    self._name.text = name
end

function HpNameItem_Monster:SetNameColor(nameColor)
    self._name.color = nameColor
end

function HpNameItem_Monster:SetLevel(level)
    self._level.text = tostring(level)
    
    --计算等级的偏移
    self._levelPos.x = -(self._name.width / 2 + 20)
    self._levelTrs.localPosition = self._levelPos
end

function HpNameItem_Monster:ResetTarget(target)
    if target then
        HpNameItem.ResetTarget(self, target)

        self:SetName(target:GetName())
        self:SetNameColor(HpNameItem_Helper.EnemyHpColor)

        self._isSpecial = HpNameItem_Helper.MonsterIsSpecial(target)
        if self._isSpecial then
            --判断是否为特殊怪
            self._skillGo:SetActive(true)
            self:SetSkillName("眩晕，定身，加血")
            self:SetSkillColor(HpNameItem_Helper.EnemyHpColor)

            self._levelGo:SetActive(true)
            self:SetLevel(10)
        else
            self._skillGo:SetActive(false)
            self._levelGo:SetActive(false)
        end

        self:ResetFollow()
    else
        self:Clean()
    end
end

return HpNameItem_Monster