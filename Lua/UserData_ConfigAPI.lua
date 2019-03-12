module("UserData",package.seeall)
local ZLUtil = UnityEngine.PlayerPrefs;

function HasConfig(key)
    return ZLUtil.HasKey(key);
end

function ReadConfig(key)
    return ZLUtil.HasKey(key) and ZLUtil.GetString(key) or "";
end

function ReadBoolConfig(key,defaultValue)
    if ZLUtil.HasKey(key) then
        return ZLUtil.GetInt(key) == 1;
    else
        return defaultValue;
    end
end

function ReadIntConfig(key)
    return ZLUtil.HasKey(key) and ZLUtil.GetInt(key) or 0;
end

function WriteConfig(key,value)
    ZLUtil.SetString(key,tostring(value));
end

function WriteBoolConfig(key,value)
    ZLUtil.SetInt(key,value and 1 or 0);
end

function WriteIntConfig(key,value)
    ZLUtil.SetInt(key,value);
end

function DeleteKey(key)
    ZLUtil.DeleteKey(key);
end