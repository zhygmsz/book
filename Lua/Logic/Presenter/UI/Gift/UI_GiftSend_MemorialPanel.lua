module("UI_GiftSend_MemorialPanel",package.seeall);
require ("Logic/Presenter/UI/Gift/UI_Gift_EditorLetter");
local UIGiftFriendWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftFriendWrapUIEx");
local UIGiftCardWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftCardWrapUIEx");
local GiftComponentBag = require("Logic/Presenter/UI/Gift/Panel/GiftComponentBag");


local mData = {};
local mLabelSendCount;
local mToggleAnonymity;

local mSelectedFriend= {};
local mSelectedGifts = {};
local mSelectedCover;

local mToggleSelectedAll;

local mEvent;

local function OpenPurchasePanel()
    --TODO
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
    mSelectedFriend = {};
    mSelectedGifts = {};
end

local function OnSendMainClose()
    UIMgr.UnShowUI(AllUI.UI_GiftSend_MemorialPanel);
end

local function OnsendSuccess(gType)
    if gType == GiftMgr.MEMORIAL then
        ClearOperateRecord();
        UpdateGiftLimit();
        mData._giftBagCom:RefreshBag();
    end
end

function ClearOperateRecord()
    mSelectedFriend = {};
    mSelectedGifts = {};
    mSelectedCover = nil;
end

function GetGiftSelectCount(gift)
    return mSelectedGifts[gift] or 0;
end

function IsFriendSelected(friend)
    return mSelectedFriend[friend];
end

function SetSelectedFriend(friend)
    mSelectedFriend[friend]= true;
end

function SetSelectedGift(gift)
    mSelectedGifts[gift] = mSelectedGifts[gift]  or 0;
    mSelectedGifts[gift] = mSelectedGifts[gift] + 1;
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
    mSelectedFriend[friend] = not mSelectedFriend[friend];
end

function OnCardClick(cover,wrapUI)
    GameLog.Log("OnCardClick "..cover.id);
    mSelectedCover = cover;
end

function IsCardSelected(cover)
    return mSelectedCover == cover;
end

function OnToggleAllChange()
    if mToggleSelectedAll.value then
        for _,friend in ipairs(mFriends) do
            mSelectedFriend[friend] = true;
        end
    else
        mSelectedFriend = {};
    end
    mData._friendTable:Update();
end

function OnCreate(ui)
    mData._panelGo = ui:Find("Offset").gameObject;

    mData._friendTable = BaseWrapContentEx.new(ui,"Offset/FriendWidget/FriendContent/Scroll View",8,UIGiftFriendWrapUIEx,nil,UI_GiftSend_MemorialPanel);
    mData._friendTable:SetUIEvent(1000,2,{OnFriendClick});

    mData._cardTable = BaseWrapContentEx.new(ui,"Offset/CardWidget/Scroll View",8,UIGiftCardWrapUIEx,nil,UI_GiftSend_MemorialPanel);
    mData._cardTable:SetUIEvent(900,2,{OnCardClick});
    
    mLabelWillCost = ui:FindComponent("UILabel","Offset/BasicWidget/LabelCost/SpriteCount/Label");
    mLabelFortuneHave = ui:FindComponent("UILabel","Offset/BasicWidget/LabelMoney/SpriteCount/Label");

    mToggleAnonymity = ui:FindComponent("UIToggle","Offset/BasicWidget/Toggle");
    ui:FindComponent("UIEvent","Offset/BasicWidget/ButtonBuy").id = 1;

    local gifts = GiftMgr.GetAllFreeGifts();
    local giftInfoTable = {gifts = gifts,callbacks = {OnItemAddClick,OnItemDeleteClick},context = UI_GiftSend_MemorialPanel};

    mData._giftBagCom = GiftComponentBag.new(ui,giftInfoTable);

    mToggleSelectedAll = ui:FindComponent("UIToggle", "Offset/FriendWidget/ToggleAll/ToggleAll");
    local eventToggleChange = EventDelegate.Callback(OnToggleAllChange);
    EventDelegate.Set(mToggleSelectedAll.onChange,eventToggleChange);
end

function OnEnable(ui)
    mData._giftBagCom:OnEnable();

    mFriends = GiftMgr.GetFriendsForMemorial();
    mData._friendTable:ResetWithData(mFriends);

    local cards = GiftMgr.GetAllCoverCards();
    if #cards > 0 then
        mSelectedCover = cards[1];
    end
    mData._cardTable:ResetWithData(cards);

    UpdateGiftLimit();
    
    mEvent = {};
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_BAG_NORMALITEMCHANGE,OnItemChange);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_SEND_SUCCESS,OnsendSuccess);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_MAIN_UI,OnSendMainClose);
end

function OnDisable()
    GameLog.Log("Unshow ui UI_GiftSend_FreddPanel");
    mData._friendTable:ReleaseData();
    mData._cardTable:ReleaseData();
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
    elseif id >= 900 then
        mData._cardTable:OnClick(id);
    elseif id == 1 then
        local friends = {};
        for friend, b in pairs(mSelectedFriend) do
            if b then
                table.insert(friends,friend);
            end
        end
        if #friends == 0 then
            TipsMgr.TipByKey("Gift_select_friend_none");
            return;
        end
        
        local total = 0;
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
            UIMgr.UnShowUI(AllUI.UI_GiftSend_MemorialPanel);

            UI_Gift_EditorLetter.PackGift{
                friends = friends,
                giftCountTable = mSelectedGifts,
                gType = Friend_pb.GFTY_MEMORIAL,
                cover = mSelectedCover,
                isAnonymity= mToggleAnonymity.value;
            };
        end
    end
end
