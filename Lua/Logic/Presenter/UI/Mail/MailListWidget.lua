local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local MailListItem = class("MailListItem", ContentItem)

function MailListItem:ctor(trs,eventId)
    ContentItem.ctor(self, trs, eventId)

    self._specTitle = trs:Find("spec/title"):GetComponent("UILabel")
    self._specTime = trs:Find("spec/time"):GetComponent("UILabel")
    self._specGift = trs:Find("spec/gift").gameObject

    self._norNode = trs:Find("nor/normalState").gameObject
    self._norGrayNode = trs:Find("nor/grayState").gameObject

    self._norTitle = trs:Find("nor/normalState/title"):GetComponent("UILabel")
    self._norTime = trs:Find("nor/normalState/time"):GetComponent("UILabel")
    self._norGrayTitle = trs:Find("nor/grayState/title"):GetComponent("UILabel")
    self._norGrayTime = trs:Find("nor/grayState/time"):GetComponent("UILabel")
    self._norReaded = trs:Find("nor/normalState/readed").gameObject
    self._norUnread = trs:Find("nor/normalState/unread").gameObject
    self._norGrayReaded = trs:Find("nor/grayState/readed").gameObject
    self._norGrayUnread = trs:Find("nor/grayState/unread").gameObject
    self._norGift = trs:Find("nor/normalState/gift").gameObject
end

function MailListItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)

    local haveItem = false
    if #data.itemlist ~= 0 then
        if data.attach_picked == 0 then
            haveItem = true
        else
            haveItem = false
        end
    else
        haveItem = false
    end
    local isGray = not haveItem and data.read ~= 0

    self._norNode:SetActive(not isGray)
    self._norGrayNode:SetActive(isGray)

    self._norTitle.text = data.title
    self._specTitle.text = data.title
    self._norGrayTitle.text = data.title

    local timeStr = TimeUtils.FormatTime(data.time, 3, true)
    self._norTime.text = timeStr
    self._specTime.text = timeStr
    self._norGrayTime.text = timeStr

    self._norReaded:SetActive(data.read ~= 0)
    self._norUnread:SetActive(data.read == 0)
    self._norGrayReaded:SetActive(data.read ~= 0)
    self._norGrayUnread:SetActive(data.read == 0)
    self._norGift:SetActive(haveItem)

    self._specGift:SetActive(haveItem)
end

-------------------- widget -------------------- 

local MailListWidget = class("MailListWidget", ContentWidget)

function MailListWidget:ctor(trs, baseEventId, OnClickCallback, ui)
    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, OnClickCallback, baseEventId, MailListItem)
end

function MailListWidget:Show(dataList, realIndex)
    self._contentWidget:Show(dataList, true)
    self._contentWidget:AutoSelectRealIdx(realIndex)
end

function MailListWidget:OnClick(id)
    self._contentWidget:OnClick(id)
end

function MailListWidget:GetCurRealIdx()
    return self._contentWidget:GetCurRealIdx()
end

function MailListWidget:UpdateItem(realIdx, data)
    self._contentWidget:UpdateItem(realIdx, data)
end

return MailListWidget