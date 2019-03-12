module("UI_Friend_QunApply",package.seeall)
local WrapUIFriendQunApplyItem = require("Logic/Presenter/UI/Friend/QunApplyList/WrapUIFriendQunApplyItem");

local mQun;
local mApplyItems;
local mCurrentCount;
local mMaxCount;
local mSelectedData;

local mSelectedCount;
local mMemberCountLabel;
local mSelectedAllToggle;
local mSelectedAllGo;


local function SortFunc(a,b)
    return a.time < b.time;
end

local function ReplyApply()

    if mSelectedCount <= 0 then
        TipsMgr.TipByKey("friend_selected_none_notice");--群申请处理，没有选择任何申请者
        return;
    end
    -- if mSelectedCount + mCurrentCount > mMaxCount then
    --     TipsMgr.TipByKey("friend_selected_toomuch_notice");--群申请处理，人数超出群数量限制
    --     return;
    -- end
    
    for player, b in pairs(mSelectedData) do
        if b then
            ChatMgr.RequestReplyCligroupJoin(mQun, player, true);
        end
    end
    UIMgr.UnShowUI(AllUI.UI_Friend_QunApply);
end

local function UpdateCount()
    mMemberCountLabel.text = string.format("%s/%s",mCurrentCount + mSelectedCount,mMaxCount);
end

-- local function OnQunRemoved(qun)
--     if qun == mQun then
--         UIMgr.UnShowUI(AllUI.UI_Friend_QunApply);
--     end
-- end
-- local function OnMemberChange(player)
--     mCurrentCount,mMaxCount = mQun:GetCurrentMaxCapacity();
--     UpdateCount();
-- end
local function OnApplyAdd(applyItem)
    mApplyItems[#mApplyItems + 1] = applyItem;
    table.sort(mApplyItems,SortFunc);
    mAllApplierTable:ResetWithPosition(mApplyItems);
end
local function OnApplyRemove(applyItem)
    for i=1,#mApplyItems do
        if mApplyItems[i] == applyItem then
            table.remove(mApplyItems,i);
            if mSelectedData[applyItem] then
                mSelectedData[applyItem] = nil;
                mSelectedCount = mSelectedCount - 1;
            end
            break;
        end
    end
    table.sort(mApplyItems,SortFunc);
    mAllApplierTable:ResetWithPosition(mApplyItems);
    UpdateCount();
end

local function OnSelectAll()
    mSelectedAllToggle = not mSelectedAllToggle;
    if mSelectedAllToggle then
        for _, app in ipairs(mApplyItems) do
            mSelectedData[app] = true;
        end
        mSelectedCount = #mApplyItems;
    else
        mSelectedData = {};
        mSelectedCount = 0;
    end
    mSelectedAllGo:SetActive(mSelectedAllToggle);
    UpdateCount();
    mAllApplierTable:ResetWithPosition(mApplyItems);
end

local function OnItemSelected(item,wrapUI)
    mSelectedData[item] = not mSelectedData[item];
    if mSelectedData[item] then
        mSelectedCount = mSelectedCount + 1;
    else
        mSelectedCount = mSelectedCount - 1;
    end
    UpdateCount();
    wrapUI:OnRefresh();
end

local function OnApplyInit(qun, list)
    if not qun == mQun then return; end
    mApplyItems = list or table.emptyTable;
    table.sort(mApplyItems,SortFunc);
    mAllApplierTable:ResetWithData(mApplyItems);
end

function IsItemSelected(item)
    return mSelectedData[item];
end

function ShowApplyList(qun)
    mQun = qun;
    UIMgr.ShowUI(AllUI.UI_Friend_QunApply);
end

function OnCreate(ui)

    mMemberCountLabel  = ui:FindComponent("UILabel","Offset/Top/LabelCount");
    mSelectedAllGo = ui:Find("Offset/Bottom/OptionSelectAll/Active").gameObject;
    local path = "Offset/Center/DragAreaFriend/ScrollView";
    mAllApplierTable = BaseWrapContentEx.new(ui,path,6,WrapUIFriendQunApplyItem,1,UI_Friend_QunApply);
    mAllApplierTable:SetUIEvent(200,1,{OnItemSelected});
end

function OnEnable(ui)
    
    mCurrentCount,mMaxCount = mQun:GetCurrentMaxCapacity();
    mSelectedData = {};
    mSelectedCount = 0;

    UpdateCount();

    mSelectedAllToggle = false;
    mSelectedAllGo:SetActive(false);

    mQun:RequestApplyInfo();

    OnApplyInit(mQun);


    -- GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN, OnQunRemoved);
    -- GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD, OnMemberChange);
    -- GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE, OnMemberChange);
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_INIT, OnApplyInit);
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_ADD, OnApplyAdd);
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_REMOVE,OnApplyRemove);
end

function OnDisable(ui)
    mQun = nil;
    mApplyItems = nil;
    mSelectedData = nil;
    mAllApplierTable:ReleaseData();

    -- GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN, OnQunRemoved);
    -- GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD, OnMemberChange);
    -- GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE, OnMemberChange);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_INIT, OnApplyInit);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_ADD, OnApplyAdd);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_APPLY_REMOVE,OnApplyRemove);
end

function OnClick(go, id)
    if id>=200 then
        mAllApplierTable:OnClick(id);
    elseif id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_QunApply);
    elseif id == 1 then
        ReplyApply();
    elseif id == 2 then
        OnSelectAll();
    end
end

