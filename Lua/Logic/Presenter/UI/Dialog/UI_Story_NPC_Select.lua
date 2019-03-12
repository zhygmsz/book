module("UI_Story_NPC_Select", package.seeall)


--组件
local mSelf
local mOffset
local mUIPanel
local mPic
local mTextLabel
local mGrid

local mAniLoader

--变量
local mSelectItemList = {}
local mContentList = {}

local mDialogData

local mContentListLen = 0

local mResultList3 = 
{
	{0.2, 0.5, 0.3},
	{0.3, 0.3, 0.4},
	{0.1, 0.6, 0.3},
	{0.1, 0.2, 0.7}
}

local mResultList2 = 
{
	{0.2, 0.8},
	{0.5, 0.5},
	{0.4, 0.6},
	{0.7, 0.3},
}

--界面关闭传出去的数据
local mOutputData = {}

local mUIPanelSortingOrder

local mAniPos = Vector3(-810, -640, 0)
local mAniScale = Vector3(40, 40, 1)

local SelectItem = class("SelectItem")
function SelectItem:ctor(ui, path, idx)
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._slider = ui:FindComponent("UISlider", path)

	path = path .. "/"

	self._slider = ui:FindComponent("UISlider", path)
	self._des = ui:FindComponent("UILabel", path .. "LabelInfo")
	self._per = ui:FindComponent("UILabel", path .. "LabelNum")
	self._perGo = ui:FindGo(path .. "LabelNum")
	self._backGo = ui:FindGo(path .. "Background")

	self._box = ui:FindComponent("BoxCollider", path .. "widget")

	self._idx = idx
end

--[[
    @desc: 显示选项
]]
function SelectItem:Show(content)
	self._gameObject:SetActive(true)
	self._box.enabled = true

	self._backGo:SetActive(false)
	self._perGo:SetActive(false)

	self._des.text = content
end

--[[
    @desc: 显示统计结果
]]
function SelectItem:ShowResult(perNum)
	self._backGo:SetActive(true)
	self._perGo:SetActive(true)

	self._per.text = tostring(perNum * 100) .. "%"

	--显示出结果后，选项的点击作用禁止
	self._box.enabled = false

	self._slider.value = perNum
end

function SelectItem:Hide()
	self._gameObject:SetActive(false)
end

--[[
    @desc: 恢复进度，供下次使用
]]
function SelectItem:OnDisable()
	self._backGo:SetActive(true)
	self._slider.value = 1
end

--local方法

local function DoShowSelect(contentList)
	local firstEmptyIdx = 4
	for idx, content in ipairs(contentList) do
		if content ~= "" then
			mSelectItemList[idx]:Show(content)
		else
			firstEmptyIdx = idx
			break
		end
	end
	for idx = firstEmptyIdx, 3 do
		mSelectItemList[idx]:Hide()
	end

	mContentListLen = firstEmptyIdx - 1

	mGrid:Reposition()
end

local function ShowPic()
	local picResId = DialogMgr.GetPicResId(mDialogData.selectPic, mDialogData)
	--使用前先清理
	mAniLoader:Clear()
	mAniLoader:LoadObject(picResId)
	mAniLoader:SetParent(mOffset)
	mAniLoader:SetLocalPosition(mAniPos)
	mAniLoader:SetLocalScale(mAniScale)
	mAniLoader:SetSortOrder(mUIPanelSortingOrder + 1)
	mAniLoader:SetActive(true)
end

local function Show()
	mDialogData = mParamData.dialogDatas[1]
	if not mDialogData then
		return
	end

	--如果引入动态赋值三个文本，也只能记录该对话id的选择结果
	if mParamData.contentList then
		DoShowSelect(mParamData.contentList)
	else
		table.clear(mContentList)
		table.insert(mContentList, mDialogData.select1)
		table.insert(mContentList, mDialogData.select2)
		table.insert(mContentList, mDialogData.select3)

		DoShowSelect(mContentList)
	end

	if mDialogData.content[1] then
		mTextLabel.text = mDialogData.content[1].data
	else
		mTextLabel.text = ""
	end
	mTextLabel:Update()

	--显示pic
	ShowPic()
end

local function HandleOnEnable()
	HpNameMgr.HideHpNameUI()
	UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_Story_NPC_Select))
end

local function AllSelectItemOnDisable()
	for _, item in ipairs(mSelectItemList) do
		item:OnDisable()
	end
end

local function DoShowResult()
	mTextLabel.text = mDialogData.statText
	if mContentListLen == 3 then
		local idx = math.random(1, 4)
		local resultData = mResultList3[idx]
		mSelectItemList[1]:ShowResult(resultData[1])
		mSelectItemList[2]:ShowResult(resultData[2])
		mSelectItemList[3]:ShowResult(resultData[3])
	elseif mContentListLen == 2 then
		local idx = math.random(1, 4)
		local resultData = mResultList2[idx]
		mSelectItemList[1]:ShowResult(resultData[1])
		mSelectItemList[2]:ShowResult(resultData[2])
	elseif mContentListLen == 1 then
		mSelectItemList[1]:ShowResult(1)
	end
end

local function RegEvent(self)
end

local function UnRegEvent(self)
end

function OnCreate(self)
	mSelf = self
	mUIPanel = self:GetRoot():GetComponent("UIPanel")
	mUIPanelSortingOrder = mUIPanel.sortingOrder
	mOffset = self:Find("offset")
	mPic = self:FindComponent("UITexture", "offset/pic")
	mTextLabel = self:FindComponent("UILabel", "offset/Sprite_Bubble/LabelInfo")
	mGrid = self:FindComponent("UIGrid", "offset/Grid")

	for idx = 1, 3 do
		mSelectItemList[idx] = SelectItem.new(self, "offset/Grid/Slider" .. tostring(idx), idx)
	end

	mAniLoader = LoaderMgr.CreateEffectLoader()
end

function OnEnable(self)
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.SELECT, true)
	RegEvent(self)

	mOutputData.selectType = nil
	mOutputData.dialogType = Dialog_pb.DialogData.SELECT
	mOutputData.dialogID = mParamData.dialogDatas[1].id
	mOutputData.groupID = mParamData.dialogDatas[1].dialogID

	mOutputData.needSendEvent = false
	
	DialogMgr.SetOutputData(mOutputData)

	HandleOnEnable()
	
	Show()

	GameEvent.Trigger(EVT.STORY,EVT.DIALOG_ENTER,mOutputData)

	--下马
	GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_OFF)
end

function OnDisable(self)
	UIMgr.MaskUI(false)
	DialogMgr.CloseDialog()
	HpNameMgr.ShowHpNameUI()
	DialogMgr.SetDialogIsShowed(Dialog_pb.DialogData.SELECT, false)
	AllSelectItemOnDisable()
	UnRegEvent(self)

	--没有做出选择时，只触发结束摇杆控制事件
	if not mOutputData.needSendEvent then
		GameEvent.Trigger(EVT.STORY,EVT.DIALOG_FALSE_FINISH,mOutputData);
	end

	mAniLoader:Clear()
end

function OnClick(go, id)
	if id == -100 then
		--关闭界面，本次选择作废，不发送对话结束事件
		UIMgr.UnShowUI(AllUI.UI_Story_NPC_Select)
	elseif id == 1 then
		--讨论
	elseif 11 <= id and id <= 13 then
		mOutputData.selectType = id - 10
		mOutputData.needSendEvent = true
		if mDialogData.needStat == 1 then
			--点击选择后，弹出统计结果
			DoShowResult()
		else
			UIMgr.UnShowUI(AllUI.UI_Story_NPC_Select)
		end
	end
end

function SetData(data)
	mParamData = data
end

function OnDestroy(self)
	if mAniLoader then
		LoaderMgr.DeleteLoader(mAniLoader)
		mAniLoader = nil
	end
end