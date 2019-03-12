local TitleItem = class("TitleItem");

function TitleItem:ctor(static)
    self._static = static;
    self._dynamic = {};
    self._group = nil;
end
--只有已经激活的才会初始化
function TitleItem:InitDynamicInfo(data)
    self._dynamic.isOpened = true;
    self._dynamic.expiretime = data.expiretime;
end

---动态信息
function TitleItem:IsOpen(value)
    return self._dynamic.isOpened;
end
function TitleItem:SetOpen(info)
    self._dynamic.isOpened = true;
    self._dynamic.expiretime = info.expiretime;
    GameEvent.Trigger(EVT.TITLE,EVT.TITLE_OPEN_CHANGE,self);
end
function TitleItem:SetClose(info)
    self._dynamic.isOpened = false;
    self._dynamic.expiretime = info.expiretime;
    GameEvent.Trigger(EVT.TITLE,EVT.TITLE_OPEN_CHANGE,self);
end
function TitleItem:GetExpireTime()
    return self._dynamic.expiretime;
end
--静态信息
function TitleItem:SetGroup(group)
    self._group = group;
end
function TitleItem:GetGroup()
    return self._group;
end
function TitleItem:GetID()
    return self._static.id;
end
function TitleItem:GetName()
    return self._static.name;
end
function TitleItem:GetNameWithColor()    
    return string.format("[%s]<%s>[-]",self:GetColor(),self:GetName());
end
function TitleItem:GetIconName()
    return self._static.resourceName;
end
function TitleItem:GetColor()
    return self._static.presentColor;
end
function TitleItem:IsArt()
    return self._static.isArt;
end
function TitleItem:IsUserDifine()
    return self._static.isUserDefine;
end
function TitleItem:IsAutoHide()
    return self._static.autoHide;
end
function TitleItem:GetDescribe()
    return self._static.titleDes;
end
function TitleItem:GetValidityPeriod()
    return self._static.validityPeriod;
end
function TitleItem:GetAchieveDescribe()
    return self._static.achieveDes;
end
function TitleItem:GetClassifyName()
    return self._static.classifyName;
end

function TitleItem:IsPreviewAble()
    return true;
end

function TitleItem:SetUI(label,labelGo,sprite,spriteGo)
    if not self:IsArt() then
        labelGo:SetActive(true);
        spriteGo:SetActive(false);
        local titleText = self:GetNameWithColor();
        label.text = titleText;
    else
        labelGo:SetActive(false);
        spriteGo:SetActive(true);
        sprite.spriteName = self:GetIconName();
    end
end

return TitleItem;