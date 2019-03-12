local TitleWrapUIContentBase = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentBase");
local TitleWrapUIContentUserDefine  = class("TitleWrapUIContentUserDefine",TitleWrapUIContentBase);


function TitleWrapUIContentUserDefine:OnRefresh()
--WordData.GetWordStringByKey("title_current_class_in_use");
    local item = self._wrapData;
    local selected = self._context:IsItemUserSelect(item);
    TitleWrapUIContentBase.OnRefresh(self,item:GetClassifyName(),selected);
    self._openGo:SetActive(false);
end
function TitleWrapUIContentUserDefine:OnClick(bid)
    self._context:OnItemUserSelect(self._wrapData,self);
end
return TitleWrapUIContentUserDefine;