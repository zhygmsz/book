module("LoadingUIData",package.seeall);

DATA.LoadingUIData.mTipsData = nil;
DATA.LoadingUIData.mTipsByType = nil;
DATA.LoadingUIData.mTipsByID = nil;

DATA.LoadingUIData.mBgBySceneName = nil;
DATA.LoadingUIData.mBgByType = nil;

local function OnLoadTipsData(data)
    local datas = LoadingInfo_pb.TipList();
    datas:ParseFromString(data);
    
    local tipsData = {};
    local tipsDataByID = {};
    local tipsDataByType = {};

    for k,v in ipairs(datas.Tips) do
        tipsData[k] = v;
        tipsDataByID[v.id] = v;
        tipsDataByType[v.contextType] = tipsDataByType[v.contextType] or {};
        table.insert(tipsDataByType[v.contextType], v);
    end
    
    DATA.LoadingUIData.mTipsData = tipsData;
    DATA.LoadingUIData.mTipsByType = tipsDataByID;
    DATA.LoadingUIData.mTipsByID = tipsDataByType;
end

local function OnLoadBgData(data)
    local datas = LoadingInfo_pb.BgList();
    datas:ParseFromString(data);
    
    local bgByType = {};
    local bgBySceneName = {};

    for k,v in ipairs(datas.infos) do
        if v.sceneName ~= "" then bgBySceneName[v.sceneName] = v end
        bgByType[v.sceneType] = bgByType[v.sceneType] or {};
        table.insert(bgByType[v.sceneType], v);           
    end
    
    DATA.LoadingUIData.mBgBySceneName = bgBySceneName;
    DATA.LoadingUIData.mBgByType = bgByType;
end

function InitModule()
	local argData1 = 
	{
		keys = { mTipsData = true,mTipsByType = true, mTipsByID = true  },
		fileName = "LoadingTips.bytes",
		callBack = OnLoadTipsData,
    }
    local argData2 = 
	{
		keys = { mBgBySceneName = true,mBgByType = true },
		fileName = "LoadingBgInfos.bytes",
		callBack = OnLoadBgData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.LoadingUIData,argData1,argData2);
end

function GetTipByID(id)  
    return DATA.LoadingUIData.mTipsByID[id];
end 

function GetTipsByType(type)
    return DATA.LoadingUIData.mTipsByType[type];
end

function GetTipsCount()
    return #DATA.LoadingUIData.mTipsData;
end

function GetRandomTip(tipType)
    local tipDatasByType = DATA.LoadingUIData.mTipsByType;
    local tipDatas = DATA.LoadingUIData.mTipsData;

    if tipType and tipDatasByType[tipType] then
        tipDatas = tipDatasByType[tipType];
    end

    return tipDatas[math.random(1,#tipDatas)];
end

function GetBgInfo(sceneName,sceneType)
    local bgDataBySceneName = DATA.LoadingUIData.mBgBySceneName;
    local bgDataByType = DATA.LoadingUIData.mBgByType;

    if sceneName and bgDataBySceneName[sceneName] then
        return bgDataBySceneName[sceneName];
    elseif sceneType and bgDataByType[sceneType] then
        local datas = bgDataByType[sceneType];
        return datas[math.random(1,#datas)];
    else
        local datas = bgDataByType[0];
        return datas[math.random(1,#datas)];
    end
end

return LoadingUIData;

