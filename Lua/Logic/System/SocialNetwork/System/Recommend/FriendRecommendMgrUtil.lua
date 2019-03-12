
module("FriendRecommendMgrUtil",package.seeall)

--将"1,3,54"解析为{1,3,54}
function String2List(value)
    local codeList = {};
    if not value or value == "" then
        return codeList;
    end
    value = StringTrim(value);
    local strList = string.split(value,',');
    for i, code in ipairs(strList) do
        code = StringTrim(code);
        if code ~= "" then
            codeList[i] = tonumber(code);
        end
    end
    return codeList;
end

--传入属性值或者属性值集合；输出字符串，集合用逗号‘，’隔开。
function Value2String(fieldValue)
    if not fieldValue then  return "" end
    local str = nil;
    if type(fieldValue) == 'table' then
        str = fieldValue[1] and tostring(fieldValue[1]) or "";
        if #fieldValue >1 then
            for i = 2,#fieldValue do
                str = str..","..tostring(fieldValue[i]);
            end
        end
    else
        str = tostring(fieldValue);
    end
    return str;
end

function StringTrim(s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

return FriendRecommendMgrUtil;