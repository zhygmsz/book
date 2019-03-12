module("UI_Pet_AddPoint", package.seeall)

--组件
local mCom = {}

local mProPoints = {}

local addPointTimer = nil

local function OnPressChangePoint(index, isAdd)
    local speed = ConfigData.GetFloatValue("Pet_addpoint_speed")
    addPointTimer = GameTimer.AddForeverTimer(speed, function ()
        PetMgr.SetPoints(index, isAdd)
    end)
end

local function OnStopChangePoint()
    if addPointTimer then
        GameTimer.DeleteTimer(addPointTimer)
        addPointTimer = nil
    end
end

local function RefreshAttr(hp, mp, attr1, attr2, attr3, attr4)
    mCom.mHpValueTxt.text = hp
    mCom.mMpValueTxt.text = mp
    mCom.mOAValueTxt.text = attr1
    mCom.mIAValueTxt.text = attr2
    mCom.mODValueTxt.text = attr3
    mCom.mIDValueTxt.text = attr4
end

local function RefreshPoint(physique, strength, endurance, intelligence, remain)

    local addHp = strength * ConfigData.GetFloatValue("Pet_liliang_rate1") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate1") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate1") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate1")

    local addMp = strength * ConfigData.GetFloatValue("Pet_liliang_rate2") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate2") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate2") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate2")

    local addOA = strength * ConfigData.GetFloatValue("Pet_liliang_rate3") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate3") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate3") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate3")

    local addIA = strength * ConfigData.GetFloatValue("Pet_liliang_rate4") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate4") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate4") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate4")

    local addOD = strength * ConfigData.GetFloatValue("Pet_liliang_rate5") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate5") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate5") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate5")

    local addID = strength * ConfigData.GetFloatValue("Pet_liliang_rate6") + 
                  physique * ConfigData.GetFloatValue("Pet_tizhi_rate6") + 
                  endurance * ConfigData.GetFloatValue("Pet_naili_rate6") + 
                  intelligence * ConfigData.GetFloatValue("Pet_zhili_rate6")

    mCom.mHpAdd:SetActive(addHp > 0)
    mCom.mMPAdd:SetActive(addMp > 0)
    mCom.mOAAdd:SetActive(addOA > 0)
    mCom.mIAAdd:SetActive(addIA > 0)
    mCom.mODAdd:SetActive(addOD > 0)
    mCom.mIDAdd:SetActive(addID > 0)

    mCom.mHpAddValue.text = math.floor( addHp )
    mCom.mMPAddValue.text = math.floor( addMp )
    mCom.mOAAddValue.text = math.floor( addOA )
    mCom.mIAAddValue.text = math.floor( addIA )
    mCom.mODAddValue.text = math.floor( addOD )
    mCom.mIDAddValue.text = math.floor( addID )

    mCom.mAddPoint1.gameObject:SetActive(physique > 0)
    mCom.mAddPoint2.gameObject:SetActive(strength > 0)
    mCom.mAddPoint3.gameObject:SetActive(endurance > 0)
    mCom.mAddPoint4.gameObject:SetActive(intelligence > 0)

    mCom.mAddPoint1.text = physique
    mCom.mAddPoint2.text = strength
    mCom.mAddPoint3.text = endurance
    mCom.mAddPoint4.text = intelligence
    
    mCom.mUsebleNumTxt.text = remain
end

local function SetPetInfo()
    local currShowPetSlotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(currShowPetSlotId)
    local petData = PetData.GetPetDataById(petInfo.tempId)

    UIUtil.SetTexture(petData.face, mCom.mPetIcon)
    mCom.mPetName.text = petInfo.name
    mCom.mPetLevel.text = petInfo.level

    UIUtil.SetTexture(petData.face, mCom.mProPetIcon)
    mCom.mProPetName.text = petInfo.name
    mCom.mProPetLevel.text = petInfo.level

    mCom.mUsebleNumTxt.text = petInfo.pointUnalloc

    local maxHp, maxMp, attr1, attr2, attr3, attr4 = 0
    local attrList = PetMgr.GetAttrListBySlotId(currShowPetSlotId)
    for i, attr in ipairs(attrList) do
        if attr.key == PropertyInfo_pb.SP_HP_BASE then
            maxHp = attr.value
        elseif attr.key == PropertyInfo_pb.SP_MP_MAX_BASE then
            maxMp = attr.value
        elseif attr.key == PropertyInfo_pb.SP_PHYSIC_ATT_BASE then
            attr1 = attr.value
        elseif attr.key == PropertyInfo_pb.SP_MAGIC_ATT_BASE then
            attr2 = attr.value
        elseif attr.key == PropertyInfo_pb.SP_PHYSIC_DEF_BASE then
            attr3 = attr.value
        elseif attr.key == PropertyInfo_pb.SP_MAGIC_DEF_BASE then
            attr4 = attr.value
        end
    end

    RefreshAttr(maxHp, maxMp, attr1, attr2, attr3, attr4)

    mCom.mStrengthValue.text = petInfo.strength
    mCom.mPhysiqueValue.text = petInfo.physical
    mCom.mEndueanceValue.text = petInfo.stamina
    mCom.mIntelligenceValue.text = petInfo.intellect

    mCom.mHpAdd:SetActive(false)
    mCom.mMPAdd:SetActive(false)
    mCom.mOAAdd:SetActive(false)
    mCom.mIAAdd:SetActive(false)
    mCom.mODAdd:SetActive(false)
    mCom.mIDAdd:SetActive(false)

    mCom.mAddPoint1.gameObject:SetActive(false)
    mCom.mAddPoint2.gameObject:SetActive(false)
    mCom.mAddPoint3.gameObject:SetActive(false)
    mCom.mAddPoint4.gameObject:SetActive(false)

    PetMgr.ResetPoins()
end

local function InitProPointsPanel()
    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    mCom.mProStrengthValue.text = petInfo.addPoints[1]
    mCom.mProPhysiqueValue.text = petInfo.addPoints[2]
    mCom.mProEndueanceValue.text = petInfo.addPoints[3]
    mCom.mProIntelligenceValue.text = petInfo.addPoints[4]
    local total = 0
    for i = 1, 4 do
        total = total + petInfo.addPoints[i]
    end
    mCom.mTotalPoint.text = string.format( WordData.GetWordStringByKey("Pet_subshow1_info2"), ConfigData.GetIntValue("Pet_perLv_freequa") - total )

    for i, v in ipairs(petInfo.addPoints) do
        mProPoints[i] = v
    end
end

local function RefreshProPointsPanel(index ,isAdd)

    if isAdd then
        local total = 0
        for i = 1, 4 do
            total = total + mProPoints[i]
        end
        if total >= ConfigData.GetIntValue("Pet_perLv_freequa") then
            return 
        end
        mProPoints[index] = mProPoints[index] + 1
    else
        if mProPoints[index] <= 0 then
            return
        end
        mProPoints[index] = mProPoints[index] - 1
    end

    local he = 0
    for i = 1, 4 do
        he = he + mProPoints[i]
    end
    mCom.mProStrengthValue.text = mProPoints[1]
    mCom.mProPhysiqueValue.text = mProPoints[2]
    mCom.mProEndueanceValue.text = mProPoints[3]
    mCom.mProIntelligenceValue.text = mProPoints[4]
    local canUsePoint = ConfigData.GetIntValue("Pet_perLv_freequa") - he
    mCom.mTotalPoint.text = string.format( WordData.GetWordStringByKey("Pet_subshow1_info2"), canUsePoint )

end

local function OnOkBtn()
    PetMgr.RequestCSPetResetPoint()
end

local function OnCancelBtn()
    
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.POINT_CHANGED, RefreshPoint)
    GameEvent.Reg(EVT.PET, EVT.PET_ONUPDATEONEINFO, SetPetInfo)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.POINT_CHANGED, RefreshPoint)
    GameEvent.UnReg(EVT.PET, EVT.PET_ONUPDATEONEINFO, SetPetInfo)
end

function OnCreate(self)
    mCom.mTitleTxt = self:Find("Offset/Title/AddPointTxt"):GetComponent("UILabel")
    mCom.mUsebleNumTxt = self:Find("Offset/PointPanel/Num"):GetComponent("UILabel")

    mCom.mPetIcon = self:Find("Offset/PetIcon/Icon"):GetComponent("UITexture")
    mCom.mPetName = self:Find("Offset/PetIcon/PetName"):GetComponent("UILabel")
    mCom.mPetLevel = self:Find("Offset/PetIcon/PetLevel/Lv"):GetComponent("UILabel")
    mCom.mHpValueTxt = self:Find("Offset/Attr/HpName/HpValue"):GetComponent("UILabel")
    mCom.mMpValueTxt = self:Find("Offset/Attr/MpName/MpValue"):GetComponent("UILabel")
    mCom.mOAValueTxt = self:Find("Offset/Attr/OAName/Value"):GetComponent("UILabel")
    mCom.mIAValueTxt = self:Find("Offset/Attr/IAName/Value"):GetComponent("UILabel")
    mCom.mODValueTxt = self:Find("Offset/Attr/ODName/Value"):GetComponent("UILabel")
    mCom.mIDValueTxt = self:Find("Offset/Attr/IDName/Value"):GetComponent("UILabel")

    mCom.mStrengthValue = self:Find("Offset/PointPanel/Strength/Strength/Value"):GetComponent("UILabel")
    mCom.mPhysiqueValue = self:Find("Offset/PointPanel/Physique/Physique/Value"):GetComponent("UILabel")
    mCom.mEndueanceValue = self:Find("Offset/PointPanel/Endurance/Endurance/Value"):GetComponent("UILabel")
    mCom.mIntelligenceValue = self:Find("Offset/PointPanel/Intelligence/Intelligence/Value"):GetComponent("UILabel")

    --加点方案面板
    mCom.mAddPointProPanel = self:Find("Offset/ProgramPanel").gameObject
    mCom.mProStrengthValue = self:Find("Offset/ProgramPanel/Bg/Strength/Value"):GetComponent("UILabel")
    mCom.mProPhysiqueValue = self:Find("Offset/ProgramPanel/Bg/Physique/Value"):GetComponent("UILabel")
    mCom.mProEndueanceValue = self:Find("Offset/ProgramPanel/Bg/Endurance/Value"):GetComponent("UILabel")
    mCom.mProIntelligenceValue = self:Find("Offset/ProgramPanel/Bg/Intelligence/Value"):GetComponent("UILabel")
    mCom.mProPetIcon = self:Find("Offset/ProgramPanel/PetInfo/Icon"):GetComponent("UITexture")
    mCom.mProPetName = self:Find("Offset/ProgramPanel/PetInfo/Name"):GetComponent("UILabel")
    mCom.mProPetLevel = self:Find("Offset/ProgramPanel/PetInfo/Lv"):GetComponent("UILabel")
    mCom.mAddPointProTitle = self:Find("Offset/ProgramPanel/Title"):GetComponent("UILabel")
    mCom.mTotalPoint = self:Find("Offset/ProgramPanel/TotalPoint"):GetComponent("UILabel")

    --加点说明Tips
    mCom.mTipsNode = self:Find("Offset/Tips").gameObject
    mCom.mTipsTitle = self:Find("Offset/Title/AddPointTxt"):GetComponent("UILabel")
    mCom.mTipsAttr1 = self:Find("Offset/Tips/Attr1"):GetComponent("UILabel")
    mCom.mTipsAttr2 = self:Find("Offset/Tips/Attr2"):GetComponent("UILabel")
    mCom.mTipsAttr3 = self:Find("Offset/Tips/Attr3"):GetComponent("UILabel")
    mCom.mTipsAttr4 = self:Find("Offset/Tips/Attr4"):GetComponent("UILabel")

    mCom.mHpAdd = self:Find("Offset/Attr/HpName/Add").gameObject
    mCom.mMPAdd = self:Find("Offset/Attr/MpName/Add").gameObject
    mCom.mOAAdd = self:Find("Offset/Attr/OAName/Add").gameObject
    mCom.mIAAdd = self:Find("Offset/Attr/IAName/Add").gameObject
    mCom.mODAdd = self:Find("Offset/Attr/ODName/Add").gameObject
    mCom.mIDAdd = self:Find("Offset/Attr/IDName/Add").gameObject
    mCom.mHpAddValue = self:Find("Offset/Attr/HpName/Add/Value"):GetComponent("UILabel")
    mCom.mMPAddValue = self:Find("Offset/Attr/MpName/Add/Value"):GetComponent("UILabel")
    mCom.mOAAddValue = self:Find("Offset/Attr/OAName/Add/Value"):GetComponent("UILabel")
    mCom.mIAAddValue = self:Find("Offset/Attr/IAName/Add/Value"):GetComponent("UILabel")
    mCom.mODAddValue = self:Find("Offset/Attr/ODName/Add/Value"):GetComponent("UILabel")
    mCom.mIDAddValue = self:Find("Offset/Attr/IDName/Add/Value"):GetComponent("UILabel")

    mCom.mAddPoint1 = self:Find("Offset/PointPanel/Physique/Value"):GetComponent("UILabel")
    mCom.mAddPoint2 = self:Find("Offset/PointPanel/Strength/Value"):GetComponent("UILabel")
    mCom.mAddPoint3 = self:Find("Offset/PointPanel/Endurance/Value"):GetComponent("UILabel")
    mCom.mAddPoint4 = self:Find("Offset/PointPanel/Intelligence/Value"):GetComponent("UILabel")
end

function OnEnable(self)
    Reg()

    mCom.mTitleTxt.text = WordData.GetWordStringByKey("Pet_subshow1_title")
    mCom.mAddPointProTitle.text = WordData.GetWordStringByKey("Pet_subshow1_title")
    mCom.mTipsTitle.text = WordData.GetWordStringByKey("Pet_info_jiadian1")
    mCom.mTipsAttr1.text = WordData.GetWordStringByKey("Pet_info_jiadian2")
    mCom.mTipsAttr2.text = WordData.GetWordStringByKey("Pet_info_jiadian3")
    mCom.mTipsAttr3.text = WordData.GetWordStringByKey("Pet_info_jiadian4")
    mCom.mTipsAttr4.text = WordData.GetWordStringByKey("Pet_info_jiadian5")

    mCom.mTipsNode:SetActive(false)

    SetPetInfo()
end

function OnDisable()
    UnReg()
end

function OnDestory()
    
end

function OnClick(go, id)
    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)

    if id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Pet_AddPoint)
    elseif id == -2 then
        mCom.mAddPointProPanel:SetActive(false)
        --请求改变加点方案
        if petInfo.addPoints[1] ~= mProPoints[1] or petInfo.addPoints[2] ~= mProPoints[2] or petInfo.addPoints[3] ~= mProPoints[3] or petInfo.addPoints[4] ~= mProPoints[4] then
            PetMgr.RequestCSPetSetPointRule(mProPoints)
        end
    elseif id == -3 then --tips
        mCom.mTipsNode:SetActive(false)
    elseif id == 1 then --加点方案
        mCom.mAddPointProPanel:SetActive(true)
        InitProPointsPanel()
    elseif id == 2 then --tips
        mCom.mTipsNode:SetActive(true)
    elseif id == 3 then --重置加点
        local freeTime = ConfigData.GetIntValue("Pet_repoint_freetimes")
        if tonumber(petInfo.reAllocCount) > tonumber(freeTime) then
            local num1 = ConfigData.GetIntValue("Pet_repoint_cost1")
            local num2 = ConfigData.GetIntValue("Pet_repoint_increment")
            local max = ConfigData.GetIntValue("Pet_repoint_costmax")
            local cost = num1 + ( petInfo.reAllocCount - freeTime - 1 ) * num2
            if cost > max then
                cost = max
            end
            local str = string.format( WordData.GetWordStringByKey("Pet_repoint_proinfo2"), petInfo.reAllocCount, cost )
            TipsMgr.TipConfirmByStr(str, OnOkBtn, OnCancelBtn)
        else
            local str = string.format( WordData.GetWordStringByKey("Pet_repoint_proinfo1"), petInfo.reAllocCount )
            TipsMgr.TipConfirmByStr(str, OnOkBtn, OnCancelBtn)
        end
    elseif id == 4 then --确认加点
        --请求加点
        PetMgr.RequestCSPetAddPoint()
    elseif id == 5 then
        RefreshProPointsPanel(1, true)
    elseif id == 6 then
        RefreshProPointsPanel(1, false)
    elseif id == 7 then
        RefreshProPointsPanel(2, true)
    elseif id == 8 then
        RefreshProPointsPanel(2, false)
    elseif id == 9 then
        RefreshProPointsPanel(3, true)
    elseif id == 10 then
        RefreshProPointsPanel(3, false)
    elseif id == 11 then
        RefreshProPointsPanel(4, true)
    elseif id == 12 then
        RefreshProPointsPanel(4, false)
    elseif id == 21 then
        PetMgr.SetPoints(1, true)
    elseif id == 22 then
        PetMgr.SetPoints(1, false)
    elseif id == 23 then
        PetMgr.SetPoints(2, true)
    elseif id == 24 then
        PetMgr.SetPoints(2, false)
    elseif id == 25 then
        PetMgr.SetPoints(3, true)
    elseif id == 26 then
        PetMgr.SetPoints(3, false)
    elseif id == 27 then
        PetMgr.SetPoints(4, true)
    elseif id == 28 then
        PetMgr.SetPoints(4, false)
    end
end

function OnPress(press, id)
    if not press then
        OnStopChangePoint()
    end
end

function OnLongPress( id)
    if id == 21 then
        OnPressChangePoint(1, true)
    elseif id == 22 then
        OnPressChangePoint(1, false)
    elseif id == 23 then
        OnPressChangePoint(2, true)
    elseif id == 24 then
        OnPressChangePoint(2, false)
    elseif id == 25 then
        OnPressChangePoint(3, true)
    elseif id == 26 then
        OnPressChangePoint(3, false)
    elseif id == 27 then
        OnPressChangePoint(4, true)
    elseif id == 28 then
        OnPressChangePoint(4, false)
    end
end