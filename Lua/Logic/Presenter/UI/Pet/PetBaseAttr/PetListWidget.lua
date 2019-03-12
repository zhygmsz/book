local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local PetListItem = class("PetListItem", ContentItem)

function PetListItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)

    self._target = trs:Find("Target").gameObject
    self._lv = trs:Find("Lv"):GetComponent("UILabel")
    self._icon = trs:Find("Icon"):GetComponent("UITexture")
    self._isFight = trs:Find("IsFight").gameObject
    self._boxCollider = trs.gameObject:GetComponent("BoxCollider")
    self._isPrecious = trs:Find("IsPrecious").gameObject
end

function PetListItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)
    local petData = PetData.GetPetDataById(data.petId)
    local petInfo = PetMgr.GetPetInfoBySlotId(data.slotId)
    local isPet = petData ~= nil

    self._target:SetActive(isPet)
    self._lv.gameObject:SetActive(isPet)
    self._icon.gameObject:SetActive(isPet)
    self._isFight:SetActive(isPet)
    self._boxCollider.enabled = isPet
    self._isPrecious:SetActive(isPet)

    if not isPet then
        return 
    end

    self._isFight:SetActive(petInfo.Current == 1)
    self._lv.text = data.level
    self._target:SetActive(petData.bindType == 1)
    UIUtil.SetTexture(petData.face, self._icon)
    self._isPrecious:SetActive(petInfo.isPrecious == 1)
end

local PetListWidget = class("PetListWidget", ContentWidget)

function PetListWidget:ctor(trs, baseEventId, OnClickCallback, ui)
    self._tranform = trs
    self._gameObject = trs.gameObject

    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, OnClickCallback, baseEventId, PetListItem)
end

function PetListWidget:Show(dataList, realIndex)
    self._contentWidget:Show(dataList)
    self._contentWidget:AutoSelectRealIdx(realIndex)
end

function PetListWidget:OnClick(id)
    self._contentWidget:OnClick(id)
end

function PetListWidget:OnEnable(realIndex)
    self._dataList = PetMgr.GetPetDataList()

    -- for i, v in ipairs(self._dataList) do
    --     local petInfo = PetMgr.GetPetInfoBySlotId(v.slotId)
    --     if petInfo then
    --         if petInfo.Current == 1 and  realIndex == 1 then
    --             realIndex = i
    --             break
    --         end
    --     end
    -- end
    self:Show(self._dataList, realIndex)
end

function PetListWidget:GetCurRealIdx()
    return self._contentWidget:GetCurRealIdx()
end

return PetListWidget