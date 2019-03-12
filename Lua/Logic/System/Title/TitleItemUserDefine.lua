local TitleItem = require("Logic/System/Title/TitleItem");
local TitleItemUserDefine = class("TitleItemUserDefine",TitleItem);
function TitleItemUserDefine:ctor(...)
    TitleItem.ctor(self,...);
    
end

function TitleItemUserDefine:InitDynamicInfo(data)
    self._dynamic.name = data.titlestr;
    self._dynamic.expiretime = data.expiretime;
end

function TitleItemUserDefine:SetOpen(info)
    self._dynamic.name = info.titlestr;
    GameEvent.Trigger(EVT.TITLE,EVT.TITLE_OPEN_CHANGE,self);
end
function TitleItemUserDefine:SetName(name)
    self._dynamic.name = name;
    GameEvent.Trigger(EVT.TITLE,EVT.TITLE_INFO_CHANGE,self);
end

function TitleItemUserDefine:IsPreviewAble()
    return self:IsOpen();
end
function TitleItemUserDefine:IsOpen(value)
    local name = self._dynamic.name;
    return name and name~="";
end

function TitleItemUserDefine:GetName()
    return self._dynamic.name;
end

return TitleItemUserDefine;