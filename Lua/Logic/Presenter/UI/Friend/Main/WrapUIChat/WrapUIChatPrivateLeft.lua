local WrapUIChatBase = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatBase");
local WrapUIChatPrivateLeft  = class("WrapUIChatPrivateLeft",WrapUIChatBase);

function WrapUIChatPrivateLeft:ctor(root,baseEventID,ui)
    self.super.ctor(self,root,baseEventID,ui,"Left");
    self._isLeft = true;
end

return WrapUIChatPrivateLeft;