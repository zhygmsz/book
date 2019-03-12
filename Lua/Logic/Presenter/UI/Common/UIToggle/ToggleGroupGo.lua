--基于ToggleItemGroup 控制GameObject
ToggleGroupGo = class("ToggleGroupGo")

function ToggleGroupGo:ctor()
    self._toggleGroup = ToggleItemGroup.new(self.OnDeSelected,self.OnSelected,self);
    self._contentTable = {};
end

--按钮transform--其下必有"nor/label" 和 "spec/label", UIEvent, 按钮名, 控制体, 控制数据
function ToggleGroupGo:AddItem(data)--{trs = btnTrans,eventId = id,content=name,ui = ui,data = data};
    local id = data.eventId;
    self._contentTable[id] = data;
    self._toggleGroup:AddItem(data.trs, data);
end

function ToggleGroupGo:OnDeSelected(id)
    self._contentTable[id].ui:SetActive(false);
end

function ToggleGroupGo:OnSelected(id)
    self._contentTable[id].ui:SetActive(true);
end

function ToggleGroupGo:OnClick(id)
    self._toggleGroup:OnClick(id);
end

function ToggleGroupGo:Init(ini)
    for id, content in pairs(self._contentTable) do
        if id == ini then
            self:OnSelected(id);
        else
            self:OnDeSelected(id);
        end
    end
    self:OnClick(ini);
end

function ToggleGroupGo:Reset()
    for id, content in pairs(self._contentTable) do
        self:OnSelected(id);
    end
    self._toggleGroup:ClearCurEventId(true);
end
return ToggleGroupGo
