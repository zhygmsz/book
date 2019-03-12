local ContentWidgetBase = require("Logic/Presenter/UI/Shop/ContentWidgetBase")
local InteractForCheck = require("Logic/Presenter/UI/Common/InteractMode/InteractForCheck")

local ContentWidgetCheck = class("ContentWidgetCheck", ContentWidgetBase)

function ContentWidgetCheck:ctor(trs, Item, eventIdBase, eventIdSpan, funcOnClick, funcOnSpanClick)
    ContentWidgetBase.ctor(self, trs, Item, eventIdBase, eventIdSpan)
    --组件

    --回调
    self._funcOnClick = funcOnClick
    self._funcOnSpanClick = funcOnSpanClick

    self._interactCheck = InteractForCheck.new(self.OnCheckedClick, self)

    --变量
end

--[[
    @desc: 
    --@dataList:
    --@restorePos: 是否恢复当前浏览位置
    --@beginIdx: 闭区间
	--@endIdx: 以上两个参数，同时有效，设置了，就读取list内的区间内来刷新UI
]]
function ContentWidgetCheck:Show(dataList, restorePos, maxCheckedNum, beginIdx, endIdx)
    self._interactCheck:ResetMaxCheckedNum(maxCheckedNum)
    self._interactCheck:ClearCurCheckedNum()
    self._interactCheck:ResetCheckedDic()
    ContentWidgetBase.Show(self, dataList, restorePos, beginIdx, endIdx)
end

function ContentWidgetCheck:OnInit(go, wrapIdx, realIdx)
    local item, data = ContentWidgetBase.OnInit(self, go, wrapIdx, realIdx)
    if item and data then
        item:SetChecked(self._interactCheck:GetChecked(item:GetRealIdx()))
    end
end

function ContentWidgetCheck:OnClick(eventId)
    if not eventId then
        return
    end

    local itemIdx, spanIdx = self:CalItemAndSpanIdx(eventId)
    local item = self._itemList[itemIdx]
    if not item then
        return
    end

    local realIdx = item:GetRealIdx()

    if spanIdx == 1 then
        self._interactCheck:OnClick(realIdx)
    else
        self:InvokeOnSpanClick(realIdx, spanIdx)
    end
end

--[[
    @desc: 
    --@success: 选中是否成功，失败发生于数量不足
	--@realIdx: 数据索引
	--@checked: 选中状态
	--@remainedNum: 剩余数量，不限量则无意义
	--@checkedNum: 已选中数量
]]
function ContentWidgetCheck:OnCheckedClick(success, realIdx, checked, remainedNum, checkedNum)
    if success then
        local item = self:RealIdx2Item(realIdx)
        if item then
            item:SetChecked(checked)
        end
    end

    if self._funcOnClick then
        self._funcOnClick(success, realIdx, checked, remainedNum, checkedNum)
    end
end

--[[
    @desc: 点中其他eventid时，走这个接口
]]
function ContentWidgetCheck:InvokeOnSpanClick(realIdx, spanIdx)
    if self._funcOnSpanClick then
        self._funcOnSpanClick(realIdx, spanIdx)
    end
end

--[[
    @desc: 返回是否选中状态
]]
function ContentWidgetCheck:GetCheckedDic()
    return self._interactCheck:GetCheckedDic()
end

function ContentWidgetCheck:OnDestroy()
    ContentWidgetBase.OnDestroy(self)

    self._interactCheck:OnDestroy()
end

return ContentWidgetCheck