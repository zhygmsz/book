module("IllegalData",package.seeall);

DATA.IllegalData.mIllegalDatas = nil;

local function OnLoadIllegalData(data)
	local datas = IllegalData_pb.AllIllegalData();
	datas:ParseFromString(data);
	DATA.IllegalData.mIllegalDatas = datas.datas;
end 

function InitModule()
	local argData1 = 
	{
		keys = { mIllegalDatas = true },
		fileName = "IllegalData.bytes",
		callBack = OnLoadIllegalData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.IllegalData,argData1);
end

function GetIllegalDatas()  
    return DATA.IllegalData.mIllegalDatas;
end 

return IllegalData;