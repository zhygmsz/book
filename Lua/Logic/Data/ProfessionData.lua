module("ProfessionData",package.seeall)

DATA.ProfessionData.mRacialTable = nil;
DATA.ProfessionData.mProfessionTable = nil;
DATA.ProfessionData.mProfessionKeys = nil;
DATA.ProfessionData.mRacialKeys = nil;

DATA.ProfessionData.mPlayerCreateResTable = nil;
DATA.ProfessionData.mProfessionAttTable = nil;

local function OnLoadProfessionData(data)
	local datas = PlayerInfo_pb.AllPlayerCreateInfos();
	datas:ParseFromString(data);

	local racialTable = {};
	local professionTable = {};
	local pkeys = {}
	local rkeys = {}

	for k,v in ipairs(datas.datas) do
		local racial = v.racial;
		local profession = v.profession;

		racialTable[racial] = racialTable[racial] or {};
		racialTable[racial][profession] = v

		professionTable[profession] = professionTable[profession] or {};
		professionTable[profession][racial] = v

		if not table.contains_value(pkeys,profession) then
			table.insert(pkeys,profession)
		end
		if not table.contains_value(rkeys,racial) then
			table.insert(rkeys,racial)
		end
	end

	DATA.ProfessionData.mRacialTable = racialTable;
	DATA.ProfessionData.mProfessionTable = professionTable;
	DATA.ProfessionData.mProfessionKeys = pkeys
	DATA.ProfessionData.mRacialKeys = rkeys
end

local function OnLoadPlayerCreateResData(data)
	local datas = PlayerInfo_pb.AllPlayerCreateRess();
	datas:ParseFromString(data);

	local resTable = {};

	for k,v in ipairs(datas.datas) do
		resTable[v.id] = v
	end

	DATA.ProfessionData.mPlayerCreateResTable = resTable;
end

local function OnLoadProfessionAttData(data)
	local datas = PlayerInfo_pb.AllProfessionAtts();
	datas:ParseFromString(data);

	local attTable = {};

	for k,v in ipairs(datas.professionAtts) do
		attTable[v.id] = v
	end

	DATA.ProfessionData.mProfessionAttTable = attTable;
end

function InitModule()
	local argData1 = 
	{
		keys = { mRacialTable = true },
		fileName = "ProfessionPlayer.bytes",
		callBack = OnLoadProfessionData,
    }
	local argData2 = 
	{
		keys = { mProfessionResTable = true},
		fileName = "ProfessionPlayerRes.bytes",
		callBack = OnLoadPlayerCreateResData,
	}
	local argData3 = 
	{
		keys = { mProfessionAttTable = true},
		fileName = "ProfessionAtt.bytes",
		callBack = OnLoadProfessionAttData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.ProfessionData,argData1,argData2,argData3);
end

--所有职业的id数组
function GetProfessionKeys()
	return DATA.ProfessionData.mProfessionKeys
end

--所有职业的id数组
function GetRacialKeys()
	return DATA.ProfessionData.mRacialKeys
end

--获取某个职业的信息
function GetProfessionData(racial,profession)
	local professionDatas = DATA.ProfessionData.mRacialTable[racial];
	return professionDatas and professionDatas[profession];
end

--获取职业属性的个数
function GetAllProfessionNum()
	return table.count(DATA.ProfessionData.mProfessionAttTable)
end

--获取某个职业属性信息
function GetProfessionAtt(profession)
	return DATA.ProfessionData.mProfessionAttTable[profession];
end

--获取某个职业名称
function GetProfessionName(profession)
	local professionData = DATA.ProfessionData.mProfessionAttTable[profession];
	return professionData and professionData.name or "";
end

--获取种族个数
function GetRacialNum()
	return table.count(DATA.ProfessionData.mRacialTable)
end

--获取已经开放的职业个数
function GetProfessionNum()
	return table.count(DATA.ProfessionData.mProfessionTable)
end

--获取某个种族的职业个数
function GetProfessionNumByRacial(racial)
	local professionDatas = DATA.ProfessionData.mRacialTable[racial];
	return professionDatas and table.count(professionDatas) or 0;
end

--获取某个职业的种族个数
function GetRacialNumByProfession(profession)
	local racialDatas = DATA.ProfessionData.mProfessionTable[profession];
	return racialDatas and table.count(racialDatas) or 0;
end

--某个种族的职业信息列表
function GetRacialTable(racial)
	return DATA.ProfessionData.mRacialTable[racial]
end

--某个职业的种族信息列表
function GetProfessionTable(profession)
	return DATA.ProfessionData.mProfessionTable[profession]
end

--获取创建角色表现资源对象
function GetProfessionResByRacialProfession(racial,profession)
	local professionData = GetProfessionData(racial,profession)
	return (professionData and professionData.playerCreateResID) and DATA.ProfessionData.mPlayerCreateResTable[professionData.playerCreateResID] or nil;
end

return ProfessionData;