local WrapUIChatBase = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatBase");
local WrapUIChatQunLeft  = class("WrapUIChatQunLeft",WrapUIChatBase);

function WrapUIChatQunLeft:ctor(root,baseEventID,ui)
    self.super.ctor(self,root,baseEventID,ui, "LeftQun");
    self._isLeft = true;
    self._labelName = self._subItemTran:Find("Player/LabelName"):GetComponent("UILabel");
end

return WrapUIChatQunLeft;