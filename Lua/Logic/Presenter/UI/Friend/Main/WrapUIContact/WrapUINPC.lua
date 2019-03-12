local WrapUINPC  = class("WrapUINPC",UICommonCollapseWrapUI);

function WrapUINPC:ctor(root,baseEventID,context)
    self._context = context;
    local subItemTran = root:Find("NPC");
    self._nickNameLabel = subItemTran:Find("LabelNick"):GetComponent("UILabel");
    self._classifyLabel= subItemTran:Find("LabelClassify"):GetComponent("UILabel");

    local iconTexture = subItemTran:Find("ButtonIcon/TextureIcon"):GetComponent("UITexture");
    self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    self._selectedToggle = subItemTran:GetComponent("UIToggle");
    self._SelectedGo = subItemTran:Find("SpriteSelected").gameObject;
    subItemTran:GetComponent("UIEvent").id = baseEventID;
    subItemTran:Find("ButtonShortcut"):GetComponent("UIEvent").id = baseEventID + 1;
    subItemTran:Find("ButtonIcon"):GetComponent("UIEvent").id = baseEventID;
    self._widget = subItemTran:GetComponent("UIWidget");
    self._gameObject = subItemTran.gameObject;
end


function WrapUINPC:OnRefresh()
    -- local npc = self._wrapData;
    -- local isSelected = self._context:IsSelected(fid,type);
    -- self._selectedToggle:Set(isSelected);
    -- self._SelectedGo:SetActive(isSelected);
    -- self._nickNameLabel.text = FriendMgr.GetNickname(fid);
    -- self._classifyLabel.text = "群组分类：??"
    -- self._chatUIEvent.id = data:GetEventID();
    -- self._shortcutUIEvent.id = data:GetShortCutEventID();
    -- self._iconUIEvent.id = data:GetEventID();
    -- local resID = FriendMgr.GetIconID(fid);
    -- self._iconTextureLoader:LoadObject(resID);
end

function WrapUINPC:OnClick()
end
return WrapUINPC;