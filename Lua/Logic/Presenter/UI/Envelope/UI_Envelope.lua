module("UI_Envelope", package.seeall)

local m_EnvelopeTrans;	--信封trans
local m_TweenScale_Envelope;
local HandObj; --开启手势动画

local m_LetterTrans;	--信纸trans
local m_TweenScale_Letter;
local m_TweenRotation_Letter;
local m_TweenPosition_Letter;
local m_TweenAlpha_Letter;
local m_isLetterFly = false;

--滑屏开启信封参数
local m_OpenEnvelopeTimer;  --信封开启Timer
local m_DesLetterTimer;  --信封销毁Timer
local DetroyEffectObj;

--信纸飞行参数
local m_IsCanOpenEnvelope = false;
local m_LetterFlySpeed = 2;
local m_LetterStartPos;
local m_LetterEndPos;
local m_LetterMiddlePos;
local m_Letter_DeltaTime = GameTime.deltaTime_L / 1000;

local letterTitle;
local writerName;
local letterText1;
local letterText2;
local letterText3;
local letterText4;
local letterText5;
local TextArray
function OnCreate(self)
	m_EnvelopeTrans = self:Find("Offset/EnvelopeRoot").transform;
	m_TweenScale_Envelope = m_EnvelopeTrans:Find("BtnOpen"):GetComponent("TweenScale");
	HandObj = m_EnvelopeTrans:Find("BtnOpen/Hand").gameObject;

	m_LetterTrans = self:Find("Offset/LetterRoot/Letter").transform;
	m_TweenScale_Letter = m_LetterTrans:GetComponent("TweenScale");
  	m_TweenRotation_Letter = m_LetterTrans:GetComponent("TweenRotation");
	m_TweenPosition_Letter = m_LetterTrans:GetComponent("TweenPosition");
	m_TweenAlpha_Letter = m_LetterTrans:GetComponent("TweenAlpha");

	letterTitle = m_LetterTrans:Find("letterTitle"):GetComponent("UILabel");
	writerName = m_LetterTrans:Find("writerName"):GetComponent("UILabel");
	letterTextRoot = m_LetterTrans:Find("letterTextRoot").transform;
	letterText1 = letterTextRoot:Find("letterText1"):GetComponent("UILabel");
	letterText2 = letterTextRoot:Find("letterText2"):GetComponent("UILabel");
	letterText3 = letterTextRoot:Find("letterText3"):GetComponent("UILabel");
	letterText4 = letterTextRoot:Find("letterText4"):GetComponent("UILabel");
	letterText5 = letterTextRoot:Find("letterText5"):GetComponent("UILabel");
	TextArray = {letterText1,letterText2,letterText3,letterText4,letterText5}
end

function OnEnable(self,actionData)
	local function ScaleFinished()
		m_LetterTrans.localScale = Vector3.New(0.28,0.28,0.28);
		HandObj:SetActive(true);

		--400400109闪光字
		local TextEffect = LoaderMgr.CreateEffectLoader();
		TextEffect:LoadObject(400400109);
		TextEffect:SetParent(m_EnvelopeTrans);
		TextEffect:SetLocalPosition(Vector3.New(19.5,-6.4,0));
		TextEffect:SetLocalRotation(UnityEngine.Quaternion.Euler(0,0,-15.861));
		TextEffect:SetSortOrder(rootSortorder);
		TextEffect:SetActive(true)

		--400400110蝴蝶
		local loder2 = LoaderMgr.CreateEffectLoader();
		loder2:LoadObject(400400110);
		loder2:SetParent(m_EnvelopeTrans);
		loder2:SetLocalPosition(Vector3.zero);
		loder2:SetSortOrder(rootSortorder);
		loder2:SetActive(true)

		--400400110消失特效
		DetroyEffectObj = LoaderMgr.CreateEffectLoader();
		DetroyEffectObj:LoadObject(400400111);
		DetroyEffectObj:SetParent(self:Find("Offset"));
		DetroyEffectObj:SetLocalPosition(Vector3.zero);
		DetroyEffectObj:SetSortOrder(rootSortorder);
		DetroyEffectObj:SetActive(false)
	end
	EventDelegate.Set(m_TweenScale_Envelope.onFinished, EventDelegate.Callback(ScaleFinished));
	m_TweenScale_Envelope.enabled = true;
	
	--读表id是策划配置，通过Action_UIOPT传过来的
	local ReadDataID = actionData.intParams[1];
	local datas = EnvelopeData.GetEnvelopeInfoByID(ReadDataID);
	--开始赋值
	letterTitle.text = datas.letterTitle;
	writerName.text = datas.writerName;
	local list = string.split(datas.letterText,'|');
	for i=1,#list do
		TextArray[i].text = list[i];
	end

	m_IsCanOpenEnvelope = true;
	m_OpenEnvelopeTimer = GameTimer.AddTimer(8,1,OpenEnvelope,nil);
	UpdateBeat:Add(OnUpdate, self)

	rootSortorder = self:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
end

function OnDisable(self)
	UpdateBeat:Remove(OnUpdate,self);
end

function OnDrag(delta,id)
	if m_IsCanOpenEnvelope and id == 1 and delta.x > 5 and delta.y > 1 then
		m_IsCanOpenEnvelope = false;
		OpenEnvelope();
		GameTimer.PauseTimer(m_OpenEnvelopeTimer,true)
	end
end

function OnClick(go, id)
	if id == 1 then
	end
end

function  OpenEnvelope()
	local function OnTweenFinish()
		m_EnvelopeTrans.gameObject:SetActive(false);
		m_isLetterFly = true;
		m_TweenRotation_Letter.enabled = true;
		m_TweenScale_Letter.enabled = true;
	end
	EventDelegate.Set(m_TweenPosition_Letter.onFinished, EventDelegate.Callback(OnTweenFinish));

	m_TweenPosition_Letter.enabled = true;

	m_LetterStartPos = m_LetterTrans.localPosition;
	m_LetterEndPos = Vector3.zero;
	m_LetterMiddlePos = Vector3.New(-44.88,0);

	--播放信封动画
	m_DesLetterTimer = GameTimer.AddTimer(5,1,DestroyLetter,nil);
end

function  DestroyLetter()
	m_TweenAlpha_Letter.enabled = true;
	DetroyEffectObj:SetActive(true);
	GameTimer.AddTimer(5,1,QuitEnvelope,nil);
end


--退出信封， 流程结束或点击跳过按钮时  
function  QuitEnvelope()
	UIMgr.UnShowUI(AllUI.UI_Envelope);
end

function Envelope_Stop_Fly()
	
end

function OnUpdate()
	--[[
	if m_isEnvelopeFly then
		if m_Envelope_DeltaTime <= 1 then
			if  0.2 < m_Envelope_DeltaTime and m_Envelope_DeltaTime < 0.8 then
				if not isLetterBtnOpen  then
					m_LetterBtnObj:SetActive(true)
					isLetterBtnOpen = true
				end
				m_Envelope_DeltaTime = m_Envelope_DeltaTime + GameTime.deltaTime_L / 1000 * m_FlySlowSpeed
			
			else 
				m_Envelope_DeltaTime = m_Envelope_DeltaTime + GameTime.deltaTime_L / 1000 * m_FlyFastSpeed
			end
			pos = math.BezierQuadratic(m_EnvelopeStartPos, m_EnvelopeMiddlePos, m_EnvelopeEndPos, m_Envelope_DeltaTime)
			m_EnvelopeTrans.localPosition = pos;
		
			if isLetterBtnOpen then --信封拾取倒计时开启
				m_UISprite_LetterBtn.fillAmount  = 1 - m_Envelope_DeltaTime
			end
		
		else
			--信封飞行结束，飞到终点或者中途被点击拾取
			m_IsCanOpenEnvelope = true;
				m_isEnvelopeFly = false;
				m_LetterBtnObj:SetActive(false);
				m_OpenEnvelopeTimer = GameTimer.AddTimer(5,1,OpenEnvelope,nil);
		end
	end
	--]]

	if m_isLetterFly then
		if m_Letter_DeltaTime <= 1 then
			m_Letter_DeltaTime = m_Letter_DeltaTime + GameTime.deltaTime_L / 1000 * m_LetterFlySpeed
			pos = math.BezierQuadratic(m_LetterStartPos, m_LetterMiddlePos, m_LetterEndPos, m_Letter_DeltaTime)
			m_LetterTrans.localPosition = pos
		else
			m_isletterfly = false;
		end

	end


end

