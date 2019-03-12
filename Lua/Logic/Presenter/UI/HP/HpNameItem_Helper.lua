
local M = {}

M.PLAYER = 1
M.HELPER = 2
M.MONSTER = 3
M.PET = 4
M.GREENNPC = 5

--玩家自己
M.SelfHpColor = Color.New(237 / 255, 237 / 255, 237 / 255, 1)
--敌方玩家，敌方助战，红名怪
M.EnemyHpColor = Color.New(254 / 255, 154 / 255, 127 / 255, 1)
--队友，我的助战，队友助战
M.TeamHpColor = Color.New(124 / 255, 237 / 255, 255 / 255, 1)
--中立怪，参战类npc
M.NeutralHpColor = Color.New(253 / 255, 237 / 255, 61 / 255, 1)
--同属一个帮会的
M.FactionHpColor = Color.New(255 / 255, 174 / 255, 0 / 255, 1)
--路人（友方），有善类npc
M.PasserbyHpColor = Color.New(87 / 255, 255 / 255, 123 / 255, 1)

--宠物名字颜色待定
--可以把以下赋值挪到编辑器功能里，这样美术跳字数字图片文件名如何变化，程序都不需要改动
M.JumpWord_Non = - 1 --无效值
M.JumpWord_CutHpToMonster = 3 --普通伤害-对怪物（泛指所有的红名类型，不管怪物，敌对玩家）
M.JumpWord_AddMp = 4 --回蓝
M.JumpWord_CutHpToPlayer = 6 --普通伤害-对玩家
M.JumpWord_AddHp = 7 --加血
M.JumpWord_CutHpCrit = 8 --暴击伤害
M.JumpWord_AddHpCrit = 9 --暴击加血
M.JumpWord_Dot = 5 --持续伤害

--是否有血条缓动
--敌方玩家，敌方玩家的助战，特殊怪，目前这三种类型
function M.HasFalseHp(target)
	if M.IsEnemy(target) then
		return true
	end
	
	if M.IsEnemyHelper(target) then
		return true
	end
	
	if M.MonsterIsSpecial(target) then
		return true
	end

	if M.IsSelf(target) then
		return true
	end
	
	return false
end

--是否有真血条
function M.HasTrueHp(target)
	local hpNameType = M.GetHpNameType(target)
	if hpNameType == M.PLAYER 
	or hpNameType == M.HELPER 
	or hpNameType == M.MONSTER then
		return true
	end
end

function M.IsSelf(target)
	if target and target:GetType() == EntityDefine.ENTITY_TYPE.PLAYER_MAIN then
		return true
	else
		return false
	end
end

--判断是否为助战
function M.IsHelper(target)
	if target and target:GetType() == EntityDefine.ENTITY_TYPE.HELPER then
		return true
	else
		return false
	end
end

--是否是我的助战
function M.IsMyHelper(target)
	--TODO 助战实体逻辑
	return true
end

--红名 <==> 可攻击
function M.IsRed(target)
	if target then
		local mainPlayer = MapMgr.GetMainPlayer();
		if mainPlayer then
			return mainPlayer:GetCampComponent():IsRed(target)
		else
			return false
		end
	else
		return false
	end
end

--判断一个PlayerEntity是否为我的队友
function M.IsTeammate(target)
	return false
end

--敌方玩家
function M.IsEnemy(target)
	if M.IsRed(target) and M.IsPlayer(target) then
		return true
	else
		return false
	end
end

--敌方玩家的助战
function M.IsEnemyHelper(target)
	return true
end

--绿名路人
function M.IsGreenPlayer(target)
	if M.IsGreen(target) and M.IsPlayer(target) then
		return not M.IsTeammate(target)
	else
		return false
	end
end

--是否是特殊怪（有用于显示在姓名版上的技能的，血条同player样式一样的）
--特殊怪<==>特殊技能
function M.MonsterIsSpecial(target)
	if M.IsNpc(target) and M.IsRed(target) then
		return target:GetNPCType() == Common_pb.NPC_SPECIAL_CRITTERS
	else
		return false
	end
end

--显示白字伤害的目标判定
function M.IsJumpWordForCutHp(target)
	if target then
		return M.IsRed(target)
	else
		return false
	end
end

--判断是否是一个npc类型
function M.IsNpc(target)
	if target then
		return(target:GetType() == EntityDefine.ENTITY_TYPE.NPC)
	else
		return false
	end
end

function M.IsPlayer(target)
	if target then
		return target:GetType() == EntityDefine.ENTITY_TYPE.PLAYER
	else
		return false
	end
end

--是否和我相关（包括我的宠物）
--助战跳字目前逻辑：当我一个人时，助战的跳字可见，当组队时，不可见
function M.IsAboutMe(target)
	if M.IsSelf(target) then
		return true
	end
	
	if M.IsMyHelper(target) then
		return true
	end
	
	return false
end

--判断我是否在一个队伍里
function M.InATeam()
	return false
end

function M.GetHpNameType(target)
	if not target == nil then
		return - 1
	end
	
	local entityType = target:GetType()
	if entityType == EntityDefine.ENTITY_TYPE.PLAYER or entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN then
		return M.PLAYER
	elseif entityType == EntityDefine.ENTITY_TYPE.NPC then
		local npcType = target:GetNPCType()
		if npcType == Common_pb.NPC_CRITTERS then
			--"小怪"类型，敌对阵营：小怪，友方阵营：友善类npc
			if M.IsGreen(target) then
				return M.GREENNPC
			elseif M.IsRed(target) then
				return M.MONSTER
			end
		elseif npcType == Common_pb.NPC_HELPER then
			return M.HELPER
		elseif npcType == Common_pb.NPC_SPECIAL_CRITTERS then
			return M.MONSTER
		elseif npcType == Common_pb.NPC_ORGAN then
			--机关不显示姓名血条
			return -1
		elseif M.IsGreen(target) then
			return M.GREENNPC
		else
			--后续判断，宠物
		end
	elseif entityType == EntityDefine.ENTITY_TYPE.PET  then
		return M.PET
	end
	
	return - 1
end

--友好阵营判断
function M.IsGreen(target)
	if target then
		local mainPlayer = MapMgr.GetMainPlayer();
		if mainPlayer then
			return mainPlayer:GetCampComponent():IsGreen(target)
		else
			return false
		end
	else
		return false
	end
end

--是否有buff倒计时
--我，我的助战，队友，敌方玩家，敌方玩家的助战，特殊怪
function M.HasBuffCountDown(target)
	if M.IsSelf(target) then
		return true
	end
	
	if M.IsMyHelper(target) then
		return true
	end
	
	if M.IsTeammate(target) then
		return true
	end
	
	if M.IsEnemy(target) then
		return true
	end
	
	if M.IsEnemyHelper(target) then
		return true
	end
	
	if M.MonsterIsSpecial(target) then
		return true
	end
	
	return false
end

--判断是否同属一个帮会
function M.IsSameFaction(target)
	return false
end

function M.CheckIsDotType(effectType)
	if effectType == StatusInfo_pb.StatusEffect.BUFF_EFFECT_DOT_HP_PHYSIC or
	effectType == StatusInfo_pb.StatusEffect.BUFF_EFFECT_DOT_HP_MAGIC then
		return true
	end
	return false
end

--检测是否是Dot类伤害
--因为Dot的含义是持续性属性修改，正值代表加血，负值代表伤害
function M.CheckIsDot(buffEffectID, deltaValue)
	local isDot = false
	
	if buffEffectID and buffEffectID ~= - 1 then
		local buffEffectData = BuffData.GetBuffEffectData(buffEffectID)
		if buffEffectData then
			if M.CheckIsDotType(buffEffectData.effectType) then
				if deltaValue < 0 then
					isDot = true
				end
			end
		end
	end
	
	return isDot
end

function M.CheckNeedHpInPlayer(target)
	if M.IsSelf(target) then
		return true
	end

	if M.IsTeammate(target) then
		return true
	end

	if M.IsEnemy(target) then
		return true
	end
	
	return false
end

return M
