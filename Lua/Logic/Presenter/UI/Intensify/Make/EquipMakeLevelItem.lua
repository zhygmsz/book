local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")
local EquipMakeLevelItem = class("EquipMakeLevelItem", ContentItem)

function EquipMakeLevelItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId);
    self._itemTrs = trs:Find("Item");
    self._level = trs:Find("label"):GetComponent("UILabel");
end

function EquipMakeLevelItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx);
    self._level.text = data.level;
end

function EquipMakeLevelItem:OnDestroy()
    ContentItem.OnDestroy(self)
end


return EquipMakeLevelItem