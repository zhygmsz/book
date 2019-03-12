local GemIconItem = class("GemIconItem")

function GemIconItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._icon = trs:Find("icon"):GetComponent("UISprite")

    --loader
    --self._loader = LoaderMgr.CreateTextureLoader(self._icon)

    --变量
    self._isShowed = false
    self._gemId = -1

    self:Hide()
end

function GemIconItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function GemIconItem:Show(gemId)
    self:SetVisible(true)

    self._gemId = gemId

    local itemData = ItemData.GetItemInfo(gemId)
    if not itemData then
        return
    end
    self._icon.spriteName = itemData.icon_big
    --[[
    local resId = ResConfigData.GetResConfigID(itemData.icon_big)
    if resId then
        self._loader:LoadObject(resId)
    end
    ]]
end

function GemIconItem:Hide()
    self:SetVisible(false)
end

function GemIconItem:OnDestroy()
    --处理loader
    --LoaderMgr.DeleteLoader(self._loader)
    --self._loader = nil
end

return GemIconItem