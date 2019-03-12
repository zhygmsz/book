ArrayList = class("ArrayList",nil)

function ArrayList:ctor()
    self._array = {};
    self._size = 0;
    self.values = self._array;
end

function ArrayList:Count()
    return self._size;
end

function ArrayList:Get(index)
    return self._array[index];
end

function ArrayList:Add(element)
    self._size = self._size + 1;
    table.insert(self._array,element)
end 

function ArrayList:RemoveAt(index)
    if self._size <= 0 or index > self._size then return nil end 
    local element = self._array[index];
    table.remove(self._array,index);
    self._size = self._size - 1;
    return element;
end 

function ArrayList:Remove(element)
    for i,v in ipairs(self._array) do
        if v == element then
            table.remove(self._array,i);
            self._size = self._size - 1;
            break;
        end
    end
end

function ArrayList:Contain(element)
    for i,v in ipairs(self._array) do
        if v == element then
            return true;
        end
    end
    return false;
end

function ArrayList:Clear()
    self._array = {};
    self.values = self._array;
    self._size = 0;
end

function ArrayList:GetValues()
    local values = {};
    for index,value in ipairs(self.values) do
        table.insert(values,value);
    end
    return values;
end

return ArrayList;