local WrapUIPlayer  = class("WrapUIPlayer",UICommonCollapseWrapUI);
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
function WrapUIPlayer:ctor(root,baseEventID,context)
    local subItemTran = root:Find("Player");
    self._levelLabel = subItemTran:Find("LabelLevel"):GetComponent("UILabel");
    local careerTexture = subItemTran:Find("SpriteCareer"):GetComponent("UITexture");--
    self._careerTextureLoader = LoaderMgr.CreateTextureLoader(careerTexture);
    self._iconTexture = subItemTran:Find("ButtonIcon/TextureIcon"):GetComponent("UITexture");
    self._bgGreyGo = subItemTran:Find("Gray").gameObject;
    self._iconBg = subItemTran:Find("ButtonIcon"):GetComponent("UISprite");

    self._nameTable = subItemTran:Find("TableName"):GetComponent("UITable");
    self._nickNameLabel = subItemTran:Find("TableName/LabelNick"):GetComponent("UILabel");
    self._remarkLabel= subItemTran:Find("TableName/LabelRemark"):GetComponent("UILabel");

    local table = subItemTran:Find("TableLocation");
    self._locationTable = table:GetComponent("UITable");
    self._tableGo = table.gameObject;
    self._locationIconGo = subItemTran:Find("TableLocation/SpriteLocation").gameObject;
    self._locationLabel= subItemTran:Find("TableLocation/LabelLocation"):GetComponent("UILabel");--
    self._signatureLabel = subItemTran:Find("TableLocation/LabelSignature"):GetComponent("UILabel");

    self._relationTable = subItemTran:Find("TableRelation"):GetComponent("UITable");
    self._shiGo = subItemTran:Find("TableRelation/SpriteShi").gameObject;
    self._tuGo = subItemTran:Find("TableRelation/SpriteTu").gameObject;
    self._fuGo = subItemTran:Find("TableRelation/SpriteFu").gameObject;
    self._qiGo = subItemTran:Find("TableRelation/SpriteQi").gameObject;
    self._yiGo = subItemTran:Find("TableRelation/SpriteYi").gameObject;
    self._loveGo = subItemTran:Find("TableRelation/SpriteLove").gameObject;


    self._selectedToggle = subItemTran:GetComponent("UIToggle");
    self._selectedGo = subItemTran:Find("SpriteSelected").gameObject;
    subItemTran:GetComponent("UIEvent").id = baseEventID;
    subItemTran:Find("ButtonShortcut"):GetComponent("UIEvent").id = baseEventID +1;
    subItemTran:Find("ButtonIcon"):GetComponent("UIEvent").id = baseEventID;
    self._gameObject = subItemTran.gameObject;
    self._context = context;
end

function WrapUIPlayer:OnRefresh()

    local member = self._wrapData;

    self._nickNameLabel.text = member:GetNickName();
    local remark = member:GetFriendAttr():GetRemark();
    if remark and remark ~= "" then
        remark = string.format("(%s)",remark);
    end
    self._remarkLabel.text = remark or "";
    self._nameTable:Reposition();

    self._shiGo:SetActive(member:IsMaster());
    self._tuGo:SetActive(member:IsApprentice());
    self._fuGo:SetActive(member:IsHusbandWife());
    self._qiGo:SetActive(member:IsHusbandWife());
    self._yiGo:SetActive(member:IsBrothers());
    self._loveGo:SetActive(member:IsUnrequitedLover());
    self._relationTable:Reposition();

    local isSelected = self._context:IsMemberSelected(member);
    self._selectedToggle:Set(isSelected);
    self._selectedGo:SetActive(isSelected);
   
    self._levelLabel.text = member:GetLevel();
    local careerResID = ResConfigData.GetResConfigID(member:GetNormalAttr():GetMenpaiID());
    self._careerTextureLoader:LoadObject(careerResID);

    member:SetHeadIcon(self._iconTexture);
    local online = member:IsOnline();
    UIMgr.MakeUIGrey(self._iconTexture,not online)
    self._bgGreyGo:SetActive(not (isSelected or online));
    local spriteName = online and "frame_common_bai" or "frame_common_hui";
    self._iconBg.spriteName = spriteName

    if online then
        self._tableGo:SetActive(true);
        local location = member:GetNormalAttr():GetCityName();
        self._locationIconGo:SetActive(location and true or false);
        self._locationLabel.text = location or "";
        local signature = member:GetNormalAttr():GetSelfintro();
        self._signatureLabel.text = signature or "";
        self._locationTable:Reposition();
    else
        self._tableGo:SetActive(false);
    end
end

function WrapUIPlayer:OnClick(bid)
    if bid == 0 then
        self._context:OnMemberSelected(self._wrapData);
        UI_Friend_Main.ShowChat(self._wrapData);
    elseif bid == 1 then
        UI_Shortcut_Player.ShowPlayer(self._wrapData);
    end
end

return WrapUIPlayer;