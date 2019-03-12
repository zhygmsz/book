module("UI_FightHelp_Recruit", package.seeall);

function OnCretae(self)
    -- body
end

function OnEnable(self)
    -- body
end

function OnDisable(self)
    -- body
end

function OnClick(go, id)
    if id == 1 then
        FightHelpMgr.RequireRecruitFightHelper(2);
    end
end