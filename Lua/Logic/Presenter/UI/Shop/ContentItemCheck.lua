local ContentItemBase = require("Logic/Presenter/UI/Shop/ContentItemBase")

local ContentItemCheck = class("ContentItemCheck", ContentItemBase)

function ContentItemCheck:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemBase.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    self:SetChecked(self._checked)

    --在子类构造方法最后调用基类的Hide
    self:Hide()
end

function ContentItemCheck:Show(data, dataIdx)
    ContentItemBase.Show(self, data, dataIdx)
end

--[[
    @desc: 修改self._checked字段
]]
function ContentItemCheck:SetChecked(checked)
    self._norGo:SetActive(not checked)
    self._specGo:SetActive(checked)
end

return ContentItemCheck