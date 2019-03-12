module("RenderInfoData",package.seeall)

DATA.RenderInfoData.mAllRenderInfos = nil;

local function OnLoadRenderInfo(data)
	local datas = RenderInfo_pb.AllRenderInfos();
	datas:ParseFromString(data);

	local allInfos = {};

	for k,v in ipairs(datas.infos) do
		allInfos[v.id] = v;
	end

	DATA.RenderInfoData.mAllRenderInfos = allInfos;
end

function InitModule()	
	local argData1 = 
	{
		keys = { mAllRenderInfos = true },
		fileName = "RenderInfo.bytes",
		callBack = OnLoadRenderInfo,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.RenderInfoData,argData1);
end

function GetRenderInfo(id)
	return DATA.RenderInfoData.mAllRenderInfos[id];
end

return RenderInfoData;
