module("UI_PersonalSpace_InputView", package.seeall);

local mUItable ={}

function OnCreate(self)
    _self=self
    mUItable._obj = self:Find("Offset/EditorView").gameObject 
    mUItable._backBtn = self:Find("Offset/EditorView/BtnBack")
    mUItable._lookBtn = self:Find("Offset/EditorView/BtnLook")
    mUItable._replyBtn = self:Find("Offset/EditorView/BtnReply")
    mUItable._Input = self:Find("Offset/EditorView/MsgView/Input")
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
	mEvents = {};
end

function OnEnable(self,wheelNum,datas)
    RegEvent(self);
end

function OnDisable(self)
	UnRegEvent(self);
end

function onDestroy(self)
end

function OnClick(go,id)
end

return UI_PersonalSpace_InputView