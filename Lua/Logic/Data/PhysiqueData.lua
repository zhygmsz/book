module("PhysiqueData",package.seeall)

DATA.PhysiqueData.mAllPhysique = nil;

local function OnLoadPhysique(data)
	local datas = Physique_pb.AllPhysiques();
	datas:ParseFromString(data);

	local allPhysiques = {};

	for k,v in ipairs(datas.datas) do
		allPhysiques[v.id] = v;
	end

	DATA.PhysiqueData.mAllPhysique = allPhysiques;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllPhysique = true },
		fileName = "Physique.bytes",
		callBack = OnLoadPhysique,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.PhysiqueData,argData1);
end

function GetPhysique(id)
	return DATA.PhysiqueData.mAllPhysique[id];
end

return PhysiqueData;
