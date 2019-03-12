--[[
    author:{hesinian}
    time:2019-02-20 18:07:32
]]
local UIAIPetBubble = class("UIAIPetBubble")

function UIAIPetBubble:ctor(trans)
    self._root = trans;
    self._go = self._root.gameObject;
    self._entity = nil;
    self._label = trans:GetComponent("UILabel");
end

function UIAIPetBubble:SetTarget(aipet)
    if not aipet then self:Close(); return; end
    self._go:SetActive(true);

    self._label.text = aipet:GetFirstMeet();
end

function UIAIPetBubble:Close()
    self._go:SetActive(false);
end

return UIAIPetBubble;