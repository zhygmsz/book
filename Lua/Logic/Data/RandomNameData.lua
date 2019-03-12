module("RandomNameData",package.seeall)
 
DATA.RandomNameData.mRandomNames = nil;

local function OnLoadRandomNameData(data)
	local datas = RandomName_pb.AllRandomName();
	datas:ParseFromString(data);

	DATA.RandomNameData.mRandomNames = datas;
end

local function GetRandomContent(key)
	local datas = DATA.RandomNameData.mRandomNames[key];
	local s1 =math.random(1,1000000);
	math.randomseed(s1)
	local rdIndex = math.random(1,#datas);
	return datas[rdIndex].data;
end

function InitModule()
	local argData1 = 
	{
		keys = { mRandomNames = true },
		fileName = "RandomName.bytes",
		callBack = OnLoadRandomNameData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.RandomNameData,argData1);
end

function GetRandomMaleName()
	local str = string.format("%s%s%s",GetRandomContent("lastNames"),GetRandomContent("nameMales1"),GetRandomContent("nameMales2"))
	return str;
end

function GetRandomFemaleName()
	local str = string.format("%s%s%s",GetRandomContent("lastNames"),GetRandomContent("nameFemales1"),GetRandomContent("nameFemales2"))
	return str;
end

return RandomNameData;
