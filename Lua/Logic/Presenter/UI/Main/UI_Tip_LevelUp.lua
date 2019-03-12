module("UI_Tip_LevelUp", package.seeall)

local mSelf;
local mLevelUpIconTrans;
local mLevelUpEffect;
local mTimer;

function OnCreate(self)
	ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_dengjitisheng_eff01.prefab");

	mSelf = self;
	mLevelUpIconTrans = self:Find("Offset/LevelUpIcon");
	--加载升级特效
	local rootSortorder = self:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	mLevelUpEffect = LoaderMgr.CreateEffectLoader();
	mLevelUpEffect:LoadObject(GameAsset.UI_dengjitisheng_eff01);
	mLevelUpEffect:SetParent(mLevelUpIconTrans);
	mLevelUpEffect:SetLocalScale(Vector3.one);
    mLevelUpEffect:SetSortOrder(rootSortorder + 10);
end

function OnDestroy(self)
	
end

function OnEnable(self)
	mTimer = GameTimer.AddTimer(2, 1, CloseLevelUpTip);
	mLevelUpEffect:SetActive(false);
	mLevelUpEffect:SetActive(true);
end

function OnDisable(self)
	GameTimer.DeleteTimer(mTimer);
end

function CloseLevelUpTip()
    UIMgr.UnShowUI(AllUI.UI_Tip_LevelUp);
end
