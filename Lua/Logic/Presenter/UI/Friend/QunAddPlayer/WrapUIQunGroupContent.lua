local WrapUIQunGroupContent  = class("WrapUIQunGroupContent",UICommonCollapseWrapUI);

function WrapUIQunGroupContent:ctor(root,baseEventID,context)
    self.super.ctor(self,itemTran,baseEventID,context);
    self._context = context;
    
    local subItemTran = root:Find("GroupContent");
    self._gameObject = subItemTran.gameObject;
    self._nameLabel = subItemTran:Find("LabelName"):GetComponent("UILabel");--
    self._countLabel = subItemTran:Find("LabelCount"):GetComponent("UILabel");--
    self._arrowTrans = subItemTran:Find("Arrow");--
    subItemTran:GetComponent("UIEvent").id = baseEventID;
    self._allSelectedGo = subItemTran:Find("Option/Active").gameObject;
    self._selectedGo = subItemTran:Find("SpriteSelected").gameObject;
    subItemTran:Find("Option"):GetComponent("UIEvent").id = baseEventID + 1;

end

function WrapUIQunGroupContent:OnRefresh()
    local group = self._wrapData;
    local isSelected = self._context.IsGroupSelected(group);
    local z = isSelected and 0 or 90;
    self._arrowTrans.localRotation = UnityEngine.Quaternion.Euler(0,0,z);
    self._selectedGo:SetActive(isSelected);

    self._nameLabel.text = group:GetName();
    self._countLabel.text = string.format("%s/%s",self._context.GetAll_Online_MemberCount(group));
    
    self._allSelectedGo:SetActive(self._context.IsGroupAllSelected(group));
end

function WrapUIQunGroupContent:OnClick(bid)
    if bid == 0 then
        self._context.OnGroupSelected(self._wrapData,self);
    elseif bid == 1 then
        self._context.OnGroupAllSelected(self._wrapData,self);
    end
end

return WrapUIQunGroupContent;