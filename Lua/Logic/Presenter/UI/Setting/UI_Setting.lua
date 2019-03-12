module("UI_Setting",package.seeall)

local mPanelStaticData = {}
local mPanelDynamicData = {}
local mContentGrid
local mToggleGroup
local mOpenIndex

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
    RegisterPanel(1,AllUI.UI_Setting_Basis,WordData.GetWordStringByKey("Setting_panel_basis"))--基础
end

local function InitPanelDynamic()
    local str = WordData.GetWordStringByKey("Setting_panel,1")
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
    local titleLable = ui:FindComponent("UILabel","Offset/Title")
    mToggleGroup = ToggleGroupUIMgr.new(titleLable)
    InitPanelStatic()
    InitPanelDynamic()
    mContentGrid = UIScrollGridTable.new(ui,"Offset/Content/Scroll View")
    mContentGrid:ResetWrapContent(#mPanelDynamicData,OnContentCreate)
end

function OnEnable(self)
    mOpenIndex = mOpenIndex or 1
    mToggleGroup:OnClick(mPanelDynamicData[mOpenIndex])
    UIMgr.MaskUI(true, 0, 199);
end

function OnDisable(self)
    mOpenIndex = nil
    mToggleGroup:Reset()
    UIMgr.MaskUI(false, 0, 199);
end

function OnClick(go, id)
     if id == 0 then--关闭
         UIMgr.UnShowUI(AllUI.UI_Setting)
         mToggleGroup:Reset()
	end
end

return UI_Setting





