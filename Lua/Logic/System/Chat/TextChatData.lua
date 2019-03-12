TextChatData = class("TextChatData")

local function NewTip(lastTipTime,tipKey)
    if lastTipTime <= GameTime.time_L then TipsMgr.TipByKey(tipKey); end
    return GameTime.time_L + 200;
end

function TextChatData:ctor()
    self._msgCommon = Chat_pb.ChatMsgCommon();
    self._lastIllegalTipTime = -1;
    self._lastMaxCharCountTipTime = -1;
end

--设置输入脚本,监听输入文本变化事件
function TextChatData:SetInput(input,limitKey)
    self._input = input;
    self._input.value = "";
    self._input.characterLimit = ConfigData.GetIntValue(limitKey or "chat_max_count_char");
    self._input.useDefaultAlign = false;
    self._inputCallBack = EventDelegate.Callback(self.OnTextChange,self);
    EventDelegate.Set(self._input.onChange,self._inputCallBack);
end

--获取序列化的输入信息
function TextChatData:GetInput(dontClear)
    local finalContent = "";
    if self._msgCommon.content ~= "" then
        ChatMgr.SetSenderInfo(self._msgCommon.sender);
        self._msgCommon.content, self._illegalflag = string.ReplaceIllegalWord(self._msgCommon.content);
        finalContent = self._msgCommon:SerializeToString();
    end
    if not dontClear then self:ClearInput() end
    return finalContent, self._illegalflag;
end

--重置输入状态
function TextChatData:ClearInput()
    local oldRoom = self._msgCommon.roomType;
    self._msgCommon = Chat_pb.ChatMsgCommon();
    self._msgCommon.roomType = oldRoom;
    self._input:RemoveFocus();
    self._input.value = "";
end

--当前房间类型
function TextChatData:SetRoom(roomType)
    self._msgCommon.roomType = roomType;
end

--新增链接信息
function TextChatData:SetLink()

end

--输入字符检查
function TextChatData:OnTextChange()
    self._msgCommon.content = self._input.value; 
    --无法显示
    if self._input:HasIllegalChar() then
        self._lastIllegalTipTime = NewTip(self._lastIllegalTipTime,"chat_not_support_char");
    end
    --字数上限
    if self._input:GetValueLength() >= self._input.characterLimit then
        self._lastMaxCharCountTipTime = NewTip(self._lastMaxCharCountTipTime,"chat_max_count_char");
    end  
end