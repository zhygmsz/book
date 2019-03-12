local HpNameItem = require("Logic/Presenter/UI/HP/HpNameItem")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")

local HpNameItem_Player = class("HpNameItem_Player", HpNameItem)

function HpNameItem_Player:ctor(ui, path, hpNameType)
    HpNameItem.ctor(self, ui, path, hpNameType)

    self._name = NGUITools.FindComponent(self._transform, "SuperTextMesh", "Name")

    self._localOffset.y = 20
end

function HpNameItem_Player:SetName(name)
    self._name.text = name
end

function HpNameItem_Player:SetNameColor(nameColor)
    self._name.color = nameColor
end

--[[
    @desc: 覆盖旧方法
    author:{author}
    time:2019-03-12 17:00:01
    --@entity: 
    @return:
]]
function HpNameItem_Player:SetTitle(entity)
    
end

--[[
    @desc: 如果不再设置血条进度条，则由hp_main里判断血量是否为0，然后调用对应的HpNameItem
    author:{author}
    time:2019-03-12 16:50:39
    --@target: 
    @return:
]]
function HpNameItem_Player:ResetTarget(target)
    if target then
        HpNameItem.ResetTarget(self, target)

        self:SetName(target:GetName())

        --判断target各种情况给定一个名字颜色
        if HpNameItem_Helper.IsHelper(target) then
            --助战
            --区分是红名助战/蓝名助战
            if HpNameItem_Helper.IsRed(self._target:GetMaster()) then
                --红名助战
                self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
            else
                --绿名助战
                self:SetNameColor(HpNameItem_Helper.TeamHpColor)
            end
        else
            --其余为玩家
            if HpNameItem_Helper.IsSelf(target) or HpNameItem_Helper.IsTeammate(target) then
                --自己或队友
                if HpNameItem_Helper.IsSelf(self._target) then
                    self:SetNameColor(HpNameItem_Helper.SelfHpColor)
                elseif HpNameItem_Helper.IsTeammate(self._target) then
                    self:SetNameColor(HpNameItem_Helper.TeamHpColor)
                end
            elseif HpNameItem_Helper.IsEnemy(self._target) then
                --敌对玩家
                self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
            elseif HpNameItem_Helper.IsGreenPlayer(self._target) then
                --绿名路人
                self:SetNameColor(HpNameItem_Helper.TeamHpColor)
            end
        end

        self:ResetFollow()
    else
        self:Clean()
    end
end

return HpNameItem_Player