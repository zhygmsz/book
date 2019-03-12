module("UI_Gang_Info", package.seeall)



--组件
local mSelf
local mInfoGo
local mLevelUpGo

--帮会名称
local mGangNameLabel
--帮主
local mGangChiefLabel
--等级
local mGangLevelLabel
--帮会id
local mGangIDLabel
--帮会成员数量
local mGangMemNumLabel
--学徒数量
local mGangTraineeNumLabel
--帮会宣言
local mGangNoticeLabel

--金库等级
local mGoldLevelLabel
--药房等级
local mYaoFangLevelLabel
--厢房等级
local mXiangFangLevelLabel
--研究院等级
local mYjyLevelLabel
--百宝箱等级
local mBoxLevelLabel
--帮会资金
local mFundLabel
--维护费用



--变量
local mLeftToggleGroup
local mLeftBtnData = 
{
    { eventId = 1, content = "帮会信息" },
    { eventId = 2, content = "帮会升级" },
}
local mLeftBtnNum = #mLeftBtnData

--引用Mgr里的结构，任何变动同步过来，并刷UI
local mGangInfo = nil


--local方法
local function OnNor(eventId)
end

local function OnSpec(eventId)
    mInfoGo:SetActive(eventId == 1)
    mLevelUpGo:SetActive(eventId == 2)
end

local function CheckIsLeftBtn(eventId)
    return 1 <= eventId and eventId <= mLeftBtnNum
end

local function DoShowInfo()
    mGangNameLabel.text = mGangInfo.guildName
    mGangChiefLabel.text = mGangInfo.masterName
    mGangLevelLabel.text = mGangInfo.guildLevel
    mGangIDLabel.text = tostring(mGangInfo.guildId)
    --待服务器添加字段
    mGangMemNumLabel.text = "11/111/1111"
    mGangTraineeNumLabel.text = "22/222/2222"
    mGangNoticeLabel.text = mGangInfo.manifesto
end

local function DoShowLevelUp()

end

--[[
    @desc: 获取到帮会信息后回调
]]
local function OnGetGangInfo()
    mGangInfo = GangMgr.GetGangInfo()
    DoShowInfo()
    DoShowLevelUp()
end

local function RegEvent()
    GameEvent.Reg(EVT.GANG, EVT.GETGANGINFO, OnGetGangInfo)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.GANG, EVT.GETGANGINFO, OnGetGangInfo)
end


function OnCreate(self)
    mSelf = self

    mLeftToggleGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mLeftBtnNum do
        trs = self:Find("Offset/Left/ChioceTab/btn" .. tostring(idx))
        mLeftToggleGroup:AddItem(trs, mLeftBtnData[idx])
    end

    mInfoGo = self:Find("Offset/Left/Info").gameObject
    mLevelUpGo = self:Find("Offset/Left/UpLevel").gameObject

    mGangNameLabel = self:FindComponent("UILabel", "Offset/Left/Info/Name/lable")
    mGangChiefLabel = self:FindComponent("UILabel", "Offset/Left/Info/Owner/lable")
    mGangLevelLabel = self:FindComponent("UILabel", "Offset/Left/Info/Level_l/lable")
    mGangIDLabel = self:FindComponent("UILabel", "Offset/Left/Info/Level_r/lable")
    mGangMemNumLabel = self:FindComponent("UILabel", "Offset/Left/Info/Number/lable")
    mGangTraineeNumLabel = self:FindComponent("UILabel", "Offset/Left/Info/Trainee/lable")
    mGangNoticeLabel = self:FindComponent("UILabel", "Offset/Left/Info/Declaration/Des")
end

function OnEnable(self)
    RegEvent()

    --默认选中帮会信息
    mLeftToggleGroup:OnClick(mLeftBtnData[1].eventId)

    --请求服务器数据
    GangMgr.RequestGangInfo()
end

function OnDisable(self)
    UnRegEvent()
    mLeftToggleGroup:OnDisable()
end

function OnDestroy(self)
    mLeftToggleGroup:OnDestroy()
end

function OnClick(go, id)
    if CheckIsLeftBtn(id) then
        mLeftToggleGroup:OnClick(id)
    elseif id == -100 then
        --修改帮会名称
    elseif id == -101 then
        --学徒数量tip
    elseif id == -102 then
        --修改帮会宣言
    elseif id == -103 then
        --管理
    elseif id == -104 then
        --合帮
    end
end