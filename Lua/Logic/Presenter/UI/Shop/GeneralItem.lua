local GeneralItem = class("GeneralItem")

function GeneralItem:ctor(trs, eventId)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --eventid
    --有的话需要响应tips，没有则不处理
    self._bg = trs:Find("bg"):GetComponent("UISprite")
    self._originalbackground = self._bg.spriteName
    self._icon = trs:Find("icon"):GetComponent("UISprite")
    self._count = trs:Find("count"):GetComponent("UILabel")
    self._countGo = self._count.gameObject
    self._countGo:SetActive(false)
    self._selectedGo = trs:Find("selected").gameObject
    self._selectedGo:SetActive(false)

    --loader
    --self._loader = LoaderMgr.CreateTextureLoader(self._icon)
    
    --变量
    self._isShowed = false
    self._itemId = -1

    self:Hide()
end

function GeneralItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function GeneralItem:ShowByItemId(itemId,itemCount,isShowQuality,isSelect,isSetGray)
    self._itemId = itemId

    --显示
    local itemData = ItemData.GetItemInfo(itemId)
    if itemData then
        self:ShowByItemData(itemData,itemCount,isShowQuality,isSelect,isSetGray)
    end
end

function GeneralItem:ShowByItemData(itemData,itemCount,isShowQuality,isSelect,isSetGray)
    if not itemData then
        return
    end

    self:SetVisible(true)
    self._icon.spriteName = itemData.icon_big
    
    if isShowQuality then
        self:ShowBg(itemData.quality)
    else
        self:ShowBg(self._originalbackground)
    end
    if itemCount and itemCount>0 then
        self._countGo:SetActive(true)
        self._count.text = tostring(itemCount)
    else
        self._countGo:SetActive(false)
        self._count.text = ""
    end
    if isSelect then
        self._selectedGo:SetActive(isSelect)
    else
        self._selectedGo:SetActive(false)
    end
    if isSetGray then
        self:SetSpriGray(isSetGray);
    else
        self:SetSpriGray(false);
    end

    --[[
    local resId = ResConfigData.GetResConfigID(itemData.icon_big)
    if resId then
        self._loader:LoadObject(resId)
    end
    ]]
end

--[[
    @desc: 显示品质框
]]
function GeneralItem:ShowBg(quality)
    self._bg.spriteName = UIUtil.GetItemQualityBgSpName(quality)
end

function GeneralItem:ShowCount(count)
    self._countGo:SetActive(true)
    self._count.text = tostring(count)
end

function GeneralItem:SetSelectedVisible(visible)
    self._selectedGo:SetActive(visible)
end

function GeneralItem:Hide()
    self:SetVisible(false)
end

function GeneralItem:OnDestroy()
    self._itemId = -1
    --销毁loader
    --LoaderMgr.DeleteLoader(self._loader)
    --self._loader = nil
end

function GeneralItem:SetSpriGray(isGray)
    UIMgr.MakeUIGrey(self._icon, isGray);
    UIMgr.MakeUIGrey(self._bg, isGray);

end

return GeneralItem