module("AIPetData",package.seeall)

DATA.AIPetData.mAllAIPets = nil;
DATA.AIPetData.mAnimationByPetID = nil;

local function OnLoadAllInfos(data)
	local datas = AiPet_pb.AllAiPetModelStaticInfos();
	datas:ParseFromString(data);
	DATA.AIPetData.mAllAIPets = datas.aiPetInfos;
end
local function OnLoadAllAnimations(data)
	local datas = AiPet_pb.AllAiPetUIAnimationInfos();
	datas:ParseFromString(data);
	DATA.AIPetData.mAnimationByPetID = {};
	for i, item in ipairs(datas.animationInfos) do
		local pid = item.aipetID;
		if not DATA.AIPetData.mAnimationByPetID[pid] then
			DATA.AIPetData.mAnimationByPetID[pid] = {};
		end
		table.insert(DATA.AIPetData.mAnimationByPetID[pid], item);
	end
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllAIPets = true },
		fileName = "AipetInfo.bytes",
		callBack = OnLoadAllInfos,
	}
	local argData2 = 
	{
		keys = { mAnimationByPetID = true },
		fileName = "AipetUIAnimation.bytes",
		callBack = OnLoadAllAnimations,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AIPetData,argData1,argData2);
end

function GetAllAIPets()
    return DATA.AIPetData.mAllAIPets;
end

function GetAIPetInfoByID(id)
	for i,info in ipairs(DATA.AIPetData.mAllAIPets) do
		if info.aipetID == id then
			return info;
		end
	end
end

function GetAll2DAnimations(pid)
	return DATA.AIPetData.mAnimationByPetID[pid];
end

return AIPetData;
