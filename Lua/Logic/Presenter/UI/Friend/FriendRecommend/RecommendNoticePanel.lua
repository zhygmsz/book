local RecommendNoticePanel = class("RecommendNoticePanel");

function RecommendNoticePanel:ctor(uiFrame,context)
    self._context = context;
    self._labelHeadCount = uiFrame:FindComponent("UILabel","Offset/Bg/NoticePanel/LabelNotice");
    self._labelNotice = uiFrame:FindComponent("UILabel","Offset/Bg/NoticePanel/Pet/LabelNotice");
    self._panelGo = uiFrame:Find("Offset/Bg/NoticePanel").gameObject;
end

function RecommendNoticePanel:Show(key)

    self._panelGo:SetActive(true);
    self._labelNotice.text = WordData.GetWordStringByKey(key);
    local headCount = FriendRecommendMgr.GetHeadCount();
    self._labelHeadCount.text = WordData.GetWordStringByKey("friend_recommend_head_count_%s",headCount);--进入剩余推荐数量
end

function RecommendNoticePanel:UnShow()
    self._panelGo:SetActive(false);
end

function RecommendNoticePanel:OnDestroy(uiFrame)
    self._context = nil;
    self._labelHeadCount = nil;
    self._labelNotice = nil;
end

return RecommendNoticePanel;