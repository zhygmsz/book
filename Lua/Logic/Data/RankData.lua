module("RankData",package.seeall)

DATA.RankData.mAllRanks = nil;
DATA.RankData.mAllRanksMap = nil;
DATA.RankData.mAllRankFilters = nil;

local function OnLoadRankInfo(data)
	local datas = RankInfo_pb.AllRanks();
	datas:ParseFromString(data);

	local ranks = {};
	for k,v in ipairs(datas.rankInfos) do
		ranks[v.id] = v;
	end

	DATA.RankData.mAllRanks = datas;
	DATA.RankData.mAllRanksMap = ranks;
end

local function OnLoadRankFilters(data)
	local datas = RankInfo_pb.AllRankFilters();
	datas:ParseFromString(data);

	local rankFilters = {};
	for k,v in ipairs(datas.rankFilterInfos) do
		rankFilters[v.filterType] = rankFilters[v.filterType] or {};
		table.insert(rankFilters[v.filterType],v);
	end

	DATA.RankData.mAllRankFilters = rankFilters;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllRanks = true, mAllRanksMap = true },
		fileName = "RankInfo.bytes",
		callBack = OnLoadRankInfo,
	}
	local argData2 = 
	{
		keys = { mAllRankFilters = true },
		fileName = "RankFilterInfo.bytes",
		callBack = OnLoadRankFilters,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.RankData,argData1,argData2);
end

function GetRankInfo(id)
	return DATA.RankData.mAllRanksMap[id];
end

function GetAllRanks()
	return DATA.RankData.mAllRanks;
end

function GetFilterListByFilterType(filterType)
	return DATA.RankData.mAllRankFilters[filterType];
end

return RankData;