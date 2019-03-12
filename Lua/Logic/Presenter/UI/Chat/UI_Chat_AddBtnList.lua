module("UI_Chat_AddBtnList", package.seeall)

--组件
local mSelf
local mBg
local mBgGo
local mBgSp
local mAnchorTrs
local mBtnListTrs
local mBtnListGo
local mGrid

--变量
local mEvents = {}
local mTakeSize
local mBgSize = { x = 0, y = 0 }
local mBtnListVisible = false
local mPosOffset = {x = 98, y = 0}
local mLocalPos = Vector3(0, 0, 0)

local mBtnGoList = {}


--local方法
--[[
    @desc: 直接通过相机或相册获取一张最大尺寸不超过256的图，然后上传
    目前看，编辑器模式下，拍照和相册功能里的宽高参数并没有其作用
    但真机上是有裁剪
    --@relativePath: 
]]
local function OnTakePhoto(relativePath, fullPath)
    MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, relativePath, fullPath)
end

local function SetBtnListVisible(visible)
    mBtnListVisible = visible
    mBtnListGo:SetActive(visible)
    mBgGo:SetActive(visible)

    TouchMgr.SetListenOnNGUIEvent(UI_Chat_AddBtnList, visible, false)
end

local function OnShowBtnList(pos, showType)
    if not pos then
        return
    end

    local btnDataList = CustomEmojiMgr.GetChatAddBtnData(showType)
    if not btnDataList then
        return
    end

    mAnchorTrs.position = pos
    local localPos = mAnchorTrs.localPosition
    mLocalPos.x = localPos.x + mPosOffset.x
    mLocalPos.y = localPos.y + mPosOffset.y
    mBtnListTrs.localPosition = mLocalPos

    for _, go in ipairs(mBtnGoList) do
        go:SetActive(false)
    end
    for _, idx in ipairs(btnDataList) do
        if mBtnGoList[idx] then
            mBtnGoList[idx]:SetActive(true)
        end
    end
    mGrid:Reposition()

    local lenY = #btnDataList * mGrid.cellHeight + 6
    mBgSp.height = lenY
    mLocalPos.x = localPos.x + 6
    mLocalPos.y = localPos.y - lenY / 2
    mBg.localPosition = mLocalPos

    mBgSize.y = mBgSp.height

    SetBtnListVisible(true)
end

local function RegEvent(self)
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWBTNLIST, OnShowBtnList)
end

local function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWBTNLIST, mEvents[1])
    mEvents = {}
end

function OnCreate(self)
    mTakeSize = CustomEmojiMgr.GetTakeSize()

    mSelf = self

    mAnchorTrs = self:Find("Offset/anchor")

    mBg = self:Find("Offset/bg")
    mBgGo = mBg.gameObject
    mBgSp = mBg:GetComponent("UISprite")
    
    mBgSize.x = mBgSp.width

    mBtnListTrs = self:Find("Offset/grid")
    mGrid = mBtnListTrs:GetComponent("UIGrid")
    mBtnListGo = mBtnListTrs.gameObject
    local btnDataList = CustomEmojiMgr.GetChatAddBtnList()
    local trs = nil
    local label = nil
    for idx, data in ipairs(btnDataList) do
        trs = mBtnListTrs:Find("btn" .. tostring(idx))
        label = trs:Find("label"):GetComponent("UILabel")
        label.text = data.name
        mBtnGoList[idx] = trs.gameObject
    end
    
    SetBtnListVisible(false)
end

function OnEnable(self)
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
end

function OnDestroy(self)
end

function OnClick(go, id)
    if id == 1 then
        --拍照
        PhotoMgr.OpenCamera(mTakeSize.compressRatio, mTakeSize.width, mTakeSize.height, OnTakePhoto, nil)
    elseif id == 2 then
        --相册
        PhotoMgr.OpenPhotoLibrary(mTakeSize.compressRatio, mTakeSize.width, mTakeSize.height, OnTakePhoto, nil)
    elseif id == 3 then
        --表情库
        CustomEmojiMgr.OpenEmojiLibraryUI()
    elseif id == 4 then
        --表情包
        UIMgr.ShowUI(AllUI.UI_Chat_MyCollectHelp)
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_MYCOLLECTHELP, true)
    end
    SetBtnListVisible(false)
end

--[[
    @desc: 点击屏幕回调
]]
function OnPressScreen(go, state)
    if not state then
        return
    end
    local localPos = mBg:InverseTransformPoint(UICamera.lastWorldPosition)
    if 0 <= localPos.x and localPos.x <= mBgSize.x and 0 <= localPos.y and localPos.y <= mBgSize.y then
        --
    else
        SetBtnListVisible(false)
    end
end