module("UI_Pet_Affination", package.seeall)

local mToggleItemGroup

local PetListWiget = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetListWidget")
local mPetListWidget

local PetSkillListWidget = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetSkillListWidget")
local mPetSkillListWidget
local mStudySkillWidget

local mIsEnough = false

local mSelf

local mItemList = nil -- 技能书

local mItemSlot = 0

local mMaterailFx = nil--洗练成功 洗练材料播的特效

local aimSkillId = 0

local mComponents = {} --组件table

local mResetPanel
local mMergePanel
local mLearnSkillPanel

local mPetListBaseEventId = 50
local mPetSKillListBaseEventId = 80
local mStudySkillBaseEventId = 120

local mShowData

local mConsumId -- 洗练道具id

local mTargetBtnInfo = 
{
    { eventId = 1, content = WordData.GetWordStringByKey("Pet_combo_info11") },
    { eventId = 2, content = WordData.GetWordStringByKey("Pet_combo_info1") },
    { eventId = 3, content = WordData.GetWordStringByKey("Pet_combo_info12") },
}

local mTargetBtn = 
{
    [mTargetBtnInfo[1].eventId] = AllUI.UI_Pet_Affination,
    [mTargetBtnInfo[2].eventId] = AllUI.UI_Pet_Compose,
    [mTargetBtnInfo[3].eventId] = nil,
}

local mPetEntityAttr = 
{
    name = nil, 
    position = Vector3.zero, 
    forward = Quaternion.identity,  
    petData = nil,
    modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER,
    physiqueID = nil, 
}

local function SetPetModel(data)
    local petData = PetData.GetPetDataById(data.petId)
    if petData == nil then
        return 
    end
    mShowData = data

    mPetEntityAttr.name = petData.name;
    mPetEntityAttr.petData = petData;
    mPetEntityAttr.physiqueID = petData.modelID;
    
    CameraRender.RenderEntity(AllUI.UI_Pet_Main, mComponents.rt, mPetEntityAttr, 1)

    CameraRender.PlayAnim(AllUI.UI_Pet_Main, 1, "Stand")

    PetMgr.SetCurrShowPetSlotId(data.slotId)
end

local function SetPetInfo(data)
    local petData = PetData.GetPetDataById(data.petId)
    if petData == nil then
        return 
    end

    if petData.petType2 == 1 then
       mComponents.target.spriteName = ConfigData.GetStringValue("Pet_Type2_bbicon")
    elseif petData.petType2 == 2 then
        mComponents.target.spriteName = ConfigData.GetStringValue("Pet_Type2_byicon")
    elseif petData.petType2 == 3 then
        mComponents.target.spriteName = ConfigData.GetStringValue("Pet_Type2_ysicon")
    elseif petData.petType2 == 4 then
        mComponents.target.spriteName = ConfigData.GetStringValue("Pet_Type2_ssicon")
    end

    local infoData = PetMgr.GetPetInfoBySlotId(data.slotId)

    if infoData then
        mComponents.fightValue.text = infoData.power
        local currExp = infoData.exp
        local level = infoData.level
        mComponents.levelValue.text = string.format( WordData.GetWordStringByKey("gem_maxlevel_for_inlay"), level )
        local currExpData = PetData.GetPetExpDataByLevel(level)
        local nextExpData = PetData.GetPetExpDataByLevel(level + 1)
        if nextExpData then
            mComponents.levelBar.value = (currExp - currExpData.exp) / (nextExpData.exp - currExpData.exp)
            mComponents.expValue.text = tostring(currExp - currExpData.exp) .."/".. tostring(nextExpData.exp - currExpData.exp)
        end
    end
end

--设置各种进度条
local function SetTalentAttrPanel(data)
    local petData = PetData.GetPetDataById(data.petId)
    local petInfoData = PetMgr.GetPetInfoBySlotId(data.slotId)
    if petInfoData == nil or petData == nil then
        return 
    end

    local oaMax, iaMax, odMax, idMax, ppMax = PetMgr.GetPetMaxTalent(petData)

    mComponents.outAckBar.value = petInfoData.physicApt / oaMax
    mComponents.outAckValue.text = math.floor( petInfoData.physicApt ) .."/".. oaMax

    mComponents.insideAckBar.value = petInfoData.magicApt / iaMax
    mComponents.insideAckValue.text = math.floor( petInfoData.magicApt )  .."/".. iaMax

    mComponents.outDefBar.value = petInfoData.physicDefApt / odMax
    mComponents.outDefValue.text = math.floor( petInfoData.physicDefApt ).."/".. odMax

    mComponents.insideDefBar.value = petInfoData.magicDefApt / idMax
    mComponents.insideDefValue.text = math.floor(petInfoData.magicDefApt)  .."/".. idMax

    mComponents.powerBar.value = petInfoData.hpApt / ppMax
    mComponents.powerValue.text = math.floor( petInfoData.hpApt )  .."/".. ppMax

    mComponents.growthValue.text = string.format( "%.3f", petInfoData.growth )
end

local function GetSaftyNum(affinationID)
    local affinationData = PetData.GetPetAffinationData(affinationID)

    if affinationData == nil then
        return  0
    end

    local maxCount = 0

    if affinationData.baseType == 1 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type1")
    elseif affinationData.baseType == 2 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type2")
    elseif affinationData.baseType == 3 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type3")
    elseif affinationData.baseType == 4 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type4")
    elseif affinationData.baseType == 5 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type5")
    elseif affinationData.baseType == 6 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type6")
    elseif affinationData.baseType == 7 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type7")
    elseif affinationData.baseType == 8 then
        maxCount = ConfigData.GetIntValue("Pet_reset_type8")
    end

    return maxCount
end


local function SetMaterialInfo(data)
    local petData = PetData.GetPetDataById(data.petId)
    if petData.petType1 == 3 then
        mComponents.canNotTips.text = WordData.GetWordStringByKey("Pet_reset_banss")
    end

    if petData.bindType == 1 then
        mComponents.canNotTips.text = WordData.GetWordStringByKey("Pet_reset_banbd")
    end
    
    if petData.affinationID == nil then
        mComponents.materialNode:SetActive(false)
        mComponents.canNotAffination:SetActive(true)
        return 
    end
    local affinationData = PetData.GetPetAffinationData(petData.affinationID)
    if affinationData == nil then
        mComponents.materialNode:SetActive(false)
        mComponents.canNotAffination:SetActive(true)
        return 
    end
    mComponents.materialNode:SetActive(true)
    mComponents.canNotAffination:SetActive(false)
    mConsumId = affinationData.consumId

    local consumData = ItemData.GetItemInfo(mConsumId)
    local haveNum = BagMgr.GetCountByItemId(mConsumId)
    local needNum = affinationData.count

    mIsEnough = haveNum >= needNum

    mComponents.materialValue.text = haveNum .."/".. needNum

    mComponents.materialIcon.spriteName = consumData.icon_big
    mComponents.qualityBg.spriteName = UIUtil.GetItemQualityBgSpName(consumData.quality)
    mComponents.materialName.text = consumData.name
end

local function SetSafty(data)
    local petData = PetData.GetPetDataById(data.petId)

    if petData.petType1 == 3 then
        mComponents.canNotTips.text = WordData.GetWordStringByKey("Pet_reset_banss")
    end

    if petData.bindType == 1 then
        mComponents.canNotTips.text = WordData.GetWordStringByKey("Pet_reset_banbd")
    end

    local petInfo = PetMgr.GetPetInfoBySlotId(data.slotId)
    if petData.affinationID == nil then
        mComponents.materialNode:SetActive(false)
        mComponents.canNotAffination:SetActive(true)
        return 
    end
    local affinationData = PetData.GetPetAffinationData(petData.affinationID)
    if affinationData == nil then
        mComponents.materialNode:SetActive(false)
        mComponents.canNotAffination:SetActive(true)
        return 
    end

    local maxCount = GetSaftyNum(petData.affinationID)

    --mComponents.saftyBar.value = petInfo.affinationCount / maxCount
    --mComponents.saftyValue.text = petInfo.affinationCount .."/".. maxCount

    local isAffination = PetMgr.GetIsAffinationSucceed()

    if isAffination and mIsEnough then
        local info = PetMgr.GetPetInfoBySlotId(mShowData.slotId)

        local function OnOkFunc()
            PetMgr.RequestCSPetAffination(mShowData.slotId)
        end

        if maxCount - info.affinationCount == 1 then
            TipsMgr.TipConfirmByKey("Pet_Opconfirm_reset3", OnOkFunc)
        end
        PetMgr.SetIsAffinationSucceed(false)
    end
    
end

local function SetStudyPanel()
    local skillList = PetMgr.GetPetSkillListByPetId(mShowData.slotId, 15, 5)
    mStudySkillWidget:Show(skillList)

    mComponents.bookIcon.gameObject:SetActive(false)
    mItemSlot = 0
    mComponents.chooseBookPanel:SetActive(false)
    mComponents.bookName.text = WordData.GetWordStringByKey("Pet_learnskill_info1")
    
end

local function OnNorClick(eventId)
    if eventId and mTargetBtn[eventId] then
        mTargetBtn[eventId]:SetActive(false)
    end
end

local function OnSpecClick(eventId)
    if eventId and mTargetBtn[eventId] then
        mTargetBtn[eventId]:SetActive(true)
    end

    if eventId == 1 and  not mMaterailFx then
        local effectResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_petreset_eff01.prefab")
        mMaterailFx = LoaderMgr.CreateEffectLoader()
        mMaterailFx:LoadObject(effectResId)
        mMaterailFx:SetParent(mComponents.materialIcon.transform)
        mMaterailFx:SetLocalPosition(Vector3.zero)
        mMaterailFx:SetLocalScale(Vector3.one)
        mMaterailFx:SetLocalRotation(UnityEngine.Quaternion.identity)
        mMaterailFx:SetActive(false)
        mMaterailFx:SetSortOrder(600)
        mMaterailFx:SetLayer(CameraLayer.UI) 
    end

    if eventId == 2 then
        UIMgr.UnShowUI(AllUI.UI_Pet_Affination)
        UIMgr.ShowUI(AllUI.UI_Pet_Compose)
    end

    if eventId == 3 then
        SetStudyPanel()
        if mMaterailFx then
            LoaderMgr.DeleteLoader(mMaterailFx)
            mMaterailFx = nil
        end
    end
end

--点击宠物icon回调
local function OnPetItemClick(data)
    local petData = PetData.GetPetDataById(data.petId)
    if petData == nil then
        return 
    end

    SetPetModel(data)
    SetPetInfo(data)
    
    if mResetPanel.gameObject.activeSelf then
        if mPetSkillListWidget then
            local skillList = PetMgr.GetPetSkillListByPetId(data.slotId, 10, 5)
            mPetSkillListWidget:Show(skillList)
        end

        SetTalentAttrPanel(data)
        SetMaterialInfo(data)
        SetSafty(data)
    end

    if mComponents.studySkillTrs.gameObject.activeSelf then
        SetStudyPanel(data)
    end
end

local function OnPetSkillItemClick(data)
    GameEvent.Trigger(EVT.PET, EVT.PET_SHOWSKILLTIPS, data, false)
end

--数据初始化完成在执行相应操作
local function OnInitInfoFinished(isInit)
    if isInit then
        local index = PetMgr.GetCurrShowPetSlotId()
        if mPetListWidget then
            mPetListWidget:OnEnable(index)
        end

        local mPetInfoList = PetMgr.GetPetInfoList()
        if next(mPetInfoList) == nil then
            GameEvent.Trigger(EVT.PET, EVT.PET_NOONE)
            TipsMgr.TipByKey("Pet_empty_banUI2")
        end
    else
        if mMaterailFx then
            mMaterailFx:SetActive(true, true)
        end

        local realIndex = mPetListWidget:GetCurRealIdx()
        mPetListWidget:OnEnable(realIndex)
    end
end

local function OnClickAffination(slotId)
    local info = PetMgr.GetPetInfoBySlotId(slotId)

    local level = UserData.GetLevel()
    if level <= ConfigData.GetIntValue("Pet_reset_Lvlimit") then
        TipsMgr.TipByKey("Pet_reset_Lvinfo")
        return 
    end

    if info.Current == 1 then
        TipsMgr.TipByKey("Pet_Fight_CannotReset")
        return 
    end

    if not mIsEnough then
        --应该弹出购买界面
        GameLog.Log("应该弹出购买界面")
        return
    end

    local function OnOkFunc()
        PetMgr.RequestCSPetAffination(slotId)
    end

    local num = PetMgr.GetTodayIsFirstAffination()

    if info.isPrecious == 1 then
        local str = string.format( WordData.GetWordStringByKey("Pet_Opconfirm_reset2"), info.name )
        TipsMgr.TipConfirmByStr(str, OnOkFunc)
    else
        if num == 0 then
            local str = string.format( WordData.GetWordStringByKey("Pet_Opconfirm_reset1"), info.name )
            TipsMgr.TipConfirmByStr(str, OnOkFunc)
        else
            OnOkFunc()
        end
    end
end

local function SetChooseBookPanel()
    mComponents.chooseBookPanel:SetActive(true)

    for i = 1, mComponents.bookParentNode.childCount do
        UnityEngine.GameObject.Destroy(mComponents.bookParentNode:GetChild(i - 1).gameObject)
    end

    mItemList = BagMgr.GetItemListByType(6, 10)

    for i, v in ipairs(mItemList) do
        local data = ItemData.GetItemInfo(v.item.tempId)
        local bookItem = mSelf:DuplicateAndAdd(mComponents.bookPerfab, mComponents.bookParentNode, i)
        bookItem.gameObject:SetActive(true)
        bookItem.gameObject:GetComponent("UIEvent").id = 200 + i
        bookItem.localPosition = Vector3.New(0, -110 * (i - 1), 0)
        bookItem.localScale = Vector3.one
        local bookName = bookItem:Find("Name"):GetComponent("UILabel")
        local bookDesc = bookItem:Find("Desc"):GetComponent("UILabel")
        local icon = bookItem:Find("Icon"):GetComponent("UITexture")

        local skillData = PetData.GetPetSkillDataBySkillId(data.useFunParam1)
        local sData = SkillData.GetSkillInfo(skillData.skillID)

        bookName.text = data.name
        bookDesc.text = data.clientdesc
        UIUtil.SetTexture(sData.icon, icon)
    end
end

local function SetBook(eventId)
    mComponents.chooseBookPanel:SetActive(false)
    mComponents.bookIcon.gameObject:SetActive(true)
    local index = eventId - 200
    local data = mItemList[index]
    local itemData = ItemData.GetItemInfo(data.item.tempId)
    local skillData = PetData.GetPetSkillDataBySkillId(itemData.useFunParam1)
    local sData = SkillData.GetSkillInfo(skillData.skillID)
    aimSkillId = skillData.skillID
    if data and itemData  then
        mComponents.bookName.text = itemData.name
        UIUtil.SetTexture(sData.icon, mComponents.bookIcon)
        mItemSlot = data.slotId
    end
end

local function RequestSkillStudy()
    local level = UserData.GetLevel()
    if level < ConfigData.GetIntValue("Pet_learn_Lvlimit") then
        TipsMgr.TipByKey("Pet_learn_Lvlimit")
        return 
    end

    local petInfo = PetMgr.GetPetInfoBySlotId(mShowData.slotId)
    local petData = PetData.GetPetDataById(mShowData.petId)
    if petData.bindType == 1 then
        TipsMgr.TipByKey("Pet_learn_banbinding")
        return 
    end

    if petData.petType2 == 4  then
        TipsMgr.TipByKey("Pet_learn_banss")
        return 
    end

    if petInfo.Current == 1 then
        TipsMgr.TipByKey("Pet_learn_banjoin")
        return 
    end
    if mItemSlot == 0 then
        TipsMgr.TipByKey("Pet_NoBook_Tips")
        return 
    end

    for i, v in ipairs(petInfo.OwnSkills) do
        if v.tempSkillId == aimSkillId then
            TipsMgr.TipByKey("Pet_learn_banreskill")
            return 
        end
    end
    PetMgr.RequestCSPetSkillStudy(mShowData.slotId, mItemSlot)
end

--合宠不是一个perfab Ui_pet_compose 打开第三个标签
local function OnOpenStudySkill()
    mToggleItemGroup:OnClick(3)
end

local function ShowStudySkillTips()
    mComponents.studySkillRuleNode:SetActive(true)
    mComponents.studySkillRuleContent.text = WordData.GetWordStringByKey("Pet_StudySkill_Tips")
end

local function ShowAffinationRuleTips()
    mComponents.affinationRuleNode:SetActive(true)
    local data = PetData.GetPetDataById(mShowData.petId)
    if data.petType2 == 1 or data.petType2 == 3 then
        mComponents.affinationRuleTitle.text = WordData.GetWordStringByKey("Pet_reset_PtinfoTT")
        mComponents.affinationRuleContent.text = WordData.GetWordStringByKey("Pet_reset_Ptinfo")
        mComponents.saftyRuleContent.text = WordData.GetWordStringByKey("Pet_reset_Ptinfobd")
    elseif data.petType2 == 2 then
        mComponents.affinationRuleTitle.text = WordData.GetWordStringByKey("Pet_reset_ByinfoTT")
        mComponents.affinationRuleContent.text = WordData.GetWordStringByKey("Pet_reset_Byinfo")
        mComponents.saftyRuleContent.text = WordData.GetWordStringByKey("Pet_reset_Byinfobd")
    end
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.INFO_FINISHED, OnInitInfoFinished)
    GameEvent.Reg(EVT.PET, EVT.PET_ONUPDATEONEINFO, OnInitInfoFinished)
    GameEvent.Reg(EVT.PET, EVT.PET_STUDYSKILLSUCCEED, SetStudyPanel)
    GameEvent.Reg(EVT.PET, EVT.PET_OPENSTUDYSKILL, OnOpenStudySkill)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.INFO_FINISHED, OnInitInfoFinished)
    GameEvent.UnReg(EVT.PET, EVT.PET_ONUPDATEONEINFO, OnInitInfoFinished)
    GameEvent.UnReg(EVT.PET, EVT.PET_STUDYSKILLSUCCEED, SetStudyPanel)
    GameEvent.UnReg(EVT.PET, EVT.PET_OPENSTUDYSKILL, OnOpenStudySkill)
end

function OnCreate(self)
    mSelf = self

    mToggleItemGroup = ToggleItemGroup.new(OnNorClick, OnSpecClick)
    for i = 1, 3 do
        local trs = self:Find("Offset/TargetBtn"..i)
        mToggleItemGroup:AddItem(trs, mTargetBtnInfo[i])
    end

    mComponents.rt =  self:Find("Offset/RenderTexture"):GetComponent("UITexture")
    mComponents.target = self:Find("Offset/TitlePanel/Target"):GetComponent("UISprite")
    mComponents.levelBar = self:Find("Offset/TitlePanel/ExpBar"):GetComponent("UISlider")
    mComponents.levelValue = self:Find("Offset/TitlePanel/ExpBar/Lv"):GetComponent("UILabel")
    mComponents.expValue = self:Find("Offset/TitlePanel/ExpBar/exp"):GetComponent("UILabel")
    mComponents.fightValue = self:Find("Offset/TitlePanel/Fight/FightValue"):GetComponent("UILabel")
    mComponents.outAckBar = self:Find("Offset/ResetPanel/AttrList/StrenghtBar"):GetComponent("UISlider")
    mComponents.outAckValue = self:Find("Offset/ResetPanel/AttrList/StrenghtBar/AttrValue"):GetComponent("UILabel")
    mComponents.insideAckBar = self:Find("Offset/ResetPanel/AttrList/MPBar"):GetComponent("UISlider")
    mComponents.insideAckValue = self:Find("Offset/ResetPanel/AttrList/MPBar/AttrValue"):GetComponent("UILabel")
    mComponents.outDefBar = self:Find("Offset/ResetPanel/AttrList/OutDefBar"):GetComponent("UISlider")
    mComponents.outDefValue = self:Find("Offset/ResetPanel/AttrList/OutDefBar/AttrValue"):GetComponent("UILabel")
    mComponents.insideDefBar = self:Find("Offset/ResetPanel/AttrList/InsideDefBar"):GetComponent("UISlider")
    mComponents.insideDefValue = self:Find("Offset/ResetPanel/AttrList/InsideDefBar/AttrValue"):GetComponent("UILabel")
    mComponents.powerBar = self:Find("Offset/ResetPanel/AttrList/PowerBar"):GetComponent("UISlider")
    mComponents.powerValue = self:Find("Offset/ResetPanel/AttrList/PowerBar/AttrValue"):GetComponent("UILabel")
    mComponents.growthValue = self:Find("Offset/ResetPanel/AttrList/PetGrowup/Value"):GetComponent("UILabel")
    mComponents.materialIcon = self:Find("Offset/ResetPanel/MaterialBg/Node/Icon"):GetComponent("UISprite")
    mComponents.qualityBg = self:Find("Offset/ResetPanel/MaterialBg/Node/IconBg"):GetComponent("UISprite")
    mComponents.materialName = self:Find("Offset/ResetPanel/MaterialBg/Node/Name"):GetComponent("UILabel")
    mComponents.materialValue = self:Find("Offset/ResetPanel/MaterialBg/Node/Num"):GetComponent("UILabel")
    --mComponents.saftyBar = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyBar"):GetComponent("UISlider")
    --mComponents.saftyValue = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyBar/Value"):GetComponent("UILabel")
    mComponents.canNotAffination = self:Find("Offset/ResetPanel/MaterialBg/CanNotAffination").gameObject
    mComponents.canNotTips = self:Find("Offset/ResetPanel/MaterialBg/CanNotAffination/txt"):GetComponent("UILabel")
    mComponents.materialNode = self:Find("Offset/ResetPanel/MaterialBg/Node").gameObject
    mComponents.bookParentNode = self:Find("Offset/ChooseBookPanel/Offset/widget/scrollview/widget")
    mComponents.bookPerfab = self:Find("Offset/ChooseBookPanel/Offset/widget/BookPerfab")
    mComponents.bookIcon = self:Find("Offset/StudySkillPanel/BookIcon"):GetComponent("UITexture")
    mComponents.studySkillTrs = self:Find("Offset/StudySkillPanel")
    mComponents.bookName = self:Find("Offset/StudySkillPanel/Bg/Name"):GetComponent("UILabel")

    mComponents.affinationRuleNode = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyTipsPanel").gameObject
    mComponents.affinationRuleNode:SetActive(false)
    mComponents.affinationRuleTitle = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyTipsPanel/AffinationRule/Title"):GetComponent("UILabel")
    mComponents.affinationRuleContent = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyTipsPanel/AffinationRule/Content"):GetComponent("UILabel")
    mComponents.saftyRuleContent = self:Find("Offset/ResetPanel/MaterialBg/Node/SaftyTipsPanel/SaftyRule/Content"):GetComponent("UILabel")

    mComponents.studySkillRuleNode = self:Find("Offset/StudySkillPanel/StudySkillTips").gameObject
    mComponents.studySkillRuleNode:SetActive(false)
    mComponents.studySkillRuleContent = self:Find("Offset/StudySkillPanel/StudySkillTips/Content"):GetComponent("UILabel")

    mComponents.chooseBookPanel = self:Find("Offset/ChooseBookPanel").gameObject

    mComponents.mPetListTrs = self:Find("Offset/PetList")

    mComponents.mPetSkillTrs = self:Find("Offset/ResetPanel/SkillList")

    mResetPanel = self:Find("Offset/ResetPanel").gameObject

    mLearnSkillPanel = self:Find("Offset/StudySkillPanel").gameObject
    mLearnSkillPanel:SetActive(false)

    mTargetBtn = 
    {
        [mTargetBtnInfo[1].eventId] = mResetPanel,
        [mTargetBtnInfo[2].eventId] = nil,
        [mTargetBtnInfo[3].eventId] = mLearnSkillPanel,
    }

    mPetListWidget = PetListWiget.new(mComponents.mPetListTrs, mPetListBaseEventId, OnPetItemClick)

    mPetSkillListWidget = PetSkillListWidget.new(mComponents.mPetSkillTrs, mPetSKillListBaseEventId, OnPetSkillItemClick)

    mStudySkillWidget = PetSkillListWidget.new(mComponents.studySkillTrs, mStudySkillBaseEventId, OnPetSkillItemClick)     
end

function OnEnable()
    Reg()

    PetMgr.RequestCSPetsInfo(true, 0)

    mToggleItemGroup:OnClick(1)

    local effectResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_petreset_eff01.prefab")
    if not mMaterailFx then
        mMaterailFx = LoaderMgr.CreateEffectLoader()
        mMaterailFx:LoadObject(effectResId)
        mMaterailFx:SetParent(mComponents.materialIcon.transform)
        mMaterailFx:SetLocalPosition(Vector3.zero)
        mMaterailFx:SetLocalScale(Vector3.one)
        mMaterailFx:SetLocalRotation(UnityEngine.Quaternion.identity)
        mMaterailFx:SetActive(false)
        mMaterailFx:SetSortOrder(600)
        mMaterailFx:SetLayer(CameraLayer.UI)   
    end
end

function OnDisable()
    UnReg()
    CameraRender.DeleteEntity(AllUI.UI_Pet_Main, 1)

    if mMaterailFx then
        LoaderMgr.DeleteLoader(mMaterailFx)
        mMaterailFx = nil
    end
end

function OnDestory()
    mComponents = {}
end

function OnClick(go, id)
    local slotId = PetMgr.GetCurrShowPetSlotId()
    if id >= 1 and id <= 3 then --标签
        mToggleItemGroup:OnClick(id)
    elseif id == 4 then -- 等级经验条加号按钮
    elseif id == 5 then --保底tips
        ShowAffinationRuleTips()
    elseif id == 6 then --请求洗练
        OnClickAffination(slotId)
    elseif id == 7 then --添加技能书
        SetChooseBookPanel()
    elseif id == 8 then --学习技能
        RequestSkillStudy()
    elseif id == 9 then --学技能tips
        ShowStudySkillTips()
    elseif id == 10 then --添加技能书 跳转至购买

    elseif id == 11 then -- 材料道具tips
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mConsumId)
    elseif id == -1 then --关闭技能书选择小界面
        mComponents.chooseBookPanel:SetActive(false)
    elseif id == -2 then --关闭学技能tips
        mComponents.studySkillRuleNode:SetActive(false)
    elseif id == -3 then --关闭洗练规则tips
        mComponents.affinationRuleNode:SetActive(false)
    elseif id >= mPetListBaseEventId and id < mPetSKillListBaseEventId then
        mPetListWidget:OnClick(id)
    elseif id > mPetSKillListBaseEventId and id < mStudySkillBaseEventId then
        mPetSkillListWidget:OnClick(id)
    elseif id > mStudySkillBaseEventId and id < 200 then
        mStudySkillWidget:OnClick(id)
    elseif id > 200 then
        SetBook(id)
    end
end

function OnDrag(delta, id)
	if id == -3 then
        CameraRender.DragEntity(AllUI.UI_Pet_Main, delta, 1)
	end
end