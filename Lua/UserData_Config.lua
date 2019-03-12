module("UserData",package.seeall)

--远程配置信息
local mRemoteConfigData = {};
--本地配置信息
local mDiskConfigData = {};
--内存配置信息
local mMemoryConfigData = {};

local function GetRemoteValue(valType,key,default)
    local value = mRemoteConfigData[key];
    if value == nil then 
        return default
    else
        if valType == 1 then return (value == "1" or value == "true")   --BOOL
        elseif valType == 2 then return tonumber(value)                 --INT32
        elseif valType == 3 then return value                           --STRING
        end
    end
end

local function SetRemoteValue(key,value)
    mRemoteConfigData[key] = tostring(value);
    --TODO 保存到服务器
end

local function GetRemoteKey(key1,key2,key3)
    return string.format("%s_%s_%s",key1 or "",key2 or "",key3 or "");
end

local function GetDiskValue(valType,key,default)
    local value = mDiskConfigData[key];
    if value == nil then 
        return default
    else
        if valType == 1 then return (value == "1" or value == "true")   --BOOL
        elseif valType == 2 then return tonumber(value)                 --INT32
        elseif valType == 3 then return value                           --STRING
        end
    end
end

local function SetDiskValue(key,value)
    mDiskConfigData[key] = tostring(value);
    --TODO 保存到本地
end

local function GetDiskKey(key1,key2,key3)
    return string.format("%s_%s_%s",key1 or "",key2 or "",key3 or "");
end

function InitConfigModule()
end

function InitConfigModuleOnLogin(moduleAtt,playerAtt,configAtt)
    --TODO 登录流程
end

--自动战斗状态
function GetAutoFight() return mMemoryConfigData.autoFight; end
function SetAutoFight(value,param)
    local autoFight = mMemoryConfigData.autoFight or false;
    if autoFight ~= value then
        local mapUnitData = MapMgr.GetMapChildInfo();
        if value and mapUnitData and not mapUnitData.mapCanAutoFight then
            --当前场景不能开启自动战斗
            TipsMgr.TipByKey("fight_autofight_map_limit"); return;
        end
        mMemoryConfigData.autoFight = value;
        MapMgr.GetMainPlayer():GetAIComponent():AutoFight(value);
        --param指定开启自动战斗的来源
        GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_AUTOFIGHT,value,param);
    end
end
--主界面按钮折叠状态
function GetMainUIBtnState() return mMemoryConfigData.mainUIBtnState; end
function SetMainUIBtnState()
    mMemoryConfigData.mainUIBtnState = not mMemoryConfigData.mainUIBtnState;
    GameEvent.Trigger(EVT.MAINUI,EVT.MAINUI_BTN_STATE);
end
--自动战斗目标设置
function GetAutoSkillLimitType() return GetRemoteValue(2,"autoSkillLimitType",EntityDefine.SKILL_PRIORITY_TYPE.NONE); end
function SetAutoSkillLimitType(autoSkillLimitType) SetRemoteValue("autoSkillLimitType",autoSkillLimitType) end
--自动战斗追击设置
function GetAutoSkillFollowFlag() return GetRemoteValue(1,"autoSkillFollowFlag",true); end
function SetAutoSkillFollowFlag(autoSkillFollowFlag) SetRemoteValue("autoSkillFollowFlag",autoSkillFollowFlag) end
--自动战斗技能开关
function GetAutoSkillActiveFlag(skillSlot) return GetRemoteValue(1,GetRemoteKey("autoSkillActive",skillSlot),true); end
function SetAutoSkillActiveFlag(skillSlot,activeFlag) SetRemoteValue(GetRemoteKey("autoSkillActive",skillSlot),activeFlag) end
--标记首充界面打开时间
function SetChargeUIOpenNextTime()
    local nextStamp = TimeUtils.TimeStampLeft2NextTime({ hour = ConfigData.GetValue("Time_newday")});
    SetDiskValue(GetDiskKey("charge","uiOpenTime","next"),nextStamp)
end
--获取当日是否过打开首充界面
function GetChargeUIOpenFlagToday()
    local systemTimeStamp = TimeUtils.SystemTimeStamp();
    local nextTimeStamp = GetDiskValue(2,GetDiskKey("charge","uiOpenTime","next"),systemTimeStamp + 1);
    return systemTimeStamp > nextTimeStamp;
end

return UserData;