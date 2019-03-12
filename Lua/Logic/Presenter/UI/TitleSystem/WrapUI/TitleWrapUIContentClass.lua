local TitleWrapUIContentBase = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentBase");
local TitleWrapUIContentClass  = class("TitleWrapUIContentClass",TitleWrapUIContentBase);

function TitleWrapUIContentClass:OnRefresh()

    local class = self._wrapData;
    

    self._openGo:SetActive(true);
    local selected = self._context:IsClassSelect(class);
    local z = selected and 90 or 180;
    self._openSprite.localRotation = UnityEngine.Quaternion.Euler(0,0,z);
    TitleWrapUIContentBase.OnRefresh(self,class:GetName(),selected);
end
function TitleWrapUIContentClass:OnClick(bid)
    self._context:OnClassSelect(self._wrapData,self);
end
return TitleWrapUIContentClass;