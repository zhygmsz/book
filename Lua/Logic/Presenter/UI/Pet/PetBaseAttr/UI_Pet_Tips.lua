module("UI_Pet_Tips", package.seeall)

local mHandName
local mHandIcon
local mHandDesc
local mHandCD
local mHandSkillNode
local mEquipBtn
local mChangeBtn
local mDemountBtn

local mCommonName
local mCommonIcon
local mCommonDesc
local mCommonSkillNode

local mAttrBg
local mAttrDesc
local mAttrNode
local mTxtNode

local mShowData

local function OnShowSkillTips(data, isShowBtn)
    mShowData = data
    local petSkillData = PetData.GetPetSkillDataBySkillId(data.tempSkillId)
    local skillData = SkillData.GetSkillInfo(data.tempSkillId)
    local skilllLevelData = SkillData.GetSkillLevelInfo(data.tempSkillId, 1)
    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    if petSkillData == nil or skillData == nil or skilllLevelData == nil then
        GameLog.Log("data is nil, skill id is : "..data.tempSkillId)
        return 
    end
    mHandSkillNode:SetActive(petSkillData.skillType == 1)
    mCommonSkillNode:SetActive(petSkillData.skillType ~= 1)
    --技能类型
    if petSkillData.skillType == 1 then
        mHandName.text = skillData.name
        mHandDesc.text = skilllLevelData.desc2
        local str = string.format( WordData.GetWordStringByKey("Pet_show1_btinfo203"), petSkillData.skillCD / 1000 )
        mHandCD.text = str
        UIUtil.SetTexture(skillData.icon, mHandIcon)
    elseif petSkillData.skillType == 2 then
        mCommonName.text = string.format( WordData.GetWordStringByKey("Pet_ordskill_blue"), skillData.name )
        mCommonDesc.text = skilllLevelData.desc2
        UIUtil.SetTexture(skillData.icon, mCommonIcon)
    elseif petSkillData.skillType == 3 then
        mCommonName.text = string.format( WordData.GetWordStringByKey("Pet_advskill_red"), skillData.name )
        mCommonDesc.text = skilllLevelData.desc2
        UIUtil.SetTexture(skillData.icon, mCommonIcon)
    end
    
    local skillId = 0 
    for _, info in ipairs(petInfo.OwnSkills) do
        if info.skillStatus == 1 then
            skillId = info.tempSkillId
        end
    end
    mEquipBtn:SetActive(skillId == 0)
    mChangeBtn:SetActive(skillId ~= 0 and  skillId ~= data.tempSkillId)
    mDemountBtn:SetActive(skillId == data.tempSkillId)

    if not isShowBtn then
        mEquipBtn:SetActive(false)
        mChangeBtn:SetActive(false)
        mDemountBtn:SetActive(false)
    end
end

local function OnShowAttrTips(content, go)
    mAttrNode:SetActive(true)

    mAttrDesc.text = content

    mAttrBg.height = mAttrDesc.height + 20

    local widget = go.transform.parent.gameObject:GetComponent("UIWidget")
    if widget then
        local pos = widget.transform.localPosition
        mTxtNode.transform.localPosition = Vector3.New( pos.x - 400, pos.y, pos.z )
    end
end

local function OnHandSkillChanged(data)
    mHandSkillNode:SetActive(false)
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.PET_SHOWSKILLTIPS, OnShowSkillTips)
    GameEvent.Reg(EVT.PET, EVT.PET_SHOWATTRTIPS, OnShowAttrTips)
    GameEvent.Reg(EVT.PET, EVT.PET_HANDSKILLCHANGE, OnHandSkillChanged)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.PET_SHOWSKILLTIPS, OnShowSkillTips)
    GameEvent.UnReg(EVT.PET, EVT.PET_SHOWATTRTIPS, OnShowAttrTips)
    GameEvent.UnReg(EVT.PET, EVT.PET_HANDSKILLCHANGE, OnHandSkillChanged)
end

function OnCreate(self)

    mHandName = self:Find("Offset/HandSkillPanel/Name"):GetComponent("UILabel")
    mHandIcon = self:Find("Offset/HandSkillPanel/IconBg/Icon"):GetComponent("UITexture")
    mHandCD = self:Find("Offset/HandSkillPanel/CD"):GetComponent("UILabel")
    mHandDesc = self:Find("Offset/HandSkillPanel/Desc"):GetComponent("UILabel")
    mHandSkillNode = self:Find("Offset/HandSkillPanel").gameObject
    mEquipBtn = self:Find("Offset/HandSkillPanel/EquipBtn").gameObject
    mChangeBtn = self:Find("Offset/HandSkillPanel/ChangeBtn").gameObject
    mDemountBtn = self:Find("Offset/HandSkillPanel/DemountBtn").gameObject

    mCommonDesc = self:Find("Offset/CommonSkillPanel/Desc"):GetComponent("UILabel")
    mCommonIcon = self:Find("Offset/CommonSkillPanel/IconBg/Icon"):GetComponent("UITexture")
    mCommonName = self:Find("Offset/CommonSkillPanel/Name"):GetComponent("UILabel")
    mCommonSkillNode = self:Find("Offset/CommonSkillPanel").gameObject

    mAttrBg = self:Find("Offset/AttrTipsPanel/Bg"):GetComponent("UISprite")
    mAttrDesc = self:Find("Offset/AttrTipsPanel/Bg/Desc"):GetComponent("UILabel")
    mAttrNode = self:Find("Offset/AttrTipsPanel").gameObject
    mTxtNode = self:Find("Offset/AttrTipsPanel/Bg").gameObject
end

function OnEnable()
    Reg()
    mHandSkillNode:SetActive(false)
    mCommonSkillNode:SetActive(false)
end

function OnDisable()
    UnReg()
end

function ONDestory()
    
end

function OnClick(go, id)
    local slotId = PetMgr.GetCurrShowPetSlotId()
    local petInfo = PetMgr.GetPetInfoBySlotId(slotId)
    if id == -1 then
        mHandSkillNode:SetActive(false)
    elseif id == -2 then
        mCommonSkillNode:SetActive(false)
    elseif id == -3 then
        mAttrNode:SetActive(false)
    elseif id == 1 then
        PetMgr.RequestCSChangeSkill(NetCS_pb.CSChangeSkill.ASSEMBLE, petInfo.slotId, mShowData)
    elseif id == 2 then
        PetMgr.RequestCSChangeSkill(NetCS_pb.CSChangeSkill.REPLACE, petInfo.slotId, mShowData)
    elseif id == 3 then
        PetMgr.RequestCSChangeSkill(NetCS_pb.CSChangeSkill.UNINSTAL, petInfo.slotId, mShowData)
    end
end

