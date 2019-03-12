local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_ItemEx = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_ItemEx")
local UIPageAndGrid_WidgetEx = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_WidgetEx")

local EmojiItem = class("EmojiItem", UIPageAndGrid_ItemEx)
function EmojiItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_ItemEx.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    self._addGo = trs:Find("add").gameObject

    self._tween = trs:GetComponent("ButtonTween")

    --变量
    self._squareLen = 88

    self:Init()
end

function EmojiItem:SetInteractMode(clickOrCheck)
    if not self._data:CheckIsAdd() then
        UIPageAndGrid_ItemEx.SetInteractMode(self, clickOrCheck)
    end
end

function EmojiItem:Show(data, dataIdx)
    UIPageAndGrid_ItemEx.Show(self, data, dataIdx)

    self._tween.enabled = data:CheckIsAdd()

    if data:CheckIsAdd() then
        self._iconGo:SetActive(false)
        self._addGo:SetActive(true)
    else
        self._iconGo:SetActive(true)
        self._addGo:SetActive(false)

        --显示tex
        self:DoShowIcon()
    end
end

function EmojiItem:OnLoadTex()
    --UIUtil.AdjustInSquare(self._icon, self._squareLen)
end

function EmojiItem:DoShowIcon()
    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), self._data:GetUrl(), true, self.OnLoadTex, self)
end

--[[
    @desc: 收藏表情时，add标识格子内显示成表情缩略图
    上传成功后，dataList内，在add数据前插入新表情数据
    相应的，add标识显示上往后推一格
    --@localPath: 
]]
function EmojiItem:OnTryCollectEmoji(localPath)
    --隐藏add标识，并从本地加载缩略图
    self._addGo:SetActive(false)
    self._iconGo:SetActive(true)
    self._tween.enabled = false
    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), localPath, false)
end

--[[
    @desc: 尝试收藏表情失败，回退add标识格子
    重置为加号标识
]]
function EmojiItem:OnTryCollectEmojiFail()
    self._addGo:SetActive(true)
    self._iconGo:SetActive(false)
    self._tween.enabled = true
end

function EmojiItem:GetPos()
    local pos = self._transform.localPosition
    return self._transform.parent:TransformPoint(pos.x + 60, pos.y, 0)
end

-------------------------------------------------------------------------------

local EmojiWidget = class("EmojiWidget", UIPageAndGrid_WidgetEx)
function EmojiWidget:ctor(trs, ui, funcOnOpenOther, eventIdBase, eventIdSpan)
    UIPageAndGrid_WidgetEx.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    self._dataList = CustomEmojiMgr.GetMyCollectEmojiListForCollect()
    self._numPerPage = CustomEmojiMgr.GetCollectEmojiNumPerPage()

    self:CreatePageAndGrid(EmojiItem, self._numPerPage)

    --
    self._funcOnOpenOther = funcOnOpenOther

    self._events = {}
    self._relativePath = ""
    self._fullPath = ""
    self._remoteDir = ChatMgr.GetCustomEmojiRemoteDir()

    self:Hide()
end

function EmojiWidget:OnSpec(dataIdx)
    UIPageAndGrid_WidgetEx.OnSpec(self, dataIdx)

    local data = self._dataList[dataIdx]
    if data:CheckIsAdd() then
        --显示btnlist
        local item = self._pageAndGrid:GetItem(dataIdx)
        if item then
            local pos = item:GetPos()
            MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWBTNLIST, pos, CustomEmojiMgr.ChatAddBtnType.AddEmoji)
        end
    else
        --显示自定义表情大图
        if self._funcOnOpenOther then
            self._funcOnOpenOther()
        end
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIPIC, data)
    end
end

function EmojiWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

--[[
    @desc: 获取到我收藏的表情
    --重刷UI
]]
function EmojiWidget:OnGetMyCollectEmoji()
    self:DoShowEmoji()
end

--[[
    @desc: 收藏一个表情后，事件处理
]]
function EmojiWidget:OnCollectOneEmoji()
    self._pageAndGrid:OnDataListChange()

    local len = #self._dataList
    self._pageAndGrid:InvokeFuncByDataIdx(len - 1, "Show", self._dataList[len - 1], len - 1)
    self._pageAndGrid:InvokeFuncByDataIdx(len, "Show", self._dataList[len], len)
end

--[[
    @desc: 收藏请求返回
]]
function EmojiWidget:OnCollectEmojiFinish(state, picId)
    if state then
        CustomEmojiMgr.AddEmoji2MyCollectListByPicId(picId)
    else
        self._pageAndGrid:InvokeFuncByDataIdx(#self._dataList, "OnTryCollectEmojiFail")
    end
end

--[[
    @desc: 添加表情的回调，里面继续发送收藏请求
]]
function EmojiWidget:OnAddEmojiFinish(state, picId, url, name)
    if state then
        --同步添加的表情集合
        CustomEmojiMgr.AddEmoji2MyAddListByPicId(picId, url, name)

        --请求收藏接口
        SNSCustomEmojiMgr.RequestCollectEmoji(picId, self.OnCollectEmojiFinish, self)
    else
        --添加表情失败
        self._pageAndGrid:InvokeFuncByDataIdx(#self._dataList, "OnTryCollectEmojiFail")
    end
end

--[[
    @desc: 
]]
function EmojiWidget:OnUpload(state, localPath, url)
    if state then
        local md5Str = GameUtil.GameFunc.GetMD5(self._fullPath)
        if md5Str ~= "" then
            --直接添加，没有名字
            SNSCustomEmojiMgr.RequestAddEmoji(md5Str, url, "", self.OnAddEmojiFinish, self)
        else
            --md5获取失败
            self._pageAndGrid:InvokeFuncByDataIdx(#self._dataList, "OnTryCollectEmojiFail")
        end
    else
        --失败，把OnAddEmoji操作回退
        self._pageAndGrid:InvokeFuncByDataIdx(#self._dataList, "OnTryCollectEmojiFail")
    end
end

--[[
    @desc: 收藏过程；先上传添加，再收藏
    --@relativePath:
	--@fullPath: 计算md5
]]
function EmojiWidget:OnReadyToUpload(relativePath, fullPath)
    self._relativePath = relativePath
    self._fullPath = fullPath

    --加载缩略图
    self._pageAndGrid:InvokeFuncByDataIdx(#self._dataList, "OnTryCollectEmoji", relativePath)

    --发起上传请求
    EmojiUploadMgr.Upload(relativePath, self._remoteDir, self.OnUpload, self)
end

function EmojiWidget:RegEvent()
    self._events[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, self.OnReadyToUpload, self)
    self._events[2] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYCOLLECTEMOJI, self.OnGetMyCollectEmoji, self)
    self._events[3] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_COLLECTONEEMOJI, self.OnCollectOneEmoji, self)
end

function EmojiWidget:UnRegEvent()
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, self._events[1])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYCOLLECTEMOJI, self._events[2])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_COLLECTONEEMOJI, self._events[3])
    self._events = {}
end

--[[
    @desc: 
]]
function EmojiWidget:DoShowEmoji()
    self._dataList = CustomEmojiMgr.GetMyCollectEmojiListForCollect()
    self._pageAndGrid:Show(self._dataList)
end

function EmojiWidget:OnEnable()
    self:RegEvent()
end

function EmojiWidget:OnDisable()
    self:UnRegEvent()
end

--[[
    @desc: 统一的显示表情接口
]]
function EmojiWidget:Show()
    UIPageAndGrid_WidgetEx.Show(self)

    self:DoShowEmoji()
end

return EmojiWidget
