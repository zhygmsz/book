LinkedList = class("LinkedList",nil)

function LinkedList:ctor()
    self._first = nil;
    self._last = nil;
    self._size = 0;
    self._idGenerator = 0;
end

function LinkedList:Count()
    return self._size;
end

function LinkedList:First()
    return self._first;
end

function LinkedList:Last()
    return self._last;
end

function LinkedList:Add(element)
    self._idGenerator = self._idGenerator + 1;
    self._size = self._size + 1;
    local prev = self._last; 
    self._last = {id=self._idGenerator};
    self._last.element = element;
    self._last.prev = prev;
    if prev then
        prev.next = self._last;
    else
        self._first = self._last;
    end
    return self._last;
end 

function LinkedList:InsertAfter(prev,element)
    self._idGenerator = self._idGenerator + 1;
    self._size = self._size + 1; 
    local current = {id=self._idGenerator};
    current.element = element;
    current.prev = prev;

    if prev then
        if prev.next then
            current.next = prev.next; 
        end
        prev.next = current;
        if prev == self._last then
            self._last = current;
        end
    else
        self._last = current;
    end

    return current;
end

function LinkedList:InsertBefore(next,element)
    self._idGenerator = self._idGenerator + 1;
    self._size = self._size + 1; 
    local current = {id=self._idGenerator};
    current.element = element;
    current.next = next;

    if next then
        if next.prev then
            current.prev = next.prev; 
        end
        next.prev = current;
        if next == self._first then
            self._first = current;
        end
    else
        self._first = current; 
    end
    return current;
end

function LinkedList:Remove(element)
    if self._size <= 0 then return false end 
    local current = self._last;
    while current do 
        if current.element == element then
            self:RemoveAt(current);
            return true;
        end
        current = current.prev;
    end
    return false;
end

function LinkedList:TestNode(node)
    local current = self._first;
    while current do 
        if current == node then
            break;
        end
        current = current.next;
    end
    if not current then
        print("test node failure ")
    end
end

function LinkedList:RemoveAt(current,noupdate)
    --self:TestNode(current);

    local prev = current.prev;
    local next = current.next;
    if prev then
        prev.next = next; 
    end
    if next then
        next.prev = prev;
    end
    if not noupdate then
        self._size = self._size - 1;
    end
    current.prev = nil;
    current.next = nil;

    if current == self._first then
        self._first = next;
    end

    if current == self._last then
        self._last = prev;
    end
end

function LinkedList:SetLast(current)
    if current == self._last then return end 
    self:RemoveAt(current,true); 
    current.next = self._last;
    self._last.next = current;
    self._last = current;    
end
 
function LinkedList:Clear()
    self._first = nil;
    self._last = nil;
    self._size = 0;
end

return LinkedList;