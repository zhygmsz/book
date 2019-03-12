local InteractForCheck = require("Logic/Presenter/UI/Common/InteractMode/InteractForCheck")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")

local UIPageAndGridWidgetEx = class("UIPageAndGridWidgetEx", UIPageAndGrid_Widget)

function UIPageAndGridWidgetEx:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)
    --组件
    self._interactCheck = InteractForCheck.new(self.OnCheckedClick, self)

    --变量
    --字段用于控制交互模式
    --默认都是click模式
    self._clickOrCheck = 1
end

function UIPageAndGridWidgetEx:ResetInteractMode(clickOrCheck)
    self._clickOrCheck = clickOrCheck

    --数据改动
    if clickOrCheck == 1 then
        self._interactCheck:ResetCheckedDic()
    elseif clickOrCheck == 2 then
        --不作为
    end

    --修改UI
    local len = #self._dataList
    local item = nil
    for idx = 1, len do
        item = self._pageAndGrid:GetItem(idx)
        if item then
            item:SetInteractMode(clickOrCheck)
            --在数据状态管理这，同时设置checked状态为false
            item:SetChecked(self._interactCheck:GetChecked(idx))
        end
    end
end

--[[
    @desc: 点击item回调
    --@dataIdx: 数据列表的索引
]]
function UIPageAndGridWidgetEx:OnItemClick(dataIdx)
    --交给交互逻辑
    if self._clickOrCheck == 1 then
        self._interactClick:OnClick(dataIdx)
    elseif self._clickOrCheck == 2 then
        self._interactCheck:OnClick(dataIdx)
    end
end

function UIPageAndGridWidgetEx:SetItemChecked(dataIdx, checked)
    local item = self._pageAndGrid:GetItem(dataIdx)
    if item then
        item:SetChecked(checked)
    end
end

--[[
    @desc: 
    --@success: 选中是否成功，失败发生于数量不足时
	--@dataIdx: 数据索引
	--@checked: 选中状态
	--@remainedNum: 剩余数量，不限量则无意义
	--@checkedNum: 已选中数量
]]
function UIPageAndGridWidgetEx:OnCheckedClick(success, dataIdx, checked, remainedNum, checkedNum)
    --基类UI表现
    if success then
        self:SetItemChecked(dataIdx, checked)
    end

    --继承方式，实现子类逻辑
end

return UIPageAndGridWidgetEx