module("UI_Pet_ComposeResult", package.seeall)

local SkillList = require("Logic/Presenter/UI/Pet/PetBaseAttr/PetSkillListWidget")
local mSkillList

local mSkillBaseEventId = 30
local mEffectLoader = nil

local mComs = 
{
    name = nil,
    level = nil,
    fight = nil,
    pAttack = nil,
    mAttack = nil,
    pDef = nil,
    mDef = nil,
    phy = nil,
    grow = nil,
    skillTrs = nil,
    rt = nil,
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

--设置宠物模型
local function SetPetModel(petId)
    local petData = PetData.GetPetDataById(petId)
    if petData == nil then return end

    mPetEntityAttr.name = petData.name;
    mPetEntityAttr.petData = petData;
    mPetEntityAttr.physiqueID = petData.modelID;
    
    CameraRender.RenderEntity(AllUI.UI_Pet_Main, mComs.rt, mPetEntityAttr, 1)
    CameraRender.PlayAnim(AllUI.UI_Pet_Main, 1, "Stand")
end

local function OnSkillClick(data)
    GameEvent.Trigger(EVT.PET, EVT.PET_SHOWSKILLTIPS, data, false)
end

function OnCreate(self)
    mComs.name = self:Find("Offset/Left/Name"):GetComponent("UILabel")
    mComs.level = self:Find("Offset/Left/Level/value"):GetComponent("UILabel")
    mComs.fight = self:Find("Offset/Left/Fight/Value"):GetComponent("UILabel")
    mComs.pAttack = self:Find("Offset/Right/AttrList/PAttack/AttrValue"):GetComponent("UILabel")
    mComs.mAttack = self:Find("Offset/Right/AttrList/MAttack/AttrValue"):GetComponent("UILabel")
    mComs.pDef = self:Find("Offset/Right/AttrList/PDef/AttrValue"):GetComponent("UILabel")
    mComs.mDef = self:Find("Offset/Right/AttrList/MDef/AttrValue"):GetComponent("UILabel")
    mComs.phy = self:Find("Offset/Right/AttrList/Phy/AttrValue"):GetComponent("UILabel")
    mComs.grow = self:Find("Offset/Right/AttrList/Grow/AttrValue"):GetComponent("UILabel")
    mComs.skillTrs = self:Find("Offset/Right")
    mComs.rt = self:Find("Offset/Left/ModeBg/RenderTexture"):GetComponent("UITexture")

    mSkillList = SkillList.new(mComs.skillTrs, mSkillBaseEventId, OnSkillClick)
end

function OnEnable()
    local data = PetMgr.GetComposeResultData()
    if data == nil then
        GameLog.LogError("data is nil")
        return 
    end
    mComs.name.text = data.name 
    mComs.level.text = data.level 
    mComs.fight.text = math.floor( data.power ) 
    mComs.pAttack.text = math.floor(data.physicApt)
    mComs.mAttack.text = math.floor(data.magicApt)
    mComs.pDef.text = math.floor(data.physicDefApt)
    mComs.mDef.text = math.floor(data.magicDefApt)
    mComs.phy.text = math.floor(data.hpApt)
    mComs.grow.text = string.format( "%.3f",data.growth )

    local skillList = PetMgr.GetPetSkillListByPetId(data.slotId, 8, 4)
    mSkillList:Show(skillList)

    SetPetModel(data.tempId)

    local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_petscore_eff01.prefab")
    mEffectLoader = LoaderMgr.CreateEffectLoader()
    mEffectLoader:LoadObject(resId)
    mEffectLoader:SetParent(mComs.fight.transform.parent)
    mEffectLoader:SetLocalPosition(Vector3.New(25, 6))
    mEffectLoader:SetLocalScale(Vector3.one)
    mEffectLoader:SetLocalRotation(UnityEngine.Quaternion.identity)
    mEffectLoader:SetActive(true)
    mEffectLoader:SetSortOrder(308)
    mEffectLoader:SetLayer(CameraLayer.UI)
end

function OnDisable()
    CameraRender.DeleteEntity(AllUI.UI_Pet_Main, 1)

    if mEffectLoader then
        LoaderMgr.DeleteLoader(mEffectLoader)
        mEffectLoader = nil
    end
end

function OnClick(go, id)
    if id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Pet_ComposeResult)
    elseif id == 1 then
        UIMgr.UnShowUI(AllUI.UI_Pet_ComposeResult)
    elseif id > mSkillBaseEventId then
        mSkillList:OnClick(id)
    end
end

function OnDrag(delta, id)
	if id == -3 then
		CameraRender.DragEntity(AllUI.UI_Pet_Main, delta, 1)
	end
end