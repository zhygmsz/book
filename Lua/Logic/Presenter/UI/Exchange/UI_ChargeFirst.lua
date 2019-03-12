module("UI_ChargeFirst",package.seeall);
local UIChargeShowCase = require("Logic/Presenter/UI/Exchange/ChargeFirst/UIChargeShowCase");
local UIChargeFirstButton = require("Logic/Presenter/UI/Exchange/ChargeFirst/UIChargeFirstButton");
local mBtnCom;
local mClotherToggle;
local mClothSelectIdx;
local mDayToggle;
local mShowCase;

local mDayEvents = {};
local mTimePoll;

local mAwards;
local mSelectedAward;
local mSelf = nil;

--首充界面特效 任意金额 3000 飘散花瓣 竹叶飘落 按钮花瓣
local mEffectsResId= {400400080,400400081,400400082,400400083,601000011};
local mEffects= {};
--展示模型Id
local mShowModelsRtx = {};
local mPetEntityAttr =
{
    name="firsrcharge_pet",
    petData=nil,
    position= Vector3.zero,
    forward = Quaternion.identity,
    modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER,
    fashions={},
    physiqueID=nil,
}
local mFollowerEntityAttr =
{
    name="firsrcharge_follower",
    petData=nil,
    position= Vector3.zero,
    forward = Quaternion.identity,
    modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER,
    fashions={},
    physiqueID=nil,
}
local mCharacterEntityAttr =
{
    name="firsrcharge_player",
    petData=nil,
    position= Vector3.zero,
    forward = Quaternion.identity,
    modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER,
    fashions={},
    physiqueID=nil,
}


local function OnClotherSelected(id)
    mClothSelectIdx=id;
    local trueId = id-30;
    mBtnCom:SelectColorIdx(trueId);
    local suitlist = ChargeMgr.GetSuitList();
    mCharacterEntityAttr.physiqueID = suitlist[trueId]._showID;
    CameraRender.RenderEntity(AllUI.UI_ChargeFirst,mShowModelsRtx[2],mCharacterEntityAttr,3);
end

local function OnDaySelected(id)
    mSelectedAward = id - 10;
    local award = mAwards[mSelectedAward];
    mShowCase:ShowDay(award);
    mBtnCom:ShowDay(award)
end

local function OnStateChange(award)
    if award == mAwards[mSelectedAward] then
        mBtnCom:ShowDay(award);
    end
end

local function OnFirstCharge()
    mSelectedAward = nil;
    mDayToggle:ClearCurEventId(true);
    
    local anyCharge = ChargeMgr.HasAnyCharge();
    if anyCharge then
        for i,award in ipairs(mAwards) do
            if award:IsWaitReceiving() then
                mSelectedAward = i;
                break;
            end
        end
        if not mSelectedAward then
            for i,award in ipairs(mAwards) do
                if award:IsWaitOpen() then
                    mSelectedAward = i;
                    break;
                end
            end
        end
        mSelectedAward = mSelectedAward or 1;
        local eventID = 10+mSelectedAward;
        mDayToggle:OnClick(eventID);
        mTimePoll:End();
    else
        mDayToggle:OnClick(11);
        mTimePoll:Start(11);
    end
end

function OnCreate(ui)
    mSelf=ui;
    ChargeMgr.SetEntryUI(true);
    mClotherToggle = ToggleItemGroup.new(nil,OnClotherSelected);
    local btn1 = ui:Find("Offset/ClotherGrid/Btn");
    local data1 = {eventId=31};
    mClotherToggle:AddItem(btn1,data1);
    local btn2 = ui:Find("Offset/ClotherGrid/Btn2");
    local data2 = {eventId=32};
    mClotherToggle:AddItem(btn2,data2);
    local btn3 = ui:Find("Offset/ClotherGrid/Btn3");
    local data3 = {eventId=33};
    mClotherToggle:AddItem(btn3,data3);
    local btn1NorLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn/nor/label");
    local btn1SpecLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn/spec/label");
    local btn2NorLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn2/nor/label");
    local btn2SpecLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn2/spec/label");
    local btn3NorLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn3/nor/label");
    local btn3SpecLabel = ui:FindComponent("UILabel","Offset/ClotherGrid/Btn3/spec/label");
    btn1NorLabel.text = WordData.GetWordStringByKey("Pay_first_color1");
    btn2NorLabel.text = WordData.GetWordStringByKey("Pay_first_color2");
    btn3NorLabel.text = WordData.GetWordStringByKey("Pay_first_color3");
    btn1SpecLabel.text = WordData.GetWordStringByKey("Pay_first_color1");
    btn2SpecLabel.text = WordData.GetWordStringByKey("Pay_first_color2");
    btn3SpecLabel.text = WordData.GetWordStringByKey("Pay_first_color3");

    mDayToggle = ToggleItemGroup.new(nil,OnDaySelected);
    local btn11 = ui:Find("Offset/DayGrid/Btn");
    local data11 = {eventId=11};
    mDayToggle:AddItem(btn11,data11);
    local btn12 = ui:Find("Offset/DayGrid/Btn2");
    local data12 = {eventId=12};
    mDayToggle:AddItem(btn12,data12);
    local btn13 = ui:Find("Offset/DayGrid/Btn3");
    local data13 = {eventId=13};
    mDayToggle:AddItem(btn13,data13);

    mShowCase = UIChargeShowCase.new(ui,"Offset/Showcase");
    mBtnCom = UIChargeFirstButton.new(ui);

    local interval = ConfigData.GetFloatValue("charge_first_roll_interval") or 1.0;
    mTimePoll = UITimePoll.new({11,12,13},interval,mDayToggle.OnClick,mDayToggle);

    mShowModelsRtx[1] = ui:FindComponent("UITexture","Offset/Bg/BgBase (7)");
    mShowModelsRtx[2] = ui:FindComponent("UITexture","Offset/Bg/BgBase (8)");
    mShowModelsRtx[3] = ui:FindComponent("UITexture","Offset/Bg/BgBase (9)");
    CreateUIEffect(ui);
end

function OnEnable(ui)
    mAwards = ChargeMgr.GetFirstRewards();
    ChargeMgr.RequestInitCharge();
    OnFirstCharge();
    if mClothSelectIdx then
        mClotherToggle:OnClick(mClothSelectIdx);
    else
        mClotherToggle:OnClick(31);
    end
    IsShowUIEffect(true);
    CreateShowModel(ui);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_FIRST_REWARD_CHANGE,OnFirstCharge);
    GameEvent.Reg(EVT.CHARGE,EVT.CHARGE_HAS_ANY_CHARGE,OnFirstCharge);
    UIMgr.MaskUI(true, 0, 199);
end

function OnDisable(ui)
    mDayToggle:ClearCurEventId(true);
    mClotherToggle:ClearCurEventId(true);
    mTimePoll:End();
    IsShowUIEffect(false);
    DeleteModels();
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_FIRST_REWARD_CHANGE,OnFirstCharge);
    GameEvent.UnReg(EVT.CHARGE,EVT.CHARGE_HAS_ANY_CHARGE,OnFirstCharge);
    UIMgr.MaskUI(false, 0, 199);
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_ChargeFirst);
    elseif id<20 then
        mDayToggle:OnClick(id);
        mTimePoll:Disturb(id);
    elseif id < 30 then
        mBtnCom:OnClick(id);
    elseif id >30 and id<100 then
        mClotherToggle:OnClick(id);
    elseif id >=100 then
        mShowCase:OnClick(id);
    end
end

function CreateUIEffect(ui)
    if not table.empty(mEffects) then return end;
    local mAnyAmount = ui:Find("Offset/Bg/BgBase (3)");
    local mRewardBtn = ui:Find("Offset/RewardBtnPanel/BtnDown");
    local mUIRootSortorder = ui:GetRoot():GetComponent("UIPanel").sortingOrder;
    mRewardBtn.transform.parent:GetComponent("UIPanel").sortingOrder = mUIRootSortorder+2;
    
    for i = 1,#mEffectsResId do
        mEffects[i] = LoaderMgr.CreateEffectLoader();
        if i<5 then
            mEffects[i]:LoadObject(mEffectsResId[i]);
        else
            mEffects[i]:LoadObject(mEffectsResId[i],OnFlowerSpineLoadOver,true);
        end
        if i==1 then
            mEffects[i]:SetTransform(mAnyAmount.transform,Vector3(-142,1,0),Vector3.one,Vector3.zero,mUIRootSortorder+1);
        elseif i==2 then
            mEffects[i]:SetTransform(mAnyAmount.transform,Vector3(79,3,0),Vector3.one,Vector3.zero,mUIRootSortorder+1);
        elseif i==3 then
            mEffects[i]:SetTransform(ui:GetRoot(),Vector3(-366,132,0),Vector3.one,Vector3.zero,mUIRootSortorder+1);
        elseif i==4 then
            mEffects[i]:SetTransform(ui:GetRoot(),Vector3(322,102,0),Vector3.one,Vector3.zero,mUIRootSortorder+1);
        elseif i==5 then
            mEffects[i]:SetTransform(mRewardBtn.transform,Vector3(-833.5,-495,0),Vector3(100,100,1),Vector3.zero);
        end
        mEffects[i]:SetLayer(CameraLayer.UILayer);
        mEffects[i]:SetActive(true,true);
    end
end


function OnFlowerSpineLoadOver(loader)
    mSpanAnimId = loader:GetResID();
    mSpanAnimId = loader:SetActive(true);
    local trans = loader:GetObject().transform;
    local skeletonAnim = trans.gameObject:GetComponent("MeshRenderer");
    local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
    skeletonAnim.sortingOrder  = rootSortorder;
end

function CreateShowModel(ui)
    
    local followerId = ConfigData.GetValue("Charge_first_zhuzhan");
    local petModelId = ConfigData.GetValue("Charge_first_pet");

    mFollowerEntityAttr.physiqueID = tonumber(followerId);
    mPetEntityAttr.physiqueID = tonumber(petModelId);

    CameraRender.RenderEntity(AllUI.UI_ChargeFirst,mShowModelsRtx[1],mFollowerEntityAttr,1);
    CameraRender.RenderEntity(AllUI.UI_ChargeFirst,mShowModelsRtx[3],mPetEntityAttr,2);
end

function DeleteModels()
	CameraRender.DeleteEntity(AllUI.UI_ChargeFirst,1);
	CameraRender.DeleteEntity(AllUI.UI_ChargeFirst,2);
	CameraRender.DeleteEntity(AllUI.UI_ChargeFirst,3);
end

function OnDrag(delta, id)
	CameraRender.DragEntity(AllUI.UI_ChargeFirst,delta,id);
end

function IsShowUIEffect(isShow)
    if not table.empty(mEffects)then
        if isShow then
            for i=1,#mEffects do
                mEffects[i]:SetActive(true,true);
            end
        else
            for i=1,#mEffects do
                mEffects[i]:SetActive(false);
            end
        end
    end
end

