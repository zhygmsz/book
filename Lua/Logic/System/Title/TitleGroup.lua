local TitleGroup = class("TitleGroup");

function TitleGroup:ctor(gid)
    self._id = gid;
    self._items = {};
    self._class = nil;
end

function TitleGroup:AddItem(item)
    table.insert(self._items,item);
end

function TitleGroup:SetClass(cla)
    self._class = cla;
end

function TitleGroup:GetAllItems()
    return self._items;
end

function TitleGroup:GetRepresentItem()
    for i = #self._items, 1,-1 do
        local item = self._items[i];
        if item:IsOpen() then
            return item;
        end
    end
    return self._items[1];
end

function TitleGroup:GetID()
    return self._id;
end

function TitleGroup:GetClass()
    return self._class;
end

return TitleGroup;