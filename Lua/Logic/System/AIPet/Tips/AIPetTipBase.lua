--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{hesinian}
    time:2019-02-15 16:42:46
]]

local AIPetTipBase = class("AIPetTipBase")

function AIPetTipBase:ctor(content, str1, func1,str2, func2, caller)
    if not func1 then GameLog.LogError("function 1 cann't be Nil"); end
    self._content = content;
    self._str1 = str1;
    self._func1 = func1;
    self._str2 = str2;
    self._func2 = func2;
    self._caller = caller;
end

function AIPetTipBase:GetContent( )
    return self._content;
end
function AIPetTipBase:GetBtn1Str( )
    return self._str1 or WordData.GetWordStringByKey("AIPetTip_Ok_Fun_Name");
end
function AIPetTipBase:GetBtn1Call( )
    return self._func1;
end
function AIPetTipBase:GetBtn2Str( )
    return self._str2 or WordData.GetWordDataByKey("AIPetTip_cancel_Func_Name");
end
function AIPetTipBase:GetBtn2Call( )
    return self._func2;
end
function AIPetTipBase:GetCaller( )
    return self._caller;
end
function AIPetTipBase:GetCallCount()
    if self._func2 then return 2; end
    return 1;
end
return AIPetTipBase;