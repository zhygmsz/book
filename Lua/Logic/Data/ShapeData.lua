module("ShapeData",package.seeall)

DATA.ShapeData.mAllShapeDatas = nil;

local function OnLoadShapeData(data)
    local datas = Shape_pb.AllShapeData()
    datas:ParseFromString(data)

    local shapeDatas = {};

    for k,v in ipairs(datas.datas) do
        shapeDatas[v.id] = v;
    end

    DATA.ShapeData.mAllShapeDatas = shapeDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllShapeDatas = true },
		fileName = "ShapeData.bytes",
		callBack = OnLoadShapeData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ShapeData,argData1);
end

function GetShapeData(id)
    return DATA.ShapeData.mAllShapeDatas[id];
end

return ShapeData;