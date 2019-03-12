local HpNameItem_FalseHpAndBuff = require("Logic/Presenter/UI/HP/HpNameItem_FalseHpAndBuff")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper");
local TitleHUD = require( "Logic/Presenter/UI/TitleSystem/TitleHUD");

local HpNameItem_Player = class("HpNameItem_Player", HpNameItem_FalseHpAndBuff)
--敌方玩家
HpNameItem_Player.RedHpFG = "frame_zhandou_hp_05"
--对于或友方玩家
HpNameItem_Player.BlueHpFG = "frame_zhandou_hp_4"
--自己
HpNameItem_Player.GreenHpFG = "frame_zhandou_hp_03"


function HpNameItem_Player:ctor(ui, path, hpNameType)
    HpNameItem_FalseHpAndBuff.ctor(self, ui, path, hpNameType)

    path = path .. "/"

    self._table = ui:FindComponent("UITable", path .. "Table")

    self._progressMP = ui:FindComponent("UIProgressBar", path .. "Table/1_MP")
    self._mpGo = ui:FindGo(path .. "Table/1_MP")

    self._hpGo = ui:FindGo(path .. "Table/2_HP")
    self._trueHp = ui:FindComponent("UIProgressBar", path .. "Table/2_HP/HP")
    self._hpSprite = ui:FindComponent("UISprite", path .. "Table/2_HP/HP/FG")

    self._falseHp = ui:FindComponent("UIProgressBar", path .. "Table/2_HP/TempHPPanel/TempHP")
    self._falsePanel = ui:FindComponent("UIPanel", path .. "Table/2_HP/TempHPPanel")

    self._profIcon = ui:FindComponent("UISprite", path .. "ProfIconBg/ProfIcon")
    self._profIconGo = ui:FindGo(path .. "ProfIconBg")

    self._factionName = ui:FindComponent("UILabel", path .. "Table/3_FactionName/FactionName")
    self._factNameGo = ui:FindGo(path .. "Table/3_FactionName")

    self._name = ui:FindComponent("UILabel", path .. "Table/4_PlayerName/PlayerName")
    self._nameGo = ui:FindGo(path .. "Table/4_PlayerName")

    self._captainIcon = ui:FindComponent("UISprite", path .. "CaptainIcon")
    self._capIconGo = ui:FindGo(path .. "CaptainIcon")

    local titleRoot = ui:Find(path .. "Table/5_Title")
    self._titleHUD = TitleHUD.new(titleRoot);

    self._titleGo = ui:FindGo(path .. "Table/5_Title")

    self._hpFG = ui:FindComponent("UISprite", path .. "Table/2_HP/HP/FG")

    self._localOffset.y = 20
end

function HpNameItem_Player:SetHpFG(isRed)
    if isRed then
        self._hpFG.spriteName = HpNameItem_Player.RedHpFG
    else
        --判断是否是自己
        if HpNameItem_Helper.IsSelf(self._target) then
            self._hpFG.spriteName = HpNameItem_Player.GreenHpFG
        else
            self._hpFG.spriteName = HpNameItem_Player.BlueHpFG
        end
    end
end

function HpNameItem_Player:SetMP(mpPer)
    self._progressMP.value = mpPer
end

function HpNameItem_Player:SetFactionName(name)
    self._factionName.text = name
    self._factionName:Update()
end

function HpNameItem_Player:SetFactionColor(color)
    self._factionName.color = color
end

function HpNameItem_Player:SetTitle(entity)
    self._titleHUD:Show(entity);
    self:Reposition();
end

--重新排序table
function HpNameItem_Player:Reposition()
    self._table:Reposition()
end

function HpNameItem_Player:OnEnterFightScene()
    self._hpGo:SetActive(true)
    self._mpGo:SetActive(true)
    self._profIconGo:SetActive(true)
    self:Reposition()
end

function HpNameItem_Player:OnLeaveFightScene()
    self._hpGo:SetActive(false)
    self._mpGo:SetActive(false)
    self._profIconGo:SetActive(false)
    self:Reposition()
end

function HpNameItem_Player:SetBuffVisible(isShow)
    --处理倒计时条的位置
    if HpNameItem_Helper.IsSelf(self._target) then
        self._mpGo:SetActive(not isShow)
    end

    --隐藏职业图标
    self._profIconGo:SetActive(not isShow)

    HpNameItem_FalseHpAndBuff.SetBuffVisible(self, isShow)
end

function HpNameItem_Player:ResetTarget(target)
    if target then
        HpNameItem_FalseHpAndBuff.ResetTarget(self, target)

        if HpNameItem_Helper.IsHelper(self._target) then
            self._mpGo:SetActive(false)

            --助战血条隐藏
            self._hpGo:SetActive(false)
            self._profIconGo:SetActive(true)

            --助战图标
            self._profIconGo:SetActive(true)

            self._factNameGo:SetActive(false)

            self._nameGo:SetActive(true)
            self:SetName(self._target:GetName())

            self._capIconGo:SetActive(false)

            self._titleGo:SetActive(false)

            --区分是红名助战/蓝名助战
            if HpNameItem_Helper.IsRed(self._target:GetMaster()) then
                --红名助战
                self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
            else
                --绿名助战
                self:SetNameColor(HpNameItem_Helper.TeamHpColor)
            end

            --助战以后有血条
        else --其余全为player
            if HpNameItem_Helper.IsSelf(self._target) or HpNameItem_Helper.IsTeammate(self._target) then
                self._mpGo:SetActive(true)
                --设置蓝条百分比

                self._hpGo:SetActive(true)
                self:SetHpFG(false)

                self._profIconGo:SetActive(true)
                --设置职业图标

                --帮会名字的显示逻辑可以提出一个函数
                --判断是否有帮会，以及是否显示帮会，获取帮会设置名字
                self._factNameGo:SetActive(true)
                self:SetFactionName("<斧头帮>")

                self._nameGo:SetActive(true)
                self:SetName(self._target:GetName())

                --判断是否为队长
                self._capIconGo:SetActive(true)

                --称号显示的逻辑也可以提出一个函数
                --称号待定，依据称号系统规则设置
                self._titleGo:SetActive(true)
                self:SetTitle(self._target)

                if HpNameItem_Helper.IsSelf(self._target) then
                    self:SetNameColor(HpNameItem_Helper.SelfHpColor)
                elseif HpNameItem_Helper.IsTeammate(self._target) then
                    self:SetNameColor(HpNameItem_Helper.TeamHpColor)
                end
            elseif HpNameItem_Helper.IsEnemy(self._target) then
                self._mpGo:SetActive(false)

                self._hpGo:SetActive(true)
                self:SetHpFG(true)

                self._profIconGo:SetActive(false)

                --判断是否有帮会，以及是否显示帮会，获取帮会设置名字
                self._factNameGo:SetActive(true)
                self:SetFactionName("<斧头帮>")

                self._nameGo:SetActive(true)
                self:SetNameColor(HpNameItem_Helper.EnemyHpColor)
                self:SetName(self._target:GetName())

                --判断是否为队长
                self._capIconGo:SetActive(true)

                --称号待定，依据称号系统规则设置
                self._titleGo:SetActive(true)
                self:SetTitle(self._target)
            elseif HpNameItem_Helper.IsGreenPlayer(self._target) then
                --绿名路人
                self._mpGo:SetActive(false)

                self._hpGo:SetActive(false)

                self._profIconGo:SetActive(false)

                --判断是否有帮会，以及是否显示帮会，获取帮会设置名字
                self._factNameGo:SetActive(true)
                self:SetFactionName("<斧头帮>")

                self._nameGo:SetActive(true)
                self:SetName(self._target:GetName())
                self:SetNameColor(HpNameItem_Helper.TeamHpColor)
                --[[
                if HpNameItem_Helper.IsSameFaction(self._target) then
                    self:SetNameColor(HpNameItem_Helper.FactionHpColor)
                else
                    self:SetNameColor(HpNameItem_Helper.PasserbyHpColor)
                end
                ]]

                self._capIconGo:SetActive(false)

                --称号待定，依据称号系统规则设置
                self._titleGo:SetActive(true)
                self:SetTitle(self._target)
            end
        end

        self:ResetFollow()

        --最后调用一次table排序
        --隐藏帮会
        --self._profIconGo:SetActive(false)
        self._factNameGo:SetActive(false)
        self._capIconGo:SetActive(false)
        
        self:Reposition()

        --设置血量值
        if HpNameItem_Helper.CheckNeedHpInPlayer(self._target) then
            self:SetHpValue(self._target:GetPropertyComponent():GetHP(), self._target:GetPropertyComponent():GetHPMax())
        end

        --查看身上是否有buff，有则立即显示更新
    else
        self:OnDie()
    end
end

return HpNameItem_Player
