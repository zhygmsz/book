module("GameFuncData",package.seeall)

DATA.GameFuncData.mAllGameFuncs = nil;
DATA.GameFuncData.mAllGameUIFuncs = nil;

local function OnLoadGameFuncData(data)
    local datas = GameFunc_pb.AllGameFuncs();
    datas:ParseFromString(data);

    DATA.GameFuncData.mAllGameFuncs = datas.funcs;
end

local function OnLoadGameUIFuncData(data)
    local datas = GameFunc_pb.AllGameUIFuncs();
    datas:ParseFromString(data);

    DATA.GameFuncData.mAllGameUIFuncs = datas.funcs;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllGameFuncs = true },
		fileName = "GameFuncInfo.bytes",
		callBack = OnLoadGameFuncData,
    }
    local argData2 = 
	{
		keys = { mAllGameUIFuncs = true },
		fileName = "GameUIFuncInfo.bytes",
		callBack = OnLoadGameUIFuncData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.GameFuncData,argData1,argData2);
end

function GetAllGameFuncs()
    return DATA.GameFuncData.mAllGameFuncs;
end

function GetAllGameUIFuncs()
    return DATA.GameFuncData.mAllGameUIFuncs;
end

return GameFuncData;