module("FunUnLockMgr", package.seeall);

local unlockedFunIndexList = {};

function InitModule()
end

function OnInitFunUnlockInfo(msg)
	local funIndexList = msg.funcIds;
	for k, v in ipairs(funIndexList) do
		table.insert(unlockedFunIndexList, v);
		--开启/关闭 是否播放解锁特效
		--		GameEvent.Trigger(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, v, true, false);
	end
end

function OnUnlockFun(msg)
	local isUnlock = msg.tp == 1;
	local isShowExpFun = msg.param;
	local funIndexList = msg.funcIds;
	for k, v in ipairs(funIndexList) do
		if isUnlock then
			local isFind = false;
			for m, n in ipairs(unlockedFunIndexList) do
				if n == v then
					isFind = true;
					break;
				end
			end
			if not isFind then
				table.insert(unlockedFunIndexList, v);
				GameEvent.Trigger(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, v, isUnlock, true);
			end
		else
			for m, n in ipairs(unlockedFunIndexList) do
				if n == v then
					table.remove(unlockedFunIndexList, m);
					GameEvent.Trigger(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, v, isUnlock, true);
					break;
				end
			end
		end
	end
end

function GetIsUnlockByFunIndex(funIndex)
	local isFind = false
	for k, v in ipairs(unlockedFunIndexList) do
		if funIndex == v then
			isFind = true;
			break;
		end
	end
	return isFind;
end

function GetSkillSlotIsUnlock(slotIndex)
	if slotIndex == 1 then return true; end
	local isUnlock = false;
	if slotIndex == 2 then
		isUnlock = GetIsUnlockByFunIndex(2);
	elseif slotIndex == 3 then
		isUnlock = GetIsUnlockByFunIndex(3);
	elseif slotIndex == 4 then
		isUnlock = GetIsUnlockByFunIndex(4);
	elseif slotIndex == 5 then
		isUnlock = GetIsUnlockByFunIndex(5);
	elseif slotIndex == 6 then
		isUnlock = GetIsUnlockByFunIndex(6);
	elseif slotIndex == 7 then
		isUnlock = GetIsUnlockByFunIndex(7);
	end
	return isUnlock;
end

function GetSkillSlotIndexByFunIndex(funcIndex)
	local slotIndex = 0;
	if funcIndex == 1 then
		slotIndex = 1;
	elseif funcIndex == 2 then
		slotIndex = 2;
	elseif funcIndex == 3 then
		slotIndex = 3;
	elseif funcIndex == 4 then
		slotIndex = 4;
	elseif funcIndex == 5 then
		slotIndex = 5;
	elseif funcIndex == 6 then
		slotIndex = 6;
	end
	return slotIndex;
end

return FunUnLockMgr; 