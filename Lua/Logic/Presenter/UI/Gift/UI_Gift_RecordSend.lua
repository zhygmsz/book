module("UI_Gift_RecordSend",package.seeall);

local UIGiftSendRecordWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftSendRecordWrapUIEx");
local UIGiftItemWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftItemWrapUIEx");

local mSendGiftList;
local mSelectedRecord;
local mEvent;

local mItemRootGo;
local mTextRootGo;

function OnSystemClose()
    UIMgr.UnShowUI(AllUI.UI_Gift_RecordSend);
    mSendGiftList = nil;
    mSelectedRecord = nil;
end

local function RefreshGiftPanel(giftSendInfo)
    local hasInfo = giftSendInfo and true or false;
    mItemRootGo:SetActive(hasInfo);
    mTextRootGo:SetActive(hasInfo);
    if not hasInfo then return; end

    if giftSendInfo.isAnonymity then
        mLabelSendName.text = WordData.GetWordStringByKey("gift_anomymity_sender_name");
    else
        mLabelSendName.text = UserData.GetName();
    end
    receiveName = FriendMgr.GetNickname(giftSendInfo.receiveID);

    mLabelSendName.text = receiveName;
    
    mLabelContentComponent:UpdateLabelWithStr(giftSendInfo.text);

    local gifts = {};
    for gift,count in pairs(giftSendInfo.giftCountTable) do
        table.insert(gifts, gift);
    end
    mGiftWrapContent:ResetWithData(gifts);
end

local function RefreshRecordList()
    mSendGiftList = GiftMgr.GetGiftSendRecord();

    mSelectedRecord = mSendGiftList[1];
    RefreshGiftPanel(mSelectedRecord);

    mRecordWrapContent:ResetWithData(mSendGiftList);
end

function OnItemRecordClick(giftSendInfo,wrapUI)
    GameLog.Log("OnItemRecordClick %s",giftSendInfo.receiveID);
    mSelectedRecord = giftSendInfo;
    RefreshGiftPanel(giftSendInfo);
end
function OnGiftItemClick(gift,wrapUI)
    GameLog.Log("OnGiftItemClick %s",gift:GetName());
end

function OnCreate(ui)
    mLabelReceiveName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameReceive");
    mLabelSendName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameSend");
    local contentRoot = ui:Find("Offset/PaintRoot/TextRoot/ContentRoot");
    mLabelContentComponent = UILabel_WithEmoji.new{uiFrame = ui,maxHeadLineWidth = 400,rootTrans = contentRoot};
    
    mGiftWrapContent = BaseWrapContentEx.new(ui,"Offset/PaintRoot/ItemRoot/Scroll View",8,UIGiftItemWrapUIEx,nil,UI_Gift_RecordSend);
    mGiftWrapContent:SetUIEvent(1000,1,{OnGiftItemClick});

    mRecordWrapContent = BaseWrapContentEx.new(ui,"Offset/RecordRoot/FriendContent/Scroll View",12,UIGiftSendRecordWrapUIEx,nil,UI_Gift_RecordSend);
    mRecordWrapContent:SetUIEvent(900,1,{OnItemRecordClick});

    mItemRootGo = ui:Find("Offset/PaintRoot/ItemRoot").gameObject;
    mTextRootGo = ui:Find("Offset/PaintRoot/TextRoot").gameObject;
end

function OnEnable(ui)
    RefreshRecordList();
    mEvent = {};
    mEvent[1] = GameEvent.Reg(EVT.GIFT,EVT.GIFT_SEND_RECORD_CHANGE,RefreshRecordList);
    mEvent[2] = GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnDisable()
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_SEND_RECORD_CHANGE,RefreshRecordList);
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
    mEvent = nil;
end

function OnClick(go,id)

    if id >= 1000 then
        mGiftWrapContent:OnClick(id);
    elseif id >= 900 then
        mRecordWrapContent:OnClick(id);
    else
        if not mSelectedRecord then return; end
    end
    if id == 1 then
        GiftMgr.DeleteSendRecord(mSelectedRecord);
    elseif id == 2 then
        UIMgr.UnShowUI(AllUI.UI_Gift_RecordSend);
        UI_GiftSend_Main.ShowSendFriend(mSelectedRecord.receiveID);
    end
end
