local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")

local InputHistoryItem = class("InputHistoryItem", UIPageAndGrid_Item)
function InputHistoryItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._root = trs:Find("Content/Root")

    --变量
    self._pos = Vector3(-130, 30, 0)
    self._labelPos = Vector3(0, -30, 0)
    self._lineWidth = 260
    self._lineSpace = 100
end

function InputHistoryItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._root.localPosition = self._pos

    local ui = AllUI.UI_Chat_CommonLink.csScript
	TextHelper.ProcessItemCommon(ui, self, data.content, 
	self._root, self._lineWidth, self._lineSpace, true,
    data.links, nil, nil, nil, data.contentPrefix)

    --修改label位置
    local label = self._transform:Find("Content/Root/label")
    if not tolua.isnull(label) then
        label.localPosition = self._labelPos
    end
end


local InputHistoryWidget = class("InputHistoryWidget", UIPageAndGrid_Widget)
function InputHistoryWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    --组件

    --变量
    self._dataList = ChatMgr.GetInputHistoryList()
    self._numPerPage = ChatMgr.GetInputHistoryNumPerPage()
    
    self:CreatePageAndGrid(InputHistoryItem, self._numPerPage)
end

function InputHistoryWidget:OnSpec(dataIdx)
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    --获取msgcommon，并合并到chatinput里
    local funcOnAppendMsgCommon = ChatMgr.GetFuncOnAppendMsgCommon()
    if funcOnAppendMsgCommon then
        funcOnAppendMsgCommon(self._dataList[dataIdx])
    end
end

function InputHistoryWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

function InputHistoryWidget:Show()
    self._pageAndGrid:Show(self._dataList)
end

return InputHistoryWidget