local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local LevelupRightItem = class("LevelupRightItem", ContentItem)

local function OnToggleClick(data, index)
    GemLevelupMgr.SetAddExp(data, true, index)
end

local function OnCancelClick(data)
    GemLevelupMgr.SetAddExp(data, false, index)
end

function LevelupRightItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)    

    self._name = trs:Find("name"):GetComponent("UILabel")
    self._icon = trs:Find("item/icon"):GetComponent("UITexture")
    self._count = trs:Find("item/count"):GetComponent("UILabel")
    self._attr = trs:Find("desc"):GetComponent("UILabel")
    self._toggle = trs:Find("toggle"):GetComponent("UIToggle")

    self._callback = EventDelegate.Callback(self.OnToggleClickCallback, self, eventId - 60)
    EventDelegate.Add(self._toggle.onChange, self._callback) 
end

function LevelupRightItem:OnToggleClickCallback(index)
    if self._toggle.value then
        OnToggleClick(self._data, index)
    else
        OnCancelClick(self._data, index)
    end
end

function LevelupRightItem:Show(data)

    self._data = data
    ContentItem.Show(self, data, selectedRealIdx)

    self._name.text = data.itemData.name
    local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
    UIUtil.SetTexture(loadResID, self._icon)

    local attrName = AttDefineData.GetDefineData(data.gemData.gemProperties[1].id).name.." + "..  data.gemData.gemProperties[1].value
    self._attr.text = string.format( WordData.GetWordStringByKey("gem_experience_value"), data.gemExp * data.count )

    self._count.text = data.count

    self._toggle.value = false
end

function LevelupRightItem:Hide()    
    
end

function LevelupRightItem:OnDestory()
    
end

function LevelupRightItem:OnToggleClick(isSelected)
    self._toggle.value = isSelected
end

------------------------widget------------------------

local LevelupRightWidget = class("LevelupRightWidget", ContentWidget)

function LevelupRightWidget:ctor(transform, baseEventId, onClickCallback, ui)
    self._transform = transform
    self._gameObject = transform.gameObject
    
    self._widgetTrs = transform:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, onClickCallback, baseEventId, LevelupRightItem)
end

function LevelupRightWidget:Show(dataList)
    self._contentWidget:Show(dataList)
end

function LevelupRightWidget:Hide()
    
end

function LevelupRightWidget:OnDestory()
    
end

function LevelupRightWidget:OnClickAllSelect( isSelected )
    self._contentWidget:InvokeFunc("OnToggleClick", isSelected)
end

function LevelupRightWidget:OnClick(id)
    self._contentWidget:OnClick(id)
end

return LevelupRightWidget