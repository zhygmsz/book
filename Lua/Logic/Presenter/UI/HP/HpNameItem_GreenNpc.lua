local HpNameItem = require("Logic/Presenter/UI/HP/HpNameItem")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_GreenNpc = class("HpNameItem_GreenNpc", HpNameItem)

function HpNameItem_GreenNpc:ctor(ui, path, hpNameType)
    HpNameItem.ctor(self, ui, path, hpNameType)

    path = path .. "/"

    self._table = ui:FindComponent("UITable", path .. "Table")

    self._name = ui:FindComponent("UILabel", path .. "Table/1_Name/Name")
    self._funcName = ui:FindComponent("UILabel", path .. "Table/0_Func/Func")
    self._funcNameGo = ui:FindGo(path .. "Table/0_Func")

    self._localOffset.y = 20
end

--重新排序table
function HpNameItem_GreenNpc:Reposition()
    self._table:Reposition()
end

function HpNameItem_GreenNpc:SetFuncName(name)
    self._funcName.text = name
    self._funcName:Update()
end

function HpNameItem_GreenNpc:SetFuncColor(color)
    self._funcName.color = color
end

function HpNameItem_GreenNpc:ResetTarget(target)
    if target then
        HpNameItem.ResetTarget(self, target)

        self:SetNameColor(HpNameItem_Helper.PasserbyHpColor)
        self:SetFuncColor(HpNameItem_Helper.PasserbyHpColor)
        self:SetName(self._target:GetName())
        self._funcNameGo:SetActive(false)
        self:SetFuncName("<铁匠铺>")

        self:ResetFollow()

        self:Reposition()
    else
        self:OnDie()
    end
end

return HpNameItem_GreenNpc