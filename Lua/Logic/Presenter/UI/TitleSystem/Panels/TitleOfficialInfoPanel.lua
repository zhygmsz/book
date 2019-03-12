local TitleOfficialInfoPanel = class("TitleOfficialInfoPanel");

function TitleOfficialInfoPanel:ctor(ui)
    local path = "Offset/Center/OfficialInfoPanel";
    self._achieveDesTable = UIScrollGridTable.new(ui,path.."/TitleDes/LabelAchieve/DragAreaContent/ScrollView");
    self._titleDesLabel = ui:FindComponent("UILabel",path.."/TitleDes/LabelHead/Label");
    self._panelGo = ui:Find(path).gameObject;
end

function  TitleOfficialInfoPanel:OnDisable()
    self._panelGo:SetActive(false);
end

function  TitleOfficialInfoPanel:OnEnable(item)
    self._panelGo:SetActive(true);
    local items = item:GetGroup():GetAllItems();
    self._datas = items;
    self._achieveDesTable:ResetWrapContent(#items,self.OnItemCreate,self)
    self._titleDesLabel.text = item:GetDescribe();
end

function TitleOfficialInfoPanel:OnItemCreate(subItemTran,index)
    local item = self._datas[index];
    self._label = subItemTran:GetComponent("UILabel");
    self._label.text = item:GetAchieveDescribe();
end


return TitleOfficialInfoPanel;