module("AppearanceData",package.seeall)

DATA.AppearanceData.mAllRoleItemInfos = nil;
DATA.AppearanceData.mAllAIPetItemInfos = nil;
DATA.AppearanceData.mAllUIItemInfos  = nil;
DATA.AppearanceData.mAllMountItemInfos = nil;
DATA.AppearanceData.mAllSkillItemInfos = nil;


local function OnLoadAllInfos(data)
	local datas = AppearanceInfo_pb.AllAppearanceInfo();
	datas:ParseFromString(data);
    local mAllRoleItemInfos = {};
    local mAllAIPetItemInfos = {};
    local mAllUIItemInfos  = {};
    local mAllMountItemInfos = {};
    local mAllSkillItemInfos = {};
    local keyTable = {};
    keyTable[AppearanceInfo_pb.APPEARANCE_ROLE] = mAllRoleItemInfos;
    keyTable[AppearanceInfo_pb.APPEARANCE_AIPET] = mAllAIPetItemInfos;
    keyTable[AppearanceInfo_pb.APPEARANCE_UI] = mAllUIItemInfos;
    keyTable[AppearanceInfo_pb.APPEARANCE_MOUNT] = mAllMountItemInfos;
    keyTable[AppearanceInfo_pb.APPEARANCE_SKILL] = mAllSkillItemInfos;

    for i,v in ipairs(datas.allAppearanceInfos) do
        table.insert(keyTable[v.appearanceType], v);
    end

    DATA.AppearanceData.mAllRoleItemInfos = mAllRoleItemInfos;
    DATA.AppearanceData.mAllAIPetItemInfos = mAllAIPetItemInfos;
    DATA.AppearanceData.mAllUIItemInfos  = mAllUIItemInfos;
    DATA.AppearanceData.mAllMountItemInfos = mAllMountItemInfos;
    DATA.AppearanceData.mAllSkillItemInfos = mAllSkillItemInfos;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllRoleItemInfos = true },
		fileName = "AppearanceItemInfo.bytes",
		callBack = OnLoadAllInfos,
	}
	local argData2 = 
	{
		keys = { mAllAIPetItemInfos = true },
		fileName = "AppearanceItemInfo.bytes",
		callBack = OnLoadAllInfos,
	}
	local argData3 = 
	{
		keys = { mAllUIItemInfos = true },
		fileName = "AppearanceItemInfo.bytes",
		callBack = OnLoadAllInfos,
	}
	local argData4 = 
	{
		keys = { mAllMountItemInfos = true },
		fileName = "AppearanceItemInfo.bytes",
		callBack = OnLoadAllInfos,
	}
	local argData5 = 
	{
		keys = { mAllSkillItemInfos = true },
		fileName = "AppearanceItemInfo.bytes",
		callBack = OnLoadAllInfos,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AppearanceData,argData1,argData2,argData3,argData4,argData5);
end

function GetAllRoleItemList()
    return DATA.AppearanceData.mAllRoleItemInfos;
end

function GetAllAIPetItemList()
    return DATA.AppearanceData.mAllAIPetItemInfos;
end

function GetAllUIItemList()
    return DATA.AppearanceData.mAllUIItemInfos;
end

function GetAllMountItemList()
    return DATA.AppearanceData.mAllMountItemInfos;
end

function GetAllSkillItemList()
    return DATA.AppearanceData.mAllSkillItemInfos;
end

return AppearanceData;
