module("UI_Gift_Main",package.seeall);
require("Logic/Presenter/UI/Gift/UI_GiftSend_Main");
require("Logic/Presenter/UI/Gift/UI_GiftSend_FreePanel");

local mToggles = {};
local mOpenPanelId;
local mPanelIDTable = {};
local mTitle;
local mTitles = {};
--展示送礼记录
function ShowGiftSendRecord()
    mOpenPanelId = 11;
    UIMgr.ShowUI(AllUI.UI_Gift_Main);
end
--展示收礼记录
function ShowGiftReceiveRecord()
    mOpenPanelId = 12;
    UIMgr.ShowUI(AllUI.UI_Gift_Main);
end

--展示节日礼物
function ShowMemorialPanel()
    UI_GiftSend_Main.ShowMemorialPanel();
    mOpenPanelId = 10;
    UIMgr.ShowUI(AllUI.UI_Gift_Main);
end
--通过选择礼品赠送
function ShowSendItem(tid)
    if UI_GiftSend_Main.ShowSendItem(tid) then
        mOpenPanelId = 10;
        UIMgr.ShowUI(AllUI.UI_Gift_Main);
    end
end
--通过选择朋友送礼
function ShowSendFriend(friend)
    UI_GiftSend_Main.ShowSendFriend(friend);
    mOpenPanelId = 10;
    UIMgr.ShowUI(AllUI.UI_Gift_Main);
end

function OnCreate(ui)
    GiftMgr.Init();
    mTitle = ui:FindComponent("UILabel","Offset/Bg/Title/");
    local path = "Offset/Bg/RToggles/";
    mToggles[10] = ui:FindComponent("UIToggle",path.."Toggle0");
    mToggles[11] = ui:FindComponent("UIToggle",path.."Toggle1");
    mToggles[12] = ui:FindComponent("UIToggle",path.."Toggle2");
    mTitles[10] = ui:FindComponent("UILabel",path.."Toggle0/Active/Name");
    mTitles[11] = ui:FindComponent("UILabel",path.."Toggle1/Active/Name");
    mTitles[12] = ui:FindComponent("UILabel",path.."Toggle2/Active/Name");
    mPanelIDTable[10] = AllUI.UI_GiftSend_Main;
    mPanelIDTable[11] = AllUI.UI_Gift_RecordReceive;--UI_GiftReceiveRecord;
    mPanelIDTable[12] = AllUI.UI_Gift_RecordSend;--UI_GiftSendRecord;
end

function OnEnable()
    UIMgr.ShowUI(mPanelIDTable[mOpenPanelId]);
    mToggles[mOpenPanelId].value = true;
    mTitle.text = mTitles[mOpenPanelId].text;
end

function OnDisable(ui)
    GameLog.Log("Unshow ui ".."UI_Gift_Main and %s",mOpenPanelId);
    --UIMgr.UnShowUI(mPanelIDTable[mOpenPanelId]);
end

function OnClick(go ,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Gift_Main);
        GameEvent.Trigger(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM);
    elseif id >= 10 and id <=12 then
        if id == mOpenPanelId then
            return;
        end
        UIMgr.UnShowUI(mPanelIDTable[mOpenPanelId]);
        mOpenPanelId = id;
        UIMgr.ShowUI(mPanelIDTable[mOpenPanelId]);
    end
end