module("PracticeData",package.seeall)

DATA.PracticeData.mAttTable = nil;
DATA.PracticeData.mTypedAttTable = nil;
DATA.PracticeData.mLimitTable = nil;
DATA.PracticeData.mTypedLimitTable = nil;

local function OnLoadPracticeData(data)
	local datas = Practice_pb.AllPracticeAtts();
	datas:ParseFromString(data);

    local temp = {};
    local typed = {};

	for k,v in ipairs(datas.atts) do
        temp[v.id] = v
        if typed[v.targetType]==nil then typed[v.targetType]={} end
        if typed[v.targetType][v.attType]==nil then typed[v.targetType][v.attType]={} end
        if typed[v.targetType][v.attType][v.level]==nil then typed[v.targetType][v.attType][v.level]={} end
        typed[v.targetType][v.attType][v.level] = v.id
	end

    DATA.PracticeData.mAttTable = temp;
    DATA.PracticeData.mTypedAttTable = typed
end

local function OnLoadPracticeLimitsData(data)
	local datas = Practice_pb.AllPracticeLimits();
	datas:ParseFromString(data);

    local temp = {};
    local GangLevel = {};
    local PlayerLevel = {};
    local OfferLevel = {};
    local SymLevel = {};
    local SymLevelNeed = {};
    local function SortFunc(a,b)
        return a<b
    end
	for k,v in ipairs(datas.limits) do
        temp[v.id] = v
        if GangLevel[v.targetType]==nil then GangLevel[v.targetType]={} end
        if GangLevel[v.targetType].datas==nil then GangLevel[v.targetType].datas={} end
        if GangLevel[v.targetType].indexs==nil then GangLevel[v.targetType].indexs={} end
        local old = GangLevel[v.targetType].datas[v.needGangLevel]
        if old == nil then
            table.insert(GangLevel[v.targetType].indexs,v.needGangLevel)
        end
        GangLevel[v.targetType].datas[v.needGangLevel] = old == nil and  v.level or math.max(old,v.level)

        if PlayerLevel[v.targetType]==nil then PlayerLevel[v.targetType]={} end
        if PlayerLevel[v.targetType].datas==nil then PlayerLevel[v.targetType].datas={} end
        if PlayerLevel[v.targetType].indexs==nil then PlayerLevel[v.targetType].indexs={} end
        old = PlayerLevel[v.targetType].datas[v.needPlayerLevel]
        if old == nil then
           table.insert(PlayerLevel[v.targetType].indexs,v.needPlayerLevel) 
        end
        PlayerLevel[v.targetType].datas[v.needPlayerLevel] = old == nil and  v.level or math.max(old,v.level)
        
        if OfferLevel[v.targetType]==nil then OfferLevel[v.targetType]={} end
        if OfferLevel[v.targetType].datas==nil then OfferLevel[v.targetType].datas={} end
        if OfferLevel[v.targetType].indexs==nil then OfferLevel[v.targetType].indexs={} end
        old = OfferLevel[v.targetType].datas[v.needGangOffer]
        if old == nil then
            table.insert(OfferLevel[v.targetType].indexs,v.needGangOffer) 
        end
        OfferLevel[v.targetType].datas[v.needGangOffer] = old == nil and  v.level or math.max(old,v.level)

        if SymLevel[v.targetType]==nil then SymLevel[v.targetType]={} end
        SymLevel[v.targetType][v.level] = v.symLevel

        if SymLevelNeed[v.targetType]==nil then SymLevelNeed[v.targetType]={} end
        old = SymLevelNeed[v.targetType][v.symLevel]
        SymLevelNeed[v.targetType][v.symLevel] = old == nil and  v.level or math.max(old,v.level)
	end

    DATA.PracticeData.mLimitTable = temp;

    DATA.PracticeData.mTypedLimitTable = {
        ["gangLevel"] = GangLevel,
        ["playerLevel"] = PlayerLevel,
        ["offerLevel"] = OfferLevel,
        ["symLevel"] = SymLevel,
        ["symLevelNeed"] = SymLevelNeed
    };
end


function InitModule()
	local argData1 = 
	{
		keys = { mAttTable = true ,mTypedAttTable = true},
		fileName = "PracticeAtt.bytes",
		callBack = OnLoadPracticeData,
    }
	local argData2 = 
	{
		keys = { mLimitTable = true,mTypedLimitTable=true},
		fileName = "PracticeLimit.bytes",
		callBack = OnLoadPracticeLimitsData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.PracticeData,argData1,argData2);
end

function GetParcticeAtt(id)
    return DATA.PracticeData.mAttTable[id]
end

function GetPracticeAttByType(targetType,attType,level)
    local id = DATA.PracticeData.mTypedAttTable[targetType][attType][level]
    return DATA.PracticeData.mAttTable[id]
end

function GetParcticeLimit(id)
    return DATA.PracticeData.mLimitTable[id]
end

function GetLevelLimit(targetType,key,inputValue)
    local index = 1
    local indexs = DATA.PracticeData.mTypedLimitTable[key][targetType].indexs
    local datas = DATA.PracticeData.mTypedLimitTable[key][targetType].datas
    for i=1,#indexs do
        if indexs[i]>inputValue then
            index = i
            break
        end
    end
    index = indexs[math.max(1,index-1)]
    return datas[index]
end

--帮会研究所建筑等级能达到的最大修炼等级
function GetGangLevelLimit(targetType,gangLevel)
    return GetLevelLimit(targetType,"gangLevel",gangLevel)
end

--角色等级能达到的最大修炼等级
function GetPlayerLevelLimit(targetType,playerLevel)
    return GetLevelLimit(targetType,"playerLevel",playerLevel)
end

--帮会贡献值能达到的最大修炼等级
function GetGaneOfferLimit(targetType,offerLevel)
    return GetLevelLimit(targetType,"offerLevel",offerLevel)
end

--共鸣能达到的最高修炼等级
function GetSymLevelLimit(targetType,minlevel)
   local symLevel = DATA.PracticeData.mTypedLimitTable["symLevel"]
   return symLevel[targetType][minlevel]
end

--共鸣升级所需要的最小修炼等级
function GetSymNeedLevel(targetType,symlevel)
    local symLevelNeed = DATA.PracticeData.mTypedLimitTable["symLevelNeed"]
    return symLevelNeed[targetType][symlevel]
 end

return PracticeData;