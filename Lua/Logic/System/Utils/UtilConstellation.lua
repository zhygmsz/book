module("UtilConstellation",package.seeall);

--索引从1开始,知道MaxIndex后可以遍历所有星座数据
function GetMaxIndex()
    return 12;
end

--输入日期，输出星座索引
function GetIndexByData(data)
    return 1;--默认
end

function GetName(index)
    return WordData.GetWordStringByKey("system_constellation_name_"..index);
end