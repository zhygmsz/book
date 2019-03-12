local WrapUIFriendQunMemberInfo  = class("WrapUIFriendQunMemberInfo",BaseWrapContentUI);

function WrapUIFriendQunMemberInfo:ctor(subItemTran,context)
    BaseWrapContentUI.ctor(self,subItemTran,context);
    self._context = context;

    self._iconTexture = subItemTran:Find("SpriteIcon/Texture"):GetComponent("UITexture");
    self._iconSprite = subItemTran:Find("SpriteIcon/Sprite"):GetComponent("UISprite");

    self._nicknameLabel = subItemTran:Find("LabelNick"):GetComponent("UILabel");
    self._levelLabel = subItemTran:Find("LabelLevel"):GetComponent("UILabel");
    self._dutyLabel = subItemTran:Find("LabelCareer"):GetComponent("UILabel");

    self._addAdmGo = subItemTran:Find("ButtonAddAdm").gameObject;
    self._removeAdmGo = subItemTran:Find("ButtonRemoveAdm").gameObject;
    self._deleteGo = subItemTran:Find("ButtomDelete").gameObject;

    self._addAdmUIEvent = subItemTran:Find("ButtonAddAdm"):GetComponent("UIEvent");
    self._removeAdmUIEvent = subItemTran:Find("ButtonRemoveAdm"):GetComponent("UIEvent");
    self._deleteUIEvent = subItemTran:Find("ButtomDelete"):GetComponent("UIEvent");
    self:InsertUIEvent(self._addAdmUIEvent);
    self:InsertUIEvent(self._removeAdmUIEvent);
    self:InsertUIEvent(self._deleteUIEvent);
end

function WrapUIFriendQunMemberInfo:OnRefresh()
    local member = self._data;

    self._nicknameLabel.text = member:GetRemark();
    self._levelLabel.text = member:GetLevel();
    member:SetHeadIcon(self._iconTexture,self._iconSprite);
    local qun = self._context:GetQun();
    local isMemAdmin = qun:IsAdmin(member);--这个成员是管理员
    local isMemOwner = qun:IsOwner(member);--这个成员是群主
    local duty = "";
    if isMemOwner then
        duty = WordData.GetWordStringByKey("friend_qun_master");--群主
    elseif isMemAdmin then
        duty = WordData.GetWordStringByKey("friend_qun_admin");--管理员
    end
    self._dutyLabel.text = duty;

    if member:IsSelf() then
        self._addAdmGo:SetActive(false);
        self._removeAdmGo:SetActive(false);
        self._deleteGo:SetActive(false);
    else
        
        local isMyQun = qun:IsMyQun();--我是群主
        local isAdminQun = qun:IsAdminByID(UserData.PlayerID);--我是管理员
        if isMyQun then
            self._addAdmGo:SetActive(not isMemAdmin);
            self._removeAdmGo:SetActive(isMemAdmin );
            self._deleteGo:SetActive(true);
        elseif isAdminQun then
            self._addAdmGo:SetActive(false);
            self._removeAdmGo:SetActive(false);
            self._deleteGo:SetActive(not(isMemAdmin or isMemOwner));
        else
            self._addAdmGo:SetActive(false);
            self._removeAdmGo:SetActive(false);
            self._deleteGo:SetActive(false);
        end
    end    

end

return WrapUIFriendQunMemberInfo;