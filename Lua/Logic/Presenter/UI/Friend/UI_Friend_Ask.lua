module("UI_Friend_Ask",package.seeall);
local FriendAskWrapContentUI = require("Logic/Presenter/UI/Friend/FriendAsk/FriendAskWrapContentUI");
local mNonePanelGo;
local mAskPanelGo;

local mWrapTable;
local mWrapData;

local mLabelNotice;

local function UpdateNotice()
    mLabelNotice.text = WordData.GetWordStringByKey("friend_ask_not_process_count", #mWrapData);--好友申请
end

function OnCreate(ui)
    local path = "Offset/Bg/FriendAskPanel";
    mWrapTable = BaseWrapContentEx.new(ui,path.."/Scroll View",6,FriendAskWrapContentUI);
    mWrapTable:SetUIEvent(10000,5,{OnRefuseClick,OnAgreeClick});

    mAskPanelGo = ui:Find(path).gameObject;
    mNonePanelGo = ui:Find("Offset/Bg/NoticePanel").gameObject;
    mLabelNotice = ui:Find(path.."/BasicInfo/LabelNotice"):GetComponent("UILabel");
    mEvents = {};
end

function OnAgreeClick(item)
    FriendAskMgr.RequestReplyAskAddFriend(nil, item,true);
end

function OnRefuseClick(item)
    FriendAskMgr.RequestReplyAskAddFriend(nil, item,false);
end

function OnInitList()
    mWrapData = FriendAskMgr.GetAskList();
    if #mWrapData ==0 then
        mNonePanelGo:SetActive(true);
    else
        mNonePanelGo:SetActive(false);
    end
    mWrapTable:ResetWithData(mWrapData);

    UpdateNotice();
end

function OnApplyProcessed(item)
    for i=1,#mWrapData do
        if mWrapData[i] == item then
            table.remove(mWrapData,i);
            break;
        end
    end

    if #mWrapData == 0 then
        mNonePanelGo:SetActive(true);
    else
        mNonePanelGo:SetActive(false);
    end

    mWrapTable:ResetWithPosition(mWrapData);
    UpdateNotice();
end

function OnBatchProcessed()
    mNonePanelGo:SetActive(true);
    mWrapData = table.emptyTable;
    mWrapTable:ResetWithPosition(mWrapData);
    UpdateNotice();
end

function OnEnable(ui)
    OnInitList();
    GameEvent.Reg(EVT.FRIENDASK,EVT.FRIENDASK_INIT_INFO,OnInitList);
    GameEvent.Reg(EVT.FRIENDASK,EVT.FRIENDASK_ITEM_PROCESSED,OnApplyProcessed);
    GameEvent.Reg(EVT.FRIENDASK,EVT.FRIENDASK_BATCH_PROCESSED,OnBatchProcessed);
end

function OnDisable(ui)
    mNonePanelGo:SetActive(true);
    
    GameEvent.UnReg(EVT.FRIENDASK,EVT.FRIENDASK_INIT_INFO,OnInitList);
    GameEvent.UnReg(EVT.FRIENDASK,EVT.FRIENDASK_ITEM_PROCESSED,OnApplyProcessed);
    GameEvent.UnReg(EVT.FRIENDASK,EVT.FRIENDASK_BATCH_PROCESSED,OnBatchProcessed);
end

function OnClick(go,id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_Ask);
    elseif id == 1 then
        UIMgr.ShowUI(AllUI.UI_Friend_FriendRecommend);
        UIMgr.UnShowUI(AllUI.UI_Friend_Ask);
    elseif id == 2 then
        --打开申请列表
    elseif id == 12 then -- 接受全部好友申请
        FriendAskMgr.RequestBatchReplyAskAddFriend(true);
    elseif id == 11 then -- 拒绝全部好友申请
        FriendAskMgr.RequestBatchReplyAskAddFriend(false);
    elseif id >= 10000 then
        mWrapTable:OnClick(id);
    end
end

function OnDestroy(ui)
end