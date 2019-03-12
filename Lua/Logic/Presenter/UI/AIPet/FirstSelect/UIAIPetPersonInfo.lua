--[[
    author:{hesinian}
    time:2019-02-20 18:07:32
]]
local UIAIPetPersonInfo = class("UIAIPetPersonInfo")

function UIAIPetPersonInfo:ctor(trans)
    self._root = trans;
    self._go = self._root.gameObject;
    self._entity = nil;

    self._name = trans:Find("LabelName"):GetComponent("UILabel");
    self._sex = trans:Find("LabelSex"):GetComponent("UILabel");

    self._interest = trans:Find("LabelInterest"):GetComponent("UILabel");
    self._sign = trans:Find("LabelTerm"):GetComponent("UILabel");
end

function UIAIPetPersonInfo:SetTarget(aipet)
    if not aipet then self:Close(); return; end
    self._go:SetActive(true);

    self._name.text = aipet:GetName();
    self._sex.text = aipet:GetStar();

    self._interest.text = aipet:GetInterest();
    self._sign.text = aipet:GetDream();
end

function UIAIPetPersonInfo:Close()
    self._go:SetActive(false);
end

return UIAIPetPersonInfo;