module("UI_GiftSend_CostPanel",package.seeall);

local UIGiftFriendWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftFriendWrapUIEx");
local GiftComponentBag = require("Logic/Presenter/UI/Gift/Panel/GiftComponentBag");

local mData = {};
local mLabelSendCount;
local mToggleAnonymity;

local mSelectedGifts = {};

local mEvent;

local mWrapInput;

local function UpdateGiftLimit()
    local total = 0;
    for gift, count in pairs(mSelectedGifts) do
        total = total + count * gift:GetValue();
    end
    local valueLimit = GiftMgr.GetCostValueLimit();
    local valueSent = GiftMgr.GetCostValueSent();

    local sent = total+valueSent;
    mLabelSendCount.text = string.format("%s/%s",sent, valueLimit);

    mBuyButton.activeGo:SetActive(sent<=valueLimit);
    mBuyButton.disactiveGo:SetActive(sent>valueLimit);
end

local function OnItemChange(tid,num)
    local gift = GiftMgr.GetGiftByItem(tid);
    mData._giftBagCom:OnItemChange(gift);
end

local function OnSystemClose()
    mSelectedGifts = {};
end

local function OnSendMainClose()
    UIMgr.UnShowUI(AllUI.UI_GiftSend_CostPanel);
end

local function OnsendSuccess(gType)
    if gType == GiftMgr.COST then
        ClearOperateRecord();
        UpdateGiftLimit();
        mData._giftBagCom:RefreshBag();
    end
end

function ClearOperateRecord()
    mSelectedGifts = {};
end

function GetGiftSelectCount(gift)
    return mSelectedGifts[gift] or 0;
end

function IsFriendSelected(friend)
    return UI_GiftSend_Main.mSelectedFriend == friend;
end

function SetSelectedGift(gift)
    mSelectedGifts[gift] = mSelectedGifts[gift]  or 0;
    mSelectedGifts[gift] = mSelectedGifts[gift] + 1;
    local select = mSelectedGifts[gift];
    if not gift:TrySelect(select) then 
        mSelectedGifts[gift] = mSelectedGifts[gift] - 1;
        return;
    end
    local total = 0;
    for gift, count in pairs(mSelectedGifts) do
        total = total + count * gift:GetValue();
    end
    local valueLimit = GiftMgr.GetCostValueLimit();
    local valueSent = GiftMgr.GetCostValueSent();
    if total + valueSent > valueLimit then
        mSelectedGifts[gift] = mSelectedGifts[gift] - 1;
        TipsMgr.TipByKey("gift_value_limit_notice");
        return;
    end
    return true;
end


function OnItemAddClick(gift,wrapUI)
    GameLog.Log("OnItemAddClick %s",gift:GetName());
    if not SetSelectedGift(gift) then return; end

    wrapUI:OnRefresh();
    UpdateGiftLimit();
end

function OnItemDeleteClick(gift,wrapUI)
    GameLog.Log("OnItemDeleteClick %s",gift:GetName());
    mSelectedGifts[gift] = mSelectedGifts[gift] - 1;
    if mSelectedGifts[gift] == 0 then
        mSelectedGifts[gift] = nil;
    end
    wrapUI:OnRefresh();
    UpdateGiftLimit();
end

function OnFriendClick(friend,wrapUI)
    UI_GiftSend_Main.mSelectedFriend = friend;
end

function OnCreate(ui)
    local path = "Offset";
    mData._panelGo = ui:Find(path).gameObject;

    mData._friendTable = BaseWrapContentEx.new(ui,path.."/FriendWidget/FriendContent/Scroll View",8,UIGiftFriendWrapUIEx,nil,UI_GiftSend_CostPanel);
    mData._friendTable:SetUIEvent(1000,2,{OnFriendClick});

    mLabelSendCount = ui:FindComponent("UILabel",path.."/BasicWidget/SpriteCount/Label");
    mToggleAnonymity = ui:FindComponent("UIToggle",path.."/BasicWidget/Toggle");

    local gifts = GiftMgr.GetAllCostGifts();
    local giftInfoTable = {gifts = gifts,callbacks = {OnItemAddClick,OnItemDeleteClick},context = UI_GiftSend_CostPanel};

    mData._giftBagCom = GiftComponentBag.new(ui,giftInfoTable);

    local input = ui:FindComponent("LuaUIInput","Offset/ChatWidget/Input");
    mWrapInput = ChatInputWrap.new(input, ChatMgr.CommonLinkOpenType.FromChat);
    mWrapInput:ResetMsgCommon()
    mWrapInput:ResetLimitCount(20)

    ui:FindComponent("UIEvent","Offset/BasicWidget/ButtonBuy/Active").id = 1;
    mBuyButton = {};
    mBuyButton.activeGo = ui:Find("Offset/BasicWidget/ButtonBuy/Active").gameObject;
    mBuyButton.disactiveGo = ui:Find("Offset/BasicWidget/ButtonBuy/Disactive").gameObject;
end

function OnEnable(ui)
    mData._giftBagCom:OnEnable();

    mData._friendTable:ResetWithData(UI_GiftSend_Main.mFriendsByIntimacy);

    UpdateGiftLimit();
    
    mEvent = {};
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_BAG_NORMALITEMCHANGE,OnItemChange);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_SEND_SUCCESS,OnsendSuccess);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_MAIN_UI,OnSendMainClose);
end

function OnDisable()
    GameLog.Log("Unshow ui ".."UI_GiftSend_FreedPanel");
    mData._friendTable:ReleaseData();
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_BAG_NORMALITEMCHANGE,OnItemChange);
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_SEND_SUCCESS,OnsendSuccess);
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_MAIN_UI,OnSendMainClose);
    mEvent = nil;
end

function OnDestroy()
    mData = {};
end

function OnClick(go,id)
    if not mData._panelGo.activeInHierarchy then
        return;
    end

    if id >= 2000 then
        mData._giftBagCom:OnClick(id);
    elseif id >= 1000 then
        mData._friendTable:OnClick(id);
    elseif id == 1 then
        GiftMgr.RequestCSGiveGifts{
            friend = UI_GiftSend_Main.mSelectedFriend,
            giftCountTable = mSelectedGifts,
            gType = Friend_pb.GFTY_RARITY,
            text = mWrapInput:GetMsgCommonStr(),
            isAnonymity= mToggleAnonymity.value
        };
    elseif id == 2 then 
        mWrapInput:OnLinkBtnClick();
    end
end
