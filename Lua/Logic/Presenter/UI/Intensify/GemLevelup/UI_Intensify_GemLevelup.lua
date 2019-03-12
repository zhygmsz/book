module("UI_Intensify_GemLevelup", package.seeall)

local LeftWidget = require("Logic/Presenter/UI/Intensify/GemLevelup/Levelup_LeftWidget")
local RightWidget = require("Logic/Presenter/UI/Intensify/GemLevelup/Levelup_RightWidget")
local ClassifyWidget = require("Logic/Presenter/UI/Intensify/GemLevelup/Levelup_ClassifyLeftWidget")

local mLeftTrs
local mMaterialTrs

local mSelf
local mLeftWidget
local mLeftEventIdBase
local mRightEventIdBase 
local mGeneralPanel
local mClassifyPanel
local mClassifyWidget
local mRightWidget
local mNoMaterial
--------------宝石信息面板--------------
local mGemInfoIcon
local mGemInfoName
local mCurrLevel
local mNextLevel
local mProgressBar
local mFPro
local mLevelLimit
local mCurrAttr
local mNextAttr
local mProTxt

local mShowData

local mSelectToggle

local mGemInfoPanel
local mNoGem
local mNoGemPanel

local mShowState
local mIsClassify
local mCurrShowIndex
local mCurrShowOneIndex
local mCurrShowTwoIndex


local mEventIds = {}

--设置宝石信息面板
local function InitGemInfoPanel(data)

    if data == nil or data.itemData == nil then
        mGemInfoPanel:SetActive(false)
        mNoGemPanel:SetActive(true)
        return
    end

    mGemInfoPanel:SetActive(true)
    mNoGemPanel:SetActive(false)

    mShowData = data

    mFPro.gameObject:SetActive(false)
    mProgressBar.gameObject:SetActive(true)

    local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
    UIUtil.SetTexture(loadResID, mGemInfoIcon)
    mGemInfoName.text = data.itemData.name
    mCurrLevel.text = string.format(WordData.GetWordStringByKey("gem_maxlevel_for_inlay"), data.gemData.level)

    local attrName = AttDefineData.GetDefineData(data.gemData.gemProperties[1].id).name.." + "..  data.gemData.gemProperties[1].value
    mCurrAttr.text = attrName

    -- calculate level limit
    local playerLevel = UserData.GetLevel()
    local levelLimit = data.equipData.gemLevel
    mLevelLimit.text = string.format( WordData.GetWordStringByKey("gem_maxlevel_for_inlay"), levelLimit)
    mNextLevel.gameObject:SetActive(false)
    mNextAttr.gameObject:SetActive(false)

    local num = data.gemExp - data.gemData.exp
    local nextData = GemData.GetGemDataById(data.gemId + 1)
    if nextData then
        local num2 = nextData.exp - data.gemData.exp
        mProTxt.text = tostring(num).."/"..tostring(num2)
        mProgressBar.value = num / num2
    else
        --already the highest level
    end

end

local function GetIsHighestLevel()
    local dataList = GemLevelupMgr.GetGemDataListById(mShowData.itemData.id)
    for _, data in ipairs(dataList) do
        if data.exp > mShowData.gemData.exp then
            return false
        end
    end
    return true
end

local function GetNextData(currData)
    local dataList = GemLevelupMgr.GetGemDataListById(mShowData.itemData.id)

    for _, data in ipairs(dataList) do
        if data.exp > currData.exp then
            return data
        end
    end
    return nil
end

--On callbcak for click right panel     perview after level up
local function OnShowForecastInfo()
    if mShowData == nil then
        return
    end

    local isMostHigh = GetIsHighestLevel()
    if isMostHigh then
        GameLog.Log("已到达最高等级，不可在升级")
        return
    end

    local addExp = GemLevelupMgr.GetAddExp()

    if addExp > 0 then
        mNextLevel.gameObject:SetActive(true)
        mNextAttr.gameObject:SetActive(true)
        mFPro.gameObject:SetActive(true)
    else
        mFPro.gameObject:SetActive(false)
        mProgressBar.gameObject:SetActive(true)
    end

    local nextData = GetNextData(mShowData.gemData)
    
    if mShowData.gemExp + addExp >= nextData.exp then
        mProgressBar.gameObject:SetActive(false)
        local dataList = GemLevelupMgr.GetGemDataListById(mShowData.itemData.id)
        local fData = nil
        for _, data in pairs(dataList) do
            if mShowData.gemExp + addExp > data.exp or mShowData.gemExp + addExp == data.exp then
                fData = data
            end
        end

        local nData = GetNextData(fData)
        if nData ~= nil then
            local num1 = mShowData.gemExp + addExp - fData.exp
            local num2 = nData.exp - fData.exp
            mProTxt.text = tostring(num1).."/"..tostring(num2)
            mFPro.value = num1 / num2
        end

        mNextLevel.gameObject:GetComponent('UILabel').text = string.format( WordData.GetWordStringByKey("gem_maxlevel_for_inlay"), fData.level)
        local attrName = AttDefineData.GetDefineData(fData.gemProperties[1].id).name.." + "..  fData.gemProperties[1].value
        mNextAttr.gameObject:GetComponent('UILabel').text = attrName

    else
        local num1 = mShowData.gemExp + addExp - mShowData.gemData.exp 
        local num2 = nextData.exp - mShowData.gemData.exp
        mProTxt.text = tostring(num1).."/"..tostring(num2)
        mFPro.value = num1 / num2

        mNextLevel.gameObject:SetActive(false)
        local attrName = AttDefineData.GetDefineData(mShowData.gemData.gemProperties[1].id).name.." + "..  mShowData.gemData.gemProperties[1].value
        mNextAttr.gameObject:GetComponent('UILabel').text = attrName
    end
end

local function OnLevelup(data)
    local rightList = GemLevelupMgr.GetLevelupMaterialList(mShowData.itemData.childType)
    mRightWidget:Show(rightList)

    local opInfo = GemLevelupMgr.GetOprerateId()

    local realIdx = nil
    --同步数据contentwidget
    local dataList = GemLevelupMgr.GetInlaiedDataList()
    for idx, gemData in ipairs(dataList) do
        if gemData.bagType == opInfo.gemBagType and gemData.slotId == opInfo.gemSlotId and gemData.gemIndex == opInfo.gemIndex then
            gemData.gemData = GemData.GetGemDataById(data.tarGemId)
            gemData.itemData = ItemData.GetItemInfo(data.tarGemId)
            gemData.gemExp = data.tarGemExp

            realIdx = idx
            break
        end
    end

    if not mIsClassify then
        if realIdx then
            mLeftWidget:Show(dataList, realIdx)
        end
    end

    --重置newData，供下面代码使用
    local list = GemLevelupMgr.GetClassifyList()
    --同步数据tableandgrid
    local newOneIdx = nil
    local newTwoIdx = nil
    for oneIdx, v in ipairs(list) do
        for twoIdx, vv in ipairs(v.list) do
            if vv.bagType == opInfo.gemBagType and vv.slotId == opInfo.gemSlotId and vv.gemIndex == opInfo.gemIndex then
                vv.gemId = data.tarGemId
                vv.gemData = GemData.GetGemDataById(data.tarGemId)
                vv.itemData = ItemData.GetItemInfo(data.tarGemId)
                vv.gemExp = data.tarGemExp

                newOneIdx = oneIdx
                newTwoIdx = twoIdx
                break
            end
        end
    end

    if mIsClassify then
        if newOneIdx and newTwoIdx then
            mClassifyWidget:Show(list, newOneIdx, newTwoIdx)
        end
    end

    mFPro.gameObject:SetActive(false)
    mProgressBar.gameObject:SetActive(true)

    local itemData = ItemData.GetItemInfo(data.tarGemId)
    local gemData = GemData.GetGemDataById(data.tarGemId)

    mShowData.itemData = itemData
    mShowData.gemData = gemData
    mShowData.gemId = data.tarGemId
    mShowData.gemExp = data.tarGemExp

    InitGemInfoPanel(mShowData)
end

local function OnLeftClickCallback(data)

    mSelectToggle.value = false
    GemLevelupMgr.ReSetMaterialList()

    InitGemInfoPanel(data)

    local rightList = GemLevelupMgr.GetLevelupMaterialList(data.itemData.childType)
    mRightWidget:Show(rightList)
    mNoMaterial:SetActive(next(rightList) == nil)
end

local function SelectAll()
    mRightWidget:OnClickAllSelect(true)

    GemLevelupMgr.ReSetMaterialList()
    
    if mShowData == nil or mShowData.itemData == nil then
        return 
    end
    local dataList = GemLevelupMgr.GetLevelupMaterialList(mShowData.itemData.childType)
    for i, data in ipairs(dataList) do
        GemLevelupMgr.SetAddExp(data, true, i)
    end
end

local function CancelSelectAll()
    mRightWidget:OnClickAllSelect(false)

    if mShowData == nil or mShowData.itemData == nil then
        return 
    end

    local dataList = GemLevelupMgr.GetLevelupMaterialList(mShowData.itemData.childType)
    for i, data in ipairs(dataList) do
        GemLevelupMgr.SetAddExp(data, false, i)
    end
end

local function SelectToggleCallback()
    if mSelectToggle.value then
        SelectAll()
    else
        CancelSelectAll()
    end
end

local function OnCancelSelect()
    mNextAttr.gameObject:SetActive(false)
end

local function ReqLevelup()
    if mShowData == nil then
        TipsMgr.TipByKey("gem_no_material_selected")
        return 
    end
    GemLevelupMgr.SetOprerateId(mShowData.bagType, mShowData.slotId, mShowData.gemIndex)
    local materailList = GemLevelupMgr.GetMaterialList()
    local gemLevel, gemId = GemLevelupMgr.GetGemLevelByExp(mShowData.gemId, mShowData.gemExp + GemLevelupMgr.GetAddExp())
    local addExp = GemLevelupMgr.GetAddExp()
    if addExp <= 0 then
        TipsMgr.TipByKey("gem_no_material_selected")
        return
    end
    GemLevelupMgr.RequestCSGemCompose(mShowData.bagType, mShowData.slotId, mShowData.gemIndex, gemId, gemLevel, materailList)
end

local function ShowCommonView(index)
    mShowState:SetActive(false)
    mClassifyPanel:SetActive(false)
    mGeneralPanel:SetActive(true)

    GemLevelupMgr.SetOneIndex(index)
    mIsClassify = false

    local dataList = GemLevelupMgr.GetInlaiedDataList()
    local isNoGem = next(dataList) == nil
    mGemInfoPanel:SetActive(not isNoGem)
    mNoGemPanel:SetActive(isNoGem)
    mNoMaterial:SetActive(isNoGem)
    mNoGem:SetActive(isNoGem)

    mLeftWidget:Show(dataList, index)
end

local function ShowClassifyView(oneIndex, twoIndex)
    mShowState:SetActive(true)
    mClassifyPanel:SetActive(true)
    mGeneralPanel:SetActive(false)

    GemLevelupMgr.SetTwoIndex(oneIndex,twoIndex)
    mIsClassify = true

    local list = GemLevelupMgr.GetClassifyList()
    mClassifyWidget:Show(list, mCurrShowOneIndex, mCurrShowTwoIndex)

end

local function RegEvent()
    mEventIds[1] = MessageSub.Register(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_MATCHANGE, OnShowForecastInfo)
    mEventIds[2] = MessageSub.Register(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_LEVELUP, OnLevelup)
    mEventIds[3] = MessageSub.Register(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_CANCEL, OnCancelSelect)
end

local function UnRegEvent()
    MessageSub.UnRegister(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_MATCHANGE, mEventIds[1])
    MessageSub.UnRegister(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_LEVELUP, mEventIds[2])
    MessageSub.UnRegister(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_CANCEL, mEventIds[3])
    mEventIds = {}
end

function OnCreate(self)
    mSelf = self

    mLeftTrs = self:Find("Offset/leftPanel")
    mMaterialTrs = self:Find("Offset/materialPanel")
    mCurrLevel = self:Find("Offset/gemInfoPanel/currinfo/level"):GetComponent("UILabel")
    mLevelLimit = self:Find("Offset/gemInfoPanel/levelLimit/level"):GetComponent("UILabel")
    mCurrAttr = self:Find("Offset/gemInfoPanel/currAttr/Attr"):GetComponent("UILabel")
    mNextAttr = self:Find("Offset/gemInfoPanel/nextAttr/Attr"):GetComponent("UILabel")
    mProgressBar = self:Find("Offset/gemInfoPanel/currinfo/progress"):GetComponent("UISlider")
    mFPro = self:Find("Offset/gemInfoPanel/currinfo/forecastprogress"):GetComponent('UISlider')

    mGeneralPanel = self:Find("Offset/leftPanel/widget").gameObject
    mClassifyPanel = self:Find("Offset/leftPanel/classifyWidget").gameObject

    mGemInfoPanel = self:Find("Offset/gemInfoPanel").gameObject

    mNoMaterial = self:Find("Offset/materialPanel/NoMaterial").gameObject
    mNoGem = self:Find("Offset/leftPanel/NoGem").gameObject
    mNoGemPanel = self:Find("Offset/noGemPanel").gameObject

    mGemInfoIcon = self:Find("Offset/gemInfoPanel/icon/icon"):GetComponent('UITexture')
    mGemInfoName = self:Find("Offset/gemInfoPanel/name"):GetComponent('UILabel')
    mNextLevel = self:Find("Offset/gemInfoPanel/currinfo/forecastLevel")
    mProTxt = self:Find("Offset/gemInfoPanel/currinfo/proTxt"):GetComponent("UILabel")

    mShowState = self:Find("Offset/leftPanel/Title/StateBtn/Target").gameObject

    mLeftEventIdBase = 20
    mRightEventIdBase = 60
    
    mSelectToggle = self:FindComponent("UIToggle", "Offset/materialPanel/toggle")
    EventDelegate.Add(mSelectToggle.onChange, EventDelegate.Callback( SelectToggleCallback ))

    mLeftWidget = LeftWidget.new(mLeftTrs, mLeftEventIdBase, OnLeftClickCallback, mSelf)

    mClassifyWidget = ClassifyWidget.new(mClassifyPanel.transform, self, OnLeftClickCallback)

    mRightWidget = RightWidget.new(mMaterialTrs, mRightEventIdBase, OnRightcallBack, mSelf)
end

function OnEnable()
    RegEvent()

    ShowCommonView(1)

    local list = GemLevelupMgr.GetClassifyList()
    mClassifyWidget:Show(list)

    mClassifyPanel:SetActive(false)

    local dataList = GemLevelupMgr.GetInlaiedDataList()
    if next(dataList) == nil then
        local rightList = {}
        mRightWidget:Show(rightList)
        mNoMaterial:SetActive(true)
    end
end

function OnDisable()
    UnRegEvent()
end

function OnDestory()
    
end

function OnClick(go, id)
    if id == 1 then --升级
        ReqLevelup()
    elseif id == 2 then --便捷升级
       
    elseif id == 3 then --切换视图
        if mIsClassify then
            local index = GemLevelupMgr.GetOneIndex(mCurrShowOneIndex, mCurrShowTwoIndex)
            ShowCommonView(index)
        else
            local oneIndex, twoIndex = GemLevelupMgr.GetTwoIndex(mCurrShowIndex)
            ShowClassifyView(oneIndex, twoIndex)
        end
    elseif  mLeftEventIdBase <= id  and  id < mRightEventIdBase then
        mLeftWidget:OnClick(id)
    elseif id >= mRightEventIdBase then
        mRightWidget:OnClick(id)
    elseif id == -100 then
        UIMgr.UnShowUI(AllUI.UI_Intensify_GemLevelup)
    end
end