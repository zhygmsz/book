
local UIGiftSendRecordWrapUIEx = class("UIGiftSendRecordWrapUIEx",BaseWrapContentUI);

function UIGiftSendRecordWrapUIEx:ctor(wrapItemTrans,context)
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

function UIGiftSendRecordWrapUIEx:OnRefresh()
    local sendInfo = self._data;
    local receiveID = sendInfo.receiveID;
    self._iconTextureLoader:LoadObject(FriendMgr.GetIconID(receiveID));
    self._labelDes.text = receiveID;--FriendMgr.GetNickname(fid);
    self._labelTime.text = sendInfo.time;
    local isSelected = self._context.IsItemRecordSelected(sendInfo);
    self._toggle:Set(isSelected);
end

return UIGiftSendRecordWrapUIEx;