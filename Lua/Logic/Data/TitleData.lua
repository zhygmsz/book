--称号系统
---------------------------------
module("TitleData",package.seeall)

DATA.TitleData.mAllTilteTableInfos = nil;

local function OnLoadAllTitleItems(data)
	local datas = Title_pb.AllTilteTableInfo();
	datas:ParseFromString(data);
	DATA.TitleData.mAllTilteTableInfos = datas.list;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllTilteTableInfos = true },
		fileName = "TitleData.bytes",
		callBack = OnLoadAllTitleItems,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.TitleData,argData1);
end

function GetAllTitleList()
    return DATA.TitleData.mAllTilteTableInfos;
end

return TitleData;
