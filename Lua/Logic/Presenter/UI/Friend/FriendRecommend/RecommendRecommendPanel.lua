local RecommendRecommendPanel = class("RecommendRecommendPanel");
local UIScrollGridTable = require("Logic/Presenter/UI/Common/UIScrollGridTable");
local UIScrollIndexer = require("Logic/Presenter/UI/Common/UIScrollIndexer");
local UIBriefLabel = require("Logic/Presenter/UI/Common/UIBriefLabel");

function RecommendRecommendPanel:ctor(uiFrame,context)
    local path = "Offset/Bg/RecommendPanel";
    self._context = context;
    self._uiFrame = uiFrame;
    self._labelHeadCount = uiFrame:FindComponent("UILabel",path.."/PanelFrontground/LabelNotice");

    self._playerInfoTable = UIScrollGridTable.new(uiFrame,path.."/Scroll View");
    self._scrollHelper = uiFrame:FindComponent("UIScrollHelper",path.."/Scroll View");
    self._panelGo = uiFrame:Find(path).gameObject;
    self._index = 1;
end

function RecommendRecommendPanel:Show()
    self._panelGo:SetActive(true);
    self:UpdateHeadCount();
    self._index = 1;
    self:UpdatePlayerInfo();
end

function RecommendRecommendPanel:UnShow()
    self._panelGo:SetActive(false);
end

function RecommendRecommendPanel:UpdateHeadCount()
    local headCount = FriendRecommendMgr.GetHeadCount();
    self._labelHeadCount.text = string.format(WordData.GetWordStringByKey("friend_recommend_head_count_%s"),headCount);
end

local function OnPhotoWallCreate(phtots,itemTrans,index)
    local url = phtots[index];
    local texture = itemTrans:GetComponent("UITexture");
    PersonSpaceMgr.LoadHeadIcon(texture,url);
end

local function UpdateRecommendItem(self,itemName,player)
    local path = "Offset/Bg/RecommendPanel/Scroll View/Grid/"..itemName;
    local ui = self._uiFrame;
    local labelSpace = self._uiFrame:FindComponent("UILabel",path.."/Center/IconInfo/LabelSpace");


    local iconTable = UIScrollGridTable.new(ui,path.."/Center/IconInfo/Scroll View");
    local phtots = player:GePhotoURLs();

    --local iconIDList = FriendRecommendMgr.GetPlayerIcons(pid);

    iconTable:ResetWrapContent(#phtots,OnPhotoWallCreate,phtots);

    local scrollHelper = ui:FindComponent("UIScrollHelper",path.."/Center/IconInfo/Scroll View");
    local scrollIndexRoot = ui:Find(path.."/Center/IconInfo/ScrollIndex");
    local scrollIndexer = UIScrollIndexer.new(ui,scrollIndexRoot);
    scrollIndexer:Reset(#phtots);

    local function NoticeIndex(index) 
        scrollIndexer:SetIndex(index) ;
        self._index = index+1;
    end
    local OnNoticeIndex = UIScrollHelper.ActionInt(NoticeIndex);
    scrollHelper:SetIndexChange(OnNoticeIndex);
    scrollHelper.ItemCount = #phtots;
    local brefLabelSpace = UIBriefLabel.new(labelSpace,25);
    local spaceText = player:GetSelfintro();
    brefLabelSpace:SetLabel(spaceText);

    local professTexture = ui:FindComponent("UITexture",path.."/Right/Basic/Profession");
    local textureLoader = LoaderMgr.CreateTextureLoader(professTexture);
    textureLoader:LoadObject(player:GetMenpaiID());

    local labelNickname = ui:FindComponent("UILabel",path.."/Right/Basic/LabelNickName");
    labelNickname.text = player:GetRemark();

    local labelLevel = ui:FindComponent("UILabel",path.."/Right/Basic/LabelLevel");
    labelLevel.text = player:GetLevel();

    local labelLocation = ui:FindComponent("UILabel",path.."/Right/LabelLocation");
    labelLocation.text = player:GetCityName();

    local labelLocationNotice = ui:FindComponent("UILabel",path.."/Right/LabelLocation/LabelNotice");
    labelLocationNotice.text = player:GetLocationNotice();

    local labelConstellation = ui:FindComponent("UILabel",path.."/Right/LabelConstellation");
    labelConstellation.text = player:GetConstellationName();

    local labelConstellationNotice = ui:FindComponent("UILabel",path.."/Right/LabelConstellation/LabelNotice");
    labelConstellationNotice.text = player:GetZodiacNotice();

    local labelGangster = ui:FindComponent("UILabel",path.."/Right/LabelGangster");
    labelGangster.text = player:GetFactionID();

    local labelGangsterNotice = ui:FindComponent("UILabel",path.."/Right/LabelGangster/LabelNotice");
    labelGangsterNotice.text = player:GetFactionNotice();

    local labelSameFriend = ui:FindComponent("UILabel",path.."/Right/LabelSameFriend");
    labelSameFriend.text = #player:GetShareFriends();

    local labelLabelSign = ui:FindComponent("UILabel",path.."/Right/LabelSign");
    labelLabelSign.text = player:GetSelfintro();
end

function RecommendRecommendPanel:OnItemCreate(itemTrans,index)
    local item = self._dataLists[index];
    UpdateRecommendItem(self,itemTrans.name,item.player);
end

function RecommendRecommendPanel:UpdatePlayerInfo()
    self._dataLists = FriendRecommendMgr.GetRecommendList();
    if #self._dataLists == 0 then
        self._context.ShowNonPlayerNotice();
        return;
    end

    self._playerInfoTable:ResetWrapContent(#self._dataLists,self.OnItemCreate,self);
    self._scrollHelper.ItemCount = #self._dataLists;
    self._scrollHelper:SetShowChildIndex(self._index and self._index-1 or 0);
end

function RecommendRecommendPanel:OnEnable()
    self:UpdateHeadCount();
    self:UpdatePlayerInfo();
    GameEvent.Reg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_DELETE_ITEM,self.UpdatePlayerInfo,self);
end

function RecommendRecommendPanel:OnClick(id)
    if not self._panelGo.activeInHierarchy then
        return;
    end
    if id == 12 then
        local index = self._scrollHelper:GetShowChildIndex();
        index = index + 1;
        local item = self._dataLists[index];
        FriendRecommendMgr.RequestAskAddFriend(item);
    elseif id == 13 then
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_Main);
    elseif id == 14 then
        FriendRecommendMgr.RequestGetRecommendPlayer();
    elseif id == 15 then
        self._scrollHelper:MoveBack();
    elseif id == 16 then
        self._scrollHelper:MoveForward();
    end
end

function RecommendRecommendPanel:OnDisable()
    self._panelGo:SetActive(true);
    GameEvent.UnReg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_DELETE_ITEM,self.UpdatePlayerInfo,self);
end

function RecommendRecommendPanel:OnDestroy(uiFrame)
    self._context = nil;
    self._uiFrame = nil;
    self._labelHeadCount = nil;

    self._playerInfoTable = nil;

    self._panelGo = nil;
end

return RecommendRecommendPanel;