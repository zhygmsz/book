module("FightHelpMgr", package.seeall);
local FightHelperOwnState =
{
	Own = 1,
	Free = 2,
	Frag = 3,
	None = 4
}

local mFightHelperList = {};
local mFormationList = {};

local mFilteredFightHelpInfoList = {};
local mCurrentActiveFormationIndex = 1;

local FORMATION_COUNT = 3;
local FORMATION_SLOT_COUNT = 5;

function InitModule()
	InitFightHelperList();
	InitFormationList();
end

function InitFightHelperList()
	local fightHelperTableList = FightHelpData.GetFightHelperList();
	for k, v in pairs(fightHelperTableList) do
		local fightHelperInfo = {};
		fightHelperInfo.id = v.id;
		fightHelperInfo.profession = v.professionId;
		fightHelperInfo.quality = v.quality;
		fightHelperInfo.fragNeedCount = v.fagmentRequireCount;
		fightHelperInfo.ownState = FightHelperOwnState.None;
		fightHelperInfo.level = 1;
		fightHelperInfo.starLevel = 0;
		fightHelperInfo.fragCount = 0;
		fightHelperInfo.fightSkillInfoList = {};
		fightHelperInfo.travelSkillInfoList = {};
		table.insert(mFightHelperList, fightHelperInfo);
	end
end

function InitFightHelperInfo(data)
	for k, fightHelperData in ipairs(data) do
		for i, fightHelperInfo in ipairs(mFightHelperList) do
			if fightHelperInfo.id == fightHelperData.cbElfID then
				--助战属性
				fightHelperInfo.level = fightHelperData.cbElfLevel;
				fightHelperInfo.starLevel = fightHelperData.cbElfStarLevel;
				fightHelperInfo.fragCount = fightHelperData.cbElfDebeisNum;
				fightHelperInfo.freeFlag = fightHelperData.cbElfWkFree ~= 0 and true or false;
				--战斗技能
				for m, fightSkillData in ipairs(fightHelperData.cbElfComSkill) do
					local fightSkillInfo = {};
					fightSkillInfo.skillId = fightSkillData.cbElfSkillID;
					fightSkillInfo.skillLevel = fightSkillData.cbElfSkillLevel;
					table.insert(fightHelperInfo.fightSkillInfoList, fightSkillInfo)
				end
				--游历技能
				for m, travelSkillData in ipairs(fightHelperData.cbElfTourSkill) do
					local travelSkillInfo = {};
					travelSkillInfo.skillId = travelSkillData.cbElfSkillID;
					travelSkillInfo.skillLevel = travelSkillData.cbElfSkillLevel;
					table.insert(fightHelperInfo.travelSkillInfoList, travelSkillInfo);
				end
				UpdateFightHelperOwnState(fightHelperInfo);
				break;
			end
		end
	end
end

function InitFormationList()
	for i = 1, FORMATION_COUNT do
		local formationItem = {};
		formationItem.formationId = 0;
		formationItem.state = i == 1 and CombatElf_pb.FPS_WORK or CombatElf_pb.FPS_FREE;
		formationItem.fightHelperList = {};
		for r = 1, FORMATION_SLOT_COUNT do
			--id为0代表玩家，-1代表空位
			--改-----------------------------------------------------------------------------------------------------------------------
			local fightHelperId = r == 1 and 0 or -1;
			table.insert(formationItem.fightHelperList, fightHelperId);
		end
		table.insert(mFormationList, formationItem);
	end
	mCurrentActiveFormationIndex = 1;
end

function InitFormationInfo(data)
	for k, v in ipairs(data) do
		local formationItem = mFormationList[v.ftProjectIndex + 1];
		if formationItem == nil then return; end
		formationItem.formationId = v.tcGroupID;
		formationItem.state = v.ftProjectState;
		for n, r in ipairs(v.cbElfList) do
			formationItem.fightHelperList[n] = r;
		end
	end
end

function SortFightHelperList()
	local function starInfoSort(a, b)
		local r;
		local ao = a.ownState;
		local bo = b.ownState;
		local as = a.starLevel;
		local bs = b.starLevel;
		local af = a.fagmentCount;
		local bf = b.fagmentCount;
		local aq = a.quality;
		local bq = b.quality;
		local ap = a.profession;
		local bp = b.profession;
		
		if ao == bo then
			if as == bs then
				if af == bf then
					if aq == bq then
						r = ap < bp;
					else
						r = aq > bq;
					end
				else
					r = af > bf
				end
			else
				r = as > bs
			end
		else
			r = ao < bo;
		end
		return r
	end
	table.sort(mFightHelperList, starInfoSort);
end

--助战数据初始化
function OnGetFightHelpInfo(msg)
	InitFightHelperInfo(msg.fightAssistData.combatElfInfo);
	--InitFormationInfo(msg.fightAssistData.fightAssistProject);
	SortFightHelperList();
end

--更新助战拥有状态
function UpdateFightHelperOwnState(fightHelperInfo)
	if fightHelperInfo.starLevel > 0 then
		fightHelperInfo.ownState = FightHelperOwnState.Own;
	elseif fightHelperInfo.freeFlag then
		fightHelperInfo.ownState = FightHelperOwnState.Free;
		fightHelperInfo.starLevel = 1;
	elseif fightHelperInfo.fragCount > 0 then
		fightHelperInfo.ownState = FightHelperOwnState.Frag;
	else
		fightHelperInfo.ownState = FightHelperOwnState.None;
	end
end

function GetNewFightHelper(newFightHelperInfo)
	--修改数据
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == newFightHelperInfo.fightHelperId then
			fightHelperInfo.starLevel = newFightHelperInfo.starLevel;
			fightHelperInfo.fagmentCount = newFightHelperInfo.fagmentCount;
			UpdateFightHelperOwnState(fightHelperInfo);
			SortFightHelperList();
			break;
		end
	end
	--提示信息
	local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(fightHelperInfo.fightHelperId);
	local fightHelperName = fightHelperBaseInfo.name;
	local tipStr = WordData.GetWordStringByKey("FightHelp_Recruit_Haved", fightHelperName);
	TipsMgr.TipCommon(tipStr);
end

--获取助战的拥有状态
function GetFightHelperOwnState(fightHelperId)
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == fightHelperId then
			return fightHelperInfo.ownState;
		end
	end
	return nil;
end

--获取助战是否处于出战状态
function GetIsInCurrentFormation(fightHelperId)
	for k, formationInfo in ipairs(mFormationList) do
		if formationInfo.state == CombatElf_pb.FPS_WORK then
			for r, Id in ipairs(formationInfo.fightHelperList) do
				if Id == fightHelperId then
					return true;
				end
			end
		end
	end
	return false;
end

--通过助战Id下阵
function WithdrawFromCurrentFormation(fightHelperId)
	local isFind = false;
	local slotIndex = r;
	local currentFormationInfo = mFormationList[mCurrentActiveFormationIndex];
	if currentFormationInfo == nil then return; end
	for r, id in ipairs(currentFormationInfo.fightHelperList) do
		if id == fightHelperId then
			slotIndex = r;
			isFind = true;
			break;
		end
	end
	if isFind == true then
		RequireFightHelperActive(fightHelperId, mCurrentActiveFormationIndex, slotIndex, false);
	end
end

--根据类型筛选助战
function GetFightHelperFilterList(filterIndex)
	if filterIndex == 0 then
		return mFightHelperList;
	else
		table.clear(mFilteredFightHelpInfoList);
		for k, v in ipairs(mFightHelperList) do
			local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(v.id);
			if fightHelperBaseInfo.professionId == filterIndex then
				table.insert(mFilteredFightHelpInfoList, v);
			end
		end
		return mFilteredFightHelpInfoList;		
	end
end

--获取助战信息
function GetFightHelpInfo(fightHelpId)
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == fightHelpId then
			return fightHelperInfo;
		end
	end
	return nil;
end

function GetFormationMember(formationIndex)
	if mFormationList[formationIndex] then
		return mFormationList[formationIndex].fightHelperList;
	end
end

function GetFightHelpStarInfo(fightHelperId, starLevel)
	return FightHelpData.GetFightHelpStarInfo(fightHelperId, starLevel);
end


--获取助战技能等级
function GetFightHelpSkillLevel(fightHelpId, skillId)
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == fightHelpId then
			for r, fightSkillInfo in ipairs(fightHelperInfo.fightSkillInfoList) do
				if fightSkillInfo.skillId == skillId then
					return fightSkillInfo.skillLevel;
				end
			end
			for r, travelSkillInfo in ipairs(fightHelperInfo.travelSkillInfoList) do
				if travelSkillInfo.skillId == skillId then
					return travelSkillInfo.skillLevel;
				end
			end
		end
	end
	return 0;
end

--获取当前启用的阵型方案索引
function GetCurrentFormationIndex()
	return mCurrentActiveFormationIndex;
end

--获取阵型方案信息
function GetFormationInfoByIndex(index)
	return mFormationList[index];
end

--助战升星请求
function FightHelperStarUp(fightHelperId)
	local msg = NetCS_pb.CSCombatElfLiftStar();
	msg.combatElfID = fightHelperId;
	GameNet.SendToGate(msg);
end

--助战升星响应
function OnFightHelperStarLevelUp(msg)
	if msg.ret ~= 0 then return; end
	local starUpInfo = {};
	starUpInfo.fightHelperId = msg.combatElfInfo.cbElfID;
	starUpInfo.starLevel = msg.combatElfInfo.cbElfStarLevel;
	starUpInfo.fagmentCount = msg.combatElfInfo.cbElfDebeisNum;
	
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == starUpInfo.fightHelperId then
			fightHelperInfo.starLevel = starUpInfo.starLevel;
			fightHelperInfo.fagmentCount = starUpInfo.fagmentCount;
			UpdateFightHelperOwnState(fightHelperInfo);
			--排列顺序
			SortFightHelperList();
			--发送事件
			GameEvent.Trigger(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, starUpInfo);
			break;
		end
	end
end

--周免助战更新
function OnGetFreeFightHelperInfo(msg)
	local fightHelperId = msg.combatElfID;
	local fragmentCount = msg.combatElfDebeis;
end

--启用阵型请求
function SetActiveFormation(formationIndex)
	local msg = NetCS_pb.CSFtAtProjectUsed();
	msg.ftAtProjectIndex = formationIndex - 1;
	GameNet.SendToGate(msg);
end

--启用阵型响应
function OnSetFormationItemUsed(msg)
	if ret ~= 0 or mFormationList[msg.fightAssistProject.ftProjectIndex + 1] == nil then return; end
	mCurrentActiveFormationIndex = msg.fightAssistProject.ftProjectIndex + 1;
	for k, formationInfo in ipairs(mFormationList) do
		if formationInfo.state == CombatElf_pb.FPS_WORK then
			formationInfo.state = CombatElf_pb.FPS_FREE;
			break;
		end
	end
	mFormationList[msg.fightAssistProject.ftProjectIndex + 1].state = CombatElf_pb.FPS_WORK;
	GameEvent.Trigger(EVT.FIGHTHELP, EVT.FIGHTHELP_USEFORMATION, mCurrentActiveFormationIndex)
end

--助战碎片数量发生变化
function OnFightHelperFragmentCountChanged(msg)
	if msg.ret ~= 0 then return; end
	local fragmentChangeInfo = {};
	fragmentChangeInfo.fightHelperId = msg.combatElfID;
	fragmentChangeInfo.fragmentCount = msg.combatElfDebeis;
	for k, fightHelperInfo in ipairs(mFightHelperList) do
		if fightHelperInfo.id == fragmentChangeInfo.fightHelperId then
			fightHelperInfo.fagmentCount = fragmentChangeInfo.fagmentCount;
			--排列顺序
			SortFightHelperList();
			--发送事件
			GameEvent.Trigger(EVT.FIGHTHELP, EVT.FIGHTHELP_FRAGMENT_COUNT_CHANGED, fragmentChangeInfo);
		end
	end
end

--招募助战
function RequireRecruitFightHelper(typeIndex)
	local msg = NetCS_pb.CSCombatElfEnlist();
	msg.enlistID = typeIndex;
	GameNet.SendToGate(msg);
end

--获得新的助战
function OnGetNewFightHelper(msg)
	if msg.combatUpType == NetCS_pb.SCUpdateCombatElfInfo.CUT_ADD then
		local fightHelperInfo = {};
		fightHelperInfo.fightHelperId = msg.combatElfInfo.cbElfID;
		fightHelperInfo.starLevel = msg.combatElfInfo.cbElfStarLevel;
		fightHelperInfo.fagmentCount = msg.combatElfInfo.cbElfDebeisNum;
		GetNewFightHelper(fightHelperInfo);
	end
end

--助战上下阵请求
function RequireFightHelperActive(fightHelperId, formationIndex, slotIndex, isActive)
	local msg = NetCS_pb.CSFtAtProjectCbEfOper();
	msg.ftAtProjectIndex = formationIndex - 1;
	msg.ftAtProjectPos = slotIndex - 1;
	msg.combatElfID = fightHelperId;
	if isActive then
		msg.combatElfState = CombatElf_pb.CES_WORK;
	else
		msg.combatElfState = CombatElf_pb.CES_FREE;
	end
	GameNet.SendToGate(msg);
end

--助战上下阵响应
function OnFightHelperActive(msg)
	if msg.ret ~= 0 then return; end
	local formationIndex = msg.fightAssistProject.ftProjectIndex + 1;
	if mFormationList[formationIndex] == nil then return; end
	for k, v in ipairs(msg.fightAssistProject.cbElfList) do
		mFormationList[formationIndex].fightHelperList[k] = msg.fightAssistProject.cbElfList[k];
	end
	TipsMgr.TipByKey("FightHelp_Formation_Update");
	GameEvent.Trigger(EVT.FIGHTHELP, EVT.FIGHTHELP_FORMATIONCHANGED, formationIndex);
end

--助战位置交换请求
function RequireFightHelperExchange(formationIndex, srcSlotIndex, dstSlotIndex)
	local msg = NetCS_pb.CSFtAtProjectCbEfSwap();
	msg.ftAtProjectIndex = formationIndex - 1;
	msg.srcFtAtProjectPos = srcSlotIndex - 1;
	msg.dstFtAtProjectPos = dstSlotIndex - 1;
	GameNet.SendToGate(msg);
end

--助战位置交换响应
function OnSlotFightHelperExchange(msg)
	if msg.ret ~= 0 then return; end
	if mFormationList[msg.tacticGroupID + 1] then
		mFormationList[msg.tacticGroupID + 1].fightHelperList[msg.tacticGroupIdx1 + 1] = msg.combatElfID1;
		mFormationList[msg.tacticGroupID + 1].fightHelperList[msg.tacticGroupIdx2 + 1] = msg.combatElfID2;
	end
	GameEvent.Trigger(EVT.FIGHTHELP, EVT.FIGHTHELP_EXCHANGE, msg.tacticGroupID + 1, msg.tacticGroupIdx1 + 1, msg.combatElfID1, msg.tacticGroupIdx2 + 1, msg.combatElfID2);
end

return FightHelpMgr; 