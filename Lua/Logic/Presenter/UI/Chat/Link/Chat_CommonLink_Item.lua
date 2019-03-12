local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")


local ItemItem = class("ItemItem", UIPageAndGrid_Item)
function ItemItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._itemTrs = trs:Find("item")
    
    --变量
    self._item = GeneralItem.new(self._itemTrs, nil)
end

function ItemItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._item:ShowByItemId(self._data.itemSlot.item.tempId)
end

function ItemItem:OnDestroy()
    UIPageAndGrid_Item.OnDestroy(self)

    self._item:OnDestroy()
end

-------------------------------------------------------------------------------

local ItemWidget = class("ItemWidget", UIPageAndGrid_Widget)
function ItemWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    --组件

    --变量
    --物品访问BagMgr
    self._dataList = ChatMgr.GetItemDataList()
    self._numPerPage = ChatMgr.GetItemNumPerPage()
    
    self:CreatePageAndGrid(ItemItem, self._numPerPage)

    --
    self:Hide()
end

function ItemWidget:OnSpec(dataIdx)
    --基类的方法只做UI表现，事实上，点击物品时，不需要做选中切换等
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    --在具体的类里做点击后的业务逻辑处理
    --发送物品信息
    local funcOnNew = ChatMgr.GetFuncOnNewMsgLink()
    local funcCreate = ChatMgr.GetFuncCreateMsgLink()
    if funcOnNew and funcCreate then
        local data = self._dataList[dataIdx]
        if not data then
            return
        end

        local msgLink = funcCreate()
        MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.ITEM, msgLink, data.itemSlot, true)

        funcOnNew(msgLink)
    end
end

function ItemWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

function ItemWidget:OnBagUpdate()
    self:DoShow()
end

function ItemWidget:RegEvent()
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID, self.OnBagUpdate, self)
end

function ItemWidget:UnRegEvent()
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID,self.OnBagUpdate,self)
end

function ItemWidget:DoShow()
    self._dataList = ChatMgr.GetItemDataList()
    self._pageAndGrid:Show(self._dataList)
end

function ItemWidget:Show()
    UIPageAndGrid_Widget.Show(self)

    self:RegEvent()

    self:DoShow()
end

function ItemWidget:Hide()
    UIPageAndGrid_Widget.Hide(self)

    self:UnRegEvent()
end

return ItemWidget
