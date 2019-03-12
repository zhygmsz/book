local TitleWrapUIContentBase = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentBase");
local TitleWrapUIItemInUse  = class("TitleWrapUIItemInUse",TitleWrapUIContentBase);


function TitleWrapUIItemInUse:OnRefresh()
    local name = WordData.GetWordStringByKey("title_current_class_in_use");
    local selected = self._context:IsItemInUseSelect();
    TitleWrapUIContentBase.OnRefresh(self,name,selected);
    self._openGo:SetActive(false);
end

function TitleWrapUIItemInUse:OnClick(bid)
    self._context:OnItemInUseSelect(self._wrapData,self);
end

return TitleWrapUIItemInUse;