--伤害数字
module("DamageNumber", package.seeall)
require("Logic/Presenter/UI/HP/DamageNumber_Param")
local DamageParam = DamageNumber_Param.DamageParam;

local mLastOffsetX = DamageParam.RandomData.lastOffsetX
local mMaxOffsetX = DamageParam.RandomData.maxOffsetX
local mLastOffsetY = DamageParam.RandomData.lastOffsetY
local mMaxOffsetY = DamageParam.RandomData.maxOffsetY
local mRandomThreshold = DamageParam.RandomData.randomThreshold
local mMaxRandomTimes = DamageParam.RandomData.maxRandomTimes

local mDamageAtlas;
local mDamageShader;

local mWorldPos = Vector3.zero;

local function GetRandomOffset(lastOffset,maxOffset,maxRandomTime,randomThreshold)
	local randomOffset = 0
	for idx = 1, maxRandomTime do
		randomOffset = math.random(1, 2 * maxOffset)
		if math.abs(randomOffset - lastOffset) >= randomThreshold then break end
	end
	local finalOffset = 0;
	if 1 <= randomOffset and randomOffset <= maxOffset then
		finalOffset = randomOffset * 0.1;
	else
		finalOffset = (maxOffset - randomOffset) * 0.1;
	end
	return randomOffset,finalOffset;
end

local function GetRandomOffsetX()
	local randomOffset,finalOffset = GetRandomOffset(mLastOffsetX,mMaxOffsetX,mMaxRandomTimes,mRandomThreshold)
	mLastOffsetX = randomOffset;
	return finalOffset;
end

local function GetRandomOffsetY()
	local randomOffset,finalOffset = GetRandomOffset(mLastOffsetY,mMaxOffsetY,mMaxRandomTimes,mRandomThreshold)
	mLastOffsetY = randomOffset;
	return finalOffset;
end

local function IsValidStatusTarget(attacker,target)
	if not target or not attacker then return false end
	--判断伤害来源 玩家 自己的宠物
	if attacker:IsSelf() or attacker:IsPetOfPlayer(UserData.PlayerID) then 
		--判断伤害目标 不显示 自己队友 自己助战
		if target:IsPlayerOfTeam() then return false end
		if target:IsHelperOfTeam() then return false end
		return true;
	else
		return false;
	end
end

local function IsValidDamageTarget(attacker,target,deltaValue,isDamage)
	local mainPlayer = MapMgr.GetMainPlayer();
	if not target or not mainPlayer or not attacker then return false; end
	local mainPlayerCampComponent = mainPlayer:GetCampComponent();
	if isDamage then
		--玩家自己或者自己的宠物
		if target:IsSelf() or target:IsPetOfPlayer(UserData.PlayerID) then return true; end
		if deltaValue < 0 then
			--判断伤害来源 玩家自己或者自己的宠物
			if attacker:IsSelf() or attacker:IsPetOfPlayer(UserData.PlayerID) then
				--判断伤害目标 敌方
				return mainPlayerCampComponent:IsRed(target);
			end
		elseif deltaValue > 0 then
			--队友
			if target:IsPlayerOfTeam() then return true end
			--助战
			if target:IsHelperOfTeam() then return true end
		end
	else
		--非伤害类型
		if target and target:IsSelf() then return true; end
	end
	return false;
end

local function GetDamageArg(target,deltaValue,isDamage,isCrit,isDot)
	if isDamage then
		if deltaValue < 0 then
			local isSelf = target:IsSelf() or target:IsPetOfPlayer(UserData.PlayerID);
			if isCrit then
				--暴击伤害
				return isSelf and DamageParam.CritDamageToSelf or DamageParam.CritDamageToOther;
			elseif isDot then
				--DOT伤害
				return isSelf and DamageParam.DotDamageToSelf or DamageParam.DotDamageToOther;
			else
				--普通伤害
				return isSelf and DamageParam.NormalDamageToSelf or DamageParam.NormalDamageToOther;
			end
		else
			if isCrit then
				--暴击治疗
				return DamageParam.CritAddHpToSelf;
			else
				--普通治疗
				return DamageParam.NormalAddHpToSelf;
			end
		end
	else
		--经验货币
		return DamageParam.ItemCount;
	end
end

local function DisplayText(alignTarget,damageArg,damageValue)
	local targetProperty = alignTarget:GetPropertyComponent();
	local targetWorldPos = targetProperty:GetPosition();
	local targetHeight = targetProperty:GetHeight();
	--默认位置在角色头顶
	mWorldPos:Set(targetWorldPos.x,targetWorldPos.y + targetHeight,targetWorldPos.z);
	--伤害数字需要随机偏移
	if damageArg.needRandomPos then 
		mWorldPos.x = mWorldPos.x + GetRandomOffsetX();
		mWorldPos.y = mWorldPos.y + GetRandomOffsetY();
	end
	GameCore.EntityDamage.Display(mWorldPos,damageValue,damageArg.valueType,damageArg.pathType);
end

function InitModule()
    --伤害跳字
    if tolua.isnull(mDamageAtlas) then
		mDamageAtlas = CommonData.FindAsset("Assets/Res/Misc/A_UI_Damage.prefab");
		mDamageShader = CommonData.FindShader("Assets/Shader/Program/EntityDamage.shader","GameEffects/EntityDamage")
		GameCore.EntityDamage.Init(mDamageShader,mDamageAtlas.gameObject:GetComponent(typeof(UIAtlas)));
		--设置跳字参数
		local argType = 0;
		local posXArg = Vector4(0,200,0,0.4);
		local posYArg = Vector4(0,400,0,0.4);
		local scaleArg = Vector4(-16,8,0,0.4);
		local alphaArg = Vector4(0,-1,1.25,1.25);
		GameCore.EntityDamage.UpdateArg(argType,posXArg,posYArg,scaleArg,alphaArg);
	end	
end

--[[
伤害数字
attacker	entity	攻击者
target		entity  被攻击者
deltaValue	int		伤害数值
isDamage	int		是否为伤害(不是伤害默认按照货币和经验处理)
isCrit		bool	是否暴击
isDot		bool	是否为DOT伤害
--]]
function OnDamage(attacker, target, deltaValue, isDamage, isCrit, isDot)
	if IsValidDamageTarget(attacker, target, deltaValue, isDamage) then
		local damageArg = GetDamageArg(target, deltaValue, isDamage, isCrit, isDot);
		DisplayText(target,damageArg,deltaValue);
	end
end

--免疫
function OnImmune(attacker, target, immuneType)
	if IsValidStatusTarget(attacker, target) then
		--没有免疫字样,用闪避代替
		DisplayText(target,DamageParam.Status,1001);
	end
end

--闪避
function OnMiss(attacker, target)
	if IsValidStatusTarget(attacker, target) then
		--闪避文字是1001
		DisplayText(target,DamageParam.Status,1001);
	end
end

--状态(只针对AddBuff事件做处理)
function OnStatus(attacker, target, buffGroup)
	if IsValidStatusTarget(attacker, target) then
		local buffLayerData = buffGroup._layerData;
		DisplayText(target,DamageParam.Status,buffLayerData.statusNumber or 1004);
	end
end

--货币和经验
function OnItemAdd(deltaValue)
	DisplayText(MapMgr.GetMainPlayer(),DamageParam.ItemCount,deltaValue);
end

return DamageNumber;
