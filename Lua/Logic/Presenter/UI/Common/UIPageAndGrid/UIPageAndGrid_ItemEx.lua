local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")

local UIPageAndGridItemEx = class("UIPageAndGridItemEx", UIPageAndGrid_Item)

function UIPageAndGridItemEx:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)
    --组件
    self._checkGo = trs:Find("check").gameObject
    self._checkedGo = trs:Find("check/checked").gameObject

    --变量
end

function UIPageAndGridItemEx:Init()
    --默认先是click模式
    --self:SetInteractMode(1)
    self:SetCheckVisible(false)
    self:ToNor()
    self:Hide()
end

function UIPageAndGridItemEx:SetInteractMode(clickOrCheck)
    if clickOrCheck == 1 then
        self:SetCheckVisible(false)
        self:ToNor()
    elseif clickOrCheck == 2 then
        self:HideNorAndSpec()
        self:SetCheckVisible(true)
        self:SetChecked(false)
    end
end

function UIPageAndGridItemEx:SetCheckVisible(visible)
    self._checkGo:SetActive(visible)
end

function UIPageAndGridItemEx:SetChecked(checked)
    self._checkedGo:SetActive(checked)
end

function UIPageAndGridItemEx:HideNorAndSpec()
    self._norGo:SetActive(false)
    self._specGo:SetActive(false)
end

return UIPageAndGridItemEx