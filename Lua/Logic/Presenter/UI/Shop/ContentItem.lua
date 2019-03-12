local ContentItem = class("ContentItem")

function ContentItem:ctor(trs, eventId)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    --uievent
    self._uiEvent = trs:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = eventId
    self._eventId = eventId

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    --变量
    self._data = nil

    self:ToNor()
end

--虚方法
function ContentItem:Show(data, selectedRealIdx)
    self._data = data

    if self._data.realIdx == selectedRealIdx then
        self:ToSpec()
    else
        self:ToNor()
    end
end

function ContentItem:ShowByData(data)
    self._data = data
end

function ContentItem:ToNor()
    if self._hasNorAndSpec then
        self._norGo:SetActive(true)
        self._specGo:SetActive(false)
    end
end

function ContentItem:ToSpec()
    if self._hasNorAndSpec then
        self._specGo:SetActive(true)
        self._norGo:SetActive(false)
    end
end

function ContentItem:GetData()
    return self._data
end

function ContentItem:GetWrapIdx()
    if self._data then
        return self._data.wrapIdx
    else
        return -1
    end
end

function ContentItem:GetRealIdx()
    if self._data then
        --待实现
        --这里的判断是保险，但最应该的是由CS同步给lua每一个UIItem的可见性
        --外部调用这些方法时，先判断该item是否可见，一切合法操作或访问的基础是可见
        return self._data.realIdx
    else
        return -1
    end
end

function ContentItem:GetUIEventId()
    return self._eventId
end

--虚方法
function ContentItem:OnDestroy()
    self._data = nil
end

return ContentItem