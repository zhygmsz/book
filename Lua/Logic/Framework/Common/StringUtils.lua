module("StringUtils",package.seeall)

local mIllegalWordHashMap = {};

local __code =
{
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
};
local __decode = {};
for k,v in pairs(__code) do
    __decode[string.byte(v,1)] = k - 1;
    if v == '+' then
        __decode[string.byte(' ')] = k - 1;
    end
end

local function encode_to_base64(text)
    local ret = {}
    local len = string.len(text)
    local left = len % 3;
    --base64编码,每三个字节转化为4个Base64字符,不足三个字节补0
    for i = 1, len, 3 do
        if i + 2 <= len then
            local a = string.byte(text,i);
            local b = string.byte(text,i+1);
            local c = string.byte(text,i+2);
            -- a << 16 + b << 8 + c
            local num = bit.lshift(a,16) + bit.lshift(b,8) + c
            for j = 1, 4 do
                -- tmp = num >> ((4-j) * 6)
                local tmp = bit.rshift(num,(4-j) * 6);
                local pos = tmp % 64 + 1;
                table.insert(ret,__code[pos]);
            end
        else
            len = i;
            break;
        end
    end
    if left == 1 then
        --右移2位,取最后一个字节的前6位
        local num = string.byte(text,len);
        local pos = bit.rshift(num,2) % 64 + 1;
        table.insert(ret,__code[pos]);
        --左移4位,取最后一个字节的后2位
        local two = bit.lshift(bit.band(num,3),4); 
        local pos = two % 64 + 1;
        table.insert(ret,__code[pos]);
        --补上2个等号
        table.insert(ret,'=');
        table.insert(ret,'=');
    elseif left == 2 then
        --左移2位,得出18位转化为3个Base64
        local num1 = string.byte(text,len);
        local num2 = string.byte(text,len + 1);
        local num = bit.lshift(num1,10) + bit.lshift(num2,2);
        --右移12位取出第一个
        local pos = bit.rshift(num,12) % 64 + 1;
        table.insert(ret,__code[pos]);
        --右移6位取出第二个
        local pos = bit.rshift(num,6) % 64 + 1;
        table.insert(ret,__code[pos]);   
        --取出第三个
        local pos = num % 64 + 1;
        table.insert(ret,__code[pos]);  
        --补上1个等号
        table.insert(ret,'=');
    end

    return table.concat(ret)
end

local function decode_from_base64(text)
    local ret = {};
    local len = string.len(text);
    local left = 0 
    if string.sub(text, len - 1) == "==" then
        left = 1 
        len = len - 4
    elseif string.sub(text, len) == "=" then
        left = 2
        len = len - 4
    end

    for i = 1, len, 4 do
        local a = __decode[string.byte(text,i    )] 
        local b = __decode[string.byte(text,i + 1)] 
        local c = __decode[string.byte(text,i + 2)] 
        local d = __decode[string.byte(text,i + 3)]
        --num = a<<18 + b<<12 + c<<6 + d
        local num = bit.lshift(a,18) + bit.lshift(b,12) + bit.lshift(c,6) + d
        --每8位1个字符
        local s1 = string.char(bit.rshift(num,16) % 256)
        local s2 = string.char(bit.rshift(num,8) % 256)
        local s3 = string.char(num % 256)
        table.insert(ret,s1);
        table.insert(ret,s2);
        table.insert(ret,s3);
    end

    if left == 2 then
        local a = __decode[string.byte(text, len + 1)]; 
        local b = __decode[string.byte(text, len + 2)];
        local c = __decode[string.byte(text, len + 3)];
        local num = bit.lshift(a,12) + bit.lshift(b,6) + c;
        
        local s1 = string.char(bit.rshift(num,10) % 256);
        local s2 = string.char(bit.rshift(num,2) % 256);
        table.insert(ret,s1);
        table.insert(ret,s2);
    elseif left == 1 then
        local a = __decode[string.byte(text, len + 1)] 
        local b = __decode[string.byte(text, len + 2)]
        local num = bit.lshift(a,6) + b
        local s1 = string.char(bit.rshift(num,4) % 256);
        table.insert(ret,s1);
    end
    return table.concat(ret)
end

--根据第一个字节判断该UTF8字符包含几个字节
local function GetByteCount(firstByte)
    local curLen = 0;
    if firstByte >= 0 and firstByte <= 127 then
        --0xxxxxxx
        curLen = 1;
    elseif firstByte >= 192 and firstByte <= 223 then
        --110xxxxx
        curLen = 2;
    elseif firstByte >= 224 and firstByte <= 239 then
        --1110xxxx
        curLen = 3;
    elseif firstByte >= 240 and firstByte <= 247 then
        --11110xxx
        curLen = 4;
    elseif firstByte >= 248 and firstByte <= 251 then
        --111110xx
        curLen = 5;
    elseif firstByte >= 252 and firstByte <= 253 then
        --1111110x
        curLen = 6;
    else
        curLen = 1;
        GameLog.LogError("invalid utf8 byte value",firstByte);
    end
    return curLen;
end

--初始化敏感字符字典树
local function InitIllegalWords()
    if string.illegalDataInited then return else string.illegalDataInited = true end

    for k,v1 in pairs(IllegalData.GetIllegalDatas()) do
        if v1 and v1.stringValue and v1.stringValue ~= "" then
            --处理当前敏感词,拆成数组,插入到敏感词数内,END_FLAG标识是否为敏感词
            local charArray = string.ToCharArray(v1.stringValue);
            local charArrayLength = #charArray;
            local tmpTable = mIllegalWordHashMap;
            for i,v2 in ipairs(charArray) do
                if not tmpTable[v2] then
                    --新增key
                    tmpTable[v2] = {};                   
                    tmpTable[v2].END_FLAG = false;
                end
                --转移至子table
                tmpTable = tmpTable[v2];
                tmpTable.END_FLAG = tmpTable.END_FLAG and tmpTable.END_FLAG or i == charArrayLength;
            end
        end
    end    
end

function InitModule()
    
end

--字符串ID转INT
function string.StringIDToInt(strID)
    return tonumber(string.sub(strID,5,#strID));
end

--[[
获取UTF8字符串长度
str     目标字符串
rule    计算规则 不填则默认为0
            0 一个单独的字符算一个长度
            1 一个ASCII算0.5长度,其他字符算1个
--]]
function string.Length(str,rule)
    local totalLen = 1;
    local charCount = 0;
    local lenRule = rule or 0;
    repeat
        local curLen = GetByteCount(string.byte(str,totalLen) or 0);
        totalLen = totalLen + curLen;
        if lenRule == 0 then
            charCount = charCount + 1;
        elseif lenRule == 1 then
            if curLen == 1 then
                charCount = charCount + 0.5;
            else
                charCount = charCount + 1;
            end
        end
    until totalLen > #str
    return charCount;
end

--[[
获取UTF8字符串长度
str     目标字符串
rule    计算规则 不填则默认为0
            0 一个单独的字符算一个长度
            1 一个ASCII算0.5长度,其他字符算1个
--]]
function string.SubString(str,len,rule)
    local totalLen = 1;
    local charCount = 0;
    local lenRule = rule or 0;
    local cutlen = math.min(len,#str)
    local cut = false
    repeat
        local curLen = GetByteCount(string.byte(str,totalLen) or 0);
        totalLen = totalLen + curLen;
        if lenRule == 0 then
            charCount = charCount + 1;
        elseif lenRule == 1 then
            if curLen == 1 then
                charCount = charCount + 0.5;
            else
                charCount = charCount + 1;
            end
        end

        if charCount == cutlen then
            cut = true
            totalLen = totalLen -curLen
        elseif charCount > cutlen then
            totalLen = totalLen -curLen
            cut = true
        end

    until cut or charCount >= cutlen
    return string.sub(str, 1,totalLen);
end


--把UTF8内某个字符替换为对应的字符
function string.Replace(str,pattern,repl)
    return string.gsub(str,pattern,repl);
end

--把敏感词替换为repl,默认替换为一个*
function string.ReplaceIllegalWord(str,repl)
    InitIllegalWords();
    local charArray = string.ToCharArray(str);
    local wordLength = #charArray;
    local flag = false;
    for i = 1,wordLength do
        local tmpChar = nil;
        local tmpTable = mIllegalWordHashMap;
        for j = i,wordLength do
            tmpChar = charArray[j];
            tmpTable = tmpTable[tmpChar];
            if tmpTable == nil then break; end
            if tmpTable.END_FLAG then
                --从i到j是敏感词,替换为*字符,目前替换为一个*
                for k = i,j do charArray[k] = (k == j and (repl or "*") or ""); end
                i = j; flag = true; break;
            end
        end
    end       
	return (flag and table.concat(charArray) or str),flag;    
end

--把UTF8字符串按照分隔符拆分为字符串数组
function string.Split(str,reps)
    return string.split(str,reps);
end

--检测UTF8字符串内是否包含指定字符串
function string.Contains(str,pattern)
    return string.find(str,pattern);
end

--检查是否包含非法字符
function string.ContainsIllegalWord(str)
	InitIllegalWords();
    --计算以每个单词开头,是否包含敏感词    
    local charArray = string.ToCharArray(str);
    local wordLength = #charArray;
    for i,_ in ipairs(charArray) do
    	local tmpChar = nil;
        local tmpTable = mIllegalWordHashMap;
        --从当前字符开始到结束,检测是否构成敏感词
        for j = i,wordLength do
            tmpChar = charArray[j];
            tmpTable = tmpTable[tmpChar];
            if tmpTable == nil then break; end
            if tmpTable.END_FLAG then return true; end
        end
    end
end

--字符串前缀检查
function string.StartWith(str,prefix)
    return string.find(str,prefix) == 1;
end

--把UTF8字符串拆分为字符数组
function string.ToCharArray(str)
    local totalLen = 1;
    local charArray = {};
    repeat
        local curLen = GetByteCount(string.byte(str,totalLen) or 0);
        charArray[#charArray + 1] = string.sub(str,totalLen,totalLen + curLen - 1);
        totalLen = totalLen + curLen;
    until totalLen > #str
    return charArray;
end

--遍历UTF8字符串中的每个字符,执行指定的函数
function string.ForEachChar(str,func,obj)
    if not func then return end
    local totalLen = 1;
    repeat
        local curLen = GetByteCount(string.byte(str,totalLen) or 0);
        local curChar = string.sub(str,totalLen,totalLen + curLen - 1);
        totalLen = totalLen + curLen;
        if obj then func(obj,totalLen,curLen,curChar); else func(totalLen,curLen,curChar); end
    until totalLen > #str
end

--对字符串进行BASE64编码
function string.ToBase64(text)
    local flag,msg = xpcall(encode_to_base64,traceback,text)
    if not flag then
        return text;
    else
        return msg;
    end
end

--对BASE64字符串解码
function string.FromBase64(text)
    local flag,msg = xpcall(decode_from_base64,traceback,text)
    if not flag then
        GameLog.LogError("decode failed text is %s",text);
        return text;
    else
        return msg;
    end
end

function string.IsPureChinese(str)
    if not str or type(str) ~= "string" then
        return false
    end

    local isPure = true

    local i = 1
    local len = #str
    local curByte = nil
    while i <= len do
        curByte = string.byte(str, i)
        if 224 <= curByte and curByte <= 239 then
            i = i + 3
            --中文字符
            --把3字节的utf-8断定为中文，其实并不准确，要想精确判断得去查编码表，不值当
            --前提是，假定客户端内出现的只有英文和中文两种字符
        else
            isPure = false
            break
        end
    end

    return isPure
end

function string.NumberFormat(number,format)
    if format==0 then -- 三位逗号显示
       local t = tonumber(number)
       local head = t or 0
       local left = 0
       local out = ""
       repeat
            left = math.floor(head%1000)
            head = math.floor(head/1000)
            if out=="" then
                if head==0 then
                    out = string.format("%d",left)
                else
                    out = string.format("%03d",left)
                end
            elseif head>0 then
                out = string.format("%03d,%s",left,out)
            else
                out = string.format("%d,%s",left,out)
            end
       until head==0
       return out
    end
end

return StringUtils