
local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local EquipMakeItem = class("EquipMakeItem", ContentItem)

function EquipMakeItem:ctor(trs, eventId)
    

    --左侧装备图标
    self._itemTrs = trs:Find("Item");
    self._name = trs:Find("name"):GetComponent("UILabel");
    self._level = trs:Find("Level"):GetComponent("UILabel");
    self._typeName = trs:Find("Label"):GetComponent("UILabel");
    self._canMake = trs:Find("Item/Select");

    -- local iconTexture = trs:Find("Item/icon"):GetComponent("UITexture");
    -- if iconTexture then
    --     self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    -- end
    self._icon = trs:Find("Item/icon"):GetComponent("UISprite");
    self._spec = trs:Find("spec");
    ContentItem.ctor(self, trs, eventId);
end

function EquipMakeItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx);

    self._name.text = data.equipName;
    self._level.text = data.equipLevel;
    --self._typeName = data.equipMakeItemData.
    self._icon.spriteName = data.icon;
    -- if self._iconTextureLoader then
    --     self._iconTextureLoader:LoadObject(data.icon);
    -- end
    if data.canMake then
        self._canMake.gameObject:SetActive(true)
    else
        self._canMake.gameObject:SetActive(false)
    end
end

function EquipMakeItem:ToSpec()
    self._spec.gameObject:SetActive(true);
end


function EquipMakeItem:ToNor()
    self._spec.gameObject:SetActive(false);
end


function EquipMakeItem:OnDestroy()
    ContentItem.OnDestroy(self)
end

return EquipMakeItem