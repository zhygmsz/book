module("UserGuideData",package.seeall)

DATA.UserGuideData.mGuideConditions = nil;
DATA.UserGuideData.mGuideActions = nil;
DATA.UserGuideData.mGuideFinishConditions = nil;
DATA.UserGuideData.mGuideDatas = nil;

local function OnLoadGuideConditions(data)
    local datas = UserGuide_pb.AllGuideConditions();
    datas:ParseFromString(data);

    local guideConditions = {};
    for k,v in ipairs(datas.conditions) do
        guideConditions[v.guideID] = guideConditions[v.guideID] or {};
        table.insert(guideConditions[v.guideID],v);
    end

    DATA.UserGuideData.mGuideConditions = guideConditions;
end

local function OnLoadGuideActions(data)
    local datas = UserGuide_pb.AllGuideActions();
    datas:ParseFromString(data);

    local guideActions = {};
    for k,v in ipairs(datas.actions) do
        guideActions[v.guideID] = guideActions[v.guideID] or {};
        table.insert(guideActions[v.guideID],v);
    end

    DATA.UserGuideData.mGuideActions = guideActions;
end

local function OnLoadGuideFinishConditions(data)
    local datas = UserGuide_pb.AllGuideFinishConditions();
    datas:ParseFromString(data);

    local guideFinishConditions = {};
    for k,v in ipairs(datas.conditions) do
        guideFinishConditions[v.guideID] = guideFinishConditions[v.guideID] or {};
        table.insert(guideFinishConditions[v.guideID],v);
    end

    DATA.UserGuideData.mGuideFinishConditions = guideFinishConditions;
end

local function OnLoadGuideDatas(data)
    local datas = UserGuide_pb.AllUserGuides();
    datas:ParseFromString(data);

    local guideDatas = {};
    for k,v in ipairs(datas.guides) do
        guideDatas[v.id] = v;
    end

    DATA.UserGuideData.mGuideDatas = guideDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mGuideConditions = true },
		fileName = "UserGuideCondition.bytes",
		callBack = OnLoadGuideConditions,
	}
	local argData2 = 
	{
		keys = { mGuideActions = true },
		fileName = "UserGuideActionInfo.bytes",
		callBack = OnLoadGuideActions,
	}
	local argData3 = 
	{
		keys = { mGuideFinishConditions = true },
		fileName = "UserGuideFinishCondition.bytes",
		callBack = OnLoadGuideFinishConditions,
	}
	local argData4 = 
	{
		keys = { mGuideDatas = true },
		fileName = "UserGuideInfo.bytes",
		callBack = OnLoadGuideDatas,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.UserGuideData,argData1,argData2,argData3,argData4);
end 

function GetGuideInfo(id)
    return DATA.UserGuideData.mGuideDatas[id];
end 

function GetAllGuideInfos()
    return DATA.UserGuideData.mGuideDatas;
end

return UserGuideData;
