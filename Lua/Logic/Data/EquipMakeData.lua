module("EquipMakeData",package.seeall);

DATA.EquipMakeData.mEquipMakeGroupDatasByEquipLevel = nil;
DATA.EquipMakeData.mEquipMakeDatas = nil;
DATA.EquipMakeData.mAllEquipMakeLevel = nil;
DATA.EquipMakeData.mCurrentEquipMakeLevel = nil;

local function OnLoadEquipMakeData(data)
	local datas = EquipMake_pb.AllEquipMakes();
	datas:ParseFromString(data);
	
	local equipMakeGroupDatasByEquipLevel = {};
	local equipMakeDatas = {};
	local allEquipMakeLevel = {};
	for i = 1,#datas.equipMakes do
		local equipMakeData = datas.equipMakes[i];
		
		equipMakeDatas[equipMakeData.id] = equipMakeData;
		if equipMakeGroupDatasByEquipLevel[equipMakeData.equipLevel] == nil then
            equipMakeGroupDatasByEquipLevel[equipMakeData.equipLevel] = {};
        end
        table.insert(equipMakeGroupDatasByEquipLevel[equipMakeData.equipLevel],equipMakeData);
        
        local isLevelInTable = EquipMakeData.IsInTable(equipMakeData.equipLevel,allEquipMakeLevel);
        if isLevelInTable == false then
            table.insert(allEquipMakeLevel,equipMakeData.equipLevel);
        end

	end

    table.sort(allEquipMakeLevel,function(a,b) return a<b end)
    DATA.EquipMakeData.mAllEquipMakeLevel = allEquipMakeLevel;
	DATA.EquipMakeData.mEquipMakeGroupDatasByEquipLevel = equipMakeGroupDatasByEquipLevel;
	DATA.EquipMakeData.mEquipMakeDatas = equipMakeDatas;
end

function IsInTable(targetValue,targetTable)
    for k,v in ipairs(targetTable) do
        if v == targetValue then
            return true;
        end
    end
    return false;
end

function InitModule()
	local argData1 = 
	{
		keys = { mEquipMakeGroupDatasByEquipLevel = true, mEquipMakeDatas = true },
		fileName = "EquipMake.bytes",
		callBack = OnLoadEquipMakeData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.EquipMakeData,argData1);
end


function GetEquipMakeDatasByEquipLevelSortedByEquipType(level)   
    local equipMakeDatas = DATA.EquipMakeData.mEquipMakeGroupDatasByEquipLevel[level];   
    table.sort(equipMakeDatas,function(a,b) return a.equipType<b.equipType end)
    return equipMakeDatas;
end

function GetEquipMakeData(equipMakeId)
	return DATA.EquipMakeData.mEquipMakeDatas[equipMakeId];
end

function GetAllEquipLevel()
     return DATA.EquipMakeData.mAllEquipMakeLevel;
end

function GetCurrentEquipMakeLevel()
    return DATA.EquipMakeData.mCurrentEquipMakeLevel;
end

function SetCurrentEquipMakeLevel(level)
    DATA.EquipMakeData.mCurrentEquipMakeLevel = level;
end

return EquipMakeData;
