module("LevelExpData", package.seeall)

DATA.LevelExpData.mLevelExpData = nil;

local function OnLoadExpData(data)
    local datas = LevelExpData_pb.LevelExp()
    datas:ParseFromString(data)

    local expDatas = {};

    for k,v in ipairs(datas.stDatas) do
        expDatas[v.level] = tonumber(v.experience)
    end

    DATA.LevelExpData.mLevelExpData = expDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mLevelExpData = true },
		fileName = "LevelExperience.bytes",
		callBack = OnLoadExpData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.LevelExpData,argData1);
end

function GetExpByLevel(level)
    return DATA.LevelExpData.mLevelExpData[level] or 0
end

return LevelExpData;
