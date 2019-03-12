--[[
    author:{hesinian}
    time:2019-02-20 18:07:32
]]
local UIAIPetArrow = class("UIAIPetArrow")

function UIAIPetArrow:ctor(trans)
    self._root = trans;
    self._go = self._root.gameObject;
    self._entity = nil;
    self._offsetPos = Vector3.zero;
    self._localOffset = Vector3.zero;
    self._labelName = trans:Find("LabelName"):GetComponent("UILabel");
    self._labelInfo = trans:Find("LabelInfo"):GetComponent("UILabel");
end

function UIAIPetArrow:SetFollow(entity)
    local followTarget = entity:GetModelComponent():GetEntityRoot();
    self._offsetPos.y = entity:GetPropertyComponent():GetHeight();
    self._localOffset.y = 40;
    self._followID = GameUIFollow.AddFollow(followTarget, self._root, self._offsetPos, self._localOffset);
    
    self._entity = entity;
    local aipet = AIPetMgr.GetPetByNPCID(entity:GetNPCStaticID());
    self._labelName.text = aipet:GetName();
end

function UIAIPetArrow:Destroy()
    GameObject.Destroy(self._go);
end

return UIAIPetArrow;