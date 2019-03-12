module("GemData", package.seeall)

DATA.GemData.mGemDataDic = nil
DATA.GemData.mGemDataList = nil

local function OnLoaded(data)
    if not data then
        return
    end
    local pb = Gem_pb.AllGemInfos()
    pb:ParseFromString(data)

    local gemDataDic = {}
    for _, v in ipairs(pb.gemInfos) do
        gemDataDic[v.id] = v
    end

    DATA.GemData.mGemDataDic = gemDataDic
    DATA.GemData.mGemDataList = pb.gemInfos
end

function InitModule()
    local argData1 = 
	{
		keys = { mGemDataDic = true, mGemDataList = true },
		fileName = "GemInfo.bytes",
		callBack = OnLoaded,
    }
    DATA.CREATE_LOAD_TRIGGER(DATA.GemData,argData1)
end

function GetGemDataList()
    return DATA.GemData.mGemDataList
end

function GetGemDataById(id)
    if id then
        return DATA.GemData.mGemDataDic[id]
    end
end

return GemData
