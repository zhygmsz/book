module("UI_Story_NPC_Painting", package.seeall)

--组件
local mSelf
local mOffset
local mUIPanel
local mModelTex  --模型
local mName
local mContent
local mFinishFlag
local mContentFinishCB
local mContentEffectCom
local mCountDownLbl
local mModelPic  --立绘

--变量
local mContentIdx = 0
local mComIsActive = false
local mIsAutoDelay = false
local AUTO_DELAY_TIME = 5
local mAutoDelayDelta = 0
local mCurAutoDelaySecond = 0
local mPreAutoDelaySecond = 0
local mIsClickToFinish = false
local mDialogDataForPic
local mEvents = {}
local mOutputData = {}

--模型显示相关
local mPlayerOrNpc
local BASE_POS = Vector3.New(1000, 1000, 1000)
local DEFAULT_SIZE = 1

--立绘相关
local mAniLoader

local mIsOpenBullet = false
local mBubbleID = 1014  --弹幕房间号

local mUIPanelSortingOrder

local mAniPos = Vector3(-681, -640, 0)
local mAniScale = Vector3(40, 40, 1)

--local方法
local function ResetAutoDelayData()
	mAutoDelayDelta = 0
	mCurAutoDelaySecond = 0
	mPreAutoDelaySecond = 0
end

local function ShowCountDown(curSec)
	--显示当前倒计时秒数
	--mCountDownLbl.gameObject:SetActive(true);
	--mCountDownLbl.text = tostring(curSec);
end

local function IsPic(dialogData)
	--不显示模型，只显示立绘
	return true
end

local function ShowPic(dialogData)
	local picResId = DialogMgr.GetPicResId(dialogData.modelPic, dialogData)
	--使用前先清理
	mAniLoader:Clear()
	mAniLoader:LoadObject(picResId)
	mAniLoader:SetParent(mOffset)
	mAniLoader:SetLocalPosition(mAniPos)
	mAniLoader:SetLocalScale(mAniScale)
	mAniLoader:SetSortOrder(mUIPanelSortingOrder + 1)
	mAniLoader:SetActive(true)

end

local function ShowModel(dialogData)
	--TODO 显示指定的模型
end

local function ShowPainting(dialogData)
	ShowPic(dialogData)
end

local function ShowName(dialogData)
	if dialogData.title == "1" then
		mName.text = UserData.GetName();
	else
		mName.text = dialogData.title
	end
end

local function SetFinishFlagVisible(isShow)
	--mFinishFlag:SetActive(isShow)
end

local function HideCountDown()
	--mCountDownLbl.gameObject:SetActive(false)
end

local function ShowNextContent()
	mContentIdx = mContentIdx + 1
	if mContentIdx <= #paramData.dialogDatas then
		local dialogData = paramData.dialogDatas[mContentIdx]
		ShowName(dialogData)
		ShowPainting(dialogData)
		mContent.text = DialogMgr.FormatContent(dialogData)
		--mContentEffectCom:ResetToBeginning()
		mComIsActive = false
		mIsAutoDelay = true
		SetFinishFlagVisible(true)
		HideCountDown()
	else
		--对话内容显示完
		mContentIdx = mContentIdx - 1
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_Painting)
	end
end

local function OnContentFinish()
	if mContentEffectCom.isActive or mIsClickToFinish then
		if mIsClickToFinish then
			mIsClickToFinish = false
		end
		mComIsActive = false
		mIsAutoDelay = true
		SetFinishFlagVisible(true)
		--是否立即显示倒计时，从0开始
		ShowCountDown(0)
	end
end

local function Update()
	if mIsAutoDelay then
		mAutoDelayDelta = mAutoDelayDelta + Time.deltaTime
		mCurAutoDelaySecond = math.floor(mAutoDelayDelta)
		if mCurAutoDelaySecond ~= mPreAutoDelaySecond then
			mPreAutoDelaySecond = mCurAutoDelaySecond
			if mCurAutoDelaySecond >= AUTO_DELAY_TIME then
				mIsAutoDelay = false
				ResetAutoDelayData()
				--下一句，并且控制变量重置，显示下一句前是否显示出倒计时5
				ShowCountDown(AUTO_DELAY_TIME)
				ShowNextContent()
			else
				ShowCountDown(mCurAutoDelaySecond)
			end
		else
			--没多出一秒，不处理
		end
	end
end

--重置数据
local function ResetData()
	mContentIdx = 0
	mComIsActive = false
	mIsAutoDelay = false
	mAutoDelayDelta = 0
	mCurAutoDelaySecond = 0
	mPreAutoDelaySecond = 0
	mIsClickToFinish = false
end

local function RegEvent(self)
	UpdateBeat:Add(Update)
end

local function UnRegEvent(self)
	UpdateBeat:Remove(Update)
end

function OnCreate(self)
	mSelf = self
	mUIPanel = self:GetRoot():GetComponent("UIPanel")
	mUIPanelSortingOrder = mUIPanel.sortingOrder
	mOffset = self:Find("Offset")
	mModelTex = self:FindComponent("UITexture", "Offset/Model")
	mModelTex.gameObject:SetActive(false)
	mName = self:FindComponent("UILabel", "Offset/Name")
	mContent = self:FindComponent("UILabel", "Offset/Content")
	mFinishFlag = self:FindGo("Offset/FinishFlag")
	mFinishFlag:SetActive(false)
	mCountDownLbl = self:FindComponent("UILabel", "Offset/CountDown")
	mCountDownLbl.gameObject:SetActive(false)
	
	mContentEffectCom = self:FindComponent("TypewriterEffect", "Offset/Content")
	mContentEffectCom.enabled = false
	mContentFinishCB = EventDelegate.Callback(OnContentFinish)
	EventDelegate.Set(mContentEffectCom.onFinished, mContentFinishCB)
	
	mModelPic = self:FindComponent("UITexture", "Offset/tex")
	mModelPic.gameObject:SetActive(false)

	--spineani被当做一个特效资源加载
	mAniLoader = LoaderMgr.CreateEffectLoader()
end

function OnEnable(self)
	RegEvent(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.MODEL, true)
	
	mOutputData.dialogType = Dialog_pb.DialogData.MODEL
	mOutputData.dialogID = paramData.dialogDatas[1].id
	mOutputData.groupID = paramData.dialogDatas[1].dialogID

	mOutputData.needSendEvent = false

	DialogMgr.SetOutputData(mOutputData)
	
	--UIMgr.ShowUI(AllUI.UI_Story_Mask)
	UIMgr.MaskUI(true, AllUI.GET_UI_DEPTH_BY_LAYER(1) - 1, AllUI.GET_UI_DEPTH(AllUI.UI_Story_NPC_Painting))
	DialogMgr.SetNpcLookAtMe(paramData)
	
	ShowNextContent()
	
	GameEvent.Trigger(EVT.STORY,EVT.DIALOG_ENTER,mOutputData)
	GameEvent.Trigger(EVT.STORY, EVT.BULLET_ENTER, mBubbleID)
	--下马
	GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_OFF)
end

function OnDisable(self)
	DialogMgr.ResetNpcLook(paramData)
	mOutputData.needSendEvent = true
	DialogMgr.CloseDialog()
	CameraRender.DeleteEntity(AllUI.UI_Story_NPC_Painting);
	
	ResetData()
	
	UIMgr.MaskUIByLayer(false)

	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.MODEL, false)
	UnRegEvent(self)
	--关闭弹幕
	GameEvent.Trigger(EVT.STORY, EVT.BULLET_FINISH, mBubbleID);

	mAniLoader:Clear()
end

function OnClick(go, id)
	if id == 0 then
		--点击屏幕
		if mComIsActive then
			mIsClickToFinish = true
			mContentEffectCom:Finish()
		elseif mIsAutoDelay then
			mIsAutoDelay = false
			ResetAutoDelayData()
			ShowNextContent()
		end
	end
end

function OnDestroy(self)
	if mAniLoader then
		LoaderMgr.DeleteLoader(mAniLoader)
		mAniLoader = nil
	end
end
