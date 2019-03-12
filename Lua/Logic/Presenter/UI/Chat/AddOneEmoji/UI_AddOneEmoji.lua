module("UI_AddOneEmoji", package.seeall)

--组件
local mSelf
local mAddTrs
local mAddGo
local mIconGo
local mIconTrs
local mIcon
local mEmojiName

local mPlayerName
local mPlayerId

local mNameWidgetGo
local mInput

--变量
local mEvents = {}
local mBtnListPos
local mLastInputValue = ""
local mEmojiNameStr = "表情单品名称"

local mRelativePath = ""
local mFullPath = ""

local mSquareLen = 100

local mRemoteDir = ""

--local方法
local function SetIconVisible(visible)
    mAddGo:SetActive(not visible)
    mIconGo:SetActive(visible)
end

local function Reset()
    mInput.value = ""
    mLastInputValue = ""
    mEmojiName.text = mEmojiNameStr
    mRelativePath = ""
    mFullPath = ""
end

--[[
    @desc: 添加过程中，失败处理
]]
local function OnAddFail()
    SetIconVisible(false)
    Reset()
end

local function SetEmojiName()
    mEmojiName.text = mInput.value
end

--[[
    @desc: 
    --@visible:
	--@state: 关闭原因，visible为false时才有用， 1确定，2取消，3关闭
]]
local function SetNameWidgetVisible(visible, state)
    mNameWidgetGo:SetActive(visible)

    if visible then
        --打开命名界面
        mInput.value = mLastInputValue
    else
        --关闭命名界面，赋值
        if state == 1 then
            if mInput.value ~= "" then
                mLastInputValue = mInput.value
                SetEmojiName(mLastInputValue)
            else
                TipsMgr.TipByFormat("名称不能为空")
            end
        elseif state == 2 or state == 3 then
            mInput.value = ""
        end
    end
end

local function InitPlayeriInfo()
    mPlayerName.text = UserData.GetName()
    mPlayerId.text = UserData.GetID()
end

local function Init()
    SetIconVisible(false)
    InitPlayeriInfo()
end

local function OnAddEmojiFinish(state, picId, url, name)
    if state then
        --同步数据
        CustomEmojiMgr.AddEmoji2MyAddListByPicId(picId, url, name)

        --表情库界面接收数据同步事件，并刷UI
        --提示成功，并关闭UI
        TipsMgr.TipByFormat("上传成功")
        UIMgr.UnShowUI(AllUI.UI_AddOneEmoji)
    else
        --添加表情失败
        --失败后的处理，再定细节
        --审核不过显示，已经有该表情的提示，等
        OnAddFail()
    end
end

local function OnUpload(state, localPath, url)
    if state then
        --继续请求https
        local md5Str = GameUtil.GameFunc.GetMD5(mFullPath)
        if md5Str ~= "" then
            SNSCustomEmojiMgr.RequestAddEmoji(md5Str, url, mEmojiName.text, OnAddEmojiFinish, nil)
        else
            --md5获取失败
            OnAddFail()
        end
    else
        OnAddFail()
    end
end

local function DoUpload()
    --检查名称是否为空
    if mLastInputValue ~= "" then
        EmojiUploadMgr.Upload(mRelativePath, mRemoteDir, OnUpload, nil)
    else
        --提示，请先编辑表情名称
        TipsMgr.TipByFormat("请先编辑表情名称")
    end
end

local function OnLoadTex()
    UIUtil.AdjustInSquare(mIcon, mSquareLen)
end

local function TryAddEmoji(relativePath)
    SetIconVisible(true)
    UIUtil.LoadImage(mIcon, CustomEmojiMgr.GetEmojiSize(), relativePath, false, OnLoadTex, nil)
end

local function OnReadyToUpload(relativePath, fullPath)
    mRelativePath = relativePath
    mFullPath = fullPath

    --加载缩略图
    TryAddEmoji(relativePath)
end

local function RegEvent(self)
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, OnReadyToUpload)
end

local function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, mEvents[1])
    mEvents = {}
end


function OnCreate(self)
    mSelf = self

    mRemoteDir = ChatMgr.GetCustomEmojiRemoteDir()

    mAddTrs = self:Find("Offset/middle/add")
    mAddGo = mAddTrs.gameObject

    mIcon = self:FindComponent("UITexture", "Offset/middle/icon")
    mIconTrs = mIcon.transform
    mIconGo = mIcon.gameObject

    local localPos = mIconTrs.localPosition
    mBtnListPos = mIconTrs.parent:TransformPoint(localPos.x + 70, localPos.y, 0)

    mEmojiName = self:FindComponent("UILabel", "Offset/middle/name/name")

    mPlayerName = self:FindComponent("UILabel", "Offset/middle/playername/name")
    mPlayerId = self:FindComponent("UILabel", "Offset/middle/playername/id")

    mInput = self:FindComponent("LuaUIInput", "Offset/namewidget/input")

    mNameWidgetGo = self:Find("Offset/namewidget").gameObject
    SetNameWidgetVisible(false, 2)

end

function OnEnable(self)
    RegEvent(self)

    Init()
end

function OnDisable(self)
    UnRegEvent(self)

    Reset()

    --再次打开表情库
    CustomEmojiMgr.DoInvokeFunc(AllUI.UI_AddOneEmoji)
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -200 then
        --关闭修改名称界面
        SetNameWidgetVisible(false, 3)
    elseif id == -201 then
        --修改名称 -  确定
        SetNameWidgetVisible(false, 1)
    elseif id == -202 then
        --修改名称 - 取消
        SetNameWidgetVisible(false, 2)
    elseif id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_AddOneEmoji)
    elseif id == -10 then
        --添加按钮
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWBTNLIST, mBtnListPos, CustomEmojiMgr.ChatAddBtnType.AddEmoji)
    elseif id == -11 then
        --修改名称
        SetNameWidgetVisible(true)
    elseif id == -12 then
        --个人空间按钮
    elseif id == -13 then
        --上传按钮
        --发起上传请求
        DoUpload()
    end
end
