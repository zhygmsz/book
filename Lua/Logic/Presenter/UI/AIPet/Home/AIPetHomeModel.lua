local AIPetHomeModel = class("AIPetHomeModel");

function AIPetHomeModel:ctor(index,ui,prefab)
    self._pid = AIPetMgr.GetPetIDByIndex(index);
    self._staticInfo = AIPetMgr.GetPetStaticInfo(self._pid);
    self._transform = ui:DuplicateAndAdd(prefab,prefab.parent,index);
    self._transform.gameObject:SetActive(true);
    self._transform.name = string.format("AIPet "..self._pid);
    local x = math.random(-700,100);
    local y = math.random(-240,240);
    self._transform.localPosition = Vector3.New(x,y,0);
    local sprite = self._transform:GetComponent("UISprite");
    sprite.spriteName = self._staticInfo.resName;
    local uievent = self._transform:GetComponent("UIEvent");
    uievent.id = 20 + index;
end

function AIPetHomeModel:Destroy()
    UnityEngine.GameObject.Destroy(self._transform.gameObject);
end

return AIPetHomeModel;