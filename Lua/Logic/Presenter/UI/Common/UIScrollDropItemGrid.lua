--UIScrollView下带有table或者grid窗口

UIScrollDropItemGrid = class("UIScrollDropItemGrid",UIScrollGridTable);

local function OnItemCreate(self,trans,index)

    local item = self._dropInfos[index];
    local itemInfo = ItemData.GetItemInfo(item.itemId);
    trans:GetComponent("UISprite").spriteName = item.icon_big and item.icon_big or itemInfo and itemInfo.icon_big or "";
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
        qualityBg:GetComponent("UISprite").spriteName = UIUtil.GetItemQualityBgSpName(itemInfo.quality);
    end
end

function UIScrollDropItemGrid:ctor(ui,path,baseEvent)
    UIScrollGridTable.ctor(self,ui,path);
    self._baseEvent = baseEvent;
end

function UIScrollDropItemGrid:ResetWrapContent(dropInfos)
    self._dropInfos = dropInfos;
    UIScrollGridTable.ResetWrapContent(self,#dropInfos,OnItemCreate,self);
    
end

function UIScrollDropItemGrid:OnClick(id)
    local bid = id - self._baseEvent;
    local item = self._dropInfos[bid];
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, item.itemId);
end

return UIScrollDropItemGrid;