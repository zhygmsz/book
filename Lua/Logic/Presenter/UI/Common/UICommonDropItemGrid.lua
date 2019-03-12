UICommonDropItemGrid = class("UICommonDropItemGrid")

local function OnItemCreate(self,trans,index)
    local drop = self._dropInfos[index];
    local item = ItemData.GetItemInfo(drop.itemId);
    local icon = trans:GetComponent("UISprite");
    icon.spriteName = item.icon_big;
    trans:GetComponent("UIEvent").id = self._baseEvent+index;
    local count = trans:Find("Count");
    if count then
        count:GetComponent("UILabel").text = self._dropInfos[index].minCount;
    end
    local name = trans:Find("Name");
    if name then
        name:GetComponent("UILabel").text = item.name;
    end
    local qualityBg = trans:Find("Icon_bg");
    if qualityBg then
        qualityBg:GetComponent("UISprite").spriteName = UIUtil.GetItemQualityBgSpName(item.quality);
    end
    local mask = trans:Find("Mask");
    if mask then
        self._uiItems[index] = {}
        self._uiItems[index].maskGo = mask.gameObject;
    end
end

function UICommonDropItemGrid:ctor(ui,grid,prefab,baseEvent)
    self._ui = ui;
    self._grid = grid;
    self._prefab = prefab;
    self._baseEvent = baseEvent;
    self._parent = self._grid.transform;
end

function UICommonDropItemGrid:Refresh(dropInfos)
    self._dropInfos = dropInfos;
    self._uiItems = {};
    UIGridTableUtil.CreateChild(self._ui,self._prefab,#dropInfos,self._parent,OnItemCreate,self);
    self._grid:Reposition();
    
end

function UICommonDropItemGrid:OnClick(id)
    local bid = id - self._baseEvent;
    local drop = self._dropInfos[bid];
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, drop.itemId);
end

function UICommonDropItemGrid:SetMask(value)
    for i,item in ipairs(self._uiItems) do
        item.maskGo:SetActive(value);
    end
end