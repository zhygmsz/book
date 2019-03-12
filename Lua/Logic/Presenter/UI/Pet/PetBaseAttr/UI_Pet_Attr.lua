module("UI_Pet_Attr", package.seeall)

local mSelf

local PetListWiget = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetListWidget")
local PetSkillListWidget = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetSkillListWidget")

local mPetListWidget
local mPetListBaseEventId = 50
local mPetSKillListBaseEventId = 80
local mPetSkillListWidget

local mToggleGroup

local mTargetBtnInfo = 
{
    { eventId = 31, content = WordData.GetWordStringByKey("Pet_show1_button1") },
    { eventId = 32, content = WordData.GetWordStringByKey("Pet_show1_button2") },
}

local mAuthCode --验证码

--组件
local mCom = {}

local mTimer = 15
local mTime = nil
local mCurrShowPetSlotId = 0

local mCurrToggleId

local mPetEntityAttr = 
{
    name = nil, 
    position = Vector3.zero, 
    forward = Quaternion.identity,  
    petData = nil,
    modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER,
    physiqueID = nil, 
}

--设置宠物模型
local function SetPetModel(data)
    local petData = PetData.GetPetDataById(data.petId)
    if petData == nil then return end

    PetMgr.SetCurrShowPetSlotId(data.slotId)
    mCurrShowPetSlotId = data.slotId

    mPetEntityAttr.name = petData.name;
    mPetEntityAttr.petData = petData;
    mPetEntityAttr.physiqueID = petData.modelID;

    CameraRender.RenderEntity(AllUI.UI_Pet_Main, mCom.mRt, mPetEntityAttr, 1)

    CameraRender.PlayAnim(AllUI.UI_Pet_Main, 1, "Stand")
end

--设置宠物信息
local function SetPetInfo(data)

    local petData = PetData.GetPetDataById(data.petId)

    if petData == nil then
        return 
    end

    if petData.attackDist == 1 then
        mCom.mAttackDistance.spriteName = ConfigData.GetStringValue("Pet_attackDist_yuanicon")
    elseif petData.attackDist == 2 then
        mCom.mAttackDistance.spriteName = ConfigData.GetStringValue("Pet_attackDist_jinicon")
    end
    if petData.attackType == 1 then
        mCom.mAttackType.spriteName = ConfigData.GetStringValue("Pet_attackType_waiicon")
    elseif petData.attackType == 2 then
        mCom.mAttackType.spriteName = ConfigData.GetStringValue("Pet_attackType_neiicon")
    end
    if petData.petType2 == 1 then
        mCom.mPetTarget.spriteName = ConfigData.GetStringValue("Pet_Type2_bbicon")
    elseif petData.petType2 == 2 then
        mCom.mPetTarget.spriteName = ConfigData.GetStringValue("Pet_Type2_byicon")
    elseif petData.petType2 == 3 then
        mCom.mPetTarget.spriteName = ConfigData.GetStringValue("Pet_Type2_ysicon")
    elseif petData.petType2 == 4 then
        mCom.mPetTarget.spriteName = ConfigData.GetStringValue("Pet_Type2_ssicon")
    end

    local infoData = PetMgr.GetPetInfoBySlotId(data.slotId)

    if infoData then
        mCom.mName.text = infoData.name
        mCom.mFight.text = infoData.power
        local currExp = infoData.exp
        local level = infoData.level
        mCom.mLevel.text = string.format( WordData.GetWordStringByKey("gem_maxlevel_for_inlay"), level )
        local currExpData = PetData.GetPetExpDataByLevel(level)
        local nextExpData = PetData.GetPetExpDataByLevel(level + 1)
        if nextExpData then
            mCom.mExpBar.value = (currExp - currExpData.exp) / (nextExpData.exp - currExpData.exp)
            mCom.mExpValue.text = tostring(currExp - currExpData.exp) .."/".. tostring(nextExpData.exp - currExpData.exp)
        end
    end

    mCom.mFightBtn:SetActive(infoData.Current == 0)
    mCom.mRestBtn:SetActive(infoData.Current == 1)
end

--设置各种进度条
local function SetTalentAttrPanel(data)
    local petData = PetData.GetPetDataById(data.petId)
    local petInfoData = PetMgr.GetPetInfoBySlotId(data.slotId)
    if petInfoData == nil or petData == nil then
        return 
    end

    local oaMax, iaMax, odMax, idMax, ppMax = PetMgr.GetPetMaxTalent(petData)

    mCom.mOATalent.value = petInfoData.physicApt / oaMax
    mCom.mOATalentTxt.text = math.floor( petInfoData.physicApt ) .."/".. oaMax

    mCom.mIATalent.value = petInfoData.magicApt / iaMax
    mCom.mIATalentTxt.text = math.floor( petInfoData.magicApt )  .."/".. iaMax

    mCom.mODTalent.value = petInfoData.physicDefApt / odMax
    mCom.mODTalentTxt.text = math.floor( petInfoData.physicDefApt ).."/".. odMax

    mCom.mIDTalent.value = petInfoData.magicDefApt / idMax
    mCom.mIDTalentTxt.text = math.floor(petInfoData.magicDefApt)  .."/".. idMax

    mCom.mPPTalent.value = petInfoData.hpApt / ppMax
    mCom.mPPTalentTxt.text = math.floor( petInfoData.hpApt )  .."/".. ppMax

    mCom.mGrowthValue.text = string.format("%.3f", petInfoData.growth) 

    for i = 1, mCom.mAttrParentNode.childCount do
        UnityEngine.GameObject.Destroy(mCom.mAttrParentNode:GetChild(i - 1).gameObject)
    end

    local maxHp, maxMp = 0
    local attrWidth, attrHeight = 160, 30

    local attrList = PetMgr.GetAttrListBySlotId(data.slotId)
    local index = 0
    for i, attr in ipairs(attrList) do
        if attr.key ~= PropertyInfo_pb.SP_HP_BASE and attr.key ~= PropertyInfo_pb.SP_MP_MAX_BASE then
            index = index + 1
            local attrTrs = mSelf:DuplicateAndAdd(mCom.mAttrPerfab, mCom.mAttrParentNode, i)
            attrTrs.gameObject:SetActive(true)
            attrTrs.gameObject:GetComponent("UIEvent").id = 152 + index --152为属性的基础Id
            attrTrs.localPosition = Vector3((i - 1) % 2 * attrWidth,  (math.floor( (i - 1) / 2  ) - 1) * attrHeight, 0)
            attrTrs.localScale = Vector3.one
            local attrName = attrTrs.gameObject:GetComponent("UILabel")
            local attrValue = attrTrs:Find("AttrValue"):GetComponent("UILabel")
            attrName.text = AttDefineData.GetDefineData(attr.key).name
            attrValue.text = math.floor( attr.value ) 
        elseif attr.key == PropertyInfo_pb.SP_HP_BASE then
            maxHp = attr.value
        elseif attr.key == PropertyInfo_pb.SP_MP_MAX_BASE then
            maxMp = attr.value
        end
    end

    --mCom.mAttrParentNode.gameObject:GetComponent("UIGrid").enabled = true

    mCom.mHpBar.value = petInfoData.curHP / maxHp
    mCom.mHpTxt.text = math.floor( petInfoData.curHP ) .."/".. maxHp

    mCom.mMpBar.value = math.floor( petInfoData.curMP )  / maxMp
    mCom.mMpTxt.text = petInfoData.curMP .."/".. maxMp

    if petInfoData.curHP == -1 then
        mCom.mHpBar.value = 1
        mCom.mHpTxt.text = maxHp .."/".. maxHp
    end

    if petInfoData.curMP == -1 then
        mCom.mMpBar.value = 1
        mCom.mMpTxt.text = maxMp .."/".. maxMp
    end
end

--普通放生 取消按钮的倒计时
local function RefreshCutDown()
    mTimer = mTimer - 1
    if mTimer > 0 then
        mCom.mCutDownTxt.text = WordData.GetWordStringByKey("Pet_free_limit", mTimer)
    else
        mCom.mComReleasePanel:SetActive(false)
        if mTime then
            GameTimer.DeleteTimer(mTime)
            mTime = nil
        end
    end
end

local function SetAuthCode()
    local code = math.random( 1000, 9999 )
    mCom.mReleaseCode.text = code
    mAuthCode = code

    mCom.mReleaseInputer.value = ""
end

local function OnPetSkillItemClick(data)
    GameEvent.Trigger(EVT.PET, EVT.PET_SHOWSKILLTIPS, data, true)
end

local function SetHandSkill()
    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    local skillId = 0 
    for _, info in ipairs(petInfo.OwnSkills) do
        if info.skillStatus == 1 then
            skillId = info.tempSkillId
        end
    end
    local skillData = SkillData.GetSkillInfo(skillId)
    local petSkillData = PetData.GetPetSkillDataBySkillId(skillId)
    local skillLevelData = SkillData.GetSkillLevelInfo(skillId, 1)
    if skillData ~= nil then
        UIUtil.SetTexture(skillData.icon, mCom.mCurrSkillIcon)
        mCom.mCurrSkillIcon.gameObject:SetActive(true)
        mCom.mSkillCDTxt.text = petSkillData.skillCD / 1000
        mCom.mSkillDescTxt.text = string.format(WordData.GetWordStringByKey("Pet_show1_btinfo204"), skillLevelData.desc2) 
        mCom.mHandSkillName.text = skillData.name
    else
        mCom.mHandSkillName.text = WordData.GetWordStringByKey("Pet_show1_btinfo202")
        mCom.mCurrSkillIcon.gameObject:SetActive(false)
    end
end

local function OnNorClick(eventId)
    if eventId == 31 then
        mCom.mAttrPanel:SetActive(false)
    elseif eventId == 32 then
        mCom.mSkillPanel:SetActive(false)
    end
end

local  function OnSpecClick(eventId)
    mCurrToggleId = eventId
    if eventId == 31 then
        mCom.mAttrPanel:SetActive(true)
    elseif eventId == 32 then
        mCom.mSkillPanel:SetActive(true)

        local slotId = PetMgr.GetCurrShowPetSlotId()
        local skillList = PetMgr.GetPetSkillListByPetId(slotId, 10, 5)
        mPetSkillListWidget:Show(skillList)

        SetHandSkill()
    end
end

local function OnPetItemClick(data)
    local isUpdate = PetMgr.GetIsUpdateInfo()
    if data.slotId == mCurrShowPetSlotId and not isUpdate then
        return
    end
    PetMgr.SetIsUpdateInfo(false)

    SetPetModel(data)
    SetPetInfo(data)
    SetTalentAttrPanel(data)

    OnSpecClick(mCurrToggleId)
end

--数据初始化完成在执行相应操作
local function OnInitInfoFinished(isInit)
    if isInit then
        local index = PetMgr.GetCurrShowPetSlotId()

        local fightIndex = 1
        local datalist = PetMgr.GetPetDataList()
        for i, v in ipairs(datalist) do
            local petInfo = PetMgr.GetPetInfoBySlotId(v.slotId)
            if petInfo then
                if petInfo.Current == 1 then
                    fightIndex = i
                    break
                end
            end
        end

        index = PetMgr.GetIsChangeTarget() and index or fightIndex

        if mPetListWidget then
            mPetListWidget:OnEnable(index)
        end

        local mPetInfoList = PetMgr.GetPetInfoList()
        if next(mPetInfoList) == nil then
            GameEvent.Trigger(EVT.PET, EVT.PET_NOONE)
            TipsMgr.TipByKey("Pet_empty_banUI1")
        end
    else
        local realIndex = mPetListWidget:GetCurRealIdx()
        mPetListWidget:OnEnable(realIndex)
    end

    PetMgr.SetIsChangeTarget(true)
end

local function OnFightStateChanged()

    local realIndex = mPetListWidget:GetCurRealIdx()
    mPetListWidget:OnEnable(realIndex)

    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    mCom.mFightBtn:SetActive(petInfo.Current == 0)
    mCom.mRestBtn:SetActive(petInfo.Current == 1)
end

local function ShowHandSkill()
    local data = {}
    data.tempSkillId = PetMgr.GetCurrHandSkill()
    GameEvent.Trigger(EVT.PET, EVT.PET_SHOWSKILLTIPS, data, true)
end

local function OnReName(name)
    mCom.mName.text = name
end

local function TriggerAttrTips(id, go)
    if id == 151 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_HP"), go)
    elseif id == 152 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_MP"), go)
    elseif id == 153 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pe_info_values-54"), go)
    elseif id == 154 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pe_info_values-62"), go)
    elseif id == 155 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pe_info_values-58"), go)
    elseif id == 156 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pe_info_values-66"), go)
    elseif id == 157 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_waiG"), go)
    elseif id == 158 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_neiG"), go)
    elseif id == 159 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_waiF"), go)
    elseif id == 160 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_neiF"), go)
    elseif id == 161 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_qixue"), go)
    elseif id == 162 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_rate"), go)
    elseif id == 163 then
        GameEvent.Trigger(EVT.PET, EVT.PET_SHOWATTRTIPS, WordData.GetWordStringByKey("Pet_info_XP"), go)
    end
end

local function ResetData()
    table.clear(mCom)
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.INFO_FINISHED, OnInitInfoFinished)
    GameEvent.Reg(EVT.PET, EVT.FIGHTSTATE_CHANGED, OnFightStateChanged)
    GameEvent.Reg(EVT.PET, EVT.PET_RENAME, OnReName)
    GameEvent.Reg(EVT.PET, EVT.PET_ONUPDATEONEINFO, OnInitInfoFinished)
    GameEvent.Reg(EVT.PET, EVT.PET_HANDSKILLCHANGE, SetHandSkill)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.INFO_FINISHED, OnInitInfoFinished)
    GameEvent.UnReg(EVT.PET, EVT.FIGHTSTATE_CHANGED, OnFightStateChanged)
    GameEvent.UnReg(EVT.PET, EVT.PET_RENAME, OnReName)
    GameEvent.UnReg(EVT.PET, EVT.PET_ONUPDATEONEINFO, OnInitInfoFinished)
    GameEvent.UnReg(EVT.PET, EVT.PET_HANDSKILLCHANGE, SetHandSkill)
end

function OnCreate(self)
    mSelf = self
    mCom.mName = self:Find("Offset/TitlePanel/NameBg/name"):GetComponent("UILabel")
    mCom.mAttackDistance = self:Find("Offset/TitlePanel/AttackDistance"):GetComponent("UISprite")
    mCom.mAttackType = self:Find("Offset/TitlePanel/AttackType"):GetComponent("UISprite")
    mCom.mPetTarget = self:Find("Offset/TitlePanel/Target"):GetComponent("UISprite")
    mCom.mLevel = self:Find("Offset/TitlePanel/ExpBar/ExpBar/Lv"):GetComponent("UILabel")
    mCom.mExpBar = self:Find("Offset/TitlePanel/ExpBar/ExpBar"):GetComponent("UISlider")
    mCom.mExpValue = self:Find("Offset/TitlePanel/ExpBar/ExpBar/exp"):GetComponent("UILabel")
    mCom.mFight = self:Find("Offset/TitlePanel/Fight/FightValue"):GetComponent("UILabel")
    mCom.mPetListTrs = self:Find("Offset/PetList")
    mCom.mRt = self:FindComponent("UITexture", "Offset/RenderTexture")
    mCom.mAttrPanel = self:Find("Offset/AttrPanel").gameObject
    mCom.mSkillPanel = self:Find("Offset/SkillPanel").gameObject

    mCom.mOATalent = self:Find("Offset/AttrPanel/OABar"):GetComponent("UISlider")
    mCom.mOATalentTxt = self:Find("Offset/AttrPanel/OABar/AttrValue"):GetComponent("UILabel")

    mCom.mIATalent = self:Find("Offset/AttrPanel/IABar"):GetComponent("UISlider")
    mCom.mIATalentTxt = self:Find("Offset/AttrPanel/IABar/AttrValue"):GetComponent("UILabel")

    mCom.mODTalent = self:Find("Offset/AttrPanel/ODBar"):GetComponent("UISlider")
    mCom.mODTalentTxt = self:Find("Offset/AttrPanel/ODBar/AttrValue"):GetComponent("UILabel")

    mCom.mIDTalent = self:Find("Offset/AttrPanel/IDBar"):GetComponent("UISlider")
    mCom.mIDTalentTxt = self:Find("Offset/AttrPanel/IDBar/AttrValue"):GetComponent("UILabel")

    mCom.mPPTalent = self:Find("Offset/AttrPanel/PPBar"):GetComponent("UISlider")
    mCom.mPPTalentTxt = self:Find("Offset/AttrPanel/PPBar/AttrValue"):GetComponent("UILabel")

    mCom.mTypeTipsNode = self:Find("Offset/PetTypeTipsPanel").gameObject

    mCom.mFightTipsNode = self:Find("Offset/FightTipsPanel").gameObject

    mCom.mHpBar = self:Find("Offset/AttrPanel/HpBar"):GetComponent("UISlider")
    mCom.mHpTxt = self:Find("Offset/AttrPanel/HpBar/AttrValue"):GetComponent("UILabel")

    mCom.mMpBar = self:Find("Offset/AttrPanel/MpBar"):GetComponent("UISlider")
    mCom.mMpTxt = self:Find("Offset/AttrPanel/MpBar/AttrValue"):GetComponent("UILabel")

    mCom.mGrowthValue = self:Find("Offset/AttrPanel/PetGrowup/Value"):GetComponent("UILabel")

    mCom.mPetSkillTrs = self:Find("Offset/SkillPanel/Bg/CurrSkill/SkillList")

    mCom.mCurrSkillIcon = self:Find("Offset/SkillPanel/Bg/CurrSkill/Icon"):GetComponent("UITexture")
    mCom.mHandSkillName = self:Find("Offset/SkillPanel/Bg/CurrSkill/HandSkill/SkillName"):GetComponent("UILabel")
    mCom.mSkillCDTxt = self:Find("Offset/SkillPanel/Bg/CurrSkill/SkillCD/CD"):GetComponent("UILabel")
    mCom.mSkillDescTxt = self:Find("Offset/SkillPanel/Bg/CurrSkill/SkillDesc"):GetComponent("UILabel")

    mCom.mAttrPerfab = self:Find("Offset/AttrPanel/AttrPerfab")
    mCom.mAttrParentNode = self:Find("Offset/AttrPanel/AttrTxtWidget")

    mCom.mReleasePanel = self:Find("Offset/ReleasePanel").gameObject
    mCom.mReleaseTips = self:Find("Offset/ReleasePanel/Tips"):GetComponent("UILabel")
    mCom.mReleaseType = self:Find("Offset/ReleasePanel/Type/Value"):GetComponent("UILabel")
    mCom.mReleaseLevel = self:Find("Offset/ReleasePanel/Level/Value"):GetComponent("UILabel")
    mCom.mReleaseInputer = self:Find("Offset/ReleasePanel/AuthCode/Input/Code"):GetComponent("LuaUIInput")
    mCom.mReleaseCode = self:Find("Offset/ReleasePanel/AuthCode/CodeBg/CodeValue"):GetComponent("UILabel")

    mCom.mComReleasePanel = self:Find("Offset/CommonReleasePanel").gameObject
    mCom.mComReleaseTips = self:Find("Offset/CommonReleasePanel/Tips"):GetComponent("UILabel")
    mCom.mCutDownTxt = self:Find("Offset/CommonReleasePanel/CancelBtn/Value"):GetComponent("UILabel")

    mCom.mFightBtn = self:Find("Offset/FightBtn").gameObject
    mCom.mRestBtn = self:Find("Offset/RestBtn").gameObject

    mCom.mTypeTipsNode:SetActive(false)
    mCom.mFightTipsNode:SetActive(false)

    mToggleGroup = ToggleItemGroup.new(OnNorClick, OnSpecClick)
    for i = 1, 2 do
        local trs = self:Find("Offset/TargetBtn"..i)
        mToggleGroup:AddItem(trs, mTargetBtnInfo[i])
    end

    mPetListWidget = PetListWiget.new(mCom.mPetListTrs, mPetListBaseEventId, OnPetItemClick)

    mPetSkillListWidget = PetSkillListWidget.new(mCom.mPetSkillTrs, mPetSKillListBaseEventId, OnPetSkillItemClick)
end

function OnEnable(self)
    Reg()
    PetMgr.RequestCSPetsInfo(true, 0)
    UIMgr.ShowUI(AllUI.UI_Pet_Tips)
    mCom.mComReleasePanel:SetActive(false)
    mCom.mReleasePanel:SetActive(false)
    mCom.mSkillPanel:SetActive(false)
    mToggleGroup:OnClick(31)
end

function OnDisable(self)
    UnReg()
    mToggleGroup:OnDisable()
    CameraRender.DeleteEntity(AllUI.UI_Pet_Main, 1)
    mCurrShowPetSlotId = 0
end

function OnDestory(self)
    ResetData()
end

function OnClick(go, id)

    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    local petData = PetData.GetPetDataById(petInfo.tempId)

    if id == 6 then --变色
        TipsMgr.TipByKey("equip_share_not_support")
    elseif id == 7 then --改名
        UIMgr.ShowUI(AllUI.UI_Pet_ReName)
    elseif id == 8 then --添加经验
    elseif id == 21 then --加点
        UIMgr.ShowUI(AllUI.UI_Pet_AddPoint)
    elseif id == 22 then --放生
        if petInfo.Current == 1 then
            TipsMgr.TipByKey("Pet_Fight_CannotRelease")
            return 
        end
        mCom.mReleaseLevel.text = petInfo.level
        mCom.mReleaseType.text = petData.name
        mCom.mReleaseTips.text = string.format( WordData.GetWordStringByKey("Pet_promess_free1"), petInfo.name)
        mCom.mComReleaseTips.text = string.format( WordData.GetWordStringByKey("Pet_promess_free1"), petInfo.name)
        if petInfo.isPrecious == 1 then
            mCom.mReleasePanel:SetActive(true)
            SetAuthCode()
        elseif petInfo.isPrecious == 2 then
            mCom.mComReleasePanel:SetActive(true)
            mTimer = 15
            mCom.mCutDownTxt.text = WordData.GetWordStringByKey("Pet_free_limit", mTimer)
            mTime = GameTimer.AddTimer( 1, 16, RefreshCutDown )
        end
    elseif id == 23 then --参战
        PetMgr.RequestCSOptPet(NetCS_pb.CSOptPet.CALL_PET)
    elseif id == 24 then --休息
        PetMgr.RequestCSOptPet(NetCS_pb.CSOptPet.TAKEBACK_PET)
    elseif id == 31 or id == 32 then
        mToggleGroup:OnClick(id)
    elseif id >= mPetListBaseEventId and id < mPetSKillListBaseEventId then
        mPetListWidget:OnClick(id)
    elseif id > mPetSKillListBaseEventId and id < 100 then
        mPetSkillListWidget:OnClick(id)
    elseif id == 101 then
        mCom.mTypeTipsNode:SetActive(false)
    elseif id == 102 then
        mCom.mTypeTipsNode:SetActive(false)
    elseif id == 103 then
        mCom.mTypeTipsNode:SetActive(true)
    elseif id == 104 then
        mCom.mTypeTipsNode:SetActive(true)
    elseif id == 110 then --确定放生
        PetMgr.SetIsChangeTarget(false)
        if tonumber(mCom.mReleaseInputer.value) == mAuthCode then
            PetMgr.RequestCSReleasePet(petInfo.slotId)
            mCom.mReleasePanel:SetActive(false)
        else
            TipsMgr.TipByKey("Pet_code_error")
        end
    elseif id == 111 then --确定普通放生
        PetMgr.SetIsChangeTarget(false)
        PetMgr.RequestCSReleasePet(petInfo.slotId)
        mCom.mComReleasePanel:SetActive(false)
    elseif id == 112 then
        ShowHandSkill()
    elseif id > 150 and  id < 165  then
        TriggerAttrTips(id, go)
    elseif id == -1 then    --特殊放生
        mCom.mReleasePanel:SetActive(false)
    elseif id == -2 then  --普通放生
        mCom.mComReleasePanel:SetActive(false)
        if mTime then
            GameTimer.DeleteTimer(mTime)
            mTime = nil
        end
    elseif id == -3 then    --特殊放生取消
        mCom.mReleasePanel:SetActive(false)
    elseif id == -4 then    --点击模型
        CameraRender.PlayAnim(AllUI.UI_Pet_Main, 1, petData.animskill1, "Stand")
    end
end

function OnDrag(delta, id)
	if id == -4 then
		CameraRender.DragEntity(AllUI.UI_Pet_Main, delta, 1)
	end
end