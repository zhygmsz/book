UICommonItemListGrid = class("UICommonItemListGrid")

local function OnItemCreate(self,trans,index)

    local info = self._itemList[index];
    local item = ItemData.GetItemInfo(info.itemid);
    local icon = trans:GetComponent("UISprite");
    icon.spriteName = item.icon_big;
    trans:GetComponent("UIEvent").id = self._baseEvent+index;
    local count = trans:Find("Count");
    if count then
        count:GetComponent("UILabel").text = info.count;
    end
    local name = trans:Find("Name");
    if name then
        name:GetComponent("UILabel").text = item.name;
    end
    local mask = trans:Find("Mask");
    if mask then
        self._uiItems[index] = {}
        self._uiItems[index].maskGo = mask.gameObject;
    end
end

function UICommonItemListGrid:ctor(ui,grid,prefab,baseEvent)
    self._ui = ui;
    self._grid = grid;
    self._prefab = prefab;
    self._baseEvent = baseEvent;
    self._parent = self._grid.transform;
end
--itemList: 对应 NetCS_pb.CommonPrize.itemlist
function UICommonItemListGrid:Refresh(itemList)
    self._itemList = itemList;
    self._uiItems = {};
    UIGridTableUtil.CreateChild(self._ui,self._prefab,#itemList,self._parent,OnItemCreate,self);
    self._grid:Reposition();
end

function UICommonItemListGrid:OnClick(id)
    local bid = id - self._baseEvent;
    local info = self._itemList[bid];
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, info.itemid);
end

function UICommonItemListGrid:SetMask(value)
    for i,item in ipairs(self._uiItems) do
        item.maskGo:SetActive(value);
    end
end