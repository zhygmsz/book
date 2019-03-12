module("WelfareData",package.seeall)

DATA.WelfareData.mSevenDayData = nil;

local function OnLoadWelfareData(data)
	local datas = Welfare_pb.AllSevenDay()
	datas:ParseFromString(data)

	DATA.WelfareData.mSevenDayData = datas.datas
end

function InitModule()
	local argData1 = 
	{
		keys = { mSevenDayData = true },
		fileName = "SevenDay.bytes",
		callBack = OnLoadWelfareData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.WelfareData,argData1);
end

function GetSevenDayData(dayIdx)
    return DATA.WelfareData.mSevenDayData[dayIdx]
end

return WelfareData;