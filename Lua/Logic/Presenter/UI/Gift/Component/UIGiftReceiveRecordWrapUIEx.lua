
local UIGiftReceiveRecordWrapUIEx = class("UIGiftReceiveRecordWrapUIEx",BaseWrapContentUI);

function UIGiftReceiveRecordWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._context = context;
    self._labelDes = wrapItemTrans:Find("LabelDes"):GetComponent("UILabel");
    self._labelTime = wrapItemTrans:Find("LabelTime"):GetComponent("UILabel");

    local iconTexture = wrapItemTrans:Find("IconBg/TextureIcon"):GetComponent("UITexture");
    self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);

    self._toggle = wrapItemTrans:GetComponent("UIToggle");

    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._uiEvent);
end

function UIGiftReceiveRecordWrapUIEx:OnRefresh()
    local receiveInfo = self._data;
    local sendID = receiveInfo.sendID;
    self._iconTextureLoader:LoadObject(FriendMgr.GetIconID(sendID));
    self._labelDes.text = sendID;--FriendMgr.GetNickname(fid);
    self._labelTime.text = receiveInfo.time;
    local isSelected = self._context.IsItemRecordSelected(receiveInfo);
    self._toggle:Set(isSelected);
end

return UIGiftReceiveRecordWrapUIEx;