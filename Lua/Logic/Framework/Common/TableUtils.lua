module("TableUtils",package.seeall)

function InitModule()
    --只读全局空的table
    local meta = {};
    meta.__newindex = function() GameLog.LogError("table is read only"); end
    table.emptyTable = setmetatable({},meta);
    table.tmpTable = {};
end

--获取table元素个数,针对自己创建的kv类型的表
function table.count(t)
    local count = 0;
    for k,v in pairs(t) do count = count + 1 end
    return count;
end

--移除table内值为value的元素,针对自己创建的kv类型的表
function table.remove_value(t,value)
    if t == nil then return end
    for k,v in pairs(t) do if v == value then rawset(t,k,nil) end end 
end

--移除数组内值为value的元素
function table.remove_array_value(t,value)
    if t == nil then return end
    local i = 1;
    repeat 
        if t[i] == value then 
            table.remove(t,i);
            i = i - 1;
        end 
        i = i + 1;
    until i > #t;
end

--table是否包含值为value的元素
function table.contains_value(t,value)
    if t == nil then return false end
    for k,v in pairs(t) do if v == value then return true end end
end

--table是否为空
function table.empty(t)
    return t == nil or next(t) == nil;
end

--插入一个最大长度固定的表,数组,最大数量,插入项,比较方法
function table.insert_limit_array(t,count,item,func)
    if #t == 0 then
        table.insert(t,item);
        return t;
    end
    local needIn = true;
    for i=1,#t do
        if func(item, t[i]) then--item 排前面
            table.insert(t,i,item);
            needIn = false;
            break;
        end
    end
    if needIn and (#t<count) then
        table.insert(t,item);
    end
    for i=#t,count+1,-1 do
        table.remove(t,i);
    end
    return t;
end

--临时空的table,目前只有一个
function table.tmpEmptyTable()
    local tmpTable = table.tmpTable;
    table.clear(tmpTable);
    return tmpTable;
end

--清空table
function table.clear(t)
    for k,v in pairs(t) do
        t[k] = nil;
    end
end

return TableUtils;