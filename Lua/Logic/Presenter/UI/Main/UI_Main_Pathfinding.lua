module("UI_Main_Pathfinding",package.seeall)

local mOffsetTrans;
local mLabelContent;
local mOffsetGo;

function OnCreate(self)
    mOffsetTrans = self:Find("offset");
    mOffsetGo = mOffsetTrans.gameObject;
    mOffsetGo:SetActive(false);
    mLabelContent = self:FindComponent("UILabel","offset/TextureBg/LabelContent");
    RigisterOpenEvent();
end

function ShowContent(content)
    mOffsetGo:SetActive(true);
    mLabelContent.text = content;
end

function RigisterOpenEvent()
    GameEvent.Reg(EVT.PLAYER,EVT.ENTITY_PATHFINDING,OnPathFindingBegin);
    GameEvent.Reg(EVT.TASK,EVT.TASK_AI_STOP,OnAutoMoveStop);
end

function OnPathFindingBegin(...)
    local args = {...};
    local msg = args[1];
    for i=2, #args do
        msg = msg.." "..args[i];
    end
    ShowContent(msg);
end

function OnAutoMoveStop()
    mOffsetGo:SetActive(false);
end



