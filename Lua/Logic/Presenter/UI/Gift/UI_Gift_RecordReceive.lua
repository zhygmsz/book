module("UI_Gift_RecordReceive",package.seeall);

local UIGiftReceiveRecordWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftReceiveRecordWrapUIEx");
local UIGiftItemWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftItemWrapUIEx");
local mReceiveGiftList;
local mSelectedRecord;
local mEvent;

local mItemRootGo;
local mTextRootGo;

function OnSystemClose()
    UIMgr.UnShowUI(AllUI.UI_Gift_RecordReceive);
    mReceiveGiftList = nil;
    mSelectedRecord = nil;
end

local function RefreshGiftPanel(giftReceiveInfo)
    local hasInfo = giftReceiveInfo and true or false;
    mItemRootGo:SetActive(hasInfo);
    mTextRootGo:SetActive(hasInfo);

    if not hasInfo then return; end

    if giftReceiveInfo.isAnonymity then
        mLabelSendName.text = WordData.GetWordStringByKey("gift_anomymity_sender_name");
    else
        mLabelSendName.text = FriendMgr.GetNickname(giftReceiveInfo.sendID);
    end

    mLabelReceiveName.text = UserData.GetName();
    
    mLabelContentComponent:UpdateLabelWithStr(giftReceiveInfo.text);

    local gifts = {};
    for gift,count in pairs(giftReceiveInfo.giftCountTable) do
        table.insert(gifts, gift);
    end
    mGiftWrapContent:ResetWithData(gifts);
end

local function RefreshRecordList()
    mReceiveGiftList = GiftMgr.GetGiftReceiveRecord();

    mSelectedRecord = mReceiveGiftList[1];
    RefreshGiftPanel(mSelectedRecord);

    mRecordWrapContent:ResetWithData(mReceiveGiftList);
end

function OnItemRecordClick(giftReceiveInfo,wrapUI)
    GameLog.Log("OnItemRecordClick %s",giftReceiveInfo.receiveID);
    mSelectedRecord = giftReceiveInfo;
    RefreshGiftPanel(giftReceiveInfo);
end
function IsItemRecordSelected(giftReceiveInfo)
    return mSelectedRecord == giftReceiveInfo;
end
function OnGiftItemClick(gift,wrapUI)
    GameLog.Log("OnGiftItemClick %s",gift:GetName());
end

function OnCreate(ui)
    mLabelReceiveName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameReceive");
    mLabelSendName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameSend");
    local contentRoot = ui:Find("Offset/PaintRoot/TextRoot/ContentRoot");
    mLabelContentComponent = UILabel_WithEmoji.new{uiFrame = ui,maxHeadLineWidth = 400,rootTrans = contentRoot};
    
    mGiftWrapContent = BaseWrapContentEx.new(ui,"Offset/PaintRoot/ItemRoot/Scroll View",8,UIGiftItemWrapUIEx,nil,UI_Gift_RecordReceive);
    mGiftWrapContent:SetUIEvent(1000,1,{OnGiftItemClick});

    mRecordWrapContent = BaseWrapContentEx.new(ui,"Offset/RecordRoot/FriendContent/Scroll View",12,UIGiftReceiveRecordWrapUIEx,nil,UI_Gift_RecordReceive);
    mRecordWrapContent:SetUIEvent(900,1,{OnItemRecordClick});

    mItemRootGo = ui:Find("Offset/PaintRoot/ItemRoot").gameObject;
    mTextRootGo = ui:Find("Offset/PaintRoot/TextRoot").gameObject;

end

function OnEnable(ui)
    RefreshRecordList();
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_RECEIVE_RECORD_CHANGE,RefreshRecordList);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnDisable()
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_RECEIVE_RECORD_CHANGE,RefreshRecordList);
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
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
        GiftMgr.DeleteReceiveRecord(mSelectedRecord);
    elseif id == 2 then
        UI_Gift_Thanks.Show(mSelectedRecord.sendID);
    elseif id == 3 then
        UIMgr.UnShowUI(AllUI.UI_Gift_RecordReceive);
        UI_GiftSend_Main.ShowSendFriend(mSelectedRecord.sendID);
    end
end
