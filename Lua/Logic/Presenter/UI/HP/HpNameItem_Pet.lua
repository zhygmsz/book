local HpNameItem_TrueHp = require("Logic/Presenter/UI/HP/HpNameItem_TrueHp")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_Pet = class("HpNameItem_Pet", HpNameItem_TrueHp)

HpNameItem_Pet.SelfHpFG = "frame_zhandou_chongwuhp_02"
HpNameItem_Pet.EnemyHpFG = "frame_zhandou_chongwuhp_03"

function HpNameItem_Pet:ctor(ui, path, hpNameType)
    HpNameItem_TrueHp.ctor(self, ui, path, hpNameType)

    path = path .. "/"

    self._trueHp = ui:FindComponent("UIProgressBar", path .. "HP")
    self._name = ui:FindComponent("UILabel", path .. "PetName")
    self._hpFG = ui:FindComponent("UISprite", path .. "HP/FG")

    self._petNameStr = WordData.GetWordStringByKey("Pet_Title_Inscene")

    self._localOffset.y = 20
end

function HpNameItem_Pet:ResetTarget(target)
    if target then
        HpNameItem_TrueHp.ResetTarget(self, target)

        local masterPlayer = MapMgr.GetEntityByID(target._entityAtt.masterEntityId)
        if not masterPlayer then
            GameLog.LogError("HpNameItem_Pet.ResetTarget -> masterPlayer is nil")
            return
        end

        --判断是己方（自己或队友）的宠物，还是敌方玩家的宠物
        --分别设置血条FG样式和名字颜色
        if HpNameItem_Helper.IsGreen(masterPlayer) then
            self._hpFG.spriteName = HpNameItem_Pet.SelfHpFG
            self:SetNameColor(HpNameItem_Helper.TeamHpColor)
        elseif HpNameItem_Helper.IsRed(masterPlayer) then
            self._hpFG.spriteName = HpNameItem_Pet.EnemyHpFG
            self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
        end

        local playerName = target:GetMasterName();
        local petName = self._target:GetName()
        local str = string.format(self._petNameStr, playerName, petName)
            
        self:SetName(str)

        self:ResetFollow()
        
        self:SetHpValue(self._target:GetPropertyComponent():GetHP(), self._target:GetPropertyComponent():GetHPMax())
    else
        self:OnDie()
    end
end

return HpNameItem_Pet