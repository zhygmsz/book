module("RankMgr",package.seeall);

local mRankList = {};
local mRankResault;

local function InitRankList()
	local allRanks = RankData.GetAllRanks();
	for index,value in pairs(allRanks.rankInfos) do
		if value.level == 1 then
			--查找是否已包含此一级标签
			local findFlag = false;
			for r,m in pairs(mRankList) do
				if r == value.id then
					findFlag = true;
					break;
				end
			end

			if findFlag == false then
				mRankList[value.id] = {name = value.name,childList = {}};
			end

		elseif value.level == 2 then
			--查找是否已包含父类一级标签
			local findFlag = false;
			for r,m in pairs(mRankList) do
				if r == value.parent then
					findFlag = true;
					break;
				end
			end

			if findFlag == false then
				for r,m in pairs(mRankList) do
					if r == value.parent then
						mRankList[r] = {name = m.name,childList = {}};
					end
				end	
			end
			mRankList[value.parent].childList[value.id] = value.name;
		end
	end
end

function GetRankList()
	if next(mRankList) == nil then InitRankList(); end
	return mRankList;
end

function GetRankInfoById(id)
	return RankData.GetRankInfo(id);
end

function FindDefaultSecondRankTitleKey(parentKey)
	for k,v in pairs(mRankList) do
		if k == parentKey then
			local key = 99999;
			for r,n in pairs(v["childList"]) do
				if key>r then
					key = r;
				end
			end
			return key;
		end
	end
end

function GetFilterListByFilterType(filterType)
	local filterList = RankData.GetFilterListByFilterType(filterType);
	return filterList;
end

function GetRankResault()
	return mRankResault;
end

function RequestRankListToServer(rankInfo,filterIndex)
	local msg = NetCT_pb.CTGetRankList();
	msg.RankId = rankInfo.id;
	msg.type = rankInfo.rankProType;
	msg.para1 = rankInfo.rankMainType;
	msg.para2 = filterIndex - 1;

	GameNet.SendToGate(msg);
end

function UpdateRankResault(rankInfo)
	mRankResault = rankInfo;
	MessageSub.SendMessage(GameConfig.SUB_G_RANK,GameConfig.SUB_U_RANK_UPDATERESAULT);
end

function InitModule()

end

return RankMgr;
