local GiftItemBase = class("GiftItemBase");

function GiftItemBase:ctor(staticInfo)
    self._id = staticInfo.id;
    self._staticInfo = staticInfo;
    local tid = staticInfo.itemID;
    self._tid = tid;
    self._itemInfo = ItemData.GetItemInfo(tid);
end

function GiftItemBase:TrySelect(selectedCount)
    local itemCount = self:GetItemCount();
    if itemCount <= 0 then
        TipsMgr.TipByFormat("TODO 打开获取途径界面");
        return false;
    end
    if selectedCount >= itemCount then
        TipsMgr.TipByKey("gift_no_more");
        return false;
    end
    return true;
end


function GiftItemBase:GetID()
    return self._id;
end

function GiftItemBase:IsFree()
    return self._staticInfo.costType == 1;
end

function GiftItemBase:IsCost()
    return self._staticInfo.costType == 2;
end

function GiftItemBase:IsCustom()
    return self._staticInfo.isCustom == 1;
end

function GiftItemBase:IsMemorial()
    return self._staticInfo.isMemorial == 1;
end

function GiftItemBase:GetCategoryID()
    return self._staticInfo.childType;
end

function GiftItemBase:GetName()
    return self._itemInfo.name;
end

function GiftItemBase:OpenSendUI()

end

function GiftItemBase:IsCustomizingGift()
    return mGiftTable[gid].isCustom;
end

function GiftItemBase:GetItemID()
    return self._tid;
end

function GiftItemBase:GetItemIcon()
    return ResConfigData.GetResConfigID(self._itemInfo.icon_big);
end

function GiftItemBase:GetItemIconName()
    return self._itemInfo.icon_big;
end
function GiftItemBase:GetItemCount()
    return BagMgr.GetCountByItemId(self._tid);
end

function GiftItemBase:GetValue()
    return 10;
end

function GiftItemBase:IsWithHorn()
    return self._itemInfo.hornID ~= 0;
end

return GiftItemBase;
