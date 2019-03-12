module("CampData",package.seeall)

DATA.CampData.mCampRelations = nil;

local function OnLoadCamps(data)
    local datas = Faction_pb.BaseFactionTable();
    datas:ParseFromString(data);

    local campRelations = {};

    for i,campData in ipairs(datas.list) do
        for j,campRelation in ipairs(campData.factions) do
            campRelations[i] = campRelations[i] or {};
            campRelations[i][j] = campRelation;
        end
    end

    DATA.CampData.mCampRelations = campRelations;
end

function InitModule()
	local argData1 = 
	{
		keys = { mCampRelations = true },
		fileName = "FactionData.bytes",
		callBack = OnLoadCamps,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.CampData,argData1);
end

--获取基础阵营关系
function GetCampRelation(id1,id2)
    return DATA.CampData.mCampRelations[id1][id2];
end

return CampData;
