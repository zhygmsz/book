
local AISpiritTipWidget = class("AISpiritTipWidget")
function AISpiritTipWidget:ctor()
    
end

function AISpiritTipWidget:Show(content, data)
    --具体表现对接ai宠物模块
    TipsMgr.TipByFormat(content)
end

return AISpiritTipWidget