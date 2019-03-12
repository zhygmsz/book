local WrapUIGroupContent  = class("WrapUIGroupContent",UICommonCollapseWrapUI);

function WrapUIGroupContent:ctor(root,baseEventID,context)
    self.super.ctor(self,itemTran,baseEventID,context);
    self._context = context;
    local subItemTran = root:Find("GroupContent");

    self._gameObject = subItemTran.gameObject;
    self._nameLabel = subItemTran:Find("Label"):GetComponent("UILabel");
    self._countLabel = subItemTran:Find("LabelCount"):GetComponent("UILabel");
    self._arrowTrans = subItemTran:Find("Arrow");
    subItemTran:GetComponent("UIEvent").id = baseEventID;
    local editTrans = subItemTran:Find("Edit");
    self._editGo = editTrans.gameObject;
    editTrans:GetComponent("UIEvent").id = baseEventID + 1;
end

function WrapUIGroupContent:OnRefresh()
    local group = self._wrapData;
    local isSelected = self._context:IsGroupSelected(group);
    local z = isSelected and 0 or 90;
    self._arrowTrans.localRotation = UnityEngine.Quaternion.Euler(0,0,z);
    self._nameLabel.text = group:GetName();
    self._countLabel.text = string.format("%s/%s",group:GetAll_Online_MemberCount());
    self._editGo:SetActive(group:IsEditable());
end

function WrapUIGroupContent:OnClick(bid)
    if bid == 0 then
        self._context:OnGroupSelected(self._wrapData);
    elseif bid == 1 then
        UI_Friend_EditGroup.ShowGroup(self._wrapData);
    end
end

return WrapUIGroupContent;