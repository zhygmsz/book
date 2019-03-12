local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")

local EasyWordItem = class("EasyWordItem", UIPageAndGrid_Item)
function EasyWordItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._label = NGUITools.FindComponent(trs, "UILabel", "count")

    self._deleteGo = NGUITools.FindGo(trs, "BtnDelate")
    self._deleteGo:SetActive(false)
    self._addGo = NGUITools.FindGo(trs, "BtnAdd")
    self._addGo:SetActive(false)

    --eventid1是被默认的item占用了
    self._deleteUIEvent = NGUITools.FindComponent(trs, "GameCore.UIEvent", "BtnDelate")
    self._deleteUIEvent.id = eventIdBase + 2
    self._addUIEvent = NGUITools.FindComponent(trs, "GameCore.UIEvent", "BtnAdd")
    self._addUIEvent.id = eventIdBase + 3

    --变量
end

function EasyWordItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._label.text = data.content

    if data.isAdd then
        self._addGo:SetActive(true)
        self._deleteGo:SetActive(false)
    else
        self._deleteGo:SetActive(true)
        self._addGo:SetActive(false)
    end    
end


local EasyWordWidget = class("EasyWordWidget", UIPageAndGrid_Widget)
function EasyWordWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    --界面内还需要其他事件，从基类里拿出一部分
    self._customEventIdBase = eventIdBase
    eventIdBase = eventIdBase + 100
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    --组件

    --变量
    self._dataList = ChatMgr.GetEasyWordList()
    self._numPerPage = ChatMgr.GetEasyWordNumPerPage()

    self:CreatePageAndGrid(EasyWordItem, self._numPerPage)

    self._funcOnClickSpanIdx = function(itemIdx, spanIdx)
        self:OnClickSpanIdx(itemIdx, spanIdx)
    end

    --便捷用语输入框
    self._inputGo = NGUITools.FindGo(trs, "input")
    self._inputGo:SetActive(false)
    self._okUIEvent = NGUITools.FindComponent(trs, "GameCore.UIEvent", "input/ok")
    self._okUIEvent.id = self._customEventIdBase + 1
    self._cancelUIEvent = NGUITools.FindComponent(trs, "GameCore.UIEvent", "input/cancel")
    self._cancelUIEvent.id = self._customEventIdBase + 2
    self._input = NGUITools.FindComponent(trs, "LuaUIInput", "input/Input")
end

function EasyWordWidget:OnClickSpanIdx(dataIdx, spanIdx)
    GameLog.LogError("--------------------------------dataIdx = %d, spanIdx = %d", dataIdx, spanIdx)
    local data = self._dataList[dataIdx]
    if not data then
        return
    end
    if spanIdx == 2 then
        --删除
        ChatMgr.RemoveEasyWord(dataIdx)
    elseif spanIdx == 3 then
        --添加
        self:SetInputGoVisible(true)
    end
end

function EasyWordWidget:OnSpec(dataIdx)
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    --询问，便捷用语是直接发出去，还是到输入框
end

function EasyWordWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

function EasyWordWidget:Show()
    self._pageAndGrid:Show(self._dataList)
end

--[[
    @desc: 输入框显示
    --@visible: 
]]
function EasyWordWidget:SetInputGoVisible(visible)
    self._inputGo:SetActive(visible)

    --关闭时清空输入框内容
    if not visible then
        self._input.value = ""
    end

    --屏蔽ChatCommonLink界面的检测屏幕
    ChatMgr.SetChatCommonLinkNeedCheckPress(not visible)
end

function EasyWordWidget:OnClick(id)
    --预留100个id给自定义事件使用
    if id - self._customEventIdBase <= 100 then
        local id = id - self._customEventIdBase
        if id == 1 then
            --输入框确定按钮
            GameLog.LogError("-------------------------ok")
            --输入过滤
            --先添加数据，再关闭界面
            ChatMgr.AddEasyWord(self._input.value)
            self:SetInputGoVisible(false)
        elseif id == 2 then
            self:SetInputGoVisible(false)
            --输入框取消按钮
            GameLog.LogError("-------------------------cancel")
        end
    else
        UIPageAndGrid_Widget.OnClick(self, id)
    end
end

--[[
    @desc: 添加一条便捷用语回调，刷新UI
    --@data: 
]]
function EasyWordWidget:OnAddEasyWord()
    self:Show()
end

--[[
    @desc: 删除一条便捷用语回调，刷新UI
    --@data: 
]]
function EasyWordWidget:OnRemoveEasyWord()
    self:Show()
end

function EasyWordWidget:RegEvent()
    GameEvent.Reg(EVT.CHAT, EVT.CHAT_ADDEASYWORD, self.OnAddEasyWord, self)
    GameEvent.Reg(EVT.CHAT, EVT.CHAT_REMOVEEASYWORD, self.OnRemoveEasyWord, self)
end

function EasyWordWidget:UnRegEvent()
    GameEvent.UnReg(EVT.CHAT, EVT.CHAT_ADDEASYWORD, self.OnAddEasyWord, self)
    GameEvent.UnReg(EVT.CHAT, EVT.CHAT_REMOVEEASYWORD, self.OnRemoveEasyWord, self)
end

function EasyWordWidget:OnEnable()
    UIPageAndGrid_Widget.OnEnable(self)

    self:RegEvent()
end

function EasyWordWidget:OnDisable()
    UIPageAndGrid_Widget.OnDisable(self)

    self:UnRegEvent()
end

return EasyWordWidget