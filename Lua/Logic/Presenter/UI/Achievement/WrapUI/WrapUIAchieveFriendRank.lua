local WrapUIAchieveFriendRank = class("WrapUIAchieveFriendRank",BaseWrapContentUI);

function WrapUIAchieveFriendRank:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._rankLabel = wrapItemTrans:Find("RankNumLabel"):GetComponent("UILabel");
    self._levelLabel = wrapItemTrans:Find("InfoTable/LevelBg/Label"):GetComponent("UILabel");
    self._nameLabel = wrapItemTrans:Find("NameLabel"):GetComponent("UILabel");
    self._scoreLabel = wrapItemTrans:Find("LabelScore"):GetComponent("UILabel");

    self._selfGo = wrapItemTrans:Find("SelfFlag").gameObject;
    self._rankSpriteGo  = wrapItemTrans:Find("RankNumSprite").gameObject;
    self._rankLabelGo = wrapItemTrans:Find("RankNumLabel").gameObject;
    self._honorBgGo = wrapItemTrans:Find("SpriteHonorBg").gameObject;

    self._rankSprite = wrapItemTrans:Find("RankNumSprite"):GetComponent("UISprite");
    self._layerSprite = wrapItemTrans:Find("SpriteLayer"):GetComponent("UISprite");

    local honorBgTexture = wrapItemTrans:Find("SpriteHonorBg"):GetComponent("UITexture");
    self._honorBgTextureLoader = LoaderMgr.CreateTextureLoader(honorBgTexture);
    local iconTexture = wrapItemTrans:Find("InfoTable/IconButton/TextureIcon"):GetComponent("UITexture");
    self._iconTexture = iconTexture;
    self._iconSprite = wrapItemTrans:Find("InfoTable/IconButton/SpriteIcon"):GetComponent("UISprite");
    self._iconCollider = wrapItemTrans:Find("InfoTable/IconButton"):GetComponent("BoxCollider");

    local compareTran = wrapItemTrans:Find("ButtonCompare");
    self._compareBtnGo = compareTran.gameObject;
    local shareTran = wrapItemTrans:Find("ButtonShare");
    self._shareBtnGo = shareTran.gameObject;

    self._iconUIEvent = wrapItemTrans:Find("InfoTable/IconButton"):GetComponent("UIEvent");
    self._compareUIEvent = compareTran:GetComponent("UIEvent");
    self._shareUIEvent = shareTran:GetComponent("UIEvent");

    local rank1_3SpriteName = "img_paihangbang_paizi0";
    local layerSpriteName = "ico_chengjiu_c_01";
 
    self:InsertUIEvent(self._iconUIEvent);
    self:InsertUIEvent(self._compareUIEvent);
    self:InsertUIEvent(self._shareUIEvent);
end

function WrapUIAchieveFriendRank:OnRefresh()
    local role = self._data;
    local rank = self._context:GetRank(role);
    if rank<=3 then
        self._rankSpriteGo:SetActive(true);
        self._rankLabelGo:SetActive(false);
        self._rankSprite.spriteName = "img_paihangbang_paizi0"..tostring(rank);
        self._honorBgGo:SetActive(true);
        local bgName = "frame_paihangbang_0"..tostring(rank);
        local resID = ResConfigData.GetResConfigID(bgName);
        self._honorBgTextureLoader:LoadObject(resID);
    else
        self._rankSpriteGo:SetActive(false);
        self._rankLabelGo:SetActive(true);
        self._rankLabel.text = rank;
        self._honorBgGo:SetActive(false);
    end
    local isSelf = role:IsSelf();
    self._selfGo:SetActive(role:IsSelf());
    self._iconCollider.enabled = not isSelf;
    self._compareBtnGo:SetActive(not isSelf);
    self._shareBtnGo:SetActive(isSelf);

    self._levelLabel.text = role:GetLevel();
    self._nameLabel.text = role:GetRemark();
    local score = 1;--role:GetAchieveStars();
    self._scoreLabel.text = score;
    
    local info = AchievementMgr.GetFinishLevelInfo(score);
    self._layerSprite.spriteName = info.iconName;
    role:SetHeadIcon(self._iconTexture,self._iconSprite);
end

return WrapUIAchieveFriendRank;