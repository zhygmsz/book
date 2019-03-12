module("UI_Chat_EmojiOperList", package.seeall)

--组件
local mSelf
local mBg
local mAnchorTrs
local mWidgetTrs
local mWidgetGo

--变量
local mEvents = {}
local mBgSize = {x= 0, y = 0}
local mWidgetVisible = false
local mPosOffset = {x = 98, y = 0}
local mLocalPos = Vector3(0, 0, 0)

local mShowingEmojiInfo

--local方法
--[[
    @desc: 查看系列
]]
local function OnClickLook()
    --该emojiinfo有合法的系列id，则隶属于某个系列，如果没有则没有
    local pkgId = mShowingEmojiInfo:GetPkgId()
    if pkgId == "" then
        TipsMgr.TipByFormat("该表情不属于表情系列")
    else
        CustomEmojiMgr.OpenPkgInfoUI(pkgId)
    end
end

local function SetWidgetVisible(visible)
    mWidgetVisible = visible
    mWidgetGo:SetActive(visible)

    TouchMgr.SetListenOnNGUIEvent(UI_Chat_EmojiOperList, visible, false)
end

local function OnShowWidget(pos, emojiInfo)
    if not pos then
        return
    end

    mShowingEmojiInfo = emojiInfo

    mAnchorTrs.position = pos
    local localPos = mAnchorTrs.localPosition
    mLocalPos.x = localPos.x + mPosOffset.x
    mLocalPos.y = localPos.y + mPosOffset.y
    mWidgetTrs.localPosition = mLocalPos

    SetWidgetVisible(true)
end

--[[
    @desc: 收藏回调
    --@state:
	--@picId: 
]]
local function OnCollectFinish(state, picId)
    if state then
        --同步收藏列表
        CustomEmojiMgr.AddEmoji2MyCollectListByEmojiInfo(mShowingEmojiInfo)

        TipsMgr.TipByFormat("收藏成功")
    else
        TipsMgr.TipByFormat("收藏失败")
    end
end

--[[
    @desc: 举报回调
    --@state:
	--@picId: 
]]
local function OnReportFinish(state, picId)
    if mShowingEmojiInfo:GetPicId() ~= picId then
        return
    end
    if state then
        TipsMgr.TipByFormat("举报成功")
    else
        TipsMgr.TipByFormat("举报失败")
    end
end

local function RegEvent()
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIOPERLIST, OnShowWidget)
end

local function UnRegEvent()
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIOPERLIST, mEvents[1])
    mEvents = {}
end

function OnCreate(self)
    mSelf = self

    mAnchorTrs = self:Find("Offset/anchor")

    mBg = self:Find("Offset/grid/bg")
    local sp = mBg:GetComponent("UISprite")
    mBgSize.x = sp.width
    mBgSize.y = sp.height

    mWidgetTrs = self:Find("Offset/grid")
    mWidgetGo = mWidgetTrs.gameObject
    SetWidgetVisible(false)
end

function OnEnable(self)
    RegEvent()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == 1 then
        --收藏
        SNSCustomEmojiMgr.RequestCollectEmoji(mShowingEmojiInfo:GetPicId(), OnCollectFinish, nil)
    elseif id == 2 then
        --转发
        TipsMgr.TipByKey("equip_share_not_support")
    elseif id == 3 then
        --查看系列
        OnClickLook()
    elseif id == 4 then
        --举报
        SNSCustomEmojiMgr.RequestReportEmoji(mShowingEmojiInfo:GetPicId(), OnReportFinish, nil)
    end
    SetWidgetVisible(false)
end

function OnPressScreen(go, state)
    if not state then
        return
    end
    local localPos = mBg:InverseTransformPoint(UICamera.lastWorldPosition)
    if 0 <= localPos.x and localPos.x <= mBgSize.x and 0 <= localPos.y and localPos.y <= mBgSize.y then
        --
    else
        SetWidgetVisible(false)
    end
end
