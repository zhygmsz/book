local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/UIPanelChatBase")
local PanelChatNone = class("PanelChatNone",Base);

function PanelChatNone:ctor(ui,path,basicPath,inputPath)
    self.super.ctor(self,ui,path,basicPath,inputPath);
end

function PanelChatNone:OnEnable()
    self.super.OnEnable(self);
end

return PanelChatNone;
