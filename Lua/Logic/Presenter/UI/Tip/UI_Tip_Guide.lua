module("UI_Tip_Guide",package.seeall)

local mUIRoot;
local mUIOff;
local mPanel;

local mLeftObj;
local mLeftTip;
local mLeftBg;
local mLeftActive;

local mRightObj;
local mRightTip;
local mRightBg;
local mRightActive;

local mGuideEffectData = {};
local mTickTime = 0;
local mTickMaxTime = 2000;
local mSortOrder = 110;

function OnCreate(self)
    mUIRoot = UnityEngine.GameObject.Find("UI Root").transform;
    mPanel = self:Find("Offset").parent:GetComponent("UIPanel");
    mLeftObj = self:FindGo("Offset/Left");
    mLeftTip = self:FindComponent("UILabel","Offset/Left/Tip");
    mLeftBg = self:FindComponent("UISprite","Offset/Left/Bg");
    mRightObj = self:FindGo("Offset/Right");
    mRightTip = self:FindComponent("UILabel","Offset/Right/Tip");
    mRightBg = self:FindComponent("UISprite","Offset/Left/Bg");
end

function OnEnable(self)
    local actionData = GAME_ACTION_DATA;
    if actionData then
        mLeftActive = actionData.params[2] == "1";
        mRightActive = actionData.params[2] ~= "1";
        mLeftTip.text = actionData.params[3];
        mRightTip.text = actionData.params[3];

        mLeftObj:SetActive(mLeftActive);
        mRightObj:SetActive(mRightActive);
        mUIOff = Vector3.New(tonumber(actionData.params[4]),tonumber(actionData.params[5]),0);

        mGuideEffectData.effectName = actionData.params[6]
        mGuideEffectData.tapPath = actionData.params[7]
        mGuideEffectData.effectState = true;
        mGuideEffectData.effectActive = true;
        mGuideEffectData.tapRoot = UnityEngine.GameObject.Find(mGuideEffectData.tapPath);
        if mLeftObj.activeSelf then
            mLeftObj.transform.position = mGuideEffectData.tapRoot.transform.position;
            mLeftObj.transform.localPosition = mLeftObj.transform.localPosition + mUIOff;
        else
            mRightObj.transform.position = mGuideEffectData.tapRoot.transform.position;
            mRightObj.transform.localPosition = mRightObj.transform.localPosition + mUIOff;
        end
        --TODO资源加载
        mTickMaxTime = tonumber(actionData.params[8]);
        if actionData.params[9] then
            mSortOrder = tonumber(actionData.params[9]);
        end
        mPanel.sortingOrder = mSortOrder;
    end
    mTickTime = 0;
    UpdateBeat:Add(OnUpdate)
    TouchMgr.SetListenOnNGUIEvent(UI_Guide_Tip,true);
end

function OnUpdate()
    mTickTime = mTickTime + GameTime.deltaTime_L;
    if mTickTime > mTickMaxTime and mTickMaxTime > 0 and not mLeftObj.activeSelf and not mRightObj.activeSelf then
        OnTickFinish(true,false);
    end
end

function OnDisable(self)
    UpdateBeat:Remove(OnUpdate)
    TouchMgr.SetListenOnNGUIEvent(UI_Guide_Tip,false);
    GAME_ACTION_DATA = nil;
    mGuideEffectData.effectActive = false;
    if not tolua.isnull(mGuideEffectData.effect) then
        UnityEngine.GameObject.Destroy(mGuideEffectData.effect);
    end
    mGuideEffectData.effect = nil;
end

function OnTickFinish(tickFinish,forceDisable)
    if forceDisable then
        mLeftObj:SetActive(false);
        mRightObj:SetActive(false);
        if mGuideEffectData.effect then
            mGuideEffectData.effect:SetActive(false);
        else
            mGuideEffectData.effectState = false;
        end
    else
        if UICamera.CountInputSources() <= 0 then
            mLeftObj:SetActive(mLeftActive);
            mRightObj:SetActive(mRightActive);
            if mGuideEffectData.effect then
                mGuideEffectData.effect:SetActive(true);
            else
                mGuideEffectData.effectState = true;
            end      
        end
    end
    mTickTime = 0;
end

function OnPressScreen()
    if mGuideEffectData and UICamera.hoveredObject == mGuideEffectData.tapRoot then
        OnTickFinish(false,true);
    end
end

function OnEffectLoad(effect)
    mGuideEffectData.effect = effect and effect.gameObject;
    if mGuideEffectData and not tolua.isnull(mGuideEffectData.effect) then
        if mGuideEffectData.effectActive then
            local effectTrans = mGuideEffectData.effect.transform;
            effectTrans.parent = mUIRoot;      
            effectTrans.position = mGuideEffectData.tapRoot.transform.position;
            effectTrans.localPosition = effectTrans.localPosition + mUIOff;
            effectTrans.localScale = Vector3.one;
            effectTrans.localEulerAngles = Vector3.zero;

            GameUtil.GameFunc.SetRendererSortOrder(mGuideEffectData.effect,mSortOrder + 1);
            GameUtil.GameFunc.SetUIParticleScale(mGuideEffectData.effect);

            mGuideEffectData.effect:SetActive(mGuideEffectData.effectState);
        else
            UnityEngine.GameObject.Destroy(mGuideEffectData.effect);
            mGuideEffectData.effect = nil;
        end
    end
end