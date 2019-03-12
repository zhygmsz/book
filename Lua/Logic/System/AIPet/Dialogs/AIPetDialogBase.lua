--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{hesinian}
    time:2019-02-15 16:42:46
]]

local AIPetDialogBase = class("AIPetDialogBase")

function AIPetDialogBase:ctor(content,time)
    self._content = content;
    self._time = time or TimeUtils.SystemTimeStamp(true);
end

function AIPetDialogBase:GetContent( )
    return self._content;
end
function AIPetDialogBase:GetTime( )
    return self._time;
end

return AIPetDialogBase;