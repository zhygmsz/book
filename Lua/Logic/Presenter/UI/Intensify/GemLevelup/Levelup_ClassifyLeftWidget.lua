local UITableAndGrid_OneItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_OneItem")
local UITableAndGrid_TwoItem = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid_TwoItem")
local UITableAndGrid = require("Logic/Presenter/UI/Common/UITableAndGrid/UITableAndGrid")
local GemIconItem = require("Logic/Presenter/UI/Intensify/Inlay/GemIconItem")

local OneItem = class("OneItem", UITableAndGrid_OneItem)

function OneItem:ctor(trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
    UITableAndGrid_OneItem.ctor(self, trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
end

function OneItem:InitUI()
    UITableAndGrid_OneItem.InitUI(self)

    self._name = self._transform:Find("name"):GetComponent("UILabel")
    self._name.text = ""

    self._gemTrs = self._transform:Find("gem")
    self._gemItem = GemIconItem.new(self._gemTrs)
end

function OneItem:Show(sourceData, oneDataIdx)
    UITableAndGrid_OneItem.Show(self, sourceData, oneDataIdx)

    self._name.text = tostring(self._data.titleName)
end

function OneItem:Hide()
    UITableAndGrid_OneItem.Hide(self)

    self._name.text = ""
end

local TwoItem = class("TwoItem", UITableAndGrid_TwoItem)

function TwoItem:ctor(trs, funcOnClick)
    UITableAndGrid_TwoItem.ctor(self, trs, funcOnClick)
end

function TwoItem:InitUI()
    UITableAndGrid_TwoItem.InitUI(self)

    self._gemTrs = self._transform:Find("gem")
    self._gemItem = GemIconItem.new(self._gemTrs)

    self._name = self._transform:Find("name"):GetComponent("UILabel")
    self._name.text = ""

    self._att = self._transform:Find("attbg/att"):GetComponent("UILabel")
    self._att.text = ""

    self._icon = self._transform:Find("gem/icon"):GetComponent("UITexture")
    self._iconNode = self._transform:Find("gem").gameObject
end

function TwoItem:Show(sourceData, oneDataIdx, twoDataIdx)
    UITableAndGrid_TwoItem.Show(self, sourceData, oneDataIdx, twoDataIdx)

    local itemData = ItemData.GetItemInfo(self._data.gemId)
    local gemData = GemData.GetGemDataById(self._data.gemId)
    if itemData ~= nil and gemData ~= nil then
        self._name.text = itemData.name
        local attrName = AttDefineData.GetDefineData(gemData.gemProperties[1].id).name.." + "..  gemData.gemProperties[1].value
        self._att.text = attrName

        self._iconNode:SetActive(true)
        local loadResID = ResConfigData.GetResConfigID(itemData.icon_big)
        UIUtil.SetTexture(loadResID, self._icon)
    end

    
end

function TwoItem:Hide()
    UITableAndGrid_TwoItem.Hide(self)  
end


local ClassifyWidget = class("ClassifyWidget")

function ClassifyWidget:ctor(trs, ui, onClickCallback)
    self._transform = trs
    self._ui = ui
    self._gameObject = trs.gameObject

    self._oneItemTemp = trs:Find("oneitem")
    self._twoItemTemp = trs:Find("twoitem")

    self._oneItemTemp.gameObject:SetActive(false)
    self._twoItemTemp.gameObject:SetActive(false)

    self._tableAndGridTrs = trs:Find("widget/panel/tableandgrid")
    self._tableAndGrid = UITableAndGrid.new(self._tableAndGridTrs, self._ui, self._oneItemTemp, self._twoItemTemp)

    self._onClickCallback = onClickCallback
    self._funcOnOneItemClick = nil
    self._funcOnTwoItemClick = function(twoDataIdx, selected)
        self:OnTwoItemClick(twoDataIdx, selected)
    end

    self._tableAndGrid:Init(OneItem, TwoItem, self._funcOnOneItemClick, self._funcOnTwoItemClick, 0)

end

function ClassifyWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShow = visible
end

function ClassifyWidget:RegEvent()
    
end

function ClassifyWidget:UnRegEvent()
    
end

function ClassifyWidget:Show(oneTwoDataList, newOneIdx, newTwoIdx)
    self._oneTwoDataList = oneTwoDataList
    self._tableAndGrid:Show(oneTwoDataList)

    --如果有的话，则根据oneidx和twoidx展开
    if newOneIdx and newTwoIdx then
        self._tableAndGrid:CustomShowOneTwoExpanded(newOneIdx, newTwoIdx)
    end
end

function ClassifyWidget:OnOneItemClick(data, expanded)
    
end

function ClassifyWidget:OnTwoItemClick(twoDataIdx, selected)
    if not selected then
        return
    end

    local oneIdx = self._tableAndGrid:GetCurOneDataIdx()
    local twoIdx = self._tableAndGrid:GetCurTwoDataIdx()
    GemLevelupMgr.SetTwoIndex(oneIdx, twoIdx)

    if self._onClickCallback then
        self._onClickCallback(self._tableAndGrid:GetCurData())
    end
end

function ClassifyWidget:OnDestroy()
    self._tableAndGrid:OnDestroy()
end

return ClassifyWidget