
module("UI_Intensify_Make_preview", package.seeall)

--require("Logic/Presenter/UI/Intensify/Make/EquipMakeModule")

local UI_Intensify_Make_preview = class("UI_Intensify_Make_preview")

local intensifyUpBtnEventId = 1001;
local normalUpBtnEventId = 1000;
local closeEventId = 1002;

function UI_Intensify_Make_preview:ctor(trs)

    self._transform = trs
    self._gameObject = trs.gameObject

    self._normalLabel1 = trs:Find("Offset/Content/LeftPanel/widget/scrollview/wrapcontent/10000/Level"):GetComponent("UILabel");
    self._normalLabel2 = trs:Find("Offset/Content/LeftPanel/widget/scrollview/wrapcontent/10001/Level"):GetComponent("UILabel");
    self._intensifyLabel1 = trs:Find("Offset/Content/LeftPanel/widget/scrollview/wrapcontent/10000/Label"):GetComponent("UILabel");
    self._intensifyLabel2 = trs:Find("Offset/Content/LeftPanel/widget/scrollview/wrapcontent/10001/Label"):GetComponent("UILabel");

    -- local iconTexture = trs:Find("Offset/Content/Item/icon"):GetComponent("UISprite");
    -- if iconTexture then
    --     self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    -- end
    self._equipIcon = trs:Find("Offset/Content/Item/icon"):GetComponent("UISprite");
    self._equipName = trs:Find("Offset/Content/name"):GetComponent("UILabel");
    self._equipType = trs:Find("Offset/Content/Label"):GetComponent("UILabel");


end

function UI_Intensify_Make_preview:Show()
    local equipMakeId = EquipMakeModule.GetCurrenEquipMakeId();
    if equipMakeId == -1 then
        return;
    end
    self._gameObject:SetActive(true);
    local data = EquipMakeData.GetEquipMakeData(equipMakeId);
    -- if self._iconTextureLoader then
    --     self._iconTextureLoader:LoadObject(data.icon);
    -- end
    self._equipIcon.spriteName = data.icon;
    self._equipName.text = data.equipName;
    --TODO掉落
    --data.normalDropId
    --data.enhanceDropId
    local tempIdNormal = data.normalEquipId;
    local tempIdIntensify = data.enhanceEquipId;
    UI_Intensify_Make_preview:ShowItemAttribute(tempIdNormal,tempIdIntensify)
    --ItemData.GetEquipmentInfo(id) 
end

function UI_Intensify_Make_preview:ShowItemAttribute(normalId, intensifyId)
    local normalItemData = ItemData.GetEquipmentInfo(normalId)
    local intensityItemData = ItemData.GetEquipmentInfo(intensifyId)
    if normalItemData and normalItemData.rateInfos[1] then
        local equipRateInfo0 = normalItemData.rateInfos[1]
        local str0 = equipRateInfo0.propertyMin .. "-" .. equipRateInfo0.propertyMax
        self._normalLabel1.text = str0
    end
    if normalItemData and normalItemData.rateInfos[2] then
        local equipRateInfo1 = normalItemData.rateInfos[2]
        local str1 = equipRateInfo1.propertyMin .. "-" .. equipRateInfo1.propertyMax
        self._normalLabel2.text = str1
    end
    if intensityItemData and intensityItemData.rateInfos[1] then
        local equipRateInfo2 = intensityItemData.rateInfos[1]
        local str3 = equipRateInfo2.propertyMin .. "-" .. equipRateInfo2.propertyMax
        self._intensifyLabel1.text = str3
    end
    if  intensityItemData and intensityItemData.rateInfos[2] then
        local equipRateInfo3 = intensityItemData.rateInfos[2]
        local str4 = equipRateInfo3.propertyMin .. "-" .. equipRateInfo3.propertyMax
        self._intensifyLabel2.text = str4
    end
end

function UI_Intensify_Make_preview:OnClick(go, id)
    if id == intensifyUpBtnEventId then
        EquipMakeModule.NormalMake();
    elseif id == normalUpBtnEventId then       
        EquipMakeModule.IntensifyMake();
    elseif id == closeEventId then       
        self._gameObject:SetActive(false);
    end
end

return UI_Intensify_Make_preview