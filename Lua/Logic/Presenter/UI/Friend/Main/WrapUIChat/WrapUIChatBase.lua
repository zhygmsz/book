local WrapUIChatBase  = class("WrapUIChatBase",UICommonCollapseWrapUI);
local ITEM_WIDGET_DEFAULT_HEIGHT = 84;
local CONTENT_BG_DEFAULT_HEIGHT = 30;
local CONTENT_BG_DEFAULT_WIDTH = 31;
local MAX_HAS_HEAD_LINE_WIDTH =364;
local MAX_LINE_SPACE = 0;
local VOICE_BG_DEFAULT_HEIGHT = 56;

function WrapUIChatBase:ctor(root,baseEventID,ui,uiName)
    self._ui = ui;
    local subItemTran = root:Find(uiName);
    self._subItemTran = subItemTran;
    self._gameObject = subItemTran.gameObject;
    self._iconTexture = subItemTran:Find("Player/HeadBg/texture"):GetComponent("UITexture");

    self._iconSprite = subItemTran:Find("Player/HeadBg/IconSprite"):GetComponent("UISprite");
    self._levelLabel = subItemTran:Find("Player/Level"):GetComponent("UILabel");--31
    local factionTexture = subItemTran:Find("Player/Faction"):GetComponent("UITexture");
    self._factionTextureLoader = LoaderMgr.CreateTextureLoader(factionTexture);
    subItemTran:Find("Player/HeadBg"):GetComponent("UIEvent").id = baseEventID;

    local textTrans = subItemTran:Find("Text");
    self._textGo = textTrans.gameObject;
    self._contentRootTrans = textTrans:Find("Content/Root");
    self._contentBgWidget = textTrans:Find("ContentBg"):GetComponent("UIWidget");
    textTrans:Find("ContentBg"):GetComponent("UIEvent").id = baseEventID+1;

    local voiceTrans = subItemTran:Find("Voice");
    self._voiceGo = voiceTrans.gameObject;
    self._voiceBgWidget = voiceTrans:Find("ContentBg"):GetComponent("UIWidget");
    self._voiceTimeLabel = voiceTrans:Find("icon/sec"):GetComponent("UILabel");
    self._voiceContentLabel = voiceTrans:Find("label"):GetComponent("UILabel");
    self._voiceRedTipGo = voiceTrans:Find("icon/ani").gameObject;
    voiceTrans:Find("icon"):GetComponent("UIEvent").id = baseEventID + 2;

    self._widget = subItemTran:GetComponent("UIWidget");
end

function WrapUIChatBase:IsLeft()
    return self._isLeft;
end

function WrapUIChatBase:OnRefresh()
    if not self._isActive then GameLog.Log("%s is not active", self.__cname);return; end
    local info = self._wrapData;
    local sender = info:GetSender();

    self._levelLabel.text = sender:GetLevel();

    sender:SetHeadIcon(self._iconTexture,self._iconSprite);

    -- local resID = ResConfigData.GetResConfigID(sender:GetFactionID());
    -- self._factionTextureLoader:LoadObject(resID);

    if self._labelName then
        self._labelName.text = sender:GetRemark();
    end
    local itemData = info:GetSendContent();--Chat_pb.ChatMsgCommon类型
    self._msgCommon = itemData;
    if itemData.contentStyle == Chat_pb.ChatContentStyle_Voice then
        self._voiceGo:SetActive(true);
        self._textGo:SetActive(false);
        self._voiceRedTipGo:SetActive(not info:IsPlayed());
        self._voiceContentLabel.text = info:GetTextContent();
        self._voiceTimeLabel.text = WordData.GetWordStringByKey("speech_lenth_%s",info:GetLength());
        self._voiceContentLabel:Update();
        local height = self._voiceContentLabel.height + VOICE_BG_DEFAULT_HEIGHT;
        self._voiceBgWidget.height = height;
        self._widget.height = height + 30;
        return;
    end

    self._voiceGo:SetActive(false);
    self._textGo:SetActive(true);

    local uiFrame = self._ui;
    local item = self;
    local content = itemData.content;
    local contentRoot = self._contentRootTrans;
    local contentWidth = MAX_HAS_HEAD_LINE_WIDTH;
    local contentSpace = MAX_LINE_SPACE;
    local contentAlignLeft = self:IsLeft();
    local contentLinks = itemData.links;
    local startColor = nil;
    local startString = nil;
    local endColor = nil;
    local endString = itemData.contentPostfix;
    TextHelper.ProcessItemCommon(uiFrame,item,content,contentRoot,contentWidth,contentSpace,contentAlignLeft,contentLinks,startColor,startString,endColor,endString)

    self._contentBgWidget.height = CONTENT_BG_DEFAULT_HEIGHT + item.curHeight;
    self._contentBgWidget.width = CONTENT_BG_DEFAULT_WIDTH + item.curWidth;
    local itemHeight = self._contentBgWidget.height + 30;
    self._widget.height = ITEM_WIDGET_DEFAULT_HEIGHT > itemHeight and ITEM_WIDGET_DEFAULT_HEIGHT or itemHeight;
end

function WrapUIChatBase:OnClick(bid)
    GameLog.Log(self.__cname .."is OnClick "..bid);
    if bid == 0 then
        local info = self._wrapData;
        local sender = info:GetSender();
        UI_Shortcut_Player.ShowPlayer(sender);
    elseif bid == 1 then
        local linkIdx = self.imageLabelContent:ProcessClick();

        if linkIdx then
            local linkData = self._msgCommon.links[linkIdx];
            if linkData then
                MsgLinkHelper.OnClick(linkData)
            end
        end
    elseif bid == 2 then
        self._wrapData:PlayVoice();
    end
end

return WrapUIChatBase;