local UIAIPetClothItemWrapUI = class("UIAIPetClothItemWrapUI",BaseWrapContentUI);

function UIAIPetClothItemWrapUI:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._labelName = wrapItemTrans:Find("LabelTitle"):GetComponent("UILabel");
    self._lifeGo = wrapItemTrans:Find("LabelDes").gameObject;
    self._labelDeadline = wrapItemTrans:Find("LabelDes/LabelDeadLine"):GetComponent("UILabel");
    self._icon = wrapItemTrans:Find("ItemBg/Icon"):GetComponent("UISprite");
    self._labelButton = wrapItemTrans:Find("ButtonHave/Label"):GetComponent("UILabel");
    local btn = wrapItemTrans:Find("ButtonHave");
    self._uiEvent = btn:GetComponent("UIEvent");
    --self:InsertUIEvent(uiEvent);

    self._buttonGo = btn.gameObject;

    self._labelUnhaveButton = wrapItemTrans:Find("ButtonUnavailable/Label"):GetComponent("UILabel");
    local unHavebtn = wrapItemTrans:Find("ButtonUnavailable");
    self._uiUnhaveEvent = unHavebtn:GetComponent("UIEvent");
    self:InsertUIEvent(self._uiUnhaveEvent);

    self._unhaveButtonGo = unHavebtn.gameObject;
    self._greyGo = wrapItemTrans:Find("SpriteGrey").gameObject;
end

function UIAIPetClothItemWrapUI:OnRefresh()
    local cloth = self._data;
    local available = cloth:IsClothAvailable();
    if not available then
        self._labelUnhaveButton.text = WordData.GetWordStringByKey("AIPet_Clothes_Unavailable");--未获得
        self._unhaveButtonGo:SetActive(true);
        self._greyGo:SetActive(true);

        self._lifeGo:SetActive(false);
        self._buttonGo:SetActive(false);
    else
        self._unhaveButtonGo:SetActive(false);
        self._greyGo:SetActive(false);
        
        self._lifeGo:SetActive(true);
        self._buttonGo:SetActive(true);

        local time = cloth:GetExpireTime();
        if time == 0 then
            time = WordData.GetWordStringByKey("title_permanent_time");--永久
        else
            time = TimeUtils.Time2Units(time,true);
            time = WordData.GetWordStringByKey("title_expire_time",time.day);--时间
        end
        self._labelDeadline.text = time;      
        if self._context.IsItemDressedIn(cloth) then
            self._uiEvent.id = self._uiUnhaveEvent.id + 2;
            self._labelButton.text = WordData.GetWordStringByKey("AIPet_Clothes_TakeOff");--脱下
        else
            self._uiEvent.id = self._uiUnhaveEvent.id + 1;
            self._labelButton.text = WordData.GetWordStringByKey("AIPet_Clothes_DressIn");--穿上
        end
    end
    
    self._icon.spriteName = cloth:GetIcon();
    self._labelName.text = cloth:GetName();
end


return UIAIPetClothItemWrapUI;