module("UI_GiftSend_CustomPanel",package.seeall);
require ("Logic/Presenter/UI/Gift/UI_Gift_EditorLetter");
local UIGiftFriendWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftFriendWrapUIEx");
local GiftComponentBag = require("Logic/Presenter/UI/Gift/Panel/GiftComponentBag");

local mData = {};
local mLabelWillCost;
local mToggleAnonymity;

local mSelectedGifts = {};

local mEvent;

local function OpenChargePanel()
    TipsMgr.TipsByString("打开充值界面");
end
function SetSelectedGift(gift)
    if not mSelectedGifts[gift] then
        mSelectedGifts[gift] = 1;
    else
        mSelectedGifts[gift] = mSelectedGifts[gift] + 1;
    end
    return true;
end

local function UpdateGiftLimit()
    local total = 0;
    for gift, count in pairs(mSelectedGifts) do
        local have = gift:GetItemCount();
        if count > have then
            total = total + (count-have) * gift:GetValue();
        end
    end
    mLabelWillCost.text = total;

    local fortuneHave = GiftMgr.GetFortuneHave();
    mLabelFortuneHave.text = fortuneHave;
end

local function OnItemChange(tid,num)
    local gift = GiftMgr.GetGiftByItem(tid);
    mData._giftBagCom:OnItemChange(gift);
end

local function OnSystemClose()
    ClearOperateRecord();
    UIMgr.UnShowUI(AllUI.UI_GiftSend_CustomPanel);
end

local function OnSendMainClose()
    UIMgr.UnShowUI(AllUI.UI_GiftSend_CustomPanel);
end

local function OnsendSuccess(gType)
    if gType == GiftMgr.CUSTOM then
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

    mData._friendTable = BaseWrapContentEx.new(ui,path.."/FriendWidget/FriendContent/Scroll View",8,UIGiftFriendWrapUIEx,nil,UI_GiftSend_CustomPanel);
    mData._friendTable:SetUIEvent(1000,2,{OnFriendClick});

    mLabelWillCost = ui:FindComponent("UILabel",path.."/BasicWidget/LabelCost/SpriteCount/Label");
    mLabelFortuneHave = ui:FindComponent("UILabel",path.."/BasicWidget/LabelMoney/SpriteCount/Label");
    mToggleAnonymity = ui:FindComponent("UIToggle",path.."/BasicWidget/Toggle");

    ui:FindComponent("UIEvent",path.."/BasicWidget/ButtonBuy").id = 1;

    local gifts = GiftMgr.GetAllFreeGifts();
    local giftInfoTable = {gifts = gifts,callbacks = {OnItemAddClick,OnItemDeleteClick},context = UI_GiftSend_CustomPanel};

    mData._giftBagCom = GiftComponentBag.new(ui,giftInfoTable);

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
    GameLog.Log("Unshow ui ".."UI_GiftSend_FreddPanel");
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
        local total = 0 ;
        for gift,count in pairs(mSelectedGifts) do
            if count <= 0 then
                mSelectedGifts[gift] = nil;
            end
            local have = gift:GetItemCount();
            if count > have then
                total = total + (count-have) * gift:GetValue();
            end
        end
        local fortuneHave = GiftMgr.GetFortuneHave();

        if total > fortuneHave then--您的{0}币数量不足。取消/获取途径
            TipsMgr.TipConfirmByKey("money_not_enough_notice",OpenPurchasePanel,nil);
        else
            UIMgr.UnShowUI(AllUI.UI_GiftSend_Main);
            UIMgr.UnShowUI(AllUI.UI_GiftSend_CustomPanel);

            UI_Gift_EditorLetter.PackGift{
                friend = UI_GiftSend_Main.mSelectedFriend,
                giftCountTable = mSelectedGifts,
                gType = Friend_pb.GFTY_SNCUSTOM,
                isAnonymity= mToggleAnonymity.value,
            };
        end
    end
end
