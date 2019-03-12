local WrapUIChatBase = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatBase");
local WrapUIChatPrivateRight  = class("WrapUIChatPrivateRight",WrapUIChatBase);

function WrapUIChatPrivateRight:ctor(root,baseEventID,ui)
    self.super.ctor(self,root,baseEventID,ui,"Right");
    self._isLeft = false;
end

return WrapUIChatPrivateRight;