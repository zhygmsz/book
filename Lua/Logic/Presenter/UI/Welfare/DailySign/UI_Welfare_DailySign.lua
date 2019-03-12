module("UI_Welfare_DailySign",package.seeall);

local Input = UnityEngine.Input

local ShakeState =
{
    enable = 1,      --可摇签
    wait = 2,        --摇动后的等待状态
    networking = 3,  --网络通信中
    animating = 4,   --动画展示中
    ending = 5,      --摇签结束
    disable = 6,     --摇签次数已满
}

local qianTitle =
{
    "sign_type_show_1",
    "sign_type_show_2",
    "sign_type_show_3",
    "sign_type_show_4",
}

local qianDesc =
{
    "sign_feedback_show_1",
    "sign_feedback_show_2",
    "sign_feedback_show_3",
    "sign_feedback_show_4",
}

local mClickEventType = {
    Close = 5,  --关闭UI
    RefreshTodayAward = 6,--刷新今日奖励
    ShareSolutionToSign = 7,--分享解签
    ShowSigninRulesTips = 8,--签到规则
    AndReceiveThreeAwards = 10,--领取3日奖励
    AndReceiveFiveAwards = 11,--领取5日奖励
    AndReceiveSevenAwards = 12,--领取7日奖励
    SendSigninMsg = 14,--签到/补签
    ShowSignResultUI = 15,--签到结果
    ShowTodyPrizeFirstItemTip = 30,--今日奖励物品tips
    ShowTodyPrizeSecondItemTip = 31,
    ShowTodyPrizeThirdFiItemTip = 32,
    ShowTodyPrizeFourthItemTip = 33,
    ShowTodyPrizeItemTip = 34,--本期大奖tips
}

local mSlef;
local mData;				--数据
local mState;				--当前摇签状态
local mSpanAnimId;          --动画Id


local mTime;
local mDesc;
local mTopPrize
local mTopGet
local mTopBg

local mPrizeBg1
local mPrizeBg2
local mPrizeBg3
local mPrizeBg4

local mPrize1
local mPrize2
local mPrize3
local mPrize4

local mGet1
local mGet2
local mGet3
local mGet4

local mPrize3Day
local mPrize5Day
local mPrize7Day

local mPrize3DayBg
local mPrize5DayBg
local mPrize7DayBg

local m3DayFx
local m5DayFx
local m7DayFx

local m3DayCollider
local m5DayCollider
local m7DayCollider

local mGet3Day
local mGet5Day
local mGet7Day

local mSeriesCount
local mCount

local mSign
local mMask
local mRefreshCount

local mConPrizes
local mSigninId = -1;
local mConsecutiveId = -1;
local mFillCheckId = -1;
local mTodayPrizesBg
local mTodayPrizesLoader
local mConsecutivePrizeLoaders
local mConsecutivePrizesBg
local mTodayGets

local mTiger3_1
local mTiger3_2
local mTiger3_3

local mTiger5_1
local mTiger5_2
local mTiger5_3

local mTiger7_1
local mTiger7_2
local mTiger7_3

local mLocalPrizes = {};
local mLocalTodayPrizes = {};
local mTrackIndex = 0;

local mShare
local mResultTitle
local mResultDesc

local mCurY = -1;
local mCurZ = -1;
local mLastY = -1;
local mLastZ = -1;

local mIsPlayingTiger = false;
local mRefreshConsecutive = true;

local mEffects

local mSpineCnt = 1;
local mLoaded = 0;

local mPrizes = {};

local mQiantongId = -1;
local mNormalResult = false;
local mUpdateResult = false;

local mBgFx;
local mAnimationState1;
local mLoaded = 0;
local mSpanCount = 1;

local mDuration = 0;
local mElipseTime = 0;

local mEvents = {};
local mConFxs = {};

local mTweenGroup10 = {};
local mTweenGroup11 = {};

local mMaxDuration10 = 0;
local mMaxDuration11 = 0;

local mEnable = false;

local mEffectList = {};
local mQiantongLoader = nil;
local mTopPrizeLoader = nil;
local rootSortorder;
function OnCreate(self)
    mSlef = self;

    rootSortorder = mSlef:GetRoot():GetComponent("UIPanel").sortingOrder;
    self:FindComponent("UIPanel","Offset/yaoyiyao").sortingOrder = rootSortorder + 2;

    mTime = self:FindComponent("UILabel","Offset/TodayWidget/TodayInfo/Time")
    mDesc = self:FindComponent("UILabel","Offset/TodayWidget/TodayInfo/Desc")
    mTopPrize = self:FindComponent("UITexture","Offset/TopPrize/Item/Icon")
    mTopPrizeLoader = LoaderMgr.CreateTextureLoader(mTopPrize);
    mTopGet = self:FindComponent("UISprite", "Offset/TopPrize/Item/Get")
    mTopBg = self:FindComponent("UISprite","Offset/TopPrize/Item")


    mPrizeBg1 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item1")
    mPrizeBg2 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item2")
    mPrizeBg3 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item3")
    mPrizeBg4 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item4")

    mPrize1 = self:FindComponent("UITexture","Offset/TodayWidget/TodayPrize/Item1/Icon")
    mPrize2 = self:FindComponent("UITexture","Offset/TodayWidget/TodayPrize/Item2/Icon")
    mPrize3 = self:FindComponent("UITexture","Offset/TodayWidget/TodayPrize/Item3/Icon")
    mPrize4 = self:FindComponent("UITexture","Offset/TodayWidget/TodayPrize/Item4/Icon")

    mGet1 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item1/Get")
    mGet2 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item2/Get")
    mGet3 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item3/Get")
    mGet4 = self:FindComponent("UISprite","Offset/TodayWidget/TodayPrize/Item4/Get")

    mPrize3Day = self:FindComponent("UITexture","Offset/SeriesPrize/Item3/Icon")
    mPrize5Day = self:FindComponent("UITexture","Offset/SeriesPrize/Item5/Icon")
    mPrize7Day = self:FindComponent("UITexture","Offset/SeriesPrize/Item7/Icon")

    mPrize3DayBg = self:FindComponent("UISprite","Offset/SeriesPrize/Item3")
    mPrize5DayBg = self:FindComponent("UISprite","Offset/SeriesPrize/Item5")
    mPrize7DayBg = self:FindComponent("UISprite","Offset/SeriesPrize/Item7")

    m3DayFx = self:Find("Offset/SeriesPrize/Item3/GetAble").gameObject
    m5DayFx = self:Find("Offset/SeriesPrize/Item5/GetAble").gameObject
    m7DayFx = self:Find("Offset/SeriesPrize/Item7/GetAble").gameObject

    m3DayCollider = self:FindComponent("BoxCollider","Offset/SeriesPrize/Item3")
    m5DayCollider = self:FindComponent("BoxCollider","Offset/SeriesPrize/Item5")
    m7DayCollider = self:FindComponent("BoxCollider","Offset/SeriesPrize/Item7")

    mGet3Day = self:FindComponent("UISprite","Offset/SeriesPrize/Item3/Get")
    mGet5Day = self:FindComponent("UISprite","Offset/SeriesPrize/Item5/Get")
    mGet7Day = self:FindComponent("UISprite","Offset/SeriesPrize/Item7/Get")

    mSeriesCount = self:FindComponent("UILabel","Offset/SeriesPrize/Count")

    mCount = self:FindComponent("UILabel","Offset/Count")

    mSign = self:Find("Offset")

    mMask = self:FindComponent("UITexture", "Offset/Mask").gameObject

    mRefreshCount = self:FindComponent("UILabel", "Offset/TodayWidget/BtnRefresh/RefreshCount")

    local prize3 = {able = m3DayFx, had = mGet3Day, collider = m3DayCollider}
    local prize5 = {able = m5DayFx, had = mGet5Day, collider = m5DayCollider}
    local prize7 = {able = m7DayFx, had = mGet7Day, collider = m7DayCollider}
    mConPrizes = {prize3, prize5, prize7}

    mTodayPrizesBg = {mPrizeBg1, mPrizeBg2, mPrizeBg3, mPrizeBg4}
    mTodayPrizesLoader = {  LoaderMgr.CreateTextureLoader(mPrize1), 
                            LoaderMgr.CreateTextureLoader(mPrize2), 
                            LoaderMgr.CreateTextureLoader(mPrize3), 
                            LoaderMgr.CreateTextureLoader(mPrize4)};

    mConsecutivePrizeLoaders = {LoaderMgr.CreateTextureLoader(mPrize3Day), 
                                LoaderMgr.CreateTextureLoader(mPrize5Day), 
                                LoaderMgr.CreateTextureLoader(mPrize7Day)};
                                
    mConsecutivePrizesBg = {mPrize3DayBg, mPrize5DayBg, mPrize7DayBg}
    mTodayGets = {mGet1, mGet2, mGet3, mGet4}

    mTiger3_1 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item3/Sprite1")
    mTiger3_2 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item3/Sprite2")
    mTiger3_3 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item3/Sprite3")

    mTiger5_1 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item5/Sprite1")
    mTiger5_2 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item5/Sprite2")
    mTiger5_3 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item5/Sprite3")

    mTiger7_1 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item7/Sprite1")
    mTiger7_2 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item7/Sprite2")
    mTiger7_3 = self:FindComponent("UISprite", "Offset/SeriesPrize/Item7/Sprite3")

    mShare = self:Find("Offset/Result")
	mResultTitle = self:FindComponent("UILabel", "Offset/Result/Anchor/Sprite_01/Sprite_02/Title")
	mResultDesc = self:FindComponent("UILabel", "Offset/Result/Anchor/Sprite_01/Sprite_02/Desc")


    InitTweens();

    mEffects = {"uimBenefitsmEff01", "uimGaiyunmEff01", "uimQiandao_jianglimEff01", "uimBenefitsmShangqianmCheng01", "uimBenefitsmZhongqianmCheng01",
        "uimBenefitsmXiaqianmCheng01", "uimShagnqianmZimEff01",  "uimShagnqianmZimEff02",  "uimZhongqianmZimEff01",  "uimZhongqianmZimEff02",  "uimXiaqianmZimEff01",
        "uimXiaqianmZimEff02", "uimBenefitsmEff06", "uimBenefitsmEff07", "uimQiandaomSuoxiaomEff01", "uimQiandaomSuoxiaomEff02", "ui_fenxiangjieqianmEff01", "ui_fenxiangjieqianmEff02"}
    CreateUIFx();
end

function OnEnable(self)
    Init();
    RegisterEvents();
    UpdateBeat:Add(Update, self);
    ShowUI();
end

function OnDisable(self)
    LoaderMgr.DeleteLoader(mQiantongLoader);
    table.clear(mLocalTodayPrizes);
    UnRegisterEvents();
end

function Init()
    mMask:SetActive(false);
    mLoaded = 0;
    mSpanCount = 1;

    mCurY = 0;
    mCurZ = 0;
    mLastY = 0;
    mLastZ = 0;

    mDuration = 1000;
    mElipseTime = 0;
end

function InitTweens()
    local panelTweens = mSign:GetComponentsInChildren(typeof(UITweener));

    for idx = 0, panelTweens.Length - 1 do
        local tween = panelTweens[idx]
        if tween.tweenGroup == 10 then
            table.insert(mTweenGroup10, tween)
            mMaxDuration10 = math.max(tween.delay + tween.duration, mMaxDuration10)
        end

        if tween.tweenGroup == 11 then
            table.insert(mTweenGroup11, tween)
            mMaxDuration11 = math.max(tween.delay + tween.duration, mMaxDuration11)
        end
    end
end

function ShowUI()
	mState = ShakeState.disable;
    mData = BenefitsMgr.GetDailySignInfo();
	--CreateUIFx();
    InitSpanAnimation();
	SetupViews();
	SetupToday();
	SetupConsecutive();
	SetupPrizesItem();

    for _, v in ipairs(mTweenGroup10) do
        v:ResetToBeginning()
    end

    for _, v in ipairs(mTweenGroup10) do
        v:PlayForward()
    end

    GameTimer.AddTimer(mMaxDuration10,1,function ()
        mEnable = true
    end,nil)
end

function SetupViews()
    --签到次数
    RefreshCount();
    --签到结果 今日大奖
    if not mData.issign then
        mResultTitle.text = WordData.GetWordDataByKey("sign_type_show_4").value;
        mResultDesc.text = WordData.GetWordDataByKey("sign_feedback_show_4").value;
        mTopGet.enabled = false;
    else
        if mData.today ~= nil and mData.today.prizetype ~= 0 then
            mResultTitle.text = WordData.GetWordDataByKey(qianTitle[mData.today.prizetype]).value;
            mResultDesc.text = WordData.GetWordDataByKey(qianDesc[mData.today.prizetype]).value;
            mTopGet.enabled = (mData.today.awarditemid ~= 0);
        else
            mResultTitle.text = WordData.GetWordDataByKey("sign_type_show_4").value;
            mResultDesc.text = WordData.GetWordDataByKey("sign_feedback_show_4").value;
            mTopGet.enabled = false;
        end
    end
    --本期大奖
    local itemData = ItemData.GetItemInfo(mData.award.itemlist[1].itemid);
    mTopPrizeLoader:LoadObject(ResConfigData.GetResConfigID(itemData.icon_big));
    mTopBg.spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality);
    --时间
    local date = os.date(WordData.GetWordStringByKey("sign_time_show"));
    mTime.text = date;
end

--今日奖励
function SetupToday()
    for _, v in ipairs(mData.todayprize) do
        table.insert(mLocalTodayPrizes, v.itemlist[1].itemid)
    end

	mRefreshCount.text = string.format(WordData.GetWordStringByKey("sign_refresh_time"), 3 - mData.refreshcount);
	if #mLocalTodayPrizes > 0 then
        for i = 1, math.min(#mLocalTodayPrizes, #mTodayPrizesLoader) do
            local itemData = ItemData.GetItemInfo(mLocalTodayPrizes[i])
            if itemData then
                mTodayPrizesLoader[i]:LoadObject(ResConfigData.GetResConfigID(itemData.icon_big))
                mTodayPrizesBg[i].spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality)
            else
                GameLog.LogError("System:DailySign,SetUpTody not find item %s",mLocalTodayPrizes[i])
            end
        end
        return
    end
end

--连续签到
function SetupConsecutive()
	for i = 1, math.min(#mData.consecutiveprize, #mConsecutivePrizeLoaders) do
        --不能领
        --可以领取
        --已经领取
        local itemData = ItemData.GetItemInfo(mData.consecutiveprize[i].itemlist[1].itemid)
        --UIUtil.LoadItemIcon(mConsecutivePrizeLoaders[i],itemData)
        mConsecutivePrizeLoaders[i]:LoadObject(ResConfigData.GetResConfigID(itemData.icon_big))
        mConsecutivePrizesBg[i].spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality)
    end

    SetupConsecutiveState(3, mData.roleflag, mConPrizes[1])
    SetupConsecutiveState(5, mData.roleflag, mConPrizes[2])
    SetupConsecutiveState(7, mData.roleflag, mConPrizes[3])
    mSeriesCount.text = string.format(WordData.GetWordStringByKey("sign_refresh_time_show"), mData.consecutivecont)
end
 
function SetupConsecutiveState(day, flag, prize)
	local alreadyGet = false;

	if day == 3 then
		alreadyGet = bit.band(1, flag) == 1;
	elseif day == 5 then
		alreadyGet = bit.band(2, flag) == 2;
	else
		alreadyGet = bit.band(4 ,flag) == 4;
	end

	if mData.consecutivecont < day then
        --不能领取
        prize.able:SetActive(false);
        prize.had.enabled = false;
    elseif mData.consecutivecont >= day and not alreadyGet then
        --可以领取
        prize.able:SetActive(true);
    elseif mData.consecutivecont >= day and alreadyGet then
        --已经领取
        prize.able:SetActive(false);
        prize.had.enabled = true;
    end
end

function SetupPrizesItem()
	if not mData.issign then
		return
	end

	local prizes = {};
	if #mPrizes == 0 then
		if mData.today.awarditemid ~= 0 then
			table.insert(mPrizes, {itemid = mData.today.awarditemid, count = mData.award.itemlist[1].count});
		end
		--根据签到结果和当天奖励
		if mData.today.prizetype == NetCS_pb.SignResult.Good then
			for i = 1, #mData.todayprize - 1 do
				table.insert(mPrizes, {itemid = mData.todayprize[i].itemlist[1].itemid, count = mData.todayprize[i].itemlist[1].count})
			end
		elseif mData.today.prizetype == NetCS_pb.SignResult.Common then
			for i = 1, #mData.todayprize - 2 do
				table.insert(mPrizes, {itemid = mData.todayprize[i].itemlist[1].itemid, count = mData.todayprize[i].itemlist[1].count})
			end
		elseif mData.today.prizetype == NetCS_pb.SignResult.Bad then
			for i = 1, #mData.todayprize - 3 do
				table.insert(mPrizes, {itemid = mData.todayprize[i].itemlist[1].itemid, count = mData.todayprize[i].itemlist[i].count})
			end
		end
	end

	--处理签到结果页面items
end

function CreateUIFx()
    --背景 Order in Layer 1
    local effectResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_Benefits_eff01.prefab")
    mEffectList[#mEffectList+1] = effectId;
--    mBgFx = UIEffectManager.ShowArtEffect(mSlef:GetRoot(),"UI_Benefits_eff01",-1, Vector3.zero, rootSortorder);
end

function OnQiantongLoadOver(loader)
    mSpanAnimId = loader:GetResID();
    mSpanAnimId = loader:SetActive(true);
    local trans = loader:GetObject().transform;
    local skeletonAnim = trans.gameObject:GetComponent("MeshRenderer");
    skeletonAnim.sortingOrder  = rootSortorder + 1;
    trans.parent = mSign;
    trans.localPosition = Vector3(-840,-950,0);
    trans.localScale = Vector3(100,100,1);
    trans.name = "qiantong";
    if SystemInfo.IsEditor() then
        local shaderName = "Spine/Skeleton"
        local shader = UnityEngine.Shader.Find(shaderName)
        local renders = trans:GetComponents(typeof(UnityEngine.Renderer))
        for rdIdx = 0, renders.Length - 1 do
            local mats = renders[rdIdx].sharedMaterials;
            for matIdx = 0, mats.Length - 1 do
                mats[matIdx].shader = shader;
            end
        end
    end
    mAnimationState1 = mSlef:FindComponent("SkeletonAnimation", "Offset/qiantong").AnimationState;
    OnLoadedSpine();
end

function InitSpanAnimation()
    mQiantongLoader = LoaderMgr.CreateEffectLoader();
    mQiantongLoader:LoadObject(601000002, OnQiantongLoadOver,true);
end

function OnLoadedSpine()
    GameLog.Log("...........................OnLoadedSpine........................................");
    mLoaded = mLoaded + 1
    if mLoaded >= mSpanCount then
    end
end

function RegisterEvents()
    --签到结果事件
    GameEvent.Reg(EVT.SUB_G_SIGN, EVT.SUB_U_SIGNIN, ResponseSignInOrFillCheck);
    GameEvent.Reg(EVT.SUB_G_SIGN, EVT.SUB_U_FILLCHECK, ResponseSignInOrFillCheck);
    --刷新今日奖励结果事件
    GameEvent.Reg(EVT.SUB_G_SIGN, EVT.SUB_U_REFRESH_TODAYPRIZE, SetupToday);
    
    --连续签到获得奖励
    GameEvent.Reg(EVT.SUB_G_SIGN, EVT.SUB_U_GETCONSECUTIVE, ResponseGetConsecutive);
end

function UnRegisterEvents()
    GameEvent.UnReg(EVT.SUB_G_SIGN, EVT.SUB_U_SIGNIN, ResponseSignInOrFillCheck);
    GameEvent.UnReg(EVT.SUB_G_SIGN, EVT.SUB_U_FILLCHECK, ResponseSignInOrFillCheck);
    GameEvent.UnReg(EVT.SUB_G_SIGN, EVT.SUB_U_REFRESH_TODAYPRIZE, SetupToday);
    GameEvent.UnReg(EVT.SUB_G_SIGN, EVT.SUB_U_GETCONSECUTIVE, ResponseGetConsecutive);
end

function ResponseSignInOrFillCheck(msg)
    if msg.ret ~= 0 then
        TipsMgr.TipErrorByID(msg.ret);
        mState = ShakeState.enable;
    end
    --根据 signresult.type 区分 上中下签
    mState = ShakeState.animating;
    mMask:SetActive(true);
    mAnimationState1:SetAnimation(0, "stand_2", false);
    --一共48帧
    --GameTimer.AddTimer(mMaxDuration10,1,OnAnimationEnd,nil,msg)
    GameTimer.AddTimer(33/30,1,OnAnimationEnd,self,msg)
end

--摇签动画播放完成
function OnAnimationEnd(msg)
    mMask:SetActive(false);
    mState = ShakeState.ending;
    --更新连续签到奖励等
    RefreshCount();
    UpdatePrizeState(msg);

    UpdateSignResult();

    SetupConsecutiveState(3, mData.roleflag, mConPrizes[1])
    SetupConsecutiveState(5, mData.roleflag, mConPrizes[2])
    SetupConsecutiveState(7, mData.roleflag, mConPrizes[3])

    mSeriesCount.text = string.format(WordData.GetWordStringByKey("sign_refresh_time_show"), mData.consecutivecont)

    local tipsData = SignTipsData.GetTipsDataById(mData.todaytips);
    if tipsData then
        mDesc.text = tipsData.title
    end

    BenefitsMgr.SetIsNormalResault(true);
    --打开签到结果界面
    UIMgr.ShowUI(AllUI.UI_Welfare_SignResault);
    mAnimationState1:SetAnimation(0, "stand_1", true);
end

function RefreshCount()
    mCount.text = string.format("%d/%d", mData.issign and mData.fillcheckcount or mData.fillcheckcount + 1 , 4);
    local mfillCheckCount = mData.issign and mData.fillcheckcount or mData.fillcheckcount + 1;
    if mfillCheckCount>0 then
        mState = ShakeState.enable;
    else
        mState = ShakeState.disable;
    end
end

function Update()
    mCurZ = Input.acceleration.z;
    mCurY = Input.acceleration.y;

    if mState == ShakeState.enable then
        if math.abs(mCurY - mLastY) > 2 or (math.abs(mCurZ - mLastZ) > 2 and math.abs(mCurY - mLastY) > 0.3) then
            mState = ShakeState.wait
            mElipseTime = 0
        end
    elseif mState == ShakeState.wait then
        mElipseTime = mElipseTime + GameTime.deltaTime_L
        if math.abs(mCurY - mLastY) > 2 or (math.abs(mCurZ - mLastZ) > 2 and math.abs(mCurY - mLastY) > 0.3) then
            mElipseTime = 0
        end
        if mElipseTime >= mDuration then
             mState = ShakeState.networking
             if not mData.issign then
                 BagMgr.CloseBagSync(30)
                 local msg_sign = NetCS_pb.CSSign()
                 GameNet.SendToGate(msg_sign)
             else
                 BagMgr.CloseBagSync(30)
                 local msg_fillcheck = NetCS_pb.CSFillCheck()
                 GameNet.SendToGate(msg_fillcheck)
             end
        end
    elseif mState == ShakeState.animating then

    end
    mLastZ = mCurZ;
    mLastY = mCurY;
end

function OnClick(go,id)
    if id == mClickEventType.Close then
        --关闭按钮

    elseif id == mClickEventType.RefreshTodayAward then
        --刷新今日奖励
        if mData.issign then
            TipsMgr.TipCommon(WordData.GetWordStringByKey("sign_feedback_finish"))
            return
        end

        if mData.refreshcount == 3 then
            TipsMgr.TipCommon(WordData.GetWordStringByKey("sign_feedback_nontime_refresh"))
            return
        end

        local msg = NetCS_pb.CSRefreshToday()
        GameNet.SendToGate(msg)
    elseif id == mClickEventType.ShareSolutionToSign then
        --分享解签
            TipsMgr.TipCommon(WordData.GetWordStringByKey("sign_non_open"))
    elseif id == mClickEventType.ShowSigninRulesTips then
        --签到规则Tips
            TipsMgr.TipCommon(WordData.GetWordStringByKey("sign_non_open"))
    elseif id == mClickEventType.AndReceiveThreeAwards then
        ----领取3日奖励
        OnClickConsecutiveItem(3)
    elseif id == mClickEventType.AndReceiveFiveAwards then
        ----领取5日奖励
        OnClickConsecutiveItem(5)
    elseif id == mClickEventType.AndReceiveSevenAwards then
        ----领取7日奖励
        OnClickConsecutiveItem(7)
    elseif id==mClickEventType.SendSigninMsg then
        if mState == ShakeState.enable then
            if not mData.issign then
                --BagMgr.CloseBagSync(30)
                local msgmSign = NetCS_pb.CSSign()
                GameNet.SendToGate(msgmSign)
            else
                --BagMgr.CloseBagSync(30)
                local msg_fillcheck = NetCS_pb.CSFillCheck()
                GameNet.SendToGate(msg_fillcheck)
            end
        elseif mState == ShakeState.disable then
            TipsMgr.TipCommon(WordData.GetWordStringByKey("ERR_CS_DROP_NOFILLCOUNT"));
        end
    elseif id == mClickEventType.ShowSignResultUI then

        if not mData.issign then
            return
        end
        if not mResultAnimating then
            --self._normalResult = false
            --self:_showResult(self._data.today.prizetype)
            UIMgr.ShowUI(AllUI.UI_Welfare_SignResault);
        end
    elseif id >= mClickEventType.ShowTodyPrizeFirstItemTip and id<=mClickEventType.ShowTodyPrizeFourthItemTip then
        local itemid = mLocalTodayPrizes[math.fmod( id, 30 ) + 1 ]
        if ItemData.GetItemInfo(itemid) then
            BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, itemid)
        end
    elseif id == mClickEventType.ShowTodyPrizeItemTip then
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mData.award.itemlist[1].itemid)
    end
end

function OnClickConsecutiveItem(day)
    local alreadyGet = false
    local itemId = -1
    local msg = NetCS_pb.CSGetConsecutive()

    if day == 3 then
        alreadyGet = bit.band(1, mData.roleflag) == 1
        --itemId = self._consecutivePrizes[1]
        itemId = mData.consecutiveprize[1].itemlist[1].itemid
        msg.type = NetCS_pb.CSGetConsecutive.ThreeDay
    elseif day == 5 then
        alreadyGet = bit.band(2, mData.roleflag) == 2
        --itemId = self._consecutivePrizes[2]
        itemId = mData.consecutiveprize[2].itemlist[1].itemid
        msg.type = NetCS_pb.CSGetConsecutive.FiveDay
    else
        alreadyGet = bit.band(4 ,mData.roleflag) == 4
        --itemId = self._consecutivePrizes[3]
        itemId = mData.consecutiveprize[3].itemlist[1].itemid
        msg.type = NetCS_pb.CSGetConsecutive.SevenDay
    end

    if mData.consecutivecont < day then
        --不能领取 Tips
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, itemId)

    elseif mData.consecutivecont >= day and not alreadyGet then
        --可以领取
        BagMgr.RequestCloseBagSync(30)
        GameNet.SendToGate(msg)
    elseif mData.consecutivecont >= day and alreadyGet then
        --已经领取 Tips
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, itemId)
    end
end

function UpdatePrizeState(msg)
    local result = {}
    local tmp = {}
    for _, v in ipairs(msg.signresult.prize.itemlist) do
        table.insert(tmp, v)
    end

    for j = 1, #mLocalTodayPrizes - 1 do
        for i = #tmp, 1, -1 do
            if mLocalTodayPrizes[j] == tmp[i].itemid then
                table.insert(result, j)
                table.remove(tmp, i)
            end
        end
    end
    --sjz
    -- for _, v in ipairs(mTodayGets) do
    --     v.enabled = false
    -- end

    for _, v in ipairs(result) do
        mTodayGets[v].enabled = true
    end

    mTopGet.enabled = (msg.signresult.awarditemid ~= nil and #msg.signresult.awarditemid.itemlist > 0 and msg.signresult.awarditemid.itemlist[1].itemid > 0)
end

function UpdateSignResult()
    mResultTitle.text = WordData.GetWordDataByKey(qianTitle[mData.today.prizetype]).value
    mResultDesc.text = WordData.GetWordDataByKey(qianDesc[mData.today.prizetype]).value
    mTopGet.enabled = (mData.today.awarditemid ~= 0)
end



function ResponseGetConsecutive(msg)
    mData = BenefitsMgr.GetDailySignInfo();
    SetupConsecutive();
    --PlayTigerAnimation(msg)
end
--[[
--连续签到奖励动画
function PlayTigerAnimation(msg)
    mIsPlayingTiger = true;
    local conFx = nil;
    for i, v in ipairs(mData.consecutiveprize) do
        local prize = msg.prize;
        local itemlist = prize.itemlist;
        local item = itemlist[1];
        if v.itemlist[1].itemid == item.itemid then
            conFx = self._conFxs[i];
            break
        end
    end

    if conFx == nil then
        return
    end

    conFx.able:SetActive(false)
    self._tigerPanel:SetActive(true)
    local itemData = ItemData.GetItemInfo(msg.prize.itemlist[1].itemid)
    UIUtil.LoadItemIcon(self._tigerItem, itemData)
    self._tigerBg.spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality)
    self._tigerFx:Show()

    STimer.New(1,1,nil, function ()
        self._tigerFx:Hide()
        self._boomFx:Show()
        self._tigerCount.enabled = true
        self._tigerCount.spriteName = string.format("Img_Number_8_%d", msg.prize.itemlist[1].count)
        self._isPlayingTiger = false

        STimer.New(1, 1, nil, function ()
            if not self._enable then
                return
            end
            self._boomFx:Hide()
        end)
    end)
end
]]
