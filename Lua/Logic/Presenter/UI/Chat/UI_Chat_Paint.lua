module("UI_Chat_Paint",package.seeall);

--画图
local mChatCommonPaint = nil;
local mOnDrawFinish;

--播放
local mChatCommonRepaint = nil;
local mLinkData = nil;
local mOpenType = 0; --0画图 1显示画图

function OnCreate(self)
    self:Find("Offset/MailPaint").gameObject:SetActive(false);
    self:Find("Offset/PaintRoot").gameObject:SetActive(false);
end

function OnEnable(self)
    if mOpenType == 0 then
        if not mChatCommonPaint then mChatCommonPaint = ChatCommonPaint.new(self); end
        mChatCommonPaint:OnEnable(mOnDrawFinish);
    else
        if not mChatCommonRepaint then mChatCommonRepaint = ChatCommonRepaint.new(self); end
        mChatCommonRepaint:OnEnable(mLinkData);
    end
end

function OnDisable(self)
    if mOpenType == 0 then
        mChatCommonPaint:OnDisable();
    else
        mChatCommonRepaint:OnDisable();
    end
end

function OnClick(go,id)
    if id == 0 or id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Chat_Paint);
    elseif id >= 1 and id <= 5 then
        mChatCommonPaint:OnClick(id);
    end
end

function OpenForRepaint(linkData)
    mOpenType = 1;
    mLinkData = linkData;
    UIMgr.ShowUI(AllUI.UI_Chat_Paint);
end

function OpenForDraw(onDrawFinish)
    mOpenType = 0;
    mOnDrawFinish = onDrawFinish;
    UIMgr.ShowUI(AllUI.UI_Chat_Paint);
end