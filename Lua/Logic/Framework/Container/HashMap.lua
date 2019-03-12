HashMap = class("HashMap",nil)

function HashMap:ctor() 
    self._values = {};
    self._size = 0;
end

function HashMap:Add(key,value)
    local oldValue = self._values[key];
    if not oldValue then
        self._values[key] = value;
        self._size = self._size + 1; 
    end 
    return oldValue == nil;
end

function HashMap:Remove(key)
    local value = self._values[key];
    if value then
        self._values[key] = nil;
        self._size = self._size - 1;
    end
    return value;
end

function HashMap:Get(key)
    return self._values[key];
end 

function HashMap:Count()
    return self._size;
end
  
function HashMap:Clear(func) 
    if func then
        self:Foreach(func);
    end
    self._values = {};
    self._size = 0;
end

function HashMap:Foreach(func,...)
    for key,value in pairs(self._values) do
        if value then
            func(key,value,...);
        end
    end
end

function HashMap:GetValues()
    return self._values;
end

return HashMap