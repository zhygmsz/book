local TitleClass = class("TitleClass");

function TitleClass:ctor(name)
    self._name = name;
    self._groups = {};
end

function TitleClass:AddGroup(group)
    table.insert(self._groups,group);
end

function TitleClass:GetName()
    return self._name;
end

function TitleClass:GetGroups()
    local temp = {};
    for _,group in ipairs(self._groups) do
        local item = group:GetRepresentItem();
        if item:IsOpen() or (not item:IsAutoHide()) then
            table.insert(temp,group);
        end
    end
    return temp;
end

-- function TitleClass:GetRecommendGroup()
--     for i = 1, #self._groups do
--         local group = self._groups[i];
--         if (not group:IsAutoHide()) or group:IsOpened() then
--             return group;
--         end
--     end
-- end

return TitleClass;