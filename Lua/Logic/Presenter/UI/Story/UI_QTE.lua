module("UI_QTE",package.seeall);

local TipObj=nil

local showTime = 5;
local lastTime = nil;
local localTime = nil;
local playing = false;
local shakeDuration =0.3
local shakeOffset = Vector3(1,1,1)
local shakeFreq = 30

--执行事件
local BeforeAction=nil
local AfterAction = nil
local SuccessAction=nil
local FailAction=nil

--点击模式相关控制
local Btn=nil;
local CountDownSprite=nil;
local CountDownBg=nil
local Icon=nil

--滑动模式相关控制
local Slider = nil
local SliderObj=nil
local SliderBack=nil
local SliderFront=nil
local SliderEnd=nil

--长按模式相关
local LongTap=nil
local LongTapObj = nil 
local LongTapFront =nil
local LongTapEnd = nil
local LongTapTime = 0
local LongTapNeedTime = 2

local PlayMode = 1;--1 按钮 2 滑动 3 长按
local Pressing = false
local data = nil

function OnCreate(self)	
    TipObj = self:Find("Offset/Tip").gameObject; 
    --btn
    Btn = self:Find("Offset/Tip/Btn").gameObject; 
    CountDownSprite = self:FindComponent("UISprite","Offset/Tip/Btn/CountDown"); 
    CountDownBg = self:FindComponent("UISprite","Offset/Tip/Btn/CountDownBg");
    Icon = self:FindComponent("UISprite","Offset/Tip/Btn/Icon");
    --slider
    SliderObj = self:Find("Offset/Tip/Slider").gameObject;
    Slider = self:FindComponent("UISlider","Offset/Tip/Slider"); 
    SliderBack = self:FindComponent("UISprite","Offset/Tip/Slider/Back"); 
    SliderFront = self:FindComponent("UISprite","Offset/Tip/Slider/Front");
    SliderEnd = self:FindComponent("UISprite","Offset/Tip/Slider/End");
    --longtap
    LongTapObj = self:Find("Offset/Tip/LongTap").gameObject;
    LongTap = self:FindComponent("UISlider","Offset/Tip/LongTap");
    LongTapFront = self:FindComponent("UISprite","Offset/Tip/LongTap/Front");
    LongTapEnd = self:FindComponent("UISprite","Offset/Tip/LongTap/End");
end

function OnEnable(self)
    UpdateBeat:Add(Update,self);
    if data then
        --设置模式
        SetMode(data.triggerType)
        --设置慢速
        SetTimeScale(data.Timescale/1000)
        --设置显示时间
        SetShowTime(data.CountDown/1000)
        --设置位置
        SetPosition(Vector3(data.tipX/1000,data.tipY/1000,0))
        --设置图标
        SetIcon(data.Icon)
        Begin()
    end
    
end

function OnDisable(self)
    UpdateBeat:Remove(Update,self);
end

--UI显示完毕
function OnShowOver()
    
end
--设置慢速
function  SetTimeScale(scale)
    UnityEngine.Time.timeScale = scale;
end
--设置显示时间

function SetShowTime(time)
    showTime = time
end

function SetData(indata)
    data = indata
end

--设置模式--1 按钮 2 滑动 3 长按
function SetMode(mode)
    PlayMode = mode
    if PlayMode==1 then
        SliderObj:SetActive(false);
        LongTapObj:SetActive(false);
    elseif PlayMode==2 then
        SliderObj:SetActive(true);
        LongTapObj:SetActive(false);
    elseif PlayMode==3 then
        SliderObj:SetActive(false);
        LongTapObj:SetActive(true);
    end
end

--设置图标
function SetIcon( name )
    Icon.spriteName = name
end
--设置图标为手指
function SetIconHand()--1-5 手 上下右左
    Icon.spriteName = "button_qte_01"
end
--设置图标为上箭头
function SetIconArrowUp()--1-5 手 上下右左
    Icon.spriteName = "button_qte_02"
end
--设置图标为下箭头
function SetIconArrowDown()--1-5 手 上下右左
    Icon.spriteName = "button_qte_03"
end
--设置图标为左箭头
function SetIconArrowLeft()--1-5 手 上下右左
    Icon.spriteName = "button_qte_05"
end
--设置图标为右箭头
function SetIconArrowRight()--1-5 手 上下右左
    Icon.spriteName = "button_qte_04"
end

--设置回调
function SetCallBack(before,success,fail,after)
    BeforeAction=before
    SuccessAction=success
    AfterAction=after
    FailAction = fail
end

--设置位置
function SetPosition(pos)
    TipObj.transform.localPosition = pos
end

--开始
function Begin()
    if BeforeAction then BeforeAction() end
    playing=true
    SetTimeScale(0.5)
    SetPosition(Vector3(0,20,20))
end
--结束
function End()
    SetTimeScale(1)
    playing=false
    Pressing=false
    localTime=nil
    PlayMode=1
    LongTapTime=0
    LongTap.value = 1
    LongTapFront.fillAmount = 1
    SliderBack.fillAmount = 1
    Slider.value=1
    if AfterAction then AfterAction() end
    GameLog.Log(" 结束了QTE")
    UIMgr.UnShowUI(AllUI.UI_QTE)
end

--更新显示
function UpdateView(overtime,deltaTime)
    -- 倒计时
    local normalizedTime = overtime/showTime
    CountDownSprite.fillAmount = normalizedTime
    if PlayMode==1 then
    elseif PlayMode==2 then
        SliderModeUpdate(normalizedTime,deltaTime)
    elseif PlayMode==3 then
        LongTapModeUpdate(normalizedTime,deltaTime)
    end
end

--滑动模式更新函数
function SliderModeUpdate(normalizedTime,deltaTime)
    SliderBack.fillAmount =  Slider.value
    GameLog.Log(" 滑动模式更新")
    if  Slider.value<=0 then
        if SuccessAction then SuccessAction() end
        End()
    end
end

--长按模式更新函数
function LongTapModeUpdate(normalizedTime,deltaTime)
    if Pressing then
        LongTapTime=LongTapTime+deltaTime
        local normalized = LongTapTime/LongTapNeedTime
        LongTap.value = 1-normalized
        LongTapFront.fillAmount = 1-normalized
        GameLog.Log(" 长按模式更新")
        if LongTap.value <= 0 then
            if SuccessAction then SuccessAction() end
            End()
        end
    end
end

function OnPress(pressed,id)
    if id == 0 then
        if pressed then
            Pressing = true--按住按钮
        else
            Pressing = false--抬起按钮
        end
    end
end

function OnClick(go,id)
	if id == 0 and PlayMode == 1 then
        GameLog.Log(" 点击了QTE")
        if SuccessAction then SuccessAction() end
        End()
	end
end

function Update()
    if playing then
        if localTime==nil then
            localTime=Time.realtimeSinceStartup
            lastTime=localTime
        end
        local nowTime=Time.realtimeSinceStartup
        local overtime =nowTime-localTime
        local deltaTime = nowTime-lastTime
        lastTime=nowTime
        GameLog.Log("overtime %f",overtime)
        UpdateView(overtime,deltaTime)
        if overtime>=showTime then
            if FailAction then FailAction() end
            End()
        end
    end
end
