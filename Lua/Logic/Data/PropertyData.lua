module("PropertyData",package.seeall)

DATA.PropertyData.mPropertyAtts = nil;

local function OnLoadPropertyData(data)
	local datas = PropertyInfo_pb.AllPropertyInfos();
	datas:ParseFromString(data);

	local propertyAtts = {};

	for k,v in ipairs(datas.datas) do
		propertyAtts[v.id] = v;
	end

	DATA.PropertyData.mPropertyAtts = propertyAtts;
end

function InitModule()
	local argData1 = 
	{
		keys = { mPropertyAtts = true },
		fileName = "PropertyInfo.bytes",
		callBack = OnLoadPropertyData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.PropertyData,argData1);
end

function GetPropertyAtt(id)
	return DATA.PropertyData.mPropertyAtts[id];
end

return PropertyData;
