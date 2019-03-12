--MsgCommon消息包装，主要是超链接管理和文本转换

MsgCommonWrap = class("MsgCommonWrap")

MsgCommonWrap.AppendFail_None = -1
--添加失败原因-超过长度（link,str,msgcommon通用）
MsgCommonWrap.AppendFail_OverLen = 1
--添加失败原因-只允许有一个（专用link）
MsgCommonWrap.AppendFail_LimitOnlyOne = 2

function MsgCommonWrap:ctor()
    --变量
    self._msgCommon = nil
    self._roomType = nil

    --0即为不限制
    self._limitCount = 0
end

--[[
    @desc: 重置MsgCommon，可以接受外部的，使用该类其他方法前先调用该方法
    --@msgCommon: 
]]
function MsgCommonWrap:ResetMsgCommon(msgCommon)
    self._msgCommon = msgCommon or Chat_pb.ChatMsgCommon()
end

--[[
    @desc: 根据text新建一个 msgCommon
    author:{author}
    time:2019-01-18 14:58:49
    --@text: 文本
    @return:
]]
function MsgCommonWrap:ResetMsgCommonWithDefaultText(text)
    self:ResetMsgCommon();
    self._msgCommon.content = text;
end

function CreateMsgCommonFromString(str)
    local ret = Chat_pb.ChatMsgCommon();
    ret:ParseFromString(msg.msgData);
    return ret;
end

--[[
    @desc: 如果操作的MsgCommon需要roomType字段，则在ResetMsgCommon方法之后，调该方法
    --@roomType: 
]]
function MsgCommonWrap:ResetRoomType(roomType)
    self._roomType = roomType
    self._msgCommon.roomType = roomType
end

function MsgCommonWrap:ResetContentStyle(contentStyle)
    self._msgCommon.contentStyle = contentStyle
end

function MsgCommonWrap:ResetLimitCount(limitCount)
    self._limitCount = limitCount
end

--[[
    @desc: 清空self._msgCommon.links数组，用于复用self._msgCommon
    只清空links，其余的字段通过对应接口清理
]]
function MsgCommonWrap:ClearMsgLinks()
    local linksCount = #self._msgCommon.links
    for idx = 1, linksCount do
        table.remove(self._msgCommon.links)
    end
end

--[[
    @desc: 自动填充sender字段
]]
function MsgCommonWrap:FillSender()
    ChatMgr.SetSenderInfo(self._msgCommon.sender)
end

function MsgCommonWrap:GetMsgCommon()
    self:FillSender()
    return self._msgCommon
end

function MsgCommonWrap:GetMsgCommonStr()
    self:FillSender()
    return self._msgCommon:SerializeToString()
end

--[[
    @desc: 创建新的MsgLink
]]
function MsgCommonWrap:CreateMsgLink()
    return self._msgCommon.links:add()
end

--[[
    @desc: 自定义的字符串长度算法，中文算一个字符
]]
function MsgCommonWrap:CustomLen(sourceStr)
    local len = 0

    if not sourceStr then
        return len
    end

    local lenInByte = #sourceStr
    local i = 1
    local byteCount = 0
    while i <= lenInByte do
        local curByte = string.byte(sourceStr, i)
        if 0 < curByte and curByte < 127 then
            byteCount = 1
        elseif 192 < curByte and curByte < 223 then
            byteCount = 2
        elseif 224 < curByte and curByte < 239 then
            byteCount = 3
        elseif 240 < curByte and curByte < 247 then
            byteCount = 4
        end

        --local char = string.sub(sourceStr, i, i + byteCount - 1)
        --GameLog.LogError("-----------------------------------------char = %s", char)
    
        i = i + byteCount
        len = len + 1
    end

    return len
end

--[[
    @desc: 尝试把msgLink添加到links数组后面，并更新self._msgCommon.content
    可能会失败，因为MsgCommon.links要求某些MsgLink只允许出现一个
    --@msgLink: 必须是从CreateMsgLink方法得来的
]]
function MsgCommonWrap:TryAppendMsgLink(msgLink)
    --contentWithId为最终显示和传递给C#的内容文本
    self:GenContentWithId(msgLink)

    local flag, failFlag = self:IsCanAppendMsgLink(msgLink)
    if flag then
        --拼接到self._msgCommon.content上
        self._msgCommon.content = self._msgCommon.content .. msgLink.contentWithId
    else
        --msgLink即为links最后一个，如添加失败。则删除
        self._msgCommon.links:remove(#self._msgCommon.links)
    end

    return flag, failFlag
end

--[[
    @desc: 尝试往往self._msgCommon.content后添加字符串
    添加成功则返回ture,添加失败（长度超过）则返回false
    --@str: 
]]
function MsgCommonWrap:TryAppendStr(str)
    local flag = true
    local failFlag = MsgCommonWrap.AppendFail_None

    if self._limitCount > 0 then
        local len = self:CustomLen(self._msgCommon.content) + self:CustomLen(str)
        if len > self._limitCount then
            flag = false
            failFlag = MsgCommonWrap.AppendFail_OverLen
        else
            self._msgCommon.content = self._msgCommon.content .. str
        end
    else
        self._msgCommon.content = self._msgCommon.content .. str
    end

    return flag, failFlag
end

--[[
    @desc: 往后添加一个msgcommon类型，content往后拼接，links往后拼接。
    类型必须是Chat_pb.ChatContentStyle_Common（图文混排）
    --@msgCommon: 不考虑是否限制一个，目前只考虑长度
]]
function MsgCommonWrap:TryAppendMsgCommon(msgCommon)
    local flag = true
    local failFlag = MsgCommonWrap.AppendFail_None

    local srcContent = msgCommon.content
    for idx, link in ipairs(msgCommon.links) do
        local newLink = self:CreateMsgLink()
        newLink:ParseFrom(link)
        self:GenContentWithId(newLink)
        local oldStr = string.sub(link.contentWithId, 2)
        local newStr = string.sub(newLink.contentWithId, 2)
        srcContent = string.gsub(srcContent, oldStr, newStr)
    end

    if self._limitCount > 0 then
        local len = self:CustomLen(self._msgCommon.content) + self:CustomLen(srcContent)
        if len > self._limitCount then
            --清理掉新创建的link
            for idx = 1, #msgCommon.links do
                self._msgCommon.links:remove(#self._msgCommon.links)
            end
            flag = false
            failFlag = MsgCommonWrap.AppendFail_OverLen
        else
            self._msgCommon.content = self._msgCommon.content .. srcContent    
        end
    else
        self._msgCommon.content = self._msgCommon.content .. srcContent
    end
    

    return flag, failFlag
end

--[[
    @desc: 检测该链接类型是否被限制只能输入一个
    除了系统表情，大多数链接都是只允许一个
    --@msgLink: 
]]
function MsgCommonWrap:IsLimitOnlyOne(msgLink)
    return msgLink.isLimitOnlyOne
end

--[[
    @desc: 是否存在相同的链接，linkType和staticID和dynamicID全相同，则为相同的链接
    链接相同的定义可能会随着需求改变
]]
function MsgCommonWrap:IsExistSameOne(msgLink)
    if not msgLink then
        return false
    end

    local linkCount = #self._msgCommon.links
    for idx, link in ipairs(self._msgCommon.links) do
        if link.linkType == msgLink.linkType 
            and link.staticID == msgLink.staticID and idx ~= linkCount then
            --暂时还没有启用dynamicID
            --links最后一个link即为参数msgLink
            return true
        end
    end

    return false
end

--[[
    @desc: 判检测重复链接
    --@msgLink: 
]]
function MsgCommonWrap:CheckIsExistSameOne(msgLink)
    local isExist = false

    if self:IsLimitOnlyOne(msgLink) then
        if self:IsExistSameOne(msgLink) then
            isExist = true
        else
            isExist = false
        end
    else
        isExist = false
    end

    return isExist
end

--[[
    @desc: 检测是否还能输入该新链接，细分各种原因
    不同原因选择性的提示
]]
function MsgCommonWrap:IsCanAppendMsgLink(msgLink)
    local isCan = true
    local failFlag = MsgCommonWrap.AppendFail_None

    --判断的先后顺序，可以根据策划需求调整
    repeat
        if self:CheckIsExistSameOne(msgLink) then
            isCan = false
            failFlag = MsgCommonWrap.AppendFail_LimitOnlyOne
            break
        end
        if self._limitCount > 0 then
            local len = self:CustomLen(self._msgCommon.content) + self:CustomLen(msgLink.contentWithId)
            if len > self._limitCount then
                isCan = false
                failFlag = MsgCommonWrap.AppendFail_OverLen
            end
        end
    until true

    return isCan, failFlag
end

--[[
    @desc: 是否需要自增id，可点击文本的超链接类型都需要
    --@msgLink: 
]]
function MsgCommonWrap:IsNeedContentAutoId(msgLink)
    return msgLink.isNeedAutoId
end

--[[
    @desc: 给contentWithId赋值，如果在已有链接中遇到相同content的，则后缀自增id
    如果没有遇到，则contentWithId和content内容一致
    --@return: 如果自增了id，则把自增后的id返回，否则返回0
]]
function MsgCommonWrap:GenContentWithId(msgLink)
    --先假定不需要自增id，直接赋值，如需要后面再次赋值
    msgLink.contentWithId = string.format("[%s]", msgLink.content)

    if not self:IsNeedContentAutoId(msgLink) then
        return
    end

    local autoId = self:GetContentAutoId(msgLink)
    --msgLink可能并非是新创建的，而是从其他msgCommon里取出的
    --如果在新的msgCommon里没找到同content的，要重置contentAutoId
    msgLink.contentAutoId = autoId
    if autoId ~= 0 then
        msgLink.contentWithId = string.format("[%s%d]", msgLink.content, msgLink.contentAutoId)
    end
end

--[[
    @desc: 遇到相同content，则返回自增id，如果没有遇到则返回0
    只判断content，忽略类型
    --@msgLink: 
]]
function MsgCommonWrap:GetContentAutoId(msgLink)
    local autoId = 0

    local len = #self._msgCommon.links
    --links最后一个link即为参数msgLink
    for idx = len - 1, 1, -1 do
        --从后往前匹配
        local link = self._msgCommon.links[idx]
        if link.content == msgLink.content then
            autoId = link.contentAutoId + 1
            break
        end
    end

    return autoId
end

--[[
    @desc: 检测所有的链接，是否还有效
    输入框内的链接文本被删除后不完整，即为失效
    删除后，又添加回来，则链接仍有效
]]
function MsgCommonWrap:CheckAllLinkIsValid()
    local content = nil
    local beginIdx, endIdx
    for _, link in ipairs(self._msgCommon.links) do
        --这里执行字符串操作，每次都会生成新的字符串
        --后面自己实现字符串匹配规则，保证在匹配过程中不产生新字符串
        content = string.sub(link.contentWithId, 2)
        --在string的各种方法里，模式的格式是由[]包起来的
        --所以[开头的字符串都被当成模式了，而不是被替字符串内容
        --超链接括号不用[]，换成其他成对的不易用的符号会更好
        beginIdx, endIdx = string.find(self._msgCommon.content, content)
        link.isValid = beginIdx ~= nil
    end
end

return MsgCommonWrap

