local UITableAndGrid_OneItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_OneItem")
local UITableAndGrid_TwoItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_TwoItem")
local UITableAndGrid = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")
local GemIconItem = require("Logic/Presenter/UI/Intensify/Inlay/GemIconItem")

local OneItem = class("OneItem", UITableAndGrid_OneItem)
function OneItem:ctor(trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
    UITableAndGrid_OneItem.ctor(self, trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)

    --变量
end

--[[
    @desc: 在基类的ctor方法内会执行该方法
]]
function OneItem:InitUI()
    UITableAndGrid_OneItem.InitUI(self)

    self._name = self._transform:Find("name"):GetComponent("UILabel")
    self._name.text = ""

    self._gemTrs = self._transform:Find("gem")
    self._gemItem = GemIconItem.new(self._gemTrs)
end

function OneItem:Show(sourceData, oneDataIdx)
    UITableAndGrid_OneItem.Show(self, sourceData, oneDataIdx)

    --
    self._gemItem:Show(self._data.gemTypeInfo.itemId)

    self._name.text = tostring(self._data.gemTypeInfo.name)
end

function OneItem:Hide()
    UITableAndGrid_OneItem.Hide(self)

    self._name.text = ""
end

function OneItem:OnDestroy()
    UITableAndGrid_OneItem.OnDestroy(self)

    self._gemItem:OnDestroy()
end


local TwoItem = class("TwoItem", UITableAndGrid_TwoItem)
function TwoItem:ctor(trs, funcOnClick)
    UITableAndGrid_TwoItem.ctor(self, trs, funcOnClick)

    --变量
    self._levelUpStr = WordData.GetWordStringByKey("gem_level_up")
    self._promoteStr = WordData.GetWordStringByKey("gem_promote")
    self._quickBuyStr = WordData.GetWordStringByKey("gem_quickbuy")
end

function TwoItem:InitUI()
    UITableAndGrid_TwoItem.InitUI(self)

    self._itemTrs = self._transform:Find("item")
    self._item = GeneralItem.new(self._itemTrs)

    self._name = self._transform:Find("name"):GetComponent("UILabel")
    self._name.text = ""

    self._att = self._transform:Find("att"):GetComponent("UILabel")
    self._att.text = ""

    self._addGo = self._transform:Find("add").gameObject
end

function TwoItem:Show(sourceData, oneDataIdx, twoDataIdx)
    UITableAndGrid_TwoItem.Show(self, sourceData, oneDataIdx, twoDataIdx)

    if self._data.isAdd then
        --add图标样式
        self._item:Hide()
        self._addGo:SetActive(true)
        self._name.text = self._quickBuyStr
        self._att.text = self._promoteStr .. self._data.gemTypeInfo.proName
    else
        --普通样式
        local itemData = ItemData.GetItemInfo(self._data.item.tempId)
        self._item:ShowByItemData(itemData,self._data.item.count)
        --self._item:ShowCount(self._data.item.count)
        self._addGo:SetActive(false)
        self._name.text = itemData.name
        local tableData = GemData.GetGemDataById(self._data.item.tempId)
        local proData = AttDefineData.GetDefineData(tableData.gemProperties[1].id)
        if proData then
            self._att.text = string.format("%s+%s", proData.name, tableData.gemProperties[1].value)
        end
    end
end

function TwoItem:Hide()
    UITableAndGrid_TwoItem.Hide(self)

end

local RightWidget = class("RightWidget")
function RightWidget:ctor(trs, ui, funcOnInlayGem, funcOnExpandOneItem)
    --组件
    self._ui = ui
    self._transform = trs
    self._gameObject = trs.gameObject

    --title
    self._maxLevelDes = trs:Find("title/level"):GetComponent("UILabel")
    self._maxLevelStr = WordData.GetWordStringByKey("gem_maxlevel_for_inlay")

    --
    self._oneItemTemp = trs:Find("oneitem")
    self._twoItemTemp = trs:Find("twoitem")
    self._oneItemTemp.gameObject:SetActive(false)
    self._twoItemTemp.gameObject:SetActive(false)
    self._tableAndGridTrs = trs:Find("widget/panel/tableandgrid")
    self._tableAndGrid = UITableAndGrid.new(self._tableAndGridTrs, self._ui, self._oneItemTemp, self._twoItemTemp)
    local funcOnOneItemClick = function(oneDataIdx, expanded)
        self:OnOneItemClick(oneDataIdx, expanded)
    end
    local funcOnTwoItemClick = function(twoDataIdx, selected)
        self:OnTwoItemClick(twoDataIdx, selected)
    end
    self._tableAndGrid:Init(OneItem, TwoItem, funcOnOneItemClick, funcOnTwoItemClick, 0)

    self._funcOnInlayGem = funcOnInlayGem
    self._funcOnExpandOneItem = funcOnExpandOneItem

    --变量
    self._isShowed = false
    self._eventIds = {}
    self._oneTwoDataList = {}

    self:Hide()
end

function RightWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function RightWidget:RegEvent()
    
end

function RightWidget:UnRegEvent()
    self._eventIds = {}
end

function RightWidget:Show(oneTwoDataList, data)
    self:SetVisible(true)

    --显示title
    self._maxLevelDes.text = string.format(self._maxLevelStr, data.equipData.gemLevel)

    self._oneTwoDataList = oneTwoDataList
    self._tableAndGrid:Show(oneTwoDataList)
end

function RightWidget:Hide()
    self:SetVisible(false)
end

function RightWidget:OnEnable()

end

function RightWidget:OnDisable()

end

function RightWidget:OnOneItemClick(oneDataIdx, expanded)
    --组织数据，返回给UI
    if expanded then
        if self._funcOnExpandOneItem then
            self._funcOnExpandOneItem(oneDataIdx)
        end
    end
end

function RightWidget:OnTwoItemClick(twoDataIdx, selected)
    if not selected then
        return
    end
    if self._funcOnInlayGem then
        self._funcOnInlayGem(self._tableAndGrid:GetCurData())
    end
end

function RightWidget:ReExpandCurOneItem()
    self._tableAndGrid:ReExpandCurOneItem()
end

function RightWidget:GetCurOneDataIdx()
    return self._tableAndGrid:GetCurOneDataIdx()
end

function RightWidget:Hide()
    self:SetVisible(false)
end

function RightWidget:OnDestroy()
    self._tableAndGrid:OnDestroy()
end

return RightWidget