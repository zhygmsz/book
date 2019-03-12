module("UI_Setting_Basis",package.seeall)

local mPanelStaticData = {}
local mPanelDynamicData = {}
local mContentGrid
local mToggleGroup
local mOpenIndex
local mUserInfo

mEventType={
    ChangeAccount = 10,
    LockScreen = 11,
    ServiceBulletins = 12,
    Share = 13,
    SweepTheYard = 14,
}

local function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

local function RegisterPanel(id,UIPanel,title)
    mPanelStaticData[id] = {eventId = id, ui = UIPanel,content=title}
end

local function InitPanelStatic()
    RegisterPanel(1,AllUI.UI_Setting_Basis_Voice,WordData.GetWordStringByKey("Setting_panel_basis_voice"))--声音
    RegisterPanel(2,AllUI.UI_Setting_Basis_Picture,WordData.GetWordStringByKey("Setting_panel_basis_picture"))--画面
    RegisterPanel(3,AllUI.UI_Setting_Basis_Fight,WordData.GetWordStringByKey("Setting_panel_basis_fight"))--战斗
    RegisterPanel(4,AllUI.UI_Setting_Basis_Other,WordData.GetWordStringByKey("Setting_panel_basis_other"))--其他
end

local function InitPanelDynamic()
    local str = WordData.GetWordStringByKey("Setting_panel_basis,1,2,3,4")
    local list = split(str,',')
    for i=1,#list do
        local flag,re = pcall(tonumber,list[i])
        if flag then
            table.insert(mPanelDynamicData,re)
        end
    end
end

local function OnContentCreate(trans,index)
    local panelID = mPanelDynamicData[index]
    mPanelStaticData[panelID].trs = trans
    mToggleGroup:AddItem(mPanelStaticData[panelID])
end

function OnCreate(ui)
    mToggleGroup = ToggleGroupUIMgr.new()
    InitPanelStatic()
    InitPanelDynamic()
    mContentGrid = UIScrollGridTable.new(ui,"Content/Scroll View")
    mContentGrid:ResetWrapContent(#mPanelDynamicData,OnContentCreate)
    mUserInfo = {}
    mUserInfo.headIcon = ui:FindComponent("UITexture","UserInfo/HeadIcon/Icon")
    mUserInfo.playerIconLoader = LoaderMgr.CreateTextureLoader(mUserInfo.headIcon)
	mUserInfo.playerIconLoader:LoadObject(UserData.PlayerAtt.playerData.headIcon)
    mUserInfo.lvLabel = ui:FindComponent("UILabel","UserInfo/HeadIcon/LevelBg/Label")
    mUserInfo.nameLabel = ui:FindComponent("UILabel","UserInfo/Account/Label")
    mUserInfo.serverLabel = ui:FindComponent("UILabel","UserInfo/Server/Label")
    ui:FindComponent("UIEvent","UserInfo/Grid/ChangeAccount").id = mEventType.ChangeAccount
    ui:FindComponent("UIEvent","UserInfo/Grid/LockScreen").id = mEventType.LockScreen
    ui:FindComponent("UIEvent","UserInfo/Grid/ServiceBulletins").id = mEventType.ServiceBulletins
    ui:FindComponent("UIEvent","UserInfo/Grid2/Share").id = mEventType.Share
    ui:FindComponent("UIEvent","UserInfo/Grid2/SweepTheYard").id = mEventType.SweepTheYard
end

function OnEnable(ui)
    mOpenIndex = mOpenIndex or 1
    mToggleGroup:OnClick(mPanelDynamicData[mOpenIndex])
    mUserInfo.lvLabel.text = UserData.GetLevel()
    mUserInfo.nameLabel.text = UserData.GetName()
    mUserInfo.serverLabel.text = LoginMgr.GetCurrentServerName()
end

function OnDisable( ui )
    mToggleGroup:Reset()
end

function OnClick( go,id )
    if id < 5 then
        mOpenIndex = id
        mToggleGroup:OnClick(id)
    elseif id == mEventType.ChangeAccount then
        GameStateMgr.EnterLogin()
    elseif id == mEventType.LockScreen then
        UIMgr.UnShowUI(AllUI.UI_Setting)
        UIMgr.ShowUI(AllUI.UI_LockScreen)
    elseif id == mEventType.ServiceBulletins then
        TipsMgr.TipByKey("Function_Not_Finished")
    elseif id == mEventType.Share then
		ShareMgr.CaptureGame()
    elseif id == mEventType.SweepTheYard then
        TipsMgr.TipByKey("Function_Not_Finished")
    end
end

return UI_Setting_Basis
