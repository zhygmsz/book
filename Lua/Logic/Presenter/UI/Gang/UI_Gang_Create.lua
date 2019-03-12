module("UI_Gang_Create", package.seeall)

--组件
local mSelf
local mNameInput
local mPosInput
local mDesInput

local mCostIcon
local mCostNum


--变量
local mEvents = nil


--local方法
local function DoShowCost()
    --花费货币类型和数量读系统参数表
    local coinType = ConfigData.GetIntValue("Underworldgang_establish_money1")
    local coinNum = ConfigData.GetIntValue("Underworldgang_establish_money2")

    mCostIcon.spriteName = UIUtil.GetCoinSpName(coinType)
    mCostNum.text = tostring(coinNum)
end

local function OnClickCreate()
    local name = mNameInput.value
    if name == "" then
        TipsMgr.TipByFormat("请输入名称")
        return
    end
    --检测名字是否为全中文
    if not string.IsPureChinese(name) then
        TipsMgr.TipByFormat("帮会名只允许中文字符")
        return
    end
    --检测名字字符长度
    local cusLen = string.Length(name)
    if 2 <= cusLen and cusLen <= 5 then
    else
        TipsMgr.TipByFormat("帮会名长度需在2~5个字符之间")
        return
    end

    local des = mDesInput.value
    if des == "" then
        TipsMgr.TipByFormat("请输入宣言")
        return
    end

    GangMgr.RequestCreate(name, des, 1, 1)
end

local function RegEvent()

end

local function UnRegEvent()

end

function OnCreate(self)
    mSelf = self

    mNameInput = self:FindComponent("LuaUIInput", "Offset/temp/Name/Input")
    mDesInput = self:FindComponent("LuaUIInput", "Offset/temp/Declaration/Input")

    mCostIcon = self:FindComponent("UISprite", "Offset/temp/Cost/Icon")
    mCostNum = self:FindComponent("UILabel", "Offset/temp/Cost/Count")
end

function OnEnable(self)
    RegEvent()

    DoShowCost()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_Create)
    elseif id == -101 then
        --选址
    elseif id == -102 then
        --创建
        OnClickCreate()
    end
end

