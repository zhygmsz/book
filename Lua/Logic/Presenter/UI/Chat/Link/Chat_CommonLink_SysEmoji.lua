local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")


local SysEmojiItem = class("SysEmojiItem", UIPageAndGrid_Item)
function SysEmojiItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._sp = trs:Find("icon"):GetComponent("UISprite")

    --变量

    self:Init()
end

--[[
    @desc: 
    --@data: Chat_pb.ChatSysEmojiData结构
	--@dataIdx: 
]]
function SysEmojiItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._sp.spriteName = self._data.icon
    self._sp:MakePixelPerfect()
end

-------------------------------------------------------------------------------

local SysEmojiWidget = class("SysEmojiWidget", UIPageAndGrid_Widget)
function SysEmojiWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    --组件
    
    --变量
    self._dataList = ChatMgr.GetSysEmojiDataList()
    self._numPerPage = ChatMgr.GetSysEmojiNumPerPage()

    self:CreatePageAndGrid(SysEmojiItem, self._numPerPage)

    --
    self:Hide()
end

function SysEmojiWidget:OnSpec(dataIdx)
    --基类的方法只做UI表现
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    --在具体的类里做点击后的业务逻辑处理
    --发送表情
    local funcOnNew = ChatMgr.GetFuncOnNewMsgLink()
    local funcCreate = ChatMgr.GetFuncCreateMsgLink()
    if funcOnNew and funcCreate then
        local emojiData = self._dataList[dataIdx]
        if not emojiData then
            return
        end

        local msgLink = funcCreate()
        MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI, msgLink, emojiData.icon, emojiData.id)

        funcOnNew(msgLink)
    end
end

function SysEmojiWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

function SysEmojiWidget:Show()
    UIPageAndGrid_Widget.Show(self)

    self._pageAndGrid:Show(self._dataList)
end

return SysEmojiWidget
