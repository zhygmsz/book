module("UI_Tip_Revive",package.seeall);

local CountDownState = {
	Idel = 1,
	CountDown_ing = 2,
	Complete = 3,
}

local mCDMask;
local mCDLabel;
local mSituReviveCollider;

local mOffset;

local mCurrentState;
local mCDTime = 0;
local mDuration = 0;

local mDieFx;

local CD = 15000;

function OnCreate(self)
	mOffset = self:Find("Offset");

	mCDMask = self:FindComponent("UISprite","Offset/SituRevive/CDMask");
	mCDLabel = self:FindComponent("UILabel","Offset/SituRevive/CDMask/CDLabel");
	mSituReviveCollider = self:FindComponent("BoxCollider","Offset/SituRevive");

end

function OnEnable(self)
	ResetUI();
	UpdateBeat:Add(OnUpdate,self);
	mDieFx:Show();
end

function OnDisable(self)
	UpdateBeat:Remove(OnUpdate,self);
end

function OnUpdate(self)
	mCDTime = mCDTime - GameTime.deltaTime_L;
	mCDTime = mCDTime <= 0 and 0 or mCDTime;
	mCDMask.fillAmount = mCDTime / mDuration;
	mCDLabel.text = math.ceil(mCDTime / 1000);
	if mCDTime <= 0 then
		OnCdComplete();
	end
end

function ResetUI()
	mCurrentState = CountDownState.Idel;
	mDuration = CD;
	mCDTime = CD;
	mCDMask.fillAmount = 1;
	mSituReviveCollider.enabled = false;
	mCDMask.gameObject:SetActive(true);
	mDieFx:Hide();
end

function OnCdComplete()
	mCDMask.gameObject:SetActive(false);
	mSituReviveCollider.enabled = true;
end

function OnClick(go, id)
	if id == 1 then
		local msg = NetCS_pb.CSRevive();
		msg.type = NetCS_pb.REVIVETYPE_PLACE;
		GameNet.SendToGate(msg);
		UIMgr.UnShowUI(AllUI.UI_Tip_Revive);
	elseif id == 2 then
		local msg = NetCS_pb.CSRevive();
		msg.type = NetCS_pb.REVIVETYPE_BORNPOINT;
		GameNet.SendToGate(msg);
		UIMgr.UnShowUI(AllUI.UI_Tip_Revive);
	end
end






