--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{hesinian}
    time:2019-02-15 16:42:46
]]
local AIPetTipBase = require("Logic/System/AIPet/Tips/AIPetTipBase");
local AIPetTipSystem = class("AIPetTipSystem",AIPetTipBase)

function AIPetTipSystem:ctor(...)
    self.super.ctor(self,...);
end

return AIPetTipSystem;