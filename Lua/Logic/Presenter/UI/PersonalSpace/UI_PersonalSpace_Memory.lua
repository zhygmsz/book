module("UI_PersonalSpace_Memory",package.seeall)

function OnCreate(self)

end

function OnEnable(self)
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
    mEvents = {};
end

function OnClick(go, id)
	
end