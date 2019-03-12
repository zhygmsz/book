module("RideData",package.seeall)

DATA.RideData.mAllRideDatas = nil;

local function OnLoadRideData(data)
    local datas = Ride_pb.AllRideData()
    datas:ParseFromString(data)

    local rideDatas = {};

    for k,v in ipairs(datas.datas) do
        rideDatas[v.id] = v;
    end

    DATA.RideData.mAllRideDatas = rideDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllRideDatas = true },
		fileName = "RideData.bytes",
		callBack = OnLoadRideData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.RideData,argData1);
end

function GetRideData(id)
    return DATA.RideData.mAllRideDatas[id];
end

return RideData;