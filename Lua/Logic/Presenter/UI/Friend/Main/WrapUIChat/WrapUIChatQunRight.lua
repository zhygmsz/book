local WrapUIChatBase = require("Logic/Presenter/UI/Friend/Main/WrapUIChat/WrapUIChatBase");
local WrapUIChatQunRight  = class("WrapUIChatQunRight",WrapUIChatBase);

function WrapUIChatQunRight:ctor(root,baseEventID,ui)
    self.super.ctor(self,root,baseEventID,ui, "RightQun");
    self._isLeft = false;
    self._labelName = self._subItemTran:Find("Player/LabelName"):GetComponent("UILabel");
end

return WrapUIChatQunRight;