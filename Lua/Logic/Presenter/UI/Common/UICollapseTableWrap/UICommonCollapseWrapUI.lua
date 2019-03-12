UICommonCollapseWrapUI  = class("UICommonCollapseWrapUI",nil);

function UICommonCollapseWrapUI:ctor(itemTran,baseEvent)
    self._baseEvent= baseEvent;
    self._isActive = true;
end

function UICommonCollapseWrapUI:GetType()
    return self._type or self.__cname;
end

function UICommonCollapseWrapUI:SetActive(show)
    self._gameObject:SetActive(show);
    self._isActive = show;
end
function UICommonCollapseWrapUI:IsActive()
    return self._isActive;
end

function UICommonCollapseWrapUI:DispatchData(wrapData)
    self._wrapData = wrapData;
end

function UICommonCollapseWrapUI:GetData()
    return self._wrapData;
end

function UICommonCollapseWrapUI:OnRefresh()

end

function UICommonCollapseWrapUI:OnClick(bid)

end

function UICommonCollapseWrapUI:GetWidget()
    return self._widget;
end
