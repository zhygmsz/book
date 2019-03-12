module("UI_Pet_Compose", package.seeall)

local mSkillList = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetSkillListWidget")

local PetListWiget = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetListWidget")

local mPetListWidget

local mBasePetEventId = 50
local mBaseSkillEventId = 60

local mBasePetOneSkillEventId = 60
local mBasePetTwoSkillEventId = 90
local mBasePetChooseSkillEventId = 110
local mBasePetPreSkillEventId = 140

local mPetOneSkillWidget
local mPetTwoSkillWidget
local mPetChooseSkillWidget
local mPetPreSkillWidget

local mSelectedSlotId = 0 --已经选泽过的宠物

local mCurrSlot = 0 --选择面板 当前展示的宠物

local mCurrPetIndex = 0 --面板index 面板一 面板二

local mPetOneSlot = 0
local mPetTwoSlot = 0

local mEffectLoader = nil --合成按钮特效
local mEffectLoader2 = nil

local mComs = 
{
    -- choosePanel = nil,
    -- perviewPanel = nil,
    -- petListTrs = nil,
    -- petOneIcon = nil,
    -- petTwoIcon = nil,
    -- petOnePanel = nil,
    -- petTwoPanel = nil,

    -- pAttackT = nil,
    -- mAttackT = nil,
    -- pDefT = nil,
    -- mDefT = nil,
    -- physicT = nil,
    -- growT = nil,
    -- pAttackS = nil,
    -- mAttackS = nil,
    -- pDefS = nil,
    -- mDefS = nil,
    -- physicS = nil,

    -- skilltTrs = nil,

    -- perIcon1 = nil,
    -- perIcon2 = nil,
    -- perName1 = nil,
    -- perName2 = nil,
    -- perProb1 = nil,
    -- perProb2 = nil,

    -- perLevel = nil,

    -- perPAtt = nil,
    -- perMAtt = nil,
    -- perpDef = nil,
    -- permDef = nil,
    -- perP = nil,
    -- perGrow = nil,

    -- perSkillTrs = nil,

    -- composeTipsNode = nil,
    -- composeTipsContent = nil,

    -- fxNode = nil,

}

local function OnSkillClick(data)
    GameEvent.Trigger(EVT.PET, EVT.PET_SHOWSKILLTIPS, data, false)
end

local function OnComposeSucceed(slot)

    local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_hechong_dianji_eff02.prefab")
    mEffectLoader2 = LoaderMgr.CreateEffectLoader()
    mEffectLoader2:LoadObject(resId)
    mEffectLoader2:SetParent(mComs.fxNode)
    mEffectLoader2:SetLocalPosition(Vector3.zero)
    mEffectLoader2:SetLocalScale(Vector3.one)
    mEffectLoader2:SetLocalRotation(UnityEngine.Quaternion.identity)
    mEffectLoader2:SetActive(true)
    mEffectLoader2:SetSortOrder(308)
    mEffectLoader2:SetLayer(CameraLayer.UI)

    local time = ConfigData.GetFloatValue("PetCompose_FxTime")
    local timer = nil

    local function callback()
        UIMgr.UnShowUI(AllUI.UI_Pet_Main)
        UIMgr.ShowUI(AllUI.UI_Pet_ComposeResult)

        local info = PetMgr.GetPetInfoBySlotId(slot)
        PetMgr.ShowTipsOnGetNewPet(info)

        if timer then
            GameTimer.DeleteTimer(timer)
            timer = nil
        end
    end

    timer = GameTimer.AddTimer(time, 1, callback)
end

--设置各种进度条
local function SetOnePetInfo(data)
    local petData = PetData.GetPetDataById(data.petId)
    local petInfoData = PetMgr.GetPetInfoBySlotId(data.slotId)
    if petInfoData == nil or petData == nil then
        return 
    end

    local oaMax, iaMax, odMax, idMax, ppMax = PetMgr.GetPetMaxTalent(petData)

    mComs.pAttackS.value = petInfoData.physicApt / oaMax
    mComs.pAttackT.text = math.floor( petInfoData.physicApt ) .."/".. oaMax

    mComs.mAttackS.value = petInfoData.magicApt / iaMax
    mComs.mAttackT.text = math.floor( petInfoData.magicApt )  .."/".. iaMax

    mComs.pDefS.value = petInfoData.physicDefApt / odMax
    mComs.pDefT.text = math.floor( petInfoData.physicDefApt ).."/".. odMax

    mComs.mDefS.value = petInfoData.magicDefApt / idMax
    mComs.mDefT.text = math.floor(petInfoData.magicDefApt)  .."/".. idMax

    mComs.physicS.value = petInfoData.hpApt / ppMax
    mComs.physicT.text = math.floor( petInfoData.hpApt )  .."/".. ppMax

    mComs.growT.text = string.format("%.3f", petInfoData.growth) 

    local skillDataList = PetMgr.GetPetSkillListByPetId(data.slotId, 8, 4)

    mPetChooseSkillWidget:Show(skillDataList)
end

local function SetPetInfo(trs, data, index)
    local iconNode = trs:Find("Bg/PetIcon").gameObject
    local icon = trs:Find("Bg/PetIcon/Icon"):GetComponent("UITexture")
    local isFight = trs:Find("Bg/PetIcon/IsFight").gameObject
    local target1 = trs:Find("Bg/PetIcon/Target1").gameObject
    local name = trs:Find("Bg/PetIcon/Name"):GetComponent("UILabel")
    local lv = trs:Find("Bg/PetIcon/Level"):GetComponent("UILabel")
    local addBtn = trs:Find("Bg/AddBtn").gameObject

    local pAttackT = trs:Find("Bg/AttrNode/Attr1/Value"):GetComponent("UILabel")
    local mAttackT = trs:Find("Bg/AttrNode/Attr2/Value"):GetComponent("UILabel")
    local pDefT = trs:Find("Bg/AttrNode/Attr3/Value"):GetComponent("UILabel")
    local mDefT = trs:Find("Bg/AttrNode/Attr4/Value"):GetComponent("UILabel")
    local physicT = trs:Find("Bg/AttrNode/Attr5/Value"):GetComponent("UILabel")
    local growT = trs:Find("Bg/AttrNode/Attr6/Value"):GetComponent("UILabel")

    local skillListTrs = trs:Find("Bg/SkillPanel")

    if data then
        iconNode:SetActive(true)
        local petData = PetData.GetPetDataById(data.tempId)

        UIUtil.SetTexture(petData.face, icon)
        isFight:SetActive(data.Current == 1)
        target1:SetActive(data.isPrecious == 1)
        name.text = data.name
        lv.text = data.level

    else
        iconNode:SetActive(false)
    end

    pAttackT.text = data and math.floor(data.physicApt) or 0
    mAttackT.text = data and math.floor(data.magicApt) or 0
    pDefT.text = data and math.floor(data.physicDefApt) or 0
    mDefT.text = data and math.floor(data.magicDefApt) or 0
    physicT.text = data and math.floor(data.hpApt) or 0
    growT.text = data and string.format("%.3f", data.growth) or 0

    mSelectedSlotId = data and data.slotId or 0 


    if index then
        if index == 1 then
            mPetOneSlot = data.slotId
            mPetOneSkillWidget = mSkillList.new(skillListTrs, mBasePetOneSkillEventId, OnSkillClick)
            local skillDataList = data and PetMgr.GetPetSkillListByPetId(data.slotId, 8, 4) or PetMgr.GetEmptySkillList(8)
            mPetOneSkillWidget:Show(skillDataList)
        elseif index == 2 then
            mPetTwoSlot = data.slotId
            mPetTwoSkillWidget = mSkillList.new(skillListTrs, mBasePetTwoSkillEventId, OnSkillClick)
            local skillDataList = data and PetMgr.GetPetSkillListByPetId(data.slotId, 8, 4) or PetMgr.GetEmptySkillList(8)
            mPetTwoSkillWidget:Show(skillDataList)
        end
    else
        local widget = mSkillList.new(skillListTrs, 0, OnSkillClick)
        local skillDataList = PetMgr.GetEmptySkillList(8)
        widget:Show(skillDataList)
    end

    if mPetOneSlot ~= 0 and mPetTwoSlot ~= 0 then
        local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_hechong_dianji_eff01.prefab")
        mEffectLoader = LoaderMgr.CreateEffectLoader()
        mEffectLoader:LoadObject(resId)
        mEffectLoader:SetParent(mComs.fxNode)
        mEffectLoader:SetLocalPosition(Vector3.zero)
        mEffectLoader:SetLocalScale(Vector3.one)
        mEffectLoader:SetLocalRotation(UnityEngine.Quaternion.identity)
        mEffectLoader:SetActive(true)
        mEffectLoader:SetSortOrder(308)
        mEffectLoader:SetLayer(CameraLayer.UI)
    end
end

local function SetChoosePanel()
    local petList = PetMgr.GetPetInfoList() --PetMgr.GetComposeList()

    local list = {}
    for i, v in ipairs(petList) do
        if v.slotId ~= mSelectedSlotId then
            local vo = {}
            vo.petId = v.tempId
            vo.level = v.level
            vo.slotId = v.slotId
            table.insert(list, vo)
        end
    end

    if next(list) == nil then
        TipsMgr.TipByKey("Pet_combo_nopet")
        return 
    end
    mComs.choosePanel:SetActive(true)

    mPetListWidget:Show(list, 1)
end

local function OnPetItemClick(data)
    mCurrSlot = data.slotId
    SetOnePetInfo(data)
end

--计算资质范围 参数为两个宠物资质的平均值
local function CalculateRange(number1, number2)
    local num = (number1 + number2) / 2
    local num1, num2 = 0
    local minRate = ConfigData.GetIntValue("Pet_compet_aptimink") 
    local maxRate = ConfigData.GetIntValue("Pet_compet_aptimaxk") 
    num1 = num * minRate
    num2 = num * maxRate

    return num1, num2
end

local function SetPreviewPanel()

    local info1 = PetMgr.GetPetInfoBySlotId(mPetOneSlot)
    local info2 = PetMgr.GetPetInfoBySlotId(mPetTwoSlot)

    if info1 == nil or info2 == nil then
        TipsMgr.TipByKey("Pet_lessTwo")
        return 
    end

    mComs.perviewPanel:SetActive(true)

    --气血
    local attr1, attr2 = CalculateRange(info1.hpApt, info2.hpApt)
    attr1 = attr1 < ConfigData.GetIntValue("Pet_compet_aptimin1") and ConfigData.GetIntValue("Pet_compet_aptimin1") or attr1
    attr2 = attr2 > ConfigData.GetIntValue("Pet_compet_aptimax1") and ConfigData.GetIntValue("Pet_compet_aptimax1") or attr2

    --外功
    local attr3, attr4 = CalculateRange(info1.physicApt, info2.physicApt)
    attr3 = attr3 < ConfigData.GetIntValue("Pet_compet_aptimin2") and ConfigData.GetIntValue("Pet_compet_aptimin2") or attr3
    attr4 = attr4 > ConfigData.GetIntValue("Pet_compet_aptimax2") and ConfigData.GetIntValue("Pet_compet_aptimax2") or attr4

    --内功
    local attr5, attr6 = CalculateRange(info1.magicApt, info2.magicApt)
    attr5 = attr5 < ConfigData.GetIntValue("Pet_compet_aptimin3") and ConfigData.GetIntValue("Pet_compet_aptimin3") or attr5
    attr6 = attr6 > ConfigData.GetIntValue("Pet_compet_aptimax3") and ConfigData.GetIntValue("Pet_compet_aptimax3") or attr6

    --外防
    local attr7, attr8 = CalculateRange(info1.physicDefApt, info2.physicDefApt)
    attr7 = attr7 < ConfigData.GetIntValue("Pet_compet_aptimin4") and ConfigData.GetIntValue("Pet_compet_aptimin4") or attr7
    attr8 = attr8 > ConfigData.GetIntValue("Pet_compet_aptimax4") and ConfigData.GetIntValue("Pet_compet_aptimax4") or attr8

    --内防
    local attr9, attr10 = CalculateRange(info1.magicDefApt, info2.magicDefApt)
    attr9 = attr9 < ConfigData.GetIntValue("Pet_compet_aptimin5") and ConfigData.GetIntValue("Pet_compet_aptimin5") or attr9
    attr10 = attr10 > ConfigData.GetIntValue("Pet_compet_aptimax5") and ConfigData.GetIntValue("Pet_compet_aptimax5") or attr10

     --成长
     local average = (info1.growth + info2.growth) * 0.5
     local attr11 = average * ConfigData.GetFloatValue("Pet_compet_ratemink")
     local attr12 = average * ConfigData.GetFloatValue("Pet_compet_ratemaxk")
     attr11 = attr11 < ConfigData.GetIntValue("Pet_compet_ratemin")  and ConfigData.GetIntValue("Pet_compet_ratemin")  or attr11
     attr12 = attr12 > ConfigData.GetIntValue("Pet_compet_ratemax")  and ConfigData.GetIntValue("Pet_compet_ratemax")  or attr12

     mComs.perP.text = math.floor( attr1 ) .."~"..math.floor( attr2 ) 
     mComs.perPAtt.text = math.floor( attr3 ) .."~"..math.floor( attr4 ) 
     mComs.perMAtt.text = math.floor( attr5 ) .."~"..math.floor( attr6 ) 
     mComs.perpDef.text = math.floor( attr7 ) .."~"..math.floor( attr8 )
     mComs.permDef.text = math.floor( attr9 ) .."~"..math.floor( attr10 ) 
     
     mComs.perGrow.text = string.format( "%.3f", attr11 ).."~"..string.format( "%.3f", attr12 )

     local data1 = PetData.GetPetDataById(info1.tempId)
     local data2 = PetData.GetPetDataById(info2.tempId)

     mComs.perName1.text = info1.name
     mComs.perName2.text = info2.name

     UIUtil.SetTexture(data1.face, mComs.perIcon1)
     UIUtil.SetTexture(data2.face, mComs.perIcon2)

    local skillData1 = PetData.GetPetSkillGroupDataByGroupId(data1.skillGroupID)
    local skillData2 = PetData.GetPetSkillGroupDataByGroupId(data2.skillGroupID)

    local skillAList = {}
    for i, v in ipairs(skillData1.mustSkills) do
        local vo = {}
        vo.tempSkillId = v
        local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
        if skillData.skillType ~= 4 then
            table.insert(skillAList, vo)
        end
    end

    for i, v in ipairs(info1.OwnSkills) do
        local isFind = false
        for _, skillId in ipairs(skillAList) do
            if tonumber(v.tempSkillId) == tonumber(skillId.tempSkillId) then
                isFind = true
            end
        end

        if not isFind then
            local vo = {}
            vo.tempSkillId = v.tempSkillId
            local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
            if skillData.skillType ~= 4 then
                table.insert(skillAList, vo)
            end
        end
    end

    for i, v in ipairs(info2.OwnSkills) do
        local isFind = false
        for _, skillId in ipairs(skillAList) do
            if tonumber(v.tempSkillId) == tonumber(skillId.tempSkillId) then
                isFind = true
            end
        end
        
        if not isFind then
            local vo = {}
            vo.tempSkillId = v.tempSkillId
            local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
            if skillData.skillType ~= 4 then
                table.insert(skillAList, vo)
            end
        end
    end

    local skillBList = {}
    for i, v in ipairs(skillData1.mustSkills) do
        local vo = {}
        vo.tempSkillId = v
        local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
        if skillData.skillType ~= 4 then
            table.insert(skillBList, vo)
        end
    end

    for i, v in ipairs(info1.OwnSkills) do
        local isFind = false
        for _, skillId in ipairs(skillBList) do
            if tonumber(v.tempSkillId) == tonumber(skillId.tempSkillId) then
                isFind = true
            end
        end

        if not isFind then
            local vo = {}
            vo.tempSkillId = v.tempSkillId
            local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
            if skillData.skillType ~= 4 then
                table.insert(skillBList, vo)
            end
        end
    end

    for i, v in ipairs(info2.OwnSkills) do
        local isFind = false
        for _, skillId in ipairs(skillBList) do
            if tonumber(v.tempSkillId) == tonumber(skillId.tempSkillId) then
                isFind = true
            end
        end
        
        if not isFind then
            local vo = {}
            vo.tempSkillId = v.tempSkillId
            local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
            if skillData.skillType ~= 4 then
                table.insert(skillBList, vo)
            end
        end
    end

    local skillList = #skillAList > #skillBList and skillAList or skillBList

    mPetPreSkillWidget:Show(skillList)

    if info1.level < info2.level then
        mComs.perLevel.text = info1.level.."~"..info2.level
    else
        mComs.perLevel.text = info2.level.."~"..info1.level
    end

end

local function RequestCompose()
    if mPetOneSlot == 0 or mPetTwoSlot == 0 then
        TipsMgr.TipByKey("Pet_lessTwo")
        return 
    end

    local level = UserData.GetLevel()
    if level < ConfigData.GetIntValue("Pet_compet_Lvlimit") then
        TipsMgr.TipByKey("Pet_compet_Lvinfo")
        return 
    end

    PetMgr.RequestCSComposePets(mPetOneSlot, mPetTwoSlot)
end

local function ShowTips()
    mComs.composeTipsNode:SetActive(true)
    mComs.composeTipsContent.text = WordData.GetWordStringByKey("Pet_Compose_Tips")
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.PET_COMPOSESUCCEED, OnComposeSucceed)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.PET_COMPOSESUCCEED, OnComposeSucceed)
end

function OnCreate(self)
    mComs.choosePanel = self:Find("Offset/ChoosePanel").gameObject
    mComs.perviewPanel = self:Find("Offset/PreviewPanel").gameObject
    mComs.petListTrs = self:Find("Offset/ChoosePanel/Offset/Left")

    mComs.petOneIcon = self:Find("Offset/PetOnePanel/Bg/PetIcon").gameObject
    mComs.petTwoIcon = self:Find("Offset/PetTwoPanel/Bg/PetIcon").gameObject

    mComs.petOnePanel = self:Find("Offset/PetOnePanel")
    mComs.petTwoPanel = self:Find("Offset/PetTwoPanel")

    mComs.pAttackT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr1/AttrValue"):GetComponent("UILabel")
    mComs.pAttackS = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr1"):GetComponent("UISlider")
    mComs.mAttackT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr2/AttrValue"):GetComponent("UILabel")
    mComs.mAttackS = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr2"):GetComponent("UISlider")
    mComs.pDefT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr3/AttrValue"):GetComponent("UILabel")
    mComs.pDefS = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr3"):GetComponent("UISlider")
    mComs.mDefT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr4/AttrValue"):GetComponent("UILabel")
    mComs.mDefS = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr4"):GetComponent("UISlider")
    mComs.physicT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr5/AttrValue"):GetComponent("UILabel")
    mComs.physicS = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr5"):GetComponent("UISlider")
    mComs.growT = self:Find("Offset/ChoosePanel/Offset/Right/AttrList/attr6/AttrValue"):GetComponent("UILabel")

    mComs.perPAtt = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/PAttack/AttrValue"):GetComponent("UILabel")
    mComs.perMAtt = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/MAttack/AttrValue"):GetComponent("UILabel")
    mComs.perpDef = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/PDef/AttrValue"):GetComponent("UILabel")
    mComs.permDef = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/MDef/AttrValue"):GetComponent("UILabel")
    mComs.perP = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/Phy/AttrValue"):GetComponent("UILabel")
    mComs.perGrow = self:Find("Offset/PreviewPanel/Offset/Right/AttrList/Grow/AttrValue"):GetComponent("UILabel")
    mComs.perName1 = self:Find("Offset/PreviewPanel/Offset/Left/Icon1/Name"):GetComponent("UILabel")
    mComs.perName2 = self:Find("Offset/PreviewPanel/Offset/Left/Icon2/Name"):GetComponent("UILabel")
    mComs.perIcon1 = self:Find("Offset/PreviewPanel/Offset/Left/Icon1/Icon"):GetComponent("UITexture")
    mComs.perIcon2 = self:Find("Offset/PreviewPanel/Offset/Left/Icon2/Icon"):GetComponent("UITexture")
    mComs.perLevel = self:Find("Offset/PreviewPanel/Offset/Left/Level/Value"):GetComponent("UILabel")
    mComs.composeTipsContent = self:Find("Offset/ComposeTips/Content"):GetComponent("UILabel")
    mComs.composeTipsNode = self:Find("Offset/ComposeTips").gameObject

    mComs.fxNode = self:Find("Offset/ComposeBtn")

    mComs.skilltTrs = self:Find("Offset/ChoosePanel/Offset/Right")

    mComs.perSkillTrs = self:Find("Offset/PreviewPanel/Offset/Right")

    mPetListWidget = PetListWiget.new(mComs.petListTrs, mBasePetEventId, OnPetItemClick)

    mPetPreSkillWidget = mSkillList.new(mComs.perSkillTrs, mBasePetPreSkillEventId, OnSkillClick)

    mPetChooseSkillWidget = mSkillList.new(mComs.skilltTrs, mBasePetChooseSkillEventId, OnSkillClick)
end

function OnEnable()
    Reg()

    mSelectedSlotId = 0

    mComs.choosePanel:SetActive(false)
    mComs.perviewPanel:SetActive(false)

    SetPetInfo(mComs.petOnePanel)
    SetPetInfo(mComs.petTwoPanel)

    mPetOneSlot = 0
    mPetTwoSlot = 0
end

function OnDisable()
    UnReg()

    mPetOneSlot = 0
    mPetTwoSlot = 0

    if mEffectLoader then
        LoaderMgr.DeleteLoader(mEffectLoader)
        mEffectLoader = nil
    end

    if mEffectLoader2 then
        LoaderMgr.DeleteLoader(mEffectLoader2)
        mEffectLoader2 = nil
    end
end

function OnDestory()
    
end

function OnClick(go, id)
    if id == 1 then --洗练
        UIMgr.UnShowUI(AllUI.UI_Pet_Compose)
        UIMgr.ShowUI(AllUI.UI_Pet_Affination)
    elseif id == -2 then
        mComs.choosePanel:SetActive(false)
    elseif id == -3 then
        mComs.perviewPanel:SetActive(false)
    elseif id == -4 then
        mComs.composeTipsNode:SetActive(false)
    elseif id == 3 then --学技能
        UIMgr.UnShowUI(AllUI.UI_Pet_Compose)
        UIMgr.ShowUI(AllUI.UI_Pet_Affination)
        GameEvent.Trigger(EVT.PET, EVT.PET_OPENSTUDYSKILL)
    elseif id == 4 then --tips
        ShowTips()
    elseif id == 5 then -- 合成
        RequestCompose()
    elseif id == 6 then --预览
        SetPreviewPanel()
    elseif id == 7 then --添加宠物1
        SetChoosePanel()
        mCurrPetIndex = 1
    elseif id == 8 then --添加宠物2
        mCurrPetIndex = 2
        SetChoosePanel()
    elseif id == 9 then --选择
        local data = PetMgr.GetPetInfoBySlotId(mCurrSlot)
        local info = PetMgr.GetPetInfoBySlotId(data.slotId)
        local petData = PetData.GetPetDataById(data.tempId)
        if data.Current == 1 then
            TipsMgr.TipByKey(WordData.GetWordStringByKey("Pet_compet_banjoin")) 
            return 
        end

        if petData.petType2 == 2 then
            TipsMgr.TipByKey(WordData.GetWordStringByKey("Pet_compet_banby")) 
            return 
        elseif petData.petType2 == 3 then
            TipsMgr.TipByKey(WordData.GetWordStringByKey("Pet_compet_banys")) 
            return 
        elseif petData.petType2 == 4 then
            TipsMgr.TipByKey(WordData.GetWordStringByKey("Pet_compet_banss")) 
            return 
        end

        if petData.bindType == 1 then
            TipsMgr.TipByKey(WordData.GetWordStringByKey("Pet_compet_banbinding")) 
            return 
        end

        mComs.choosePanel:SetActive(false)

        if mCurrPetIndex == 1 then
            SetPetInfo(mComs.petOnePanel, data, 1)
        else
            SetPetInfo(mComs.petTwoPanel, data, 2)
        end
    elseif id > mBasePetEventId and id < mBasePetOneSkillEventId then
        mPetListWidget:OnClick(id)
    elseif id > mBasePetOneSkillEventId and id < mBasePetTwoSkillEventId then
        mPetOneSkillWidget:OnClick(id)
    elseif id > mBasePetTwoSkillEventId and id < mBasePetChooseSkillEventId then
        mPetTwoSkillWidget:OnClick(id)
    elseif id > mBasePetChooseSkillEventId and id < mBasePetPreSkillEventId then
        mPetChooseSkillWidget:OnClick(id)
    elseif id > mBasePetPreSkillEventId then
        mPetPreSkillWidget:OnClick(id)
    end
end