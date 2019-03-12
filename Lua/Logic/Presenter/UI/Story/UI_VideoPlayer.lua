module("UI_VideoPlayer",package.seeall);
local mScreen = nil
local mSkip = nil
local mPlay = nil
local mPause = nil
--UITexture组件
local mTexture=nil
local mPanel=nil
--渲染图片对象
local mRenderTexture=nil
local mVideoPlayer = nil
--播放模式 默认是1 全屏点击跳过
--2 全屏点击 控制play pause 按钮的出现
local mPlayMode = 1
local mShowSate=true
local mUIFinished=nil
local mSortOrder=10

local tipShow=false
local SKIP_DEPTH = 699;
local askTip = false
local tipText = ""
local mTimeLabel=nil
local mSlider = nil
local mSkipBtn = nil
local delaySkip = 0
local mInit = false

function OnCreate(self)
    mScreen = self:Find("Offset/Screen").gameObject;
    mSkip = self:Find("Offset/TopRight/SkipPanel").gameObject;
    mPlay = self:Find("Offset/Bottom/Play").gameObject;
    mPause = self:Find("Offset/Bottom/Pause").gameObject;
	mTexture =  mScreen:GetComponent("UITexture");
    mPanel = self:Find("Offset").transform.parent.gameObject:GetComponent("UIPanel");
    mSlider = self:FindComponent("UISlider","Offset/TopRight/SkipPanel/Slider");
    mTimeLabel = self:FindComponent("UILabel","Offset/TopRight/SkipPanel/Time");
    mSkipBtn = self:Find("Offset/TopRight/SkipPanel/SkipBtn");
    mInit= true
end

function OnEnable(self)
    SetMode(mPlayMode)
    SetTimeLabelAndSlider(0,1)
    UpdateBeat:Add(Update, self);
    if mUIFinished then
        mUIFinished()
    end
    if mPlayMode == 3 and delaySkip>=0 then
		mSkipBtn.gameObject:SetActive(false)
        GameTimer.AddTimer(delaySkip/1000,1,ShowSkipBtn,nil)
    else
        mSkipBtn.gameObject:SetActive(true)
	end
end

function OnDisable(self)
    mPlayMode = 1
    if  tipShow==true then
        tipShow=false
        TipsMgr.TipConfirmOnClose()
    end
    delaySkip = 0
    UpdateBeat:Remove(Update,self);
end

function OnShowOver(self)
    
    if mUIFinished then
        mUIFinished()
    end
end

function ShowSkipBtn()
    
	mSkipBtn.gameObject:SetActive(true)
end

function SetUICompleted(UIFinished)
    mUIFinished=UIFinished
end

function Update()
    SetTimeLabelAndSlider(VideoMgr.RunningTime(),VideoMgr.Duration())
end

function SetTimeLabelAndSlider(runtime,duration)
    if runtime and duration then
        mSlider.value =1- runtime/duration
        local f = duration/60
        local f11 = f/10
        local f12 = f%10
        local s = duration%60
        local s11 = s/10
        local s12 = s%10
        local f1 = runtime/60
        local s1 = runtime%60
        local f21 = f1/10
        local f22 = f1%10
        local s21 = s1/10
        local s22 = s1%10
        mTimeLabel.text = string.format( "%d%d:%d%d/%d%d:%d%d",f21,f22,s21,s22,f11,f12,s11,s12)
    end
end

--设置模式
function SetMode(model)
    mPlayMode=model
    if mPlayMode == 1 then--全屏跳过
        mShowSate=true
        HideShow(false)
    elseif mPlayMode == 2 then--播放器模式
        mShowSate=false
        ClipScreen()
    elseif mPlayMode == 3 then--跳过按钮跳过
        if mPause then mPause:SetActive(false) end
        if mSkip then mSkip:SetActive(true) end
        if mPlay then mPlay:SetActive(false) end
    elseif mPlayMode == 4 then--全屏不可跳过
        if mPause then mPause:SetActive(false) end
        if mSkip then mSkip:SetActive(false) end
        if mPlay then mPlay:SetActive(false) end
    end
end

function HideShow(state)
    if mPause then  mPause:SetActive(false) end
    if mShowSate~=state then
        if mSkip then  mSkip:SetActive(state) end
        if mPlay then  mPlay:SetActive(state) end
        mShowSate=state
    end
end

function ClipScreen()
    if mPlayMode==2 then
        if mShowSate then
            HideShow(false)
            mShowSate=false
        else
            HideShow(true)
            mShowSate=true
            GameTimer.AddTimer(2,1,HideShow,nil,false)
        end
    end
end

--设置剧情跳过模式
function SetSkipShow(mskip,masktip,mtiptext,delay)
	if mskip==0 then
        SetMode(3)
    elseif mskip==1 then
       SetMode(4)
    end
	askTip = not(masktip==0)
    tipText = mtiptext
    delaySkip = delay and delay or 0
end


local function okFunc( ... )
	Skip();
end

function OnClick(go,id)
    --全屏跳过
    if mPlayMode==1 and mVideoPlayer then
        if id ==1 then
           Skip()
        end
    end
    if mPlayMode==2 and mVideoPlayer then
        if id ==2 then
            Skip()
        elseif id == 3 then
            Pause()
            mPlay:SetActive(true)
            mPause:SetActive(false)
        elseif id == 4 then
            Play()
            mPlay:SetActive(false)
            mPause:SetActive(true)
        end
        ClipScreen()
    end
    if id ==2 and mPlayMode==3 and mVideoPlayer then
        if askTip then
			tipShow=true
            TipsMgr.TipConfirmByStrWithOrder(tipText,okFunc,nil,SKIP_DEPTH,SKIP_DEPTH)
        else
			okFunc()
		end
    end
end

--设置UI的sortOrder
function SetSequenceOrder(sortOrder)
    mPanel.sortingOrder = sortOrder;
end

--设置渲染图片到texture组件
function SetRenderTexture(tex)
    if mTexture then
        mTexture.enabled = false
        mRenderTexture=tex
        if mTexture==nil then
            mTexture = mScreen:GetComponent("UITexture");
        end
        mTexture.mainTexture=mRenderTexture
        mTexture.enabled = true
    end
end

--empty显示
function CleanScreen()
    if mTexture then
        mTexture.mainTexture=nil
    end
end

function OnDestroy()
    mInit = false
end