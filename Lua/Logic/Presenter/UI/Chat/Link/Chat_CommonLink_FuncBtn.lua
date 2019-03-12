local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")


local FuncBtnItem = class("FuncBtnItem", UIPageAndGrid_Item)
function FuncBtnItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._norSp = trs:Find("nor"):GetComponent("UISprite")
    self._specSp = trs:Find("spec"):GetComponent("UISprite")
    self._name = trs:Find("name"):GetComponent("UILabel")
    self._norIcon = trs:Find("nor/Sprite_Icon"):GetComponent("UISprite")
    self._specIcon = trs:Find("spec/Sprite_Icon"):GetComponent("UISprite")

    --变量
    self._btnNorColor = Color(169 / 255, 138 / 255, 109 / 255, 1)
    self._btnSpecColor = Color(158 / 255, 103 / 255, 65 / 255, 1)

    self:Init()
end

function FuncBtnItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._name.text = self._data.name
    self._norIcon.spriteName = self._data.norSpName
    self._norIcon.color = self._btnNorColor
    self._specIcon.spriteName = self._data.specSpName
    self._specIcon.color = self._btnSpecColor
end

-------------------------------------------------------------------------------

local FuncBtnWidget = class("FuncBtnWidget", UIPageAndGrid_Widget)
function FuncBtnWidget:ctor(trs, ui, eventIdBase, eventIdSpan, onBtnNor, onBtnSpec)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    --组件
    self._onBtnNor = onBtnNor
    self._onBtnSpec = onBtnSpec

    --变量
    --根据打开途径不同，功能按钮列表不同，读程序内配置文件
    self._dataList = nil
    self._numPerPage = 9

    self:CreatePageAndGrid(FuncBtnItem, self._numPerPage)
    
    --
    self:Hide()    
end

function FuncBtnWidget:OnNor(dataIdx)
    UIPageAndGrid_Widget.OnNor(self, dataIdx)

    if self._onBtnNor then
        self._onBtnNor(self._dataList[dataIdx].id)
    end
end

--功能按钮点击回调
function FuncBtnWidget:OnSpec(dataIdx)
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    if self._onBtnSpec then
        self._onBtnSpec(self._dataList[dataIdx].id)
    end
end

function FuncBtnWidget:OnDisable()
    UIPageAndGrid_Widget.OnDisable(self)
    
    self:Hide()
end

--[[
    @desc: 根据功能id，打开对应的widget，如果找不到则打开第一个item对应的功能
    --@funcIdx: 
]]
function FuncBtnWidget:OpenWidget(funcIdx)
    local itemIdx = -1
    for idx, funcData in ipairs(self._dataList) do
        if funcData.id == funcIdx then
            itemIdx = idx
            break
        end
    end
    if itemIdx == -1 then
        itemIdx = 1
    end
    self._interactClick:OnClick(itemIdx)
end

function FuncBtnWidget:Show(dataList)
    UIPageAndGrid_Widget.Show(self)

    self._dataList = dataList

    self._pageAndGrid:Show(self._dataList)
end

return FuncBtnWidget
