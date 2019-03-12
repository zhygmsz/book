module("UI_Skill_Interest", package.seeall);

local OperateModel =
{
	Ope_Normal = 1,
	Ope_Skill = 2;
	Ope_Slot = 3;
}

local mSelf;
local mCurrentOperateModel = 1;
local mCurrentSelectSlotIndex = - 1;
local mCurrentSelectSkillId = - 1;
local mCurrentFilterIndex = - 1;

local mSkillSlotList = {};

local mFilterItemPrefab;
local mFilterTable;
local mFilterScrollView;

local mSkillWrap;
local mWrapCall;
local mSkillItemPrefab;

local mSkillFilterPool = {};

local mSkillItemPool = {};
local mSkillInfoList = {};

local MAX_SLOT_COUNT = 5;
local SKILL_POOL_COUNT = 36;
local SKILL_FILTER_ITEM_EVENT_ID_BASE = 100;

function OnCreate(self)
	mSelf = self;
	
	local commonSlotPath = "Offset/SlotList/SkillSlot";
	for i = 1, MAX_SLOT_COUNT do
		local slotItem = {};
		slotItem.id = - 1;
		slotItem.skillIcon = self:FindComponent("UITexture", commonSlotPath .. i .. "/Icon");
		slotItem.skillIconLoader = LoaderMgr.CreateTextureLoader(slotItem.skillIcon);
		slotItem.selectFlag = self:FindComponent("UISprite", commonSlotPath .. i .. "/SelectFlag");
		slotItem.selectFlag.gameObject:SetActive(false);
		table.insert(mSkillSlotList, slotItem);
	end
	
	mFilterItemPrefab = self:Find("Offset/Rigth/FilterList/FilterPrefab");
	mFilterItemPrefab.gameObject:SetActive(false);
	mFilterTable = self:FindComponent("UITable", "Offset/Rigth/FilterList/FilterScrollView/Table");
	mFilterScrollView = self:FindComponent("UIScrollView", "Offset/Rigth/FilterList/FilterScrollView");
	
	mSkillWrap = self:FindComponent("UIWrapContent", "Offset/Rigth/SkillList/SkillScrollView/SkillWrap");
	mWrapCall = UIWrapContent.OnInitializeItem(OnUpdateItem);
	mSkillItemPrefab = self:Find("Offset/Rigth/SkillList/SkillItemPrefab");
	mSkillItemPrefab.gameObject:SetActive(false);
	
	InitSkillItemPool();
end

function OnEnable(self)
	RegEvent(self);
	local isInitByNetInfo = SkillMgr.GetIsInitByNetInfo();
	if not isInitByNetInfo then
		SkillMgr.RequestSkillData();
	else
		GameEvent.Trigger(EVT.SKILL, EVT.UPDATE_INTEREST_SKILL_VIEW, fightHelperId, fragmentCount);
	end	
end

function OnDisable(self)
	UnRegEvent(self);
end

function RegEvent(self)
	GameEvent.Reg(EVT.SKILL, EVT.UPDATE_INTEREST_SKILL_VIEW, OnInitInterestSkillView);
	GameEvent.Reg(EVT.SKILL, EVT.INTEREST_SKILL_ADD, OnInterestSkillAdded);
	GameEvent.Reg(EVT.SKILL, EVT.INTEREST_SKILL_EQUIP, OnInterestEquiped);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.SKILL, EVT.UPDATE_INTEREST_SKILL_VIEW, OnInitInterestSkillView);
	GameEvent.UnReg(EVT.SKILL, EVT.INTEREST_SKILL_ADD, OnInterestSkillAdded);
	GameEvent.UnReg(EVT.SKILL, EVT.INTEREST_SKILL_EQUIP, OnInterestEquiped);
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Skill_Interest);
	elseif id > 0 and id < 10 then
		SelectSlotItem(id);
	elseif id >= SKILL_FILTER_ITEM_EVENT_ID_BASE and id < 1000 then
		mCurrentFilterIndex = id - SKILL_FILTER_ITEM_EVENT_ID_BASE;
		ResetSkillList()
	elseif id > 1000 then
		SelectSkillItem(id);
	end
	UIMgr.UnShowUI(AllUI.UI_Tip_SkillInfo);
end


function OnLongPress(id)
	if id > 1000 then
		SkillMgr.ShowPlayerSkillInfoTips(id, 1, nil, -210, 0);
	else
		UIMgr.UnShowUI(AllUI.UI_Tip_SkillInfo);
	end
end

function OnInitInterestSkillView()
	InitSkillFilterList();
	mCurrentFilterIndex = 1;
	ResetSkillList();
	InitSkillSlotList();
	SetSelectedSkillItem(- 1);
	mCurrentOperateModel = 1;
end

function InitSkillItemPool()
	for i = 1, SKILL_POOL_COUNT do
		local skillItem = {};
		skillItem.id = 0;
		skillItem.gameObject = mSelf:DuplicateAndAdd(mSkillItemPrefab, mSkillWrap.transform, i).gameObject;
		skillItem.gameObject:SetActive(true);
		skillItem.transform = skillItem.gameObject.transform;
		skillItem.skillIcon = skillItem.transform:Find("Icon"):GetComponent("UITexture");
		skillItem.skillIcon.gameObject:SetActive(false);
		skillItem.skillIconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.selectFlag = skillItem.transform:Find("SelectFlag"):GetComponent("UISprite");
		skillItem.selectFlag.gameObject:SetActive(false);
		skillItem.equipFlag = skillItem.transform:Find("EquipFlag"):GetComponent("UISprite");
		skillItem.equipFlag.gameObject:SetActive(false);
		skillItem.uiEvent = skillItem.transform:GetComponent("UIEvent");
		table.insert(mSkillItemPool, skillItem);
	end
end

function InitSkillFilterList()
	for k, v in ipairs(mSkillFilterPool) do
		UnityEngine.GameObject.DestroyImmediate(v.gameObject);
	end
	mSkillFilterPool = {};
	local filterList = SkillMgr.GetInterestSkillFilterList();
	for i = 1, #filterList + 1 do
		local filterItem = {};
		local filterContent = "";
		if i == 1 then
			filterContent = "全部";
		else
			filterContent = filterList[i - 1];
		end
		filterItem.gameObject = mSelf:DuplicateAndAdd(mFilterItemPrefab, mFilterTable.transform, i).gameObject;
		filterItem.gameObject:SetActive(true);
		filterItem.transform = filterItem.gameObject.transform;
		filterItem.filter = filterContent;
		filterItem.normalFilterLabel = filterItem.transform:Find("Normal/Label"):GetComponent("UILabel");
		filterItem.normalFilterLabel.text = filterContent;
		filterItem.heightLightFilterLabel = filterItem.transform:Find("HightLight/Label"):GetComponent("UILabel");
		filterItem.heightLightFilterLabel.text = filterContent;
		filterItem.toggle = filterItem.transform:GetComponent("UIToggle");
		filterItem.uiEvent = filterItem.transform:GetComponent("UIEvent");
		filterItem.uiEvent.id = SKILL_FILTER_ITEM_EVENT_ID_BASE + i;
		if i == 1 then
			filterItem.toggle.value = true;
		else
			filterItem.toggle.value = false;
		end
		table.insert(mSkillFilterPool, filterItem);
	end
	mFilterTable:Reposition();
	mFilterScrollView:ResetPosition();
end

function InitSkillSlotList()
	for k, v in ipairs(mSkillSlotList) do
		local skillId = SkillMgr.GetInterestSkillIdBySlotIndex(k);
		if skillId == - 1 then
			v.skillIcon.gameObject:SetActive(false);
		else
			v.skillIcon.gameObject:SetActive(true);
			mSkillSlotList[k].id = skillId;
			local skillInfo = SkillData.GetSkillInfo(skillId);
			v.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
		end
		v.selectFlag.gameObject:SetActive(false);
	end
	mCurrentSelectSlotIndex = - 1;
end

function ResetWrap()
	mSkillWrap:ResetWrapContent(#mSkillInfoList, mWrapCall);
end

function OnUpdateItem(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mSkillInfoList then
		local skillPoolItem = mSkillItemPool[index + 1];
		skillPoolItem.skillIcon.gameObject:SetActive(true);
		SetSkillItemInfo(index + 1, realIndex + 1);
	else
		local skillPoolItem = mSkillItemPool[index + 1];
		skillPoolItem.id = 0;
		skillPoolItem.uiEvent.id = -1;
		skillPoolItem.gameObject:SetActive(true);
		skillPoolItem.skillIcon.gameObject:SetActive(false);
	end
end

function SetSkillItemInfo(skillPollIndex, skillInfoIndex)
	local skillPoolItem = mSkillItemPool[skillPollIndex];
	local skillIdInfo = mSkillInfoList[skillInfoIndex];
	if not skillPoolItem or not skillIdInfo then return; end
	local skillInfo = SkillData.GetSkillInfo(skillIdInfo);
	skillPoolItem.id = skillIdInfo;
	skillPoolItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
	if skillPoolItem.id == mCurrentSelectSkillId then
		skillPoolItem.selectFlag.gameObject:SetActive(true);
	else
		skillPoolItem.selectFlag.gameObject:SetActive(false);
	end
	skillPoolItem.uiEvent.id = skillIdInfo;
end

function ResetSkillList()
	local filterItem = mSkillFilterPool[mCurrentFilterIndex];
	if filterItem == nil then return; end
	local filterContent = filterItem.filter;
	mSkillInfoList = SkillMgr.GetFilteredInterestSkillList(filterContent);
	--mSkillInfoList = SkillMgr.GetInterestSkillList();
	ResetWrap();
	if mCurrentOperateModel ==  OperateModel.Ope_Skill then
		SetSelectedSkillItem(- 1);
		mCurrentOperateModel = OperateModel.Ope_Normal;
	end
end

function SelectSlotItem(slotIndex)
	if mCurrentOperateModel == OperateModel.Ope_Normal then
		mCurrentSelectSlotIndex = slotIndex;
		mSkillSlotList[slotIndex].selectFlag.gameObject:SetActive(true);
		mCurrentOperateModel = OperateModel.Ope_Slot;
	elseif mCurrentOperateModel == OperateModel.Ope_Skill then
		--发送网络协议
		SkillMgr.RequestInterestSkillEquip(slotIndex, mCurrentSelectSkillId);
		SetSelectedSkillItem(- 1);
		mCurrentOperateModel = OperateModel.Ope_Normal;
	else
		if slotIndex ~= mCurrentSelectSlotIndex then
			if mSkillSlotList[mCurrentSelectSlotIndex].id ~= - 1 then
				--发送网络协议
				SkillMgr.RequestInterestSkillEquip(slotIndex, mSkillSlotList[mCurrentSelectSlotIndex].id);
			elseif mSkillSlotList[slotIndex].id ~= - 1 then
				--发送网络协议
				SkillMgr.RequestInterestSkillEquip(slotIndex, mSkillSlotList[slotIndex].id);
			end
		end
		mSkillSlotList[mCurrentSelectSlotIndex].selectFlag.gameObject:SetActive(false);
		mCurrentOperateModel = OperateModel.Ope_Normal;
	end
end

function SelectSkillItem(skillId)
	if mCurrentOperateModel == OperateModel.Ope_Normal then
		SetSelectedSkillItem(skillId);
		mCurrentOperateModel = OperateModel.Ope_Skill;
	elseif mCurrentOperateModel == OperateModel.Ope_Skill then
		if mCurrentSelectSkillId == skillId then
			SetSelectedSkillItem(- 1);
			mCurrentOperateModel = OperateModel.Ope_Normal;
		else
			SetSelectedSkillItem(skillId);
			mCurrentOperateModel = OperateModel.Ope_Skill;
		end
	else
		--发送网络协议
		SkillMgr.RequestInterestSkillEquip(mCurrentSelectSlotIndex, skillId);
		SetSelectedSkillItem(- 1);
		mSkillSlotList[mCurrentSelectSlotIndex].selectFlag.gameObject:SetActive(false);
		mCurrentOperateModel = OperateModel.Ope_Normal;
	end
end

function SetSelectedSkillItem(id)
	if id == mCurrentSelectSkillId then
		if mCurrentSelectSkillId ~= - 1 then
			for k, v in ipairs(mSkillItemPool) do
				if v.id == mCurrentSelectSkillId then
					v.selectFlag.gameObject:SetActive(false);
					break;
				end
			end
		end
		mCurrentSelectSkillId = - 1;
	else
		if mCurrentSelectSkillId ~= - 1 then
			for k, v in ipairs(mSkillItemPool) do
				if v.id == mCurrentSelectSkillId then
					v.selectFlag.gameObject:SetActive(false);
					break;
				end
			end
		end
		if id ~= - 1 then
			for k, v in ipairs(mSkillItemPool) do
				if v.id == id then
					v.selectFlag.gameObject:SetActive(true);
					break;
				end
			end
		end
		mCurrentSelectSkillId = id;
	end
end

function OnInterestSkillAdded(skillId)
	ResetSkillList();
end

function OnInterestEquiped(equipInfoList)
	for k, v in ipairs(equipInfoList) do
		local slotItem = mSkillSlotList[v.slotIndex];
		if slotItem ~= nil then
			if v.skillId == - 1 then
				slotItem.skillIcon.gameObject:SetActive(false);
				slotItem.id = - 1;
			else
				slotItem.skillIcon.gameObject:SetActive(true);
				local skillInfo = SkillData.GetSkillInfo(v.skillId);
				slotItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
				slotItem.id = v.skillId;
			end
		end
	end
end 