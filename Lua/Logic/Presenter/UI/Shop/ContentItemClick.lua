local ContentItemBase = require("Logic/Presenter/UI/Shop/ContentItemBase")

local ContentItemClick = class("ContentItemClick", ContentItemBase)

function ContentItemClick:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemBase.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    --变量

    self:ToNor()

    self:Hide()
end

function ContentItemClick:Show(data, dataIdx)
    ContentItemBase.Show(self, data, dataIdx)
end

function ContentItemClick:ToNor()
    if self._hasNorAndSpec then
        self._norGo:SetActive(true)
        self._specGo:SetActive(false)
    end
end

function ContentItemClick:ToSpec()
    if self._hasNorAndSpec then
        self._specGo:SetActive(true)
        self._norGo:SetActive(false)
    end
end

return ContentItemClick