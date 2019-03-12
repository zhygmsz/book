module("UI_Tips_Describe", package.seeall)

--变量
local mOriginLayer
local mOriginDepth
local mTitle = ""
local mContent = ""
local mTitleLabel = nil
local mContentLabel = nil


--local方法
local function ResetLayer()
    UIMgr.ChangeLayer(AllUI.UI_Tips_Describe, mOriginLayer, mOriginDepth)
end

local function NewLayer(newLayer, newDepth)
    UIMgr.ChangeLayer(AllUI.UI_Tips_Describe, newLayer, newDepth)
end

function OnCreate(self)
    mSelf = self
    mRoot = self:Find("confirmroot")
    mTitleLabel = self:FindComponent("UILabel","confirmroot/offset/title")
    mContentLabel = self:FindComponent("UILabel","confirmroot/offset/scrollviewroot/scrollview/content")
    mOriginLayer = AllUI.UI_Tips_Describe.layer
    mOriginDepth = AllUI.UI_Tips_Describe.depth
end

function OnEnable(self)
    RegEvent(self)
    mTitleLabel.text = mTitle
    mContentLabel.text = mContent
end

function OnDisable(self)
    UnRegEvent(self)
    ResetLayer()
end
function SetData(title,content)
    mTitle = title
    mContent =content
end

function ShowDescribe(data)
    if data then
        UI_Tips_Describe.SetData(data.title,data.content)
        if data.newLayer and data.newDepth then
            NewLayer(data.newLayer, data.newDepth)
        end
        UIMgr.ShowUI(AllUI.UI_Tips_Describe)
    end
end

function RegEvent(self)
end

function UnRegEvent(self)
end

function OnClick(go, id)
    if id ==-1000 then
        UIMgr.UnShowUI(AllUI.UI_Tips_Describe)
    end
end