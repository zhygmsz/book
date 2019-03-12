--基于ToggleItemGroup 控制UIPanel
ToggleGroupUIMgr = class("ToggleGroupUIMgr",ToggleGroupGo)

function ToggleGroupUIMgr:ctor(titleLabel)
    ToggleGroupGo.ctor(self);
    self._titleLabel = titleLabel;
end

function ToggleGroupUIMgr:OnDeSelected(id)
    UIMgr.UnShowUI(self._contentTable[id].ui);
end

function ToggleGroupUIMgr:OnSelected(id)
    UIMgr.ShowUI(self._contentTable[id].ui);
    if self._titleLabel then
        local title = self._contentTable[id].content;
        if not string.find(title, '[b]') then
            title = '[b]'..title;
        end
        self._titleLabel.text = title;
    end
end

function ToggleGroupUIMgr:Reset()
    for id, content in pairs(self._contentTable) do
        self:OnDeSelected(id);
    end
    self._toggleGroup:ClearCurEventId(true);
end


return ToggleGroupUIMgr;
