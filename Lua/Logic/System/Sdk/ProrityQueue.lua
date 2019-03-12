local ProrityQueue = class("ProrityQueue",nil)

function ProrityQueue:ctor()
    self._stack={}
    self._keyMap={}
end

function ProrityQueue:Count()
    return table.count(self._stack)
end


function ProrityQueue:Enqueue(key,item,priority)
    local N = table.count(self._stack)
    local data = {}
    data.key = key
    data.item = item
    data.priority = priority
    self._stack[N+1] = data
    self._keyMap[key] = N+1
    self:Arrangement()
end

function ProrityQueue:GetItemByKey(key)
    local index = self._keyMap[key]
    if index then
        local N = table.count(self._stack)
        if index<=N then
            return self._stack[index].item
        end
    end
    return nil
end

function ProrityQueue:GetItemByIndex(index)
    if index then
        local N = table.count(self._stack)
        if index<=N then
            return self._stack[index].item
        end
    end
    return nil
end

function ProrityQueue:DequeueByKey(key)
    local index = self._keyMap[key]
    local min = self._stack[index]
    local N = table.count(self._stack)
    local max =  self._stack[N]
    self._stack[index] = max
    self._stack[N] = nil
    self._keyMap[max.key] = index
    self._keyMap[min.key] = nil
    self:Arrangement()
    return min.item
end

function ProrityQueue:Dequeue()
    local min = self._stack[1]
    local N = table.count(self._stack)
    local max =  self._stack[N]
    self._stack[1] = max
    self._stack[N] = nil
    self._keyMap[max.key] = 1
    self._keyMap[min.key] = nil
    self:SiftDown(1)
    return min.item
end

function ProrityQueue:Init(array)
    self._stack = {}
    self._stack = array
    local N = table.count(array)
    for i=math.floor(N/2),1,-1 do
        self:SiftDown(i)
    end
end

--最小堆整理
function ProrityQueue:Arrangement()
    local N = table.count(self._stack)
    for i=math.floor(N/2),1,-1 do
        self:SiftDown(i)
    end
end

function ProrityQueue:Swap(index1,index2)
    local item ={}
    item = self._stack[index1]
    self._keyMap[item.key] = index2
    self._keyMap[self._stack[index2].key] = index1
    self._stack[index1] = self._stack[index2]
    self._stack[index2] = item
end

function ProrityQueue:SiftUp(index)--index 向上调整的编号
    local flag = 0 --标记是否继续向上调整
    if index==1 then return end
    while index~=1 and flag==0 do
        local pindex = math.floor(index/2)
        --父节点的优先级大
        if self._stack[pindex].priority > self._stack[index].priority then
            --交换位置
            self:Swap(pindex,index)
        else
            --不需要继续调整
            flag=1
        end
        index = pindex
    end
end

function ProrityQueue:SiftDown(index)--index 向下调整的编号
    local flag = 0 --标记是否继续向下调整
    local N = table.count(self._stack)

    while 2*index<=N and flag==0 do
        local left = 2*index
        local right = 2*index+1
        local min = index
        --比较左节点
        if self._stack[min].priority > self._stack[left].priority then
            min = left
        end
        if right<=N then
            if self._stack[min].priority > self._stack[right].priority then
                min = right
            end
        end
        if min~=index then
             --交换位置
             self:Swap(min,index)
             index = min --更新为价换的儿子节点编号 继续向下调整
        else
            flag = 1
        end
    end
end

return ProrityQueue