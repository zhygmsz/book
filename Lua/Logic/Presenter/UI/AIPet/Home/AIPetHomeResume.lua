local AIPetHomeResume = class("AIPetHomeResume");

function AIPetHomeResume:ctor(ui)
    self._mainGo = ui:Find("Offset/ResumePanel").gameObject;
    self._petNameLabel = ui:FindComponent("UILabel","Offset/ResumePanel/Offset/LabelName/Sprite/Label");
    self._hostNameLabel = ui:FindComponent("UILabel","Offset/ResumePanel/Offset/LabelHost/Sprite/Label");
    local petInput = ui:FindComponent("LuaUIInput","Offset/ResumePanel/Offset/LabelName/Sprite");
    local hostInput = ui:FindComponent("LuaUIInput","Offset/ResumePanel/Offset/LabelHost/Sprite");
    local maxLength = ConfigData.GetIntValue("AIPet_Name_MaxLength") or 5;
    self._petNameInput = UICommonLuaInput.new(petInput,maxLength);
    self._hostNameInput = UICommonLuaInput.new(hostInput,maxLength);
    self._petNameInput:SetCallback(nil,self.OnPetNameDeselect,self);
    self._hostNameInput:SetCallback(nil,self.OnHostNameDeselect,self);
    self._timeLabel = ui:FindComponent("UILabel","Offset/ResumePanel/Offset/SpriteTime/Label");

    self._buttonUseGo = ui:Find("Offset/ResumePanel/Offset/ButtonUse").gameObject;

    self._spriteUsedGo = ui:Find("Offset/ResumePanel/Offset/SpriteUsed").gameObject;
end

function AIPetHomeResume:Show(pet)
    
    if pet then
        self._mainGo:SetActive(true);
        self._petNameInput:SetEnable(false);
        self._hostNameInput:SetEnable(false);

        self._selectedPet = pet;

        local timePast = TimeUtils.SystemTimeStamp(true) - pet:GetReceiveTime();
        self._petNameInput:SetInitText(pet:GetName());
        self._hostNameInput:SetInitText(pet:GetHostName());
        local time = TimeUtils.Time2Units(timePast * 1000,true);

        self._timeLabel.text = WordData.GetWordStringByKey("AIPet_time_spend",time.day);--共同在一起的时间
        self:OnPetInUse();
    else
        self._mainGo:SetActive(false);
    end
end

function AIPetHomeResume:OnPetInUse(usePet)
    usePet = usePet or AIPetMgr.GetPetInUse();
    self._buttonUseGo:SetActive(usePet ~= self._selectedPet);
    self._spriteUsedGo:SetActive(usePet == self._selectedPet);
end

function AIPetHomeResume:OnPetNameDeselect()
    if self._petNameInput:CheckValid() then
        local name = self._petNameInput:GetValue();
        self._selectedPet:SetName(name);
        self._petNameInput:SetInitText(name);
    end
end

function AIPetHomeResume:OnHostNameDeselect()
    if self._hostNameInput:CheckValid() then
        local name = self._hostNameInput:GetValue();
        self._selectedPet:SetHostName(name);
        self._hostNameInput:SetInitText(name);
    end
end

function AIPetHomeResume:OnClick(id)
    if not self._mainGo.activeInHierarchy then return; end
    if id == 101 then
        AIPetMgr.RequestSetPetInUse(self._selectedPet);
    elseif id == 102 then
        self._petNameInput:SetEnable(true);
        self._hostNameInput:SetEnable(true);
        self._petNameInput:SetSelect(true);
    elseif id == 103 then
        self._petNameInput:SetEnable(false);
        self._hostNameInput:SetEnable(false);
    end
end

return AIPetHomeResume;