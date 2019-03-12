module("UI_HP_Main", package.seeall)

require("Logic/Presenter/UI/HP/DamageNumber").InitModule()

local HpNameItem_Player = require("Logic/Presenter/UI/HP/HpNameItem_PlayerEx")
local HpNameItem_Monster = require("Logic/Presenter/UI/HP/HpNameItem_MonsterEx")
local HpNameItem_GreenNpc = require("Logic/Presenter/UI/HP/HpNameItem_GreenNpcEx")
local HpNameItem_Helper = require("Logic/Presenter/UI/HP/HpNameItem_Helper")
local HpNameItem_Pet = require("Logic/Presenter/UI/HP/HpNameItem_Pet")

--组件
local mPlayerItem = nil
local mMonsterItem = nil
local mPetItem = nil
local mNpcItem = nil
local mSelf = nil
local mSelfRoot = nil
local mOtherAllRoot = nil
local mPanel
local mSelfPanel

local mPlayerItemIdx = 0
local mMonsterItemIdx = 0
local mPetItemIdx = 0
local mNpcItemIdx = 0

local mTempGo
local mTempTrs

--变量
local mHintFightLoader
local mUnusedPlayerItem = {} --助战也在player
local mUnusedMonsterItem = {} --怪物
local mUnusedPetItem = {} --宠物
local mUnusedGreenNpcItem = {} --友善NPC
local mLastRandomNumX = - 1
local mLastRandomNumY = - 1
local mMaxRandomTimes = 5

--测试
local mInputHurt  --伤害跳字
local mInputStatus  --状态跳字

--添加一个PlayerEntity成为队友
--失去一个PlayerEntity队友，这两个要发出事件，及时更新他们姓名版
--我加入一个队伍
--我离开一个队伍，这两个要发出事件，及时更新头顶姓名版，是否可以和上两个合并
--local方法
local function SetAlpha(value)
	mPanel.alpha = value
	mSelfPanel.alpha = value
end

local function GetUnusedTable(hpNameType)
	local unused = nil
	if hpNameType == HpNameItem_Helper.PLAYER or hpNameType == HpNameItem_Helper.HELPER then
		unused = mUnusedPlayerItem
	elseif hpNameType == HpNameItem_Helper.MONSTER then
		unused = mUnusedMonsterItem
	elseif hpNameType == HpNameItem_Helper.GREENNPC then
		unused = mUnusedGreenNpcItem
	elseif hpNameType == HpNameItem_Helper.PET then
		unused = mUnusedPetItem
	end
	return unused
end

local function GetNewItem(hpNameType, isSelf)
	local unused = GetUnusedTable(hpNameType)
	if unused and #unused > 0 then
		local item = table.remove(unused, #unused)
		return item
	else
		--区分出player|helper,monster,pet,npc
		if hpNameType == HpNameItem_Helper.PLAYER or hpNameType == HpNameItem_Helper.HELPER then
			local trs = nil
			local childPath = nil
			if isSelf then
				trs = mSelf:DuplicateAndAdd(mPlayerItem, mSelfRoot, 0)
				childPath = "Offset/Self/PlayerItemEx"
			else
				trs = mSelf:DuplicateAndAdd(mPlayerItem, mOtherAllRoot, 0)
				childPath = "Offset/OtherAll/PlayerItemEx"
			end
			mPlayerItemIdx = mPlayerItemIdx + 1
			trs.name = "PlayerItemEx" .. tostring(mPlayerItemIdx)
			local item = HpNameItem_Player.new(mSelf, childPath .. tostring(mPlayerItemIdx), hpNameType)
			return item
		elseif hpNameType == HpNameItem_Helper.MONSTER then
			local trs = mSelf:DuplicateAndAdd(mMonsterItem, mOtherAllRoot, 0)
			mMonsterItemIdx = mMonsterItemIdx + 1
			trs.name = "MonsterItemEx" .. tostring(mMonsterItemIdx)
			local item = HpNameItem_Monster.new(mSelf, "Offset/OtherAll/MonsterItemEx" .. tostring(mMonsterItemIdx), hpNameType)
			return item
		elseif hpNameType == HpNameItem_Helper.GREENNPC then
			local trs = mSelf:DuplicateAndAdd(mNpcItem, mOtherAllRoot, 0)
			mNpcItemIdx = mNpcItemIdx + 1
			trs.name = "NpcItemEx" .. tostring(mNpcItemIdx)
			local item = HpNameItem_GreenNpc.new(mSelf, "Offset/OtherAll/NpcItemEx" .. tostring(mNpcItemIdx), hpNameType)
			return item
		elseif hpNameType == HpNameItem_Helper.PET then
			local trs = mSelf:DuplicateAndAdd(mPetItem, mOtherAllRoot, 0)
			mPetItemIdx = mPetItemIdx + 1
			trs.name = "PetItem" .. tostring(mPetItemIdx)
			local item = HpNameItem_Pet.new(mSelf, "Offset/OtherAll/PetItem" .. tostring(mPetItemIdx), hpNameType)
			return item
		end
	end
end

local function OnDeleteEntity(target)
	if not target then
		GameLog.LogError("UI_HP_Main.OnDeleteEntity -> target is nil")
		return
	end
	
	--local unusedItem = target:GetHpNameItem()
	local unusedItem = HpNameMgr.GetHpNameItemByEntity(target)
	
	--TODO BUFF整理,删除直接在BUFF上注册回调方法,后续改为统一的事件注册
	
	if not unusedItem then
		GameLog.Log("UI_HP_Main.OnDeleteEntity -> unusedItem is nil, id = %s, name = %s", target:GetID(), target:GetName())
		return
	end
	unusedItem:Clean()

	local unusedTable = GetUnusedTable(unusedItem:GetHpNameType())
	if unusedTable then
		table.insert(unusedTable, unusedItem)
	end
end

--场景里的entity隐藏/显现
local function OnEntityActive(target, active)
	if not target then
		GameLog.LogError("UI_HP_Main.OnEntityActive -> target is nil")
		return
	end
	--local hpNameItem = target:GetHpNameItem()
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(target)
	if hpNameItem then
		--暂时先隐藏，可能会在隐藏过程中有动态变化，等再次显示没有及时更新问题，先不管
		--这个问题和同一个item刷新不同样式有关
		--解决方案：对于每一个HpNameItem类型，参照UI的开发原则，在onenable里做初始UI显示
		--在ondisable里做重置逻辑，不管item被怎么关闭打开，每次打开的时候执行onenable方法
		--item的显示总是和target的数据对应起来
		--玩家下线再上线后，buff数据估计会清空，也就是说新上线的玩家buff数据为空
		--中了buff的玩家，进到新场景后，如果在新场景创建角色的时候，buff数据还没结束，则要在显示血条的时候恢复buff倒计时
		hpNameItem:SetVisible(active)
	else
		GameLog.LogError("UI_HP_Main.OnEntityActive -> target.hpNameItem is nil, id = %s, name = %s", target:GetID(), target:GetName())
	end
end

--血量变化
--attacker：Entity
--target：Entity
local function OnHPChange(attacker, target, deltaValue, crit, buffEffectID)
	if not target then
		GameLog.LogError("UI_HP_Main.OnHPChange -> target is nil")
		return
	end

	--伤害跳字
	DamageNumber.OnDamage(attacker,target,deltaValue,true,crit,false);

	--同步到血条
	--暂定没有血条
	--[[
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(target)
	if hpNameItem and HpNameItem_Helper.HasTrueHp(target) then
		hpNameItem:SetHpValue(target:GetPropertyComponent():GetHP(), target:GetPropertyComponent():GetHPMax())
	end
	--]]
end

--attacker:Entity
--target:Entity
local function OnImmune(attacker, target, immuneType)
	DamageNumber.OnImmune(attacker, target, immuneType)
end

--attacker:Entity
--target:Entity
local function OnMiss(attacker, target)
	DamageNumber.OnMiss(attacker, target)
end

local function OnAddBuff(buffGroup)
	DamageNumber.OnStatus(buffGroup._attacker,buffGroup._buffComponent._entity,buffGroup);
end

local function OnRemoveBuff()
end

--蓝
local function OnModifyMP(attacker, target, deltaValue, crit)
	--同步到蓝条
end

--经验增加
local function OnExpAdd(deltaValue)
	DamageNumber.OnItemAdd(deltaValue);
end

--货币增加
local function OnCoinAdd(deltaValue)
	DamageNumber.OnItemAdd(deltaValue);
end

--进入战斗场景
local function OnEnterFightScene(target)
	if not target then
		GameLog.LogError("UI_HP_Main.OnEnterFightScene -> target is nil")
		return
	end
	--local hpNameItem = target:GetHpNameItem()
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(target)
	if hpNameItem then
		hpNameItem:OnEnterFightScene()
	end
end

--离开战斗场景
local function OnLeaveFightScene(target)
	if not target then
		GameLog.LogError("UI_HP_Main.OnLeaveFightScene -> target is nil")
		return
	end
	--local hpNameItem = target:GetHpNameItem()
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(target)
	if hpNameItem then
		hpNameItem:OnLeaveFightScene()
	end
end

local function OnAddEntity(target)
	if not target then
		GameLog.LogError("UI_HP_Main.OnAddEntity -> target is nil")
		return
	end
	
	--有姓名版，直接返回，add和delete事件出错
	if HpNameMgr.GetHpNameItemByEntity(target) then
		GameLog.LogError("UI_HP_Main.OnAddEntity -> target has hpNameItem, id = %s, name = %s", target:GetID(), target:GetName())
		return
	end
	
	--TODO BUFF整理,删除直接在BUFF上注册回调方法,后续改为统一的事件注册
	
	local hpNameType = HpNameItem_Helper.GetHpNameType(target)
	local isSelf = HpNameItem_Helper.IsSelf(target)
	local item = GetNewItem(hpNameType, isSelf)
	if item then
		--不管什么类型的item，都有该方法
		item:ResetTarget(target)
	end
end

local function ShowAllHpNameItem()
	local charactors = MapMgr.GetAllCharactor()
	for _, charactor in pairs(charactors) do
		if charactor then
			OnAddEntity(charactor)
		end
	end
end

--target:entity
local function OnCampChange(target)
	if target then
		local entityID = target:GetID()
		local entityName = target:GetName()
		GameLog.Log("UI_HP_Main.OnCampChange -> entityID = %s, entityName = %s", entityID, entityName)
		OnDeleteEntity(target)
		OnAddEntity(target)
	else
		GameLog.LogError("UI_HP_Main.OnCampChange -> target is nil")
	end
end

--称号
local function OnTitleChange(entity)
	--local hpNameItem = entity:GetHpNameItem()
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(entity)
	if hpNameItem then
		hpNameItem:SetTitle(entity);
	end
end

local function OnPetNameUpdate(entity)
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(entity)
	if hpNameItem then
		local finalName = WordData.GetWordStringByKey("Pet_Title_Inscene", entity:GetMasterName(), entity:GetName());
		hpNameItem:SetName(finalName)
	end
end

local function OnStoryEnter()
	HideHpNameUI()
end

local function OnStoryFinish()
	ShowHpNameUI()
end

--[[
    @desc: 高度变化
    --@target: 
]]
local function OnEntityHeightChange(target)
	local hpNameItem = HpNameMgr.GetHpNameItemByEntity(target)
	if hpNameItem then
		hpNameItem:OnHeightChange()
	end
end

local function RegEvent(self)
	--实体增删和BUFF状态
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_CREATE,OnAddEntity);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_DELETE,OnDeleteEntity);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_HP_UPDATE,OnHPChange);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_IMMUNE_BUFF,OnImmune);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_MISS_BUFF,OnMiss);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_ADD_BUFF,OnAddBuff);
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_REMOVE_BUFF,OnRemoveBuff);
	--实体属性刷新
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_PET_NAME, OnPetNameUpdate)
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_CAMP,OnCampChange);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT, OnEntityHeightChange)
	--玩家数据刷新
	GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_EXP_ADD,OnExpAdd)
	GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_SYNCCOIN,OnCoinAdd);

	GameEvent.Reg(EVT.TITLE,EVT.TITLE_PLAYER_RESET,OnTitleChange);
	GameEvent.Reg(EVT.STORY,EVT.STORY_ENTER, OnStoryEnter)
	GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH, OnStoryFinish)
end

local function UnRegEvent(self)
	--实体增删和BUFF状态
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_CREATE,OnAddEntity);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_DELETE,OnDeleteEntity);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_HP_UPDATE,OnHPChange);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_IMMUNE_BUFF,OnImmune);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_MISS_BUFF,OnMiss);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_ADD_BUFF,OnAddBuff);
	GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_REMOVE_BUFF,OnRemoveBuff);

	--实体属性刷新
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_PET_NAME, OnPetNameUpdate)
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_CAMP,OnCampChange);

	GameEvent.UnReg(EVT.TITLE,EVT.TITLE_PLAYER_RESET,OnTitleChange);
	GameEvent.UnReg(EVT.STORY,EVT.STORY_ENTER, OnStoryEnter)
	GameEvent.UnReg(EVT.STORY,EVT.STORY_FINISH, OnStoryFinish)

	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT, OnEntityHeightChange)
end

--全局方法
function OnCreate(self)
	mSelf = self
	
	mOtherAllRoot = self:Find("Offset/OtherAll")
	mSelfRoot = self:Find("Offset/Self")
	mPlayerItem = self:Find("Offset/PlayerItemEx")
	mMonsterItem = self:Find("Offset/MonsterItemEx")
	mPetItem = self:Find("Offset/PetItem")
	mNpcItem = self:Find("Offset/NpcItemEx")
	mPanel = self:Find("Offset").parent:GetComponent(typeof(UIPanel))
	mSelfPanel = self:FindComponent("UIPanel", "Offset/Self")
	
	mPlayerItem.localPosition = Vector3.zero
	mMonsterItem.localPosition = Vector3.zero
	mPetItem.localPosition = Vector3.zero
	mNpcItem.localPosition = Vector3.zero
	
	mPlayerItem.gameObject:SetActive(false)
	mMonsterItem.gameObject:SetActive(false)
	mPetItem.gameObject:SetActive(false)
	mNpcItem.gameObject:SetActive(false)
	
	--测试
	mInputHurt = self:FindComponent("UIInput", "Offset/Debug/Offset1/Input")
	mInputStatus = self:FindComponent("UIInput", "Offset/Debug/Offset2/Input")
end

function OnEnable(self)
	HpNameMgr.SetIsShowed(true)
	ShowAllHpNameItem()
	RegEvent(self)
end

function OnDisable(self)
	UnRegEvent(self)
	HpNameMgr.SetIsShowed(false)
end
--[[
    @desc: 引入SuperTextMesh后，隐藏显示换成移动位置
    author:{author}
    time:2019-03-12 17:06:16
    @return:
]]
function ShowHpNameUI()
	SetAlpha(1)
end

function HideHpNameUI()
	SetAlpha(0.01)
end
