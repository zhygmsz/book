
local UIAIPetStateBase = require("Logic/Presenter/UI/Main/AIPetMain/State/UIAIPetStateBase");
local UIAIPetStateClosed = class("UIAIPetStateClosed",UIAIPetStateBase);

function UIAIPetStateClosed:ctor(context)
    self.super.ctor(self, context);
end

function UIAIPetStateClosed:OnEnter()
    self._context:DiableAllComs();
end

function UIAIPetStateClosed:OnExit()
    --self._context:EnableAllComs();
end

return UIAIPetStateClosed;

