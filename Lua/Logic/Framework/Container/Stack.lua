Stack = class("Stack",nil)

function Stack:ctor()
    self._top = nil;
    self._size = 0;
end

function Stack:Count()
    return self._size;
end

function Stack:Top()
    return self._top;
end

function Stack:Push(element)
    self._size = self._size + 1;
    local next = self._top; 
    self._top = {};
    self._top.element = element;
    self._top.next = next;
end

function Stack:PopTo(target,callback)
    if self._size <= 0 then return nil end 
    local result = nil; 
    local current = self._top;
    while current do  
        self._size = self._size - 1;
        if current.element == target then
            self._top = current.next;                     
            result = target;
            break;
        end
        if callback then
            callback(current.element);
        end
        current = current.next;                  
    end

    return result;
end

function Stack:SafePopTo(target,callback)
    if self._size <= 0 then return nil end 
    local result = nil;
    local counter = 0;
    local current = self._top;
    while current do 
        counter = counter + 1;
        if current.element == target then                       
            result = current;
            break;
        end        
        current = current.next;        
    end
    if result then
        if callback then
            current = self._top;
            while current do  
                if current == result then   
                    break;
                end
                callback(current.element);
                current = current.next;        
            end
        end
        self._top = result.next;
        self._size = self._size - counter; 
        return result.element;
    end
    return nil;
end

function Stack:Pop()
    if self._size <= 0 then return nil end 
    local element = self._top.element; 
    self._top = self._top.next;
    self._size = self._size - 1;
    return element;
end

function Stack:Peek()
    if self._size <= 0 then return nil end    
    return self._top.element;
end

function Stack:Clear()
    self._top = nil;
    self._size = 0;
end

return Stack;