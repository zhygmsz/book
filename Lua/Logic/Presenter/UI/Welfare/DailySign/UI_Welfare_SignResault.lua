module("UI_Welfare_SignResault",package.seeall);

local mData;
local mPrizes = {};

local mDesign;

local mPoem1;
local mPoem2;
local mPoem3;
local mPoem4;

local mPanel;
local mGrid;

local mItem1;
local mItem1Bg;
local mItem1Icon;
local mItem1Name;

local mItem2;
local mItem2Bg;
local mItem2Icon;
local mItem2Name;

local mItem3;
local mItem3Bg;
local mItem3Icon;
local mItem3Name;

local mItem4;
local mItem4Bg;
local mItem4Icon;
local mItem4Name;

local mBtnRefresh;
local mResult;
local mTips;
local mTigerPanel;
local mTigerBg;
local mTigerItem;
local mTigerCount;
local mSprite;

local mItems;

local mTweenGroup20;
local mTweenGroup21;
local mTweenGroup23;
local mTweenGroup24;

local mMaxDuration20;
local mMaxDuration21;
local mMaxDuration23;
local mMaxDuration24;

local mQianSprite;
local mQianScale;
local mResultAnimating = false;

local mItemFxs;

local mShangqianFx;
local mZhongqianFx;
local mXiaqianFx;

local mShangZi1;
local mShangZi2;
local mShangZi2NoDelay;

local mZhongZi1;
local mZhongZi2;
local mZhongZi2NoDelay;

local mXiaZi1;
local mXiaZi2;
local mXiaZi2NoDelay;

local mPanelQian;

function OnCreate(self)
	mDesign = self:FindComponent("UILabel","Offset/Panel/Result/Desc/Desc");

	mPoem1 = self:FindComponent("UILabel", "Offset/Panel/Result/Left/Poem1");
    mPoem2 = self:FindComponent("UILabel", "Offset/Panel/Result/Left/Poem2");
    mPoem3 = self:FindComponent("UILabel", "Offset/Panel/Result/Left/Poem3");
    mPoem4 = self:FindComponent("UILabel", "Offset/Panel/Result/Left/Poem4");

    mPanel = self:Find("Offset/Panel");
    mGrid = self:FindComponent("UIGrid", "Offset/Panel/Result/Grid");

    mItem1 = self:Find("Offset/Panel/Result/Grid/Item1").gameObject;
    mItem1Bg = self:FindComponent("UISprite", "Offset/Panel/Result/Grid/Item1");
    mItem1Icon = self:FindComponent("UITexture", "Offset/Panel/Result/Grid/Item1/Icon");
    mItem1IconLoader = LoaderMgr.CreateTextureLoader(mItem1Icon);
    mItem1Name = self:FindComponent("UILabel", "Offset/Panel/Result/Grid/Item1/Label");

    mItem2 = self:Find("Offset/Panel/Result/Grid/Item2").gameObject;
    mItem2Bg = self:FindComponent("UISprite", "Offset/Panel/Result/Grid/Item2");
    mItem2Icon = self:FindComponent("UITexture", "Offset/Panel/Result/Grid/Item2/Icon");
    mItem2IconLoader = LoaderMgr.CreateTextureLoader(mItem2Icon);
    mItem2Name = self:FindComponent("UILabel", "Offset/Panel/Result/Grid/Item2/Label");

    mItem3 = self:Find("Offset/Panel/Result/Grid/Item3").gameObject;
    mItem3Bg = self:FindComponent("UISprite", "Offset/Panel/Result/Grid/Item3");
    mItem3Icon = self:FindComponent("UITexture", "Offset/Panel/Result/Grid/Item3/Icon");
    mItem3IconLoader = LoaderMgr.CreateTextureLoader(mItem3Icon);
    mItem3Name = self:FindComponent("UILabel", "Offset/Panel/Result/Grid/Item3/Label");

    mItem4 = self:Find("Offset/Panel/Result/Grid/Item4").gameObject;
    mItem4Bg = self:FindComponent("UISprite", "Offset/Panel/Result/Grid/Item4");
    mItem4Icon = self:FindComponent("UITexture", "Offset/Panel/Result/Grid/Item4/Icon");
    mItem4IconLoader = LoaderMgr.CreateTextureLoader(mItem4Icon);
    mItem4Name = self:FindComponent("UILabel", "Offset/Panel/Result/Grid/Item4/Label");

    mBtnRefresh = self:Find("Offset/Panel/Result/BtnRefresh");

    mResult = self:Find("Offset/Panel/Result");

    mTips = self:FindComponent("UILabel", "Offset/Panel/Tips");

    mTigerPanel = self:Find("Offset/Panel/Tiger").gameObject;
    mTigerBg = self:FindComponent("UISprite", "Offset/Panel/Tiger/Item");
    mTigerItem = self:FindComponent("UITexture", "Offset/Panel/Tiger/Item/Icon");
    mTigerCount = self:FindComponent("UISprite", "Offset/Panel/Tiger/Count");
    mSprite = self:Find("Offset/Panel/Sprite");

    mQianSprite = self:FindComponent("UISprite", "Offset/Panel_Qian/Qian/Scale/Sprite");
    mQianScale = self:Find("Offset/Panel_Qian/Qian/Scale");
    mPanelQian = self:Find("Offset/Panel_Qian");

    local item1 = {go = mItem1, icon = mItem1Icon, iconLoader = mItem1IconLoader, name = mItem1Name, quality = mItem1Bg}
    local item2 = {go = mItem2, icon = mItem2Icon, iconLoader = mItem2IconLoader, name = mItem2Name, quality = mItem2Bg}
    local item3 = {go = mItem3, icon = mItem3Icon, iconLoader = mItem3IconLoader, name = mItem3Name, quality = mItem3Bg}
    local item4 = {go = mItem4, icon = mItem4Icon, iconLoader = mItem4IconLoader, name = mItem4Name, quality = mItem4Bg}
    mItems = {item1, item2, item3, item4}

	local resultTweens = mResult:GetComponentsInChildren(typeof(UITweener));
	local qianTweens = mPanelQian:GetComponentsInChildren(typeof(UITweener))

	mTweenGroup20 = {}
    mTweenGroup21 = {}
    mTweenGroup23 = {}
    mTweenGroup24 = {}

    mMaxDuration20 = 0
    mMaxDuration21 = 0
    mMaxDuration23 = 0
    mMaxDuration24 = 0

    for idx = 0, resultTweens.Length - 1 do
        local tween = resultTweens[idx]
        if tween.tweenGroup == 20 then
            table.insert(mTweenGroup20, tween)
            mMaxDuration20 = math.max(tween.delay + tween.duration, mMaxDuration20)
        end

        if tween.tweenGroup == 21 then
            table.insert(mTweenGroup21, tween)
            mMaxDuration21 = math.max(tween.delay + tween.duration, mMaxDuration21)
        end

        if tween.tweenGroup == 23 then
            table.insert(mTweenGroup23, tween)
            mMaxDuration23 = math.max(tween.delay + tween.duration, mMaxDuration23)
        end

        if tween.tweenGroup == 24 then
            table.insert(mTweenGroup24, tween)
            mMaxDuration24 = math.max(tween.delay + tween.duration, mMaxDuration24)
        end
    end

    for idx = 0, qianTweens.Length - 1 do
        local tween = qianTweens[idx]
        if tween.tweenGroup == 20 then
            table.insert(mTweenGroup20, tween)
            mMaxDuration20 = math.max(tween.delay + tween.duration, mMaxDuration20)
        end

        if tween.tweenGroup == 21 then
            table.insert(mTweenGroup21, tween)
            mMaxDuration21 = math.max(tween.delay + tween.duration, mMaxDuration21)
        end

        if tween.tweenGroup == 23 then
            table.insert(mTweenGroup23, tween)
            mMaxDuration23 = math.max(tween.delay + tween.duration, mMaxDuration23)
        end

        if tween.tweenGroup == 24 then 
            table.insert(mTweenGroup24, tween)
            mMaxDuration24 = math.max(tween.delay + tween.duration, mMaxDuration24)
        end
    end
end

function OnEnable(self)
    mData = BenefitsMgr.GetDailySignInfo();
	SetupTips();
    --CreateUIFx();
    InitViews();
end

function OnDisable(self)
	
end

function CreateUIFx()
    --奖励
    local itemFx1 = UIEffectManager.ShowArtEffect(mItem1.transform,"UImQiandao_jianglimEff01",-1, Vector3.zero, 220)
    local itemFx2 = UIEffectManager.ShowArtEffect(mItem2.transform,"UImQiandao_jianglimEff01",-1, Vector3.zero, 220)
    local itemFx3 = UIEffectManager.ShowArtEffect(mItem3.transform,"UImQiandao_jianglimEff01",-1, Vector3.zero, 220)
    local itemFx4 = UIEffectManager.ShowArtEffect(mItem4.transform,"UImQiandao_jianglimEff01",-1, Vector3.zero, 220)
    mItemFxs = {itemFx1, itemFx2, itemFx3, itemFx4}

    mShangqianFx = UIEffectManager.ShowArtEffect(mQianScale,"UImBenefitsmShangqianmCheng01",-1, Vector3.zero, 94)
    --Order in Layer 1 3 4
    mZhongqianFx = UIEffectManager.ShowArtEffect(mQianScale,"UImBenefitsmZhongqianmCheng01",-1, Vector3.zero, 204)
    --Order in Layer 115
    mXiaqianFx = UIEffectManager.ShowArtEffect(mQianScale,"UImBenefitsmXiaqianmCheng01",-1, Vector3.zero, 94)
    --签字特效 Order in Layer 125

    --上
    mShangZi1 = UIEffectManager.ShowArtEffect(mQianScale,"UImShagnqianmZimEff01",-1, Vector3.zero, 91)
    mShangZi2 = UIEffectManager.ShowArtEffect(mQianScale,"UImShagnqianmZimEff02",-1, Vector3.zero, 91)
    mShangZi2NoDelay = UIEffectManager.ShowArtEffect(mQianScale,"UImShagnqianmZimEff02mNodelay",-1, Vector3.zero, 91)

    --中
    mZhongZi1 = UIEffectManager.ShowArtEffect(mQianScale,"UImZhongqianmZimEff01",-1, Vector3.zero, 91)
    mZhongZi2 = UIEffectManager.ShowArtEffect(mQianScale,"UImZhongqianmZimEff02",-1, Vector3.zero, 91)
    mZhongZi2NoDelay = UIEffectManager.ShowArtEffect(mQianScale,"UImZhongqianmZimEff02mNodelay",-1, Vector3.zero, 91)

    --下
    mXiaZi1 = UIEffectManager.ShowArtEffect(mQianScale,"UImXiaqianmZimEff01",-1, Vector3.zero, 91)
    mXiaZi2 = UIEffectManager.ShowArtEffect(mQianScale,"UImXiaqianmZimEff02",-1, Vector3.zero, 91)
    mXiaZi2NoDelay = UIEffectManager.ShowArtEffect(mQianScale,"UImXiaqianmZimEff02mNodelay",-1, Vector3.zero, 91)

    mGaiyunFx = UIEffectManager.ShowArtEffect(mBtnRefresh,"UI_gaiyun_eff01",-1, Vector3.zero, 100)
    mGaiyunFx2 = UIEffectManager.ShowArtEffect(mBtnRefresh,"UI_gaiyun_eff01_nodelay",-1, Vector3.zero, 100)
end

function ShowResault(type)
	--显示签到结果
	local isNormalResault = BenefitsMgr.GetIsNormalResult();

	if isNormalResault then
		for _, v in ipairs(mTweenGroup20) do
            v:ResetToBeginning()
        end

        for _, v in ipairs(mTweenGroup20) do
            v:PlayForward()
        end

        for i, v in ipairs(mItemFxs) do
            STimer.New(i * 0.15, 1, nil, function ()
                v:Show()
            end)
        end

		mResultAnimating = true;
        STimer.New(mMaxDuration20, 1, nil, function ()
            mResultAnimating = false;
        end)

        --根据type 显示不同特效
        if type == NetCSmPb.SignResult.Good  then
            mShangqianFx:Show()
            mShangZi1:Show()
            mShangZi2:Show()
        elseif type == NetCSmPb.SignResult.Common then
            mZhongqianFx:Show()
            mZhongZi1:Show()
            mZhongZi2:Show()
        elseif type == NetCSmPb.SignResult.Bad then
            mXiaqianFx:Show()
            mXiaZi1:Show()
            mXiaZi2:Show()
        end
        mGaiyunFx:Show()
    else
    	for _, v in ipairs(mTweenGroup20) do
            v:Sample(1, true)
            v.enabled = false
        end

        for _, v in ipairs(mTweenGroup23) do
            v:ResetToBeginning()
        end

        for _, v in ipairs(mTweenGroup23) do
            v:PlayForward()
        end

        STimer.New(mMaxDuration23, 1, nil, function ()
            mResultAnimating = false
        end)

        --根据type 显示不同特效
        if type == NetCSmPb.SignResult.Good  then
            mShangqianFx:Show()
            mShangZi2NoDelay:Show()
            mShangZi2NoDelay:SetLocalRotation(UnityEngine.Quaternion.Euler(0,0,0))
        elseif type == NetCSmPb.SignResult.Common then
            mZhongqianFx:Show()
            mZhongZi2NoDelay:Show()
            mZhongZi2NoDelay:SetLocalRotation(UnityEngine.Quaternion.Euler(0,0,0))
        elseif type == NetCSmPb.SignResult.Bad then
            mXiaqianFx:Show()
            mXiaZi2NoDelay:Show()
            mXiaZi2NoDelay:SetLocalRotation(UnityEngine.Quaternion.Euler(0,0,0))
        end
        mGaiyunFx2:Show()
	end
end

function SetupTips()
	local tipsData = SignTipsData.GetTipsDataById(mData.todaytips)
    if tipsData then
        mPoem1.text = tipsData.content1
        mPoem2.text = tipsData.content2
        mPoem3.text = tipsData.content3
        mPoem4.text = tipsData.content4

        local rates = {}
        for i, v in ipairs(tipsData.list) do
            table.insert(rates, v.rate)
        end
        local idx = GetDesign(mData.tips, rates)
        mDesign.text = tipsData.list[idx].design
    end
end

function SetResaultData()
	local type = BenefitsMgr.GetPrizeType();
    if type == NetCS_pb.SignResult.Good  then
        mQianSprite.spriteName = "bg_chouqian_qian03"
    elseif type == NetCS_pb.SignResult.Common then
        mQianSprite.spriteName = "bg_chouqian_qian02"
    elseif type == NetCS_pb.SignResult.Bad then
        mQianSprite.spriteName = "bg_chouqian_qian01"
    end
end

function InitViews()
    --隐藏所有奖励
    for i, v in ipairs(mItems) do
        v.go:SetActive(false);
    end

    local signPrizeItems = BenefitsMgr.GetSignPrizeltItems();
    local prizes = {};
    if signPrizeItems then
        for i, v in ipairs(signPrizeItems) do
            table.insert(prizes, {itemid = v.itemid, count = v.count});
        end
    end

    --id为数值类型？？？？？？？？？？？？？？？？？？？？？？？
    --local awardItemId = BenefitsMgr.GetAwardItemId();
    --if awardItemId ~= nil and #awardItemId.itemlist > 0 and awardItemId.itemlist[1].itemid > 0 then
    --    table.insert(prizes, {itemid = awardItemId.itemlist[1].itemid, count = awardItemId.itemlist[1].count});
    --end

    for i, v in ipairs(prizes) do
        table.insert(mPrizes, v);
    end

    for i = 1, math.min(#mItems, #prizes) do
        local itemData = ItemData.GetItemInfo(prizes[i].itemid)
        if itemData then
            mItems[i].go:SetActive(true);
            mItems[i].name.text = itemData.name;
            --UIUtil.LoadItemIcon(self._items[i].icon, itemData)
            mItems[i].iconLoader:LoadObject(ResConfigData.GetResConfigID(itemData.icon_big));
            mItems[i].quality.spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality);
        end
    end

    mGrid:Reposition();
    SetupTips();

    SetResaultData();


end

function GetDesign(id, rates)

    local random =  math.random(0,30)
    local sumProb = 0

    if #rates == 1 then
        return 1
    end

    for i = 1, #rates do

        sumProb = sumProb + rates[i]

        if i == 1 and random <= sumProb then
            return i
        elseif  i == #rates and random > sumProb - rates[i] then
            return i
        elseif i > 1 and i < #rates then

            if random > sumProb - rates[i] and random <= sumProb then
                return i
            end

        end

    end
    GameLog.LogError("SignTips GetDesign error id -> %s", id)
    return 0
end

function ShowResault(type)
    mResultAnimating = True;
    if BenefitsMgr.GetIsNormalResault() then
        for i, v in ipairs(mTweenGroup20) do
            v:ResetToBeginning()
        end

        for i, v in ipairs(mTweenGroup20) do
            v:PlayForward()
        end


    end
end

function OnClick(go, id)
    if id == 16 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Welfare_SignResault)
    elseif id == 17 then
        TipsMgr.TipByKey("equip_share_not_support");
    end
end