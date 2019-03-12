module("WelfareMgr", package.seeall)

--变量
local mLeftItemData = {
    [1] = { name = "签到", ui = AllUI.UI_Welfare_DailySign },
    [2] = { name = "七天登录", ui = AllUI.UI_SevenDayLogin },
    [3] = { name = "等级礼包" },
    [4] = { name = "特惠礼包" },
    [5] = { name = "拼图", ui = AllUI.UI_Puzzle },
    [6] = { name = "测试" },
    [7] = { name = "测试" },
    [8] = { name = "测试" },
    [9] = { name = "测试" },
    [10] = { name = "测试" },
}

DebugMode = true

--local方法
local function InitData()

end

local function Init()
    InitData()
end

function GetLeftItemDataList()
    local list = {}
    for key, itemData in pairs(mLeftItemData) do
        local data = {}
        data.id = key
        data.name = itemData.name
        data.ui = itemData.ui
        table.insert(list, data)
    end
    return list
end

--模块初始化
function InitModule()
    Init()
end

return WelfareMgr