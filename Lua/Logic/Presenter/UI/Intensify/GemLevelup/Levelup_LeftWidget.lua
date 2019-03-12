local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")


local  LevelupLeftItem = class("LevelupLeftItem", ContentItem)

function LevelupLeftItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)    

    self._gameObject = trs.gameObject

    self._icon = trs:Find("item/icon"):GetComponent('UITexture')
    self._name = trs:Find("name"):GetComponent("UILabel")
    self._attrTxt = trs:Find("desc"):GetComponent("UILabel")
end

function LevelupLeftItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)

    self._name.text = data.itemData.name

    local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
    UIUtil.SetTexture(loadResID, self._icon)
    
    local attrName = AttDefineData.GetDefineData(data.gemData.gemProperties[1].id).name.." + "..  data.gemData.gemProperties[1].value

    self._attrTxt.text = attrName
end

function LevelupLeftItem:Hide()
    self._gameObject:SetActive(false)
end

------------------ Widget ------------------

local LevelupLeftWidget = class("LevelupLeftWidget")

function LevelupLeftWidget:ctor(transform, baseEventId, onClickCallback, ui)
    self._transform = transform
    self._gameObject = transform.gameObject
    
    self._widgetTrs = transform:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, onClickCallback, baseEventId, LevelupLeftItem)
    
end

function LevelupLeftWidget:Show(dataList, realIndex)
    self._contentWidget:Show(dataList)

    self._contentWidget:AutoSelectRealIdx(realIndex)
end

function LevelupLeftWidget:Hide()
    self._widgetTrs.gameObject:SetActive(false)
end

function LevelupLeftWidget:OnDestory()
    
end

function LevelupLeftWidget:GetCurRealIdx()
    return self._contentWidget:GetCurRealIdx()
end

function LevelupLeftWidget:UpdateItem(realIdx, data)
    self._contentWidget:UpdateItem(realIdx, data)
end

function LevelupLeftWidget:OnClick(eventId)
    self._contentWidget:OnClick(eventId)
    local index = self._contentWidget:GetCurRealIdx()
    GemLevelupMgr.SetOneIndex(index)
    GemLevelupMgr.SetLeftEventId(eventId)
end

return LevelupLeftWidget