module("UI_Vitality_News", package.seeall);

function OnCreate(self)
    -- body
end

function OnClick(go, id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Vitality_News);
    end
end