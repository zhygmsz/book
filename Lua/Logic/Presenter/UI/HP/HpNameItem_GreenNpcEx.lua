--新方式，npc姓名版

local HpNameItem = require("Logic/Presenter/UI/HP/HpNameItem")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_GreenNpc = class("HpNameItem_GreenNpc", HpNameItem)

function HpNameItem_GreenNpc:ctor(ui, path, hpNameType)
    HpNameItem.ctor(self, ui, path, hpNameType)

    self._name = NGUITools.FindComponent(self._transform, "SuperTextMesh", "Name")

    self._localOffset.y = 20
end

--[[
    @desc: 重写该方法，覆盖掉基类
    author:{author}
    time:2019-03-12 14:36:19
    --@name: 
    @return:
]]
function HpNameItem_GreenNpc:SetName(name)
    self._name.text = name
end

function HpNameItem_GreenNpc:SetNameColor(nameColor)
    self._name.color = nameColor
end

function HpNameItem_GreenNpc:ResetTarget(target)
    if target then
        HpNameItem.ResetTarget(self, target)
        
        self:SetNameColor(HpNameItem_Helper.PasserbyHpColor)

        self:SetName(self._target:GetName())

        self:ResetFollow()
    else
        self:Clean()
    end
end

return HpNameItem_GreenNpc