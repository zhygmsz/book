module("AnimationData",package.seeall)

DATA.AnimationData.mAnimationInfos = nil;
DATA.AnimationData.mAnimationGroups = nil;

local function OnLoadAnimationInfo(data)
	local datas = AnimationInfo_pb.AllAnimationInfo();
	datas:ParseFromString(data);

	local infos = {};
	local groups = {};

	for k,v in ipairs(datas.anims) do
		infos[v.id] = v;
		groups[v.group] = groups[v.group] or {}
		table.insert(groups[v.group],v);
	end	

	DATA.AnimationData.mAnimationInfos = infos;
	DATA.AnimationData.mAnimationGroups = groups;
end

function InitModule()
	local argData = 
	{
		keys = { mAnimationInfos = true, mAnimationGroups = true },
		fileName = "AnimationInfo.bytes",
		callBack = OnLoadAnimationInfo,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AnimationData,argData);
end

function GetAnimationInfo(id)
	return DATA.AnimationData.mAnimationInfos[id];
end 

function GetAnimationGroup(groupID)
	return DATA.AnimationData.mAnimationGroups[groupID];
end

return AnimationData;
