module("UI_Friend_FriendRecommend",package.seeall);
local basicPath = "Logic/Presenter/UI/Friend/FriendRecommend/";
local RecommendBasicPanel = require(basicPath.."RecommendBasicPanel");
local RecommendNoticePanel = require(basicPath.."RecommendNoticePanel");
local RecommendRecommendPanel = require(basicPath.."RecommendRecommendPanel");
local RecommendSearchResultPanel = require(basicPath.."RecommendSearchResultPanel");

local panelTable;
local mBasicPanel;
local mRecommendPanel;
local mSearchResultPanel;
local mNoticePanel;

local mEvents;

local mCommandCenter = {};

function mCommandCenter.ShowRecommend()
    mSearchResultPanel:UnShow();
    if not FriendRecommendMgr.HasCustomerSet() then
        mNoticePanel:Show("friend_recommend_ask_settings");--好友推荐面板，请设置提醒
        mRecommendPanel:UnShow();
    else
        local recCount =  FriendRecommendMgr.GetRecommendCount();
        if recCount <= 0 then
            mCommandCenter.ShowNonPlayerNotice();
            return;
        end
        mNoticePanel:UnShow();
        mRecommendPanel:Show();
        
    end
end

function mCommandCenter.ShowNonPlayerNotice()
    mNoticePanel:Show("friend_recommend_non_player");--好友推荐面板，没有好友的提示
    mRecommendPanel:UnShow();
end

function mCommandCenter.ShowSearchResult()
    mSearchResultPanel:Show();
    mRecommendPanel:UnShow();
    mNoticePanel:UnShow();
end


function OnCreate(uiFrame)
    FriendRecommendMgr.RequestGetRecommendPlayer();
    panelTable = {};
    mBasicPanel = RecommendBasicPanel.new(uiFrame,mCommandCenter);
    mNoticePanel = RecommendNoticePanel.new(uiFrame,mCommandCenter);
    mRecommendPanel = RecommendRecommendPanel.new(uiFrame,mCommandCenter);
    mSearchResultPanel = RecommendSearchResultPanel.new(uiFrame,mCommandCenter);
    table.insert(panelTable,mBasicPanel);
    table.insert(panelTable,mNoticePanel);
    table.insert(panelTable,mRecommendPanel);
    table.insert(panelTable,mSearchResultPanel);
end

local mEventList;
function OnEnable(uiFrame)
    for _,panel in ipairs(panelTable) do
        if panel.OnEnable  then
            panel:OnEnable(uiFrame);
        end
    end
    mCommandCenter.ShowRecommend();
    GameEvent.Reg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_PLAYER_CHANGE,mCommandCenter.ShowRecommend);
    GameEvent.Reg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_HEAD_COUNT,mRecommendPanel.UpdateHeadCount,mRecommendPanel);
    GameEvent.Reg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SEARCH_RESULT,mSearchResultPanel.NewResult,mSearchResultPanel);
end

function OnDisable(uiFrame)
    for _,panel in ipairs(panelTable) do
        if panel.OnDisable  then
            panel:OnDisable(uiFrame);
        end
    end
    GameEvent.UnReg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_PLAYER_CHANGE,mCommandCenter.ShowRecommend);
    GameEvent.UnReg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_HEAD_COUNT,mRecommendPanel.UpdateHeadCount,mRecommendPanel);
    GameEvent.UnReg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SEARCH_RESULT,mSearchResultPanel.NewResult,mSearchResultPanel);
end

function OnDestroy(uiFrame)
    for _,panel in ipairs(panelTable) do
        panel:OnDestroy(uiFrame);
    end
    panelTable = nil;
end

function OnClick(go, id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_FriendRecommend);
    elseif id == 1 then
        --打开推荐好友
    elseif id == 2 then
        UIMgr.ShowUI(AllUI.UI_Friend_Ask);
        UIMgr.UnShowUI(AllUI.UI_Friend_FriendRecommend);
    elseif id == 3 then
        GameLog.Log("QR Add Friend");
    elseif id == 4 then
        GameLog.Log("Face2Face Add Friend");
    elseif id == 10 then --强制搜索
        mBasicPanel:OnClick(id);
    elseif id == 11 then -- 打开推荐设置
        UIMgr.ShowUI(AllUI.UI_Friend_RecommendSetting);
    elseif id >= 12 and id <= 16 then
        mRecommendPanel:OnClick(id);
    else
        mSearchResultPanel:OnClick(id);
    end
end


