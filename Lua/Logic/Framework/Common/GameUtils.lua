module("GameUtils",package.seeall)

local xpcall = xpcall;
local traceback = traceback;
local string = string;

function InitModule()

end

--保护模式调用函数
function TryCatch(func, ...)
	local flag,msg = xpcall(func, traceback, ...);
	if not flag then
        GameLog.LogError("call func error-> %s",msg);
        return false;
    else
        return true; 
	end
end
--自动判断是否是面向对象的方法调用
function TryInvokeCallback(callback,caller,...)
    if not callback then return; end
    if caller then
        TryCatch(callback,caller,...);
    else
        TryCatch(callback,...);
    end
end

function StringCharactorLength(str,filters,limitCharater)
    local count=0 
    local cutMaxIndex= 0
    local found = false
    local cut=false
    local function Filter(totalLen,curLen,curChar)
        if curLen==1 then
            count=count+1
        else
            count=count+1
        end
        if filters then
            for j=1,#filters do
                if curChar == filters[j] then
                    found = true
                end
            end
        end
        if cut == false then
            if limitCharater and  type(limitCharater) == "number"  then
                if count == limitCharater then
                    cutMaxIndex = totalLen-1
                    cut = true
                elseif count > limitCharater then
                    cutMaxIndex = totalLen -curLen
                    cut = true
                end
            end
        end
    end
    string.ForEachChar(str,Filter)
    return count,found,indexbyteLen
end

return GameUtils;
