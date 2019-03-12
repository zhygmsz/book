local TitleBasicPanel = class("TitleBasicPanel");

function TitleBasicPanel:ctor(ui)
    local path = "Offset/Center/PreviewPanel";
    self._panelGo = ui:Find(path).gameObject;
    self._titleLabel = ui:FindComponent("UILabel",path.."/HUD/LabelTitle");
    self._titleLabelGo = ui:Find(path.."/HUD/LabelTitle").gameObject;
    self._titleSprite = ui:FindComponent("UISprite",path.."/HUD/SpriteTitle");
    self._titleSpriteGo = ui:Find(path.."/HUD/SpriteTitle").gameObject;
    self._validationLabel = ui:FindComponent("UILabel",path.."/LabelValidation");
    self._wearGo = ui:Find(path.."/ButtonWear").gameObject;
    self._hideGo = ui:Find(path.."/ButtonHide").gameObject;
end

function TitleBasicPanel:OnEnable(item)
    self._selectedItem = item;

    if (not item) or (not item:IsPreviewAble()) then
        self._panelGo:SetActive(false);
        return;
    end
    self._panelGo:SetActive(true);
    item:SetUI(self._titleLabel,self._titleLabelGo,self._titleSprite,self._titleSpriteGo);

    local day = 0;
    if TitleMgr.IsItemInUse(item) then
        self._hideGo:SetActive(true);
        self._wearGo:SetActive(false);
        day = item:GetExpireTime();

        if (day==nil) or day == 0 then
            day = WordData.GetWordStringByKey("title_permanent_time");
        else
            day = WordData.GetWordStringByKey("title_expire_time",day);
        end
    elseif item:IsOpen() then
        self._hideGo:SetActive(false);
        self._wearGo:SetActive(true);
        day = item:GetValidityPeriod();
        if day == 0 then
            day = WordData.GetWordStringByKey("title_permanent_time");
        else
            day = WordData.GetWordStringByKey("title_validity_time",day);
        end
    else
        self._hideGo:SetActive(false);
        self._wearGo:SetActive(false);
        day = item:GetValidityPeriod();
        day = WordData.GetWordStringByKey("title_not_available",day);
    end
    self._validationLabel.text = day;
end
function TitleBasicPanel:OnDisable()
    self._selectedItem = nil;
    self._panelGo:SetActive(false);
end

function TitleBasicPanel:OnClick(id)
    if id == 2 then--hide
        TitleMgr.RequestUnuseTitle();
    elseif id == 3 then --wear
        TitleMgr.RequestUseItem(self._selectedItem);
    end
end

return TitleBasicPanel;