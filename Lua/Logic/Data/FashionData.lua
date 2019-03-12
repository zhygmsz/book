module("FashionData",package.seeall)

DATA.FashionData.mAllFashionSlots = nil;

local function OnLoadAllFashionSlotDatas(data)
	local datas = Fashion_pb.AllFashionSlots();
    datas:ParseFromString(data);
    
    local fashionDatas = {};
    for k,v in ipairs(datas.datas) do
        fashionDatas[v.id] = v;
    end

	DATA.FashionData.mAllFashionSlots = fashionDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllFashionSlots = true },
		fileName = "FashionData.bytes",
		callBack = OnLoadAllFashionSlotDatas,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.FashionData,argData1);
end

function GetFashionData(fashionID)
    return DATA.FashionData.mAllFashionSlots[fashionID];
end

return FashionData;
