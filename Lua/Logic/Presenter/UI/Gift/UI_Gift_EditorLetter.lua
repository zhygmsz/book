module("UI_Gift_EditorLetter",package.seeall)
local UIGiftItemWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftItemWrapUIEx");
local UIGiftLetterPaint = require("Logic/Presenter/UI/Gift/Component/UIGiftLetterPaint");

local mRootUIPanel;
local mPreviewGo;

local mDefaultColorToggle;
local mDefaultSizeToggle;
local mPaintComponent;

local mLabelReceiveName;
local mLabelSendName;
local mLabelContent;
local mGiftWrapContent;
local mGiftInfo;

local mLabelContentComponent;
local mMsgCommon;

local mEvent;


local function OnInputFinish()
    mLabelContentComponent:UpdateLabel(mMsgCommon);
end

local function OpenPreview()
    --mRootUIPanel.enabled = false;
    mPreviewGo:SetActive(true);
end

local function ClosePreview()
    --mRootUIPanel.enabled = true;
    mPreviewGo:SetActive(false);
end

local function SendGift()
    TipsMgr.TipByFormat("Open Purchase Panel");
    mGiftInfo.text = mMsgCommon:SerializeToString();
    GiftMgr.RequestCSGiveGifts(mGiftInfo);
end

function PackGift(giftInfo)
    mGiftInfo = giftInfo;
    UIMgr.ShowUI(AllUI.UI_Gift_EditorLetter);
end

function OnGiftItemClick(gift,wrapUI)
    GameLog.Log("OnGiftItemClick %s ",gift:GetName());
end

function OnCreate(ui)
    mRootUIPanel = ui:GetRoot():GetComponent("UIPanel");
    mPreviewGo = ui:Find("Offset/PaintRoot/Preview").gameObject;

    local paint = ui:FindComponent("UIPaint","Offset/PaintRoot/PaintBg/Paint");
    local paintRootGo = ui:Find("Offset/PaintRoot").gameObject;
    
    local colorRoot = ui:Find("Offset/FuncRoot/ColorRoot");
    local colorToggles = {};
    for i =0, colorRoot.childCount-1 do
        local togglePath = "Offset/FuncRoot/ColorRoot/color"..tostring(i+1);
        local toggle = ui:FindComponent("UIToggle",togglePath);
        colorToggles[i+1] = toggle;
        if i == 0 then
            mDefaultColorToggle = toggle;
        end
    end

    local sizeRoot = ui:Find("Offset/FuncRoot/SizeRoot");
    toggleSizeTable = {};
    for i =0, sizeRoot.childCount-1 do
        local togglePath = "Offset/FuncRoot/SizeRoot/size"..tostring(i+1);
        local toggle = ui:FindComponent("UIToggle",togglePath);
        local size = ui:FindComponent("UIWidget",togglePath.."/bg").width;
        toggleSizeTable[toggle] = size;
        if i == 0 then
            mDefaultSizeToggle = toggle;
        end
    end

    mEraseToggle = ui:FindComponent("UIToggle","Offset/FuncRoot/Erase");
    mPaintComponent = UIGiftLetterPaint.new{
        paintRootGo = paintRootGo,
        uiPaint = paint;
        colorToggles= colorToggles;
        toggleSizeTable = toggleSizeTable;
        eraseToggle = mEraseToggle;
        defaultColorToggle = mDefaultColorToggle;
        defaultSizeToggle = mDefaultSizeToggle;
    };
    
    mLabelReceiveName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameReceive");
    mLabelSendName = ui:FindComponent("UILabel","Offset/PaintRoot/TextRoot/NameSend");
    local contentRoot = ui:Find("Offset/PaintRoot/TextRoot/ContentRoot");
    mLabelContentComponent = UILabel_WithEmoji.new{uiFrame = ui,maxHeadLineWidth = 400,rootTrans = contentRoot};
    
    mGiftWrapContent = BaseWrapContentEx.new(ui,"Offset/PaintRoot/ItemRoot/Scroll View",8,UIGiftItemWrapUIEx,nil,UI_GiftSend_CostPanel);
    mGiftWrapContent:SetUIEvent(1000,1,{OnGiftItemClick});
end

function OnEnable(ui)
    local receiveName = nil;
    if mGiftInfo.friend then
        receiveName = mGiftInfo.friend:GetRemark();
    elseif mGiftInfo.friends then
        local friend = mGiftInfo.friends[1];
        if #(mGiftInfo.friends) > 1 then
            receiveName = friend:GetRemark().."Common_tip_and_so_on";
        else
            receiveName = friend:GetRemark();
        end
    end
    mLabelReceiveName.text = receiveName;

    mLabelSendName.text = mGiftInfo.isAnonymity and UserData.GetName() or WordData.GetWordStringByKey("gift_anomymity_sender_name");
    local defaultContent = WordData.GetWordStringByKey("gift_default_bless_content");
    mMsgCommon = mMsgCommon or UIMsgCommonFactory.CreateMsgCommonWithDefaultText(defaultContent);
    OnInputFinish();

    local gifts = {};
    for gift,count in pairs(mGiftInfo.giftCountTable) do
        table.insert(gifts, gift);
    end
    
    mPaintComponent:OnEnable();
    mGiftWrapContent:ResetWithData(gifts);
    ClosePreview();
    GameEvent.Reg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnDisable(ui)
    mPaintComponent:OnDisable();
    GameEvent.UnReg(EVT.GIFT,EVT.GIFT_CLOSE_UI_SYSTEM,OnSystemClose);
end

function OnClick(go,id)
    GameLog.Log("OnClick %s, %s",go.name,id);
    if id == 1 then
        UIMgr.UnShowUI(AllUI.UI_Gift_EditorLetter);
        UI_GiftSend_Main.ShowMemorialPanel();
    elseif id == 2 then
        mPaintComponent:Undo();
    --elseif id == 3 then --恢复 改为 橡皮檫
        --mPaintComponent:Recover();
    elseif id == 4 then
        TipsMgr.TipComfirmByString("礼物编辑使用面板没设计");
    elseif id == 10 then
        local inputLimit = ConfigData.GetIntValue("Gift_bless_input_limit") or 50;
        UI_Input_WithEmoji.Show(mMsgCommon,inputLimit,OnInputFinish);
    elseif id == 11 then
        OpenPreview();
    elseif id == 12 then
        ClosePreview();
    elseif id == 13 then
        SendGift();
    end
end

function OnSystemClose()
    mMsgCommon = nil;
    UIMgr.UnShowUI(AllUI.UI_Gift_EditorLetter);
end

return UI_GiftSend_Letter;