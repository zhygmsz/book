--一个常用的可以显示表情和文字的组件
UILabel_WithEmoji = class("UILabel_WithEmoji");

function UILabel_WithEmoji:ctor(infoTable)
    self._ui = infoTable.uiFrame;
    self._maxHeadLineWidth = infoTable.maxHeadLineWidth or 400;
    self._msxLineSpace = infoTable.msxLineSpace or 0;
    self._isRight = infoTable.isRight;
    self._contentRootTrans = infoTable.rootTrans;
end

--Chat_pb.ChatMsgCommon
function UILabel_WithEmoji:UpdateLabel(msgCommon)
    self._msgCommon = msgCommon;
    local itemData = msgCommon;
    local uiFrame = self._ui;
    local item = self;
    local content = itemData.content;
    local contentRoot = self._contentRootTrans;
    local contentWidth = self._maxHeadLineWidth;
    local contentSpace = self._msxLineSpace;
    local contentAlignLeft = not self._isRight;
    local contentLinks = itemData.links;
    local startColor = nil;
    local startString = nil;
    local endColor = nil;
    local endString = itemData.contentPostfix;
    TextHelper.ProcessItemCommon(uiFrame,item,content,contentRoot,contentWidth,contentSpace,contentAlignLeft,contentLinks,startColor,startString,endColor,endString);
end

function UILabel_WithEmoji:GetItemHeight()
    return self.curHeight;
end

function UILabel_WithEmoji:GetItemWidth()
    return self.curWidth;
end

function UILabel_WithEmoji:UpdateLabelWithStr(str)
    local msgCommon = Chat_pb.ChatMsgCommon();
    msgCommon:ParseFromString(str);
    self:UpdateLabel(msgCommon);
end

function UILabel_WithEmoji:OnClick()
    local linkIdx = self.imageLabelContent:ProcessClick();

    if linkIdx then
        local linkData = self._msgCommon.links[linkIdx];
        if linkData then
            MsgLinkHelper.OnClick(linkData)
        end
    end
end