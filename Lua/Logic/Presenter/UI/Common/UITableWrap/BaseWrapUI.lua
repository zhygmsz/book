local BaseWrapUI  = class("BaseWrapUI",nil);

function BaseWrapUI:ctor()

end

function BaseWrapUI:GetType()
    return self._type;
end

function BaseWrapUI:SetActive(show)
    self._gameObject:SetActive(show);
end

function BaseWrapUI:GetWidget()
    return self._widget;
end

return BaseWrapUI;