--公用输入框，继承自MsgCommonWrap，添加输入限制逻辑

local MsgCommonWrap = require("Logic/Presenter/UI/Chat/MsgCommonWrap")

ChatInputWrap = class("ChatInputWrap", MsgCommonWrap)
--[[
    @desc: 
    --@input:C#类LuaUIInput
    --@openType: 详见ChatMgr_Main文件的CommonLinkOpenType枚举类型
]]
function ChatInputWrap:ctor(input, openType)
    --input
    self._input = input
    self._input.useDefaultAlign = false
    self._input.selectAllTextOnFocus = false

    self._funcOnTryAppendMsgLink = function(msgLink)
        self:TryAppendMsgLink(msgLink)
    end
    self._funcCreateMsgLink = function()
        return self:CreateMsgLink()
    end

    self._funcAppendMsgCommon = function(msgCommon)
        self:TryAppendMsgCommon(msgCommon)
    end

    self._funcOnTextChange = EventDelegate.Callback(self.OnTextChange, self)
    EventDelegate.Set(self._input.onChange, self._funcOnTextChange)

    self._funcOnSelect = EventDelegate.Callback(self.OnSelect, self)
    EventDelegate.Set(self._input.onSelect, self._funcOnSelect)

    self._funcOnDeSelect = EventDelegate.Callback(self.OnDeSelect, self)
    EventDelegate.Set(self._input.onDeSelect, self._funcOnDeSelect)



    --对外
    self._openType = openType
end

--[[
    @desc: 自定义msgCommon
    --@msgCommon:
	--@applyToInput: 是否把msgCommon.content应用到输入框里
]]
function ChatInputWrap:ResetMsgCommon(msgCommon, applyToInput)
    MsgCommonWrap.ResetMsgCommon(self, msgCommon)

    if applyToInput then
        self._input.value = self._msgCommon.content
    else
        self._input.value = ""
    end
end

--[[
    @desc: 重设输入框数量限制
]]
function ChatInputWrap:ResetLimitCount(limitCount)
    MsgCommonWrap.ResetLimitCount(self, limitCount)
    self._input.characterLimit = limitCount
end

--[[
    @desc: 重置输入框状态，每次发送完消息调用
]]
function ChatInputWrap:ResetInput()
    self._input:RemoveFocus()
    self:ResetMsgCommon()
    self:ResetRoomType(self._roomType)
end

function ChatInputWrap:OnSelect()
    
end

function ChatInputWrap:OnDeSelect()
    
end

--[[
    @desc: 发送按钮点击时，调用该方法
]]
function ChatInputWrap:OnSendBtnClick()
    --判空输入
    if self._input:GetValueLength() < 1 then
        TipsMgr.TipByFormat("输入内容为空")
        return
    end

    --检测链接输入框内的文本对应的链接是否还有效
    --该检测可以在TextChange事件方法里做，但要考虑效率问题
    self:CheckAllLinkIsValid()

    --发送消息
    ChatMgr.RequestSendRoomMessage(self._roomType, "", Chat_pb.CHATMSG_COMMON, self:GetMsgCommonStr())

    self:ResetInput()
end

--[[
    @desc: 表情按钮点击时，调用该方法
]]
function ChatInputWrap:OnLinkBtnClick()
    --ChatInputWrap脚本有多个，但在某时刻,能响应UI_Chat_CommonLink界面超链接数据的只有一个
    ChatMgr.OpenCommonLinkByType(self._openType, self._funcOnTryAppendMsgLink, self._funcCreateMsgLink, self._roomType, self._funcAppendMsgCommon)
end

--[[
    @desc: 输入框内文本变化回调
]]
function ChatInputWrap:OnTextChange()
    self._msgCommon.content = self._input.value

    if self._input:HasIllegalChar() then
        TipsMgr.TipByKey("chat_not_support_char")
    end

    if self._limitCount > 0 then
        local len = self._input:GetValueLength()
        if self._input:GetValueLength() >= self._limitCount then
            --访问self._limitCount远比self._input.characterLimit好得多
            TipsMgr.TipByKey("chat_max_count_char")
        end
    end
end

--[[
    @desc: 尝试把msgLink添加到links数组后面，并更新self._msgCommon.content
    可能会失败，因为MsgCommon.links要求某些MsgLink只允许出现一个
    --@msgLink: 必须是从CreateMsgLink方法得来的
]]
function ChatInputWrap:TryAppendMsgLink(msgLink)
    local flag, failFlag = MsgCommonWrap.TryAppendMsgLink(self, msgLink)

    if flag then
        --更新输入框显示
        self._input.value = self._msgCommon.content
    else
        --根据错误类型选择性提示
        if failFlag == MsgCommonWrap.AppendFail_OverLen then
            TipsMgr.TipByKey("chat_max_count_char")
        elseif failFlag == MsgCommonWrap.AppendFail_LimitOnlyOne then
            --只能有一个link限制（玩法层面）
        end
    end
end

--[[
    @desc: 尝试往往self._msgCommon.content后添加字符串
    添加成功则返回ture,添加失败（长度超过）则返回false
    --@str: 
]]
function ChatInputWrap:TryAppendStr(str)
    local flag, failFlag = MsgCommonWrap.TryAppendStr(self, str)

    if flag then
        --更新输入框显示
        self._input.value = self._msgCommon.content
    else
        if failFlag == MsgCommonWrap.AppendFail_OverLen then
            TipsMgr.TipByKey("chat_max_count_char")
        end
    end
end

--[[
    @desc: 往后添加一个msgcommon类型，content往后拼接，links往后拼接。
    类型必须是Chat_pb.ChatContentStyle_Common（图文混排），并同步到输入框里
    --@msgCommon: 不考虑是否限制一个，目前只考虑长度
]]
function ChatInputWrap:TryAppendMsgCommon(msgCommon)
    local flag, failFlag = MsgCommonWrap.TryAppendMsgCommon(self, msgCommon)

    if flag then
        self._input.value = self._msgCommon.content
    else
        if failFlag == MsgCommonWrap.AppendFail_OverLen then
            TipsMgr.TipByKey("chat_max_count_char")
        end
    end
end

return ChatInputWrap