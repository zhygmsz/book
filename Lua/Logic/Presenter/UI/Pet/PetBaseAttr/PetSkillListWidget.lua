local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local PetSkillListItem = class("PetSkillListItem", ContentItem)

function PetSkillListItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)

    self._icon = trs:Find("Icon"):GetComponent("UITexture")    
end

function PetSkillListItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)
    
    local skillData = SkillData.GetSkillInfo(data.tempSkillId)
    self._icon.gameObject:SetActive(skillData ~= nil)
    if skillData == nil then
        return 
    end
    UIUtil.SetTexture(skillData.icon, self._icon)
end

local PetSkillListWidget = class("PetListWidget", ContentWidget)

function PetSkillListWidget:ctor(trs, baseEventId, OnClickCallback, ui)
    self._tranform = trs
    self._gameObject = trs.gameObject

    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, OnClickCallback, baseEventId, PetSkillListItem)
end

function PetSkillListWidget:Show(dataList)
    self._contentWidget:Show(dataList)
end

function PetSkillListWidget:OnClick(id)
    self._contentWidget:OnClick(id)
end

function PetSkillListWidget:SetVisible(isShow)
    self._gameObject:SetVisible(isShow)
end


return PetSkillListWidget