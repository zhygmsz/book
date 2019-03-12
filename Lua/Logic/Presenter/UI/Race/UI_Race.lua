module("UI_Race", package.seeall)

local RaceController = require("Logic/System/Race/RaceController")
local RacePlayer = require("Logic/System/Race/RacePlayer")
--场景中UI物体
local mTimerLabel
local mCountDownLabel
local mSkillButton
local mBg
local mBegainLine
local mSkillBtn
local mItemIcon
local mPlayerNode

local mSelf
local itemIndex = 1

local mEvents = {} 

local mPlayerInfo = 
{
	progressbars = {},
	tracks = {},
	labels = {},
	dialogs = {},
	models = {}
}

local isBegein = false

local COUNT_DOWN_TIME = 3 --游戏开始倒计时总时间
local ticker = 0 

local rideController = nil

--local itemIconObj = {}

local function CreateItemIcon(iconName, pos, index)
	local go = mSelf:DuplicateAndAdd(mItemIcon, mPlayerNode.transform, itemIndex)
	itemIndex = itemIndex + 1
	go.transform.localPosition = pos
	go.transform.localScale = Vector3.one
	go.gameObject:SetActive(true)

	go.gameObject:GetComponent('UISprite').spriteName = iconName
	go.gameObject:GetComponent('UISprite'):MakePixelPerfect()

	-- if itemIconObj[index] == nil then
	-- 	itemIconObj[index] = {}
	-- end
	-- table.insert(itemIconObj[index], go)
	if RaceController._iconList[index] == nil then
		RaceController._iconList[index] = {}
	end
	table.insert(RaceController._iconList[index], go)
end

local function AddListener()
	GameEvent.Reg(EVT.RACE, EVT.RACE_CREATEICON, CreateItemIcon)
end

local function RemoveListener()
	GameEvent.UnReg(EVT.RACE, EVT.RACE_CREATEICON, CreateItemIcon)
end

--3 2 1 倒计时
local function RefreshCutDown()
	ticker = ticker + 1
	if ticker <= 3 then
		mCountDownLabel.text = tostring(COUNT_DOWN_TIME - ticker)
	else
		rideController:Start()
		mCountDownLabel.gameObject:SetActive(false)
		isBegein = true
		mBegainLine.gameObject:SetActive(false)
	end
end

--显示游戏时间 
local function OnRefreshTimer(raceTime)
	local second = raceTime % 60
	local minutes = math.floor(raceTime / 60) % 60
	mTimerLabel.text = string.format("%02d:%02d", minutes, second)
end

local function InitGame()
	GameTimer.AddTimer( 1, 4, RefreshCutDown )
	rideController = RaceController.new(OnRefreshTimer)
end

local function UseSkill()
	local player = rideController:GetMainPlayer()

	if not player:UseSkill() then 
        TipsMgr.TipByFormat("被眩晕后无法使用技能")
	end
	
	if not player:HasSkill() then
		mSkillButton.gameObject:SetActive(false)
	end
end

local function Jump()
	local player = rideController:GetMainPlayer()
    if not player:Jump() then 
        TipsMgr.TipByFormat("您的操作过于频繁，请爱护动物")
    end
end

local function OnGameTick(state, param)
    if state == RaceController.STATE_OVER then
        OnGameOver(param)
    elseif state == RaceController.STATE_TICK then
        OnRefreshTimer(param) 
    end
end

 --加载模型
local function LoadModel(name, parent)
	local modelLoader = LoaderMgr.CreateModelLoader()
    local modelId = ResConfigData.GetResConfigID(name)
    modelLoader:LoadObject(modelId)
    modelLoader:SetLayer(CameraLayer.UILayer)
    modelLoader:SetActive(true)
    modelLoader:SetParent(parent.transform)
    modelLoader:SetLocalPosition(Vector3.zero)
    modelLoader:SetLocalRotation(Quaternion.identity)
    modelLoader:SetLocalScale(Vector3(80, 80, 80))
end

function OnCreate(ui)
	mSelf = ui
    mTimerLabel = ui:FindComponent("UILabel","Top/ProgressBar/Time/TimeTxt")   
    mCountDownLabel = ui:FindComponent("UILabel","CountDownLabel")   
    mSkillButton = ui:Find("SkillBtn").gameObject
    mBg = ui:Find("Anchor/BG/Sprite")
	mBegainLine = ui:Find("StartLine")
	mItemIcon = ui:Find("PlayerNode/ItemIcon")
	mItemIcon.gameObject:SetActive(false)
	mPlayerNode = ui:Find("PlayerNode")

    for i = 1, 3 do 
        mPlayerInfo.progressbars[i] =  ui:FindComponent("UIProgressBar","Top/ProgressBar"..tostring(i))   
        mPlayerInfo.labels[i] =  ui:FindComponent("UILabel","InfoLabel"..tostring(i).."/Label")   
		mPlayerInfo.dialogs[i] =  ui:FindComponent("UILabel","InfoLabel"..tostring(i).."/Sprite/Label")
		mPlayerInfo.dialogs[i].gameObject:SetActive(false)
        mPlayerInfo.models[i] = ui:Find("PlayerNode/Player"..tostring(i)).gameObject 
        LoadModel("ZYzuoqi_Mengchong",  mPlayerInfo.models[i])

        local player = RacePlayer.new( mPlayerInfo.models[i])
        RaceController:AddPlayer(player, i, i == 3)
    end
end

function OnUpdate()
	if not isBegein then
		return
	end

	local bg = mBg:GetComponent('UITexture')
	local mainPlayer = RaceController:GetMainPlayer()

	if mainPlayer._slowTimer > 0 then
		bg.width = bg.width + 1
		RacePlayer.bgSpeed = 1
	elseif mainPlayer._speedUpTimer > 0 then
		bg.width = bg.width + 4
		RacePlayer.bgSpeed = 4
	else
		bg.width = bg.width + 2
		RacePlayer.bgSpeed = 2
	end
end

function OnEnable()
	mTimerLabel.text = "00:00"
	mCountDownLabel.gameObject:SetActive(true)
	mSkillButton:SetActive(false)

	InitGame()

    UpdateBeat:Add(OnUpdate)

    AddListener()
end

function OnDisable(self)

	if rideController then
		rideController:Stop()
	end

	UpdateBeat:Remove(OnUpdate)

	RemoveListener()
end

function OnClick(go, id)
	if id == 400 then
		UIMgr.UnShowUI(AllUI.UI_Race)
	elseif id == 1 then --放技能
		UseSkill()
	elseif id == 2 then --跳跃
		Jump()
	end
end 