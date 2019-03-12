--UIWrapContent 的封装类,配合BaseWrapContentUI一起使用
BaseWrapContentEx = class("BaseWrapContentEx",BaseWrapContent)

function BaseWrapContentEx:ctor(...)
    BaseWrapContent.ctor(self, ...);
    self._panelGo = self._dragPanel.gameObject;
end

function BaseWrapContentEx:OnInitItem(go,wrapIndex,realIndex)
    if self._lineDatas[realIndex+1] then
        go:SetActive(true);
        local wrapUI = self._wrapItemList[wrapIndex + 1];
        local wrapData = self._lineDatas[realIndex+1];
        wrapUI:DispatchData(wrapData);
        wrapUI:OnRefresh();
    else
        go:SetActive(false);
    end
end

function BaseWrapContentEx:SetUIEvent(baseEventId,eventIdSpan,callbacks,caller)
    self._baseEventId = baseEventId;
    self._eventIdSpan = eventIdSpan;
    for i, wrapUI in ipairs(self._wrapItemList) do
        local eventId = baseEventId  + eventIdSpan * (i-1);
        wrapUI:SetOnClick(callbacks,caller, eventId);
    end
end

function BaseWrapContentEx:OnClick(id)
    if not self._panelGo.activeInHierarchy then return; end
    id = (id - self._baseEventId);
    local uiIndex = math.floor(id / self._eventIdSpan) + 1;
    local buttonId = id - (uiIndex-1) * self._eventIdSpan + 1;
    local wrapUI = self._wrapItemList[uiIndex];
    wrapUI:OnClick(buttonId);
end


return BaseWrapContentEx;
