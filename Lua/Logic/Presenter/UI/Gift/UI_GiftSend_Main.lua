module("UI_GiftSend_Main",package.seeall);
require("Logic/Presenter/UI/Gift/UI_GiftSend_FreePanel");
require("Logic/Presenter/UI/Gift/UI_GiftSend_CostPanel");
local mToggles = {};
local mOpenPanelId;
local mPanelIDTable = {};

mSelectedFriend = nil;
mFriendsByIntimacy = nil;

function OnSystemClose()
    UIMgr.UnShowUI(AllUI.UI_GiftSend_Main);
    mSelectedFriend = nil;
    mFriendsByIntimacy = nil;
end
--展示节日礼物
function ShowMemorialPanel()
    mOpenPanelId = 24;
    UIMgr.ShowUI(AllUI.UI_GiftSend_Main);
end
--通过选择礼品赠送
function ShowSendItem(tid)
    local gift = GiftMgr.GetGiftByItem(tid);
    if not gift then return false; end
    mFriendsByIntimacy = GiftMgr.GetAllFriendsOrderByIntimacy();
    if #mFriendsByIntimacy == 0 then
        TipsMgr.TipByKey("gift_no_friend_limit");
        return;
    end
    mSelectedFriend = mFriendsByIntimacy[1];

    mOpenPanelId = nil;
    if gift:IsFree() then
        if not UI_GiftSend_FreePanel.SetSelectedGift(gift) then
            return;
        end
        UI_GiftSend_FreePanel.SetSelectedFriend();
        mOpenPanelId = 21;
    elseif GiftMgr.IsCost(gid) then
        if not UI_GiftSend_CostPanel.SetSelectedGift(gift) then
            return;
        end
        UI_GiftSend_CostPanel.SetSelectedFriend();
        mOpenPanelId = 22;
    end
    if mOpenPanelId then
        UIMgr.ShowUI(AllUI.UI_GiftSend_Main);
    end
    return mOpenPanelId and true or false;
end
--通过选择朋友送礼
function ShowSendFriend(friend)
    mFriendsByIntimacy = GiftMgr.GetAllFriendsOrderByIntimacy();
    mOpenPanelId = 21;
    mSelectedFriend = friend;
    UIMgr.ShowUI(AllUI.UI_GiftSend_Main);
end

function OnCreate(ui)
    GiftMgr.Init();
    local path = "Offset/LeftContent/Grid/";
    mToggles[21] = ui:FindComponent("UIToggle",path.."ItemPrefab1");
    mToggles[22] = ui:FindComponent("UIToggle",path.."ItemPrefab2");
    mToggles[23] = ui:FindComponent("UIToggle",path.."ItemPrefab3");
    mToggles[24] = ui:FindComponent("UIToggle",path.."ItemPrefab4");
    mPanelIDTable[21] = AllUI.UI_GiftSend_FreePanel;
    mPanelIDTable[22] = AllUI.UI_GiftSend_CostPanel--UI_GiftSend_PaidPanel;
    mPanelIDTable[23] = AllUI.UI_GiftSend_CustomPanel--UI_GiftSend_CustomizingPanel;
    mPanelIDTable[24] = AllUI.UI_GiftSend_MemorialPanel--UI_GiftSend_MemorialPanel;
end

function OnEnable()
    mFriendsByIntimacy = mFriendsByIntimacy or GiftMgr.GetAllFriendsOrderByIntimacy();
    mOpenPanelId = mOpenPanelId or 21;
    
    mToggles[mOpenPanelId].value = true;
    UIMgr.ShowUI(mPanelIDTable[mOpenPanelId]);
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnDisable()
    GameEvent.Trigger(EVT.GIFT,EVT.GIFT_CLOSE_MAIN_UI);
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnClick(go ,id)
    if id >= 21 and id <=24 then
        if id == mOpenPanelId then
            return;
        end
        UIMgr.UnShowUI(mPanelIDTable[mOpenPanelId]);
        mOpenPanelId = id;
        UIMgr.ShowUI(mPanelIDTable[mOpenPanelId]);
    end
end