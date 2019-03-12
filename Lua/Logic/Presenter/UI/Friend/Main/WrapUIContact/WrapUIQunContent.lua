local WrapUIQunContent  = class("WrapUIQunContent",UICommonCollapseWrapUI);

function WrapUIQunContent:ctor(root,baseEventID,context)
    local subItemTran = root:Find("QunContent");
    self._context = context;
    self._gameObject = subItemTran.gameObject;
    local iconTexture = subItemTran:Find("ButtonIcon/TextureIcon"):GetComponent("UITexture");
    self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    self._nickNameLabel = subItemTran:Find("LabelName"):GetComponent("UILabel");
    self._classLabel = subItemTran:Find("LabelClass"):GetComponent("UILabel");
    self._selectedToggle = subItemTran:GetComponent("UIToggle");
    self._SelectedGo = subItemTran:Find("SpriteSelected").gameObject;
    self._hostGo = subItemTran:Find("SpriteHost").gameObject;
    subItemTran:Find("MoreButton"):GetComponent("UIEvent").id = baseEventID + 1;
    subItemTran:Find("ButtonIcon"):GetComponent("UIEvent").id = baseEventID;
    subItemTran:GetComponent("UIEvent").id = baseEventID;
end

function WrapUIQunContent:OnRefresh()
    local qun = self._wrapData;
    local isSelected = self._context:IsMemberSelected(qun);
    self._selectedToggle:Set(isSelected);
    self._SelectedGo:SetActive(isSelected);
    local online,all = qun:GetMemberCountInfo();
    self._nickNameLabel.text = string.format("%s(%s/%s)",qun:GetName(),online,all);
    self._classLabel.text = qun:GetType();
    self._iconTextureLoader:LoadObject(qun:GetIconID());
    self._hostGo:SetActive(qun:IsMyQun());
end

function WrapUIQunContent:OnClick(id)
    if id == 0 then
        self._context:OnMemberSelected(self._wrapData);
        UI_Friend_Main.ShowChat(self._wrapData);
    elseif id == 1 then
        UI_Shortcut_Qun.ShowQun(self._wrapData);
    end
end

return WrapUIQunContent;