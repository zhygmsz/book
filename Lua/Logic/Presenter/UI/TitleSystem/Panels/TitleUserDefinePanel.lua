local TitleUserDefinePanel = class("TitleUserDefinePanel");

function TitleUserDefinePanel:ctor(ui)
    local path = "Offset/Center/UserInfoPanel";
    self._panelGo = ui:Find(path).gameObject;
    self._input = ui:FindComponent("LuaUIInput",path.."/InputName");
    self._inputCollider = ui:FindComponent("BoxCollider",path.."/InputName");
    
    self._buttonAddGo = ui:Find(path.."/ButtonAdd").gameObject;
    self._buttonOkGo = ui:Find(path.."/InputName/ButtonOk").gameObject;
    self._buttonEditGo = ui:Find(path.."/InputName/ButtonRevise").gameObject;
    self._inputLabel = ui:FindComponent("UILabel",path.."/InputName/Label");
    --EventDelegate.Set(self._input.onSelect,EventDelegate.Callback(OnInputSelect));
    EventDelegate.Set(self._input.onDeSelect,EventDelegate.Callback(self.OnInputDeSelect,self));
end

function TitleUserDefinePanel:Refresh(item)
    self._buttonOkGo:SetActive(false);
    self._inputCollider.enabled = false;

    if item:IsOpen() then
        self._input.value = item:GetName();
        self._buttonAddGo:SetActive(false);
        self._buttonEditGo:SetActive(true);
    else
        self._input.value = "";
        self._inputLabel.text = "";--WordData.GetWordStringByKey("input_notice");
        self._buttonAddGo:SetActive(true);
        self._buttonEditGo:SetActive(false);
    end
end

function TitleUserDefinePanel:OnInputSelect()
    self._buttonAddGo:SetActive(false);
    self._buttonOkGo:SetActive(true);
    self._buttonEditGo:SetActive(false);
end

function TitleUserDefinePanel:OnInputDeSelect()

    local name = self._item:GetName();
    local hasName = name and name ~= "";
    local hasInput = self._input.value and self._input.value ~= "";
    local newName = hasName and hasInput and name ~= self._input.value;

    if hasName and (not hasInput or not newName) then
        self._buttonOkGo:SetActive(false);
        self._buttonEditGo:SetActive(true);
        self._inputCollider.enabled = false;
        self._input.value = name;
    end
    if not hasName and not hasInput then
        self._buttonAddGo:SetActive(true);
        self._buttonOkGo:SetActive(false);
        self._inputCollider.enabled = false;
    end
end

function TitleUserDefinePanel:OnEnable(item)
    self._panelGo:SetActive(true);
    self:Refresh(item);
    self._item = item;
end
function TitleUserDefinePanel:OnClick(id)
    if id == 1 then
        local name = self._input.value;
        
        local oldName = self._item:GetName();
        local length = self._input:GetValueLength();
        if not name or name == "" then
        elseif length >6 then
            TipsMgr.TipByKey("input_error_length_com",6);
        elseif name == oldName then
            TipsMgr.TipByKey("input_error_same_value");
        else
            TitleMgr.RequestSetUserDefineName(name);
        end
    elseif id == 4 then
        self._buttonOkGo:SetActive(true);
        self._buttonAddGo:SetActive(false);
        self._inputCollider.enabled = true;
        self._input.isSelected = true;
    elseif id == 5 then
        self._buttonOkGo:SetActive(true);
        self._buttonEditGo:SetActive(false);
        self._inputCollider.enabled = true;
        self._input.isSelected = true;
    end
end

function TitleUserDefinePanel:OnDisable()
    self._panelGo:SetActive(false);
end

return TitleUserDefinePanel;
