module("WordData",package.seeall)

DATA.WordData.mWordDataByID = nil;
DATA.WordData.mWordDataByKey = nil;
DATA.WordData.mWordDatasByEqualKey = nil;

DATA.WordData.mTipDataByID = nil;

local function OnLoadWordData(data)
	local datas = WordData_pb.AllWordData()
	datas:ParseFromString(data)

	local wordDataByID = {};
	local wordDataByKey = {};
	local wordDatasByEqualKey = {};

	local needEqualKey = 
	{ 
		bullet_hot_word = true,
	}

	for _,v in ipairs(datas.datas) do
		if needEqualKey[v.key] then
			wordDatasByEqualKey[v.key] = wordDatasByEqualKey[v.key] or {};
			table.insert(wordDatasByEqualKey[v.key],v.value);
		end
		
		wordDataByID[v.id] = v;
		wordDataByKey[v.key] = v;
	end
	local defaultData = {id = 0, tipTypeID = 1};
	wordDataByID[0] = defaultData;

	DATA.WordData.mWordDataByID = wordDataByID;
	DATA.WordData.mWordDataByKey = wordDataByKey;
	DATA.WordData.mWordDatasByEqualKey = wordDatasByEqualKey;
end

local function OnLoadTipTypeData(data)
	local datas = WordData_pb.AllTipTypeData()
	datas:ParseFromString(data)

	local tipDataByID = {};

	for k,v in ipairs(datas.datas) do
		tipDataByID[v.id] = v;
	end

	DATA.WordData.mTipDataByID = tipDataByID;
end

function InitModule()
	local argData1 = 
	{
		keys = { mWordDataByID = true, mWordDataByKey = true, mWordDatasByEqualKey = true },
		fileName = "WordData.bytes",
		callBack = OnLoadWordData,
	}
	local argData2 = 
	{
		keys = { mTipDataByID = true },
		fileName = "TipTypeData.bytes",
		callBack = OnLoadTipTypeData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.WordData,argData1,argData2);
end

function GetWordDataByID(id)
	return DATA.WordData.mWordDataByID[id];
end

function GetWordDataByKey(key)
	return DATA.WordData.mWordDataByKey[key];
end

function GetWordDataDefault()
	return DATA.WordData.mWordDataByID[0];
end

function GetWordStringByKey(key,...)
	if not key then GameLog.LogError("key is nil"); return; end
	local data = DATA.WordData.mWordDataByKey[key];
	local value = data and data.value or key;
	if ... then
		local flag, msg = xpcall(string.format,traceback,value,...);
		if not flag then
			GameLog.LogError("format error %s %s", key, msg);
		else
			value = msg;
		end
	end
	return value;
end

function GetTipTypeData(id)
	return DATA.WordData.mTipDataByID[id];
end

function GetErrorDataByID(id)
	return DATA.WordData.mWordDataByID[id]
end

function GetWordDatasByKey(key)
	return DATA.WordData.mWordDatasByEqualKey[key] or {};
end

return WordData;
