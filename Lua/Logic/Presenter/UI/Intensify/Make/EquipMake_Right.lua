local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")
local EquipMakeMaterialItem = require("Logic/Presenter/UI/Intensify/Make/EquipMakeMaterialItem")
local EquipMakeItem = require("Logic/Presenter/UI/Intensify/Make/EquipMakeItem")
local PreviewUI = require("Logic/Presenter/UI/Intensify/Make/UI_Intensify_Make_preview")
require("Logic/Presenter/UI/Bag/UI_Tip_ItemInfoEx")
local EquipMake_Right = class("EquipMake_Right")

local m_equipMakeLevelEventIdBase = 500;
local m_equipMakeItemEventIdBase; --20
local m_levelSelectEventId = 250;
local m_normalLevelUpBtnEventId = 801;
local m_intensifyLevelUpBtnEventId = 802;
local m_previewBtnEventId = 803;
local m_askMakeValueReward = 804;
local m_BtnIronItem = 805;
local m_BtnBookItem = 806;
local m_BtnRuneItem = 807;
local m_BtnIntensifyItem = 808;
local m_BtnIntensifyTips = 809;
local m_previewEventRang = 1000;

local m_makeValueConfigDataKey = "Equipment_Make_Craftsmanship_Limit";   --巧匠值总数在GameConfig表中的值

local m_ironItemIndex = 1;
local m_bookItemIndex = 2;
local m_runeIndex = 3;
local m_intensifyItemIndex = 4;

local m_playerDefaultUseIntensifyLevel = 60;
local m_IsSelectedIntensify = false;
local m_IsHaveHigherLevelItem = false;

function EquipMake_Right:ctor(trs, eventequipMakeItemIdBase)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._makeBtnLabel = trs:Find("levelupBtn"):GetComponent("UILabel");
    self._coinNeedLabel = trs:Find("CoinNeed/NeedTab/CoountTab"):GetComponent("UILabel");
    self._coinHasLabel = trs:Find("CoinNeed/HaveTab/CoountTab"):GetComponent("UILabel");
    self._intensitfyDes = trs:Find("Des"):GetComponent("UILabel");

    local cb = EventDelegate.Callback(self.OnTextToggleChange, self)
    self._toggle = trs:Find("EquipList/toggle"):GetComponent("UIToggle");
    EventDelegate.Set(self._toggle.onChange, cb)

    self._makeValueProgress = trs:Find("EquipList/Box/HpBar"):GetComponent("UISlider");

    self._previewUITrs = trs:Find("UI_Intensify_Make_preview");
    self._previewUI = PreviewUI.new(self._previewUITrs);

    self._ironTrs = trs:Find("EquipList/Iron");
    self._ironItem = EquipMakeMaterialItem.new(self._ironTrs);

    self._bookTrs = trs:Find("EquipList/MakeBook");
    self._bookItem = EquipMakeMaterialItem.new(self._bookTrs);   

    self._runeTrs = trs:Find("EquipList/Symbol");
    self._runeItem = EquipMakeMaterialItem.new(self._runeTrs);

    self._intensifyTrs = trs:Find("EquipList/Stone");
    self._intensifyItem = EquipMakeMaterialItem.new(self._intensifyTrs);

    self._normalUpBtn = trs:Find("levelupBtn");
    self._intensifyUpBtn = trs:Find("intensifyLevelupBtn");

    self._equipMakeItemName = trs:Find("EquipList/HuaGuangci/name"):GetComponent("UILabel");
    self._equipMakeItemIcon = trs:Find("EquipList/HuaGuangci/Item/icon"):GetComponent("UISprite");
    -- local iconTextur = trs:Find("EquipList/HuaGuangci/Item/icon"):GetComponent("UITexture");
    -- if iconTextur then 
    --     self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    -- end
    self._requireItems = {};
    self._requireItems[m_ironItemIndex] = self._ironItem;
    self._requireItems[m_bookItemIndex] = self._bookItem;
    self._requireItems[m_runeIndex] = self._runeItem;
    self._requireItems[m_intensifyItemIndex] = self._intensifyItem;

    self._effLoader = LoaderMgr.CreateEffectLoader()
    self:RefreshMakeValue()
end

function EquipMake_Right:RefreshInfo(itemId)
    self.equipMakeData = EquipMakeData.GetEquipMakeData(itemId);
    if self.equipMakeData == nil then
        return;
    end

    equipMakeDataTemp = EquipMakeData.GetEquipMakeData(itemId);
    self._equipMakeItemName.text = equipMakeDataTemp.equipName;
    -- if self._iconTextureLoader then
    --     self._iconTextureLoader:LoadObject(equipMakeDataTemp.icon);
    -- end
    self._equipMakeItemIcon.spriteName = equipMakeDataTemp.icon;
    
    local materials = EquipMakeModule.GetMaterials();
    self.materialsIconId = {};
    
    if materials[m_ironItemIndex] == -1 then
    self.materialsIconId[m_ironItemIndex] = self.equipMakeData.materials[m_ironItemIndex].itemId
    else
        self.materialsIconId[m_ironItemIndex] = materials[m_ironItemIndex]
    end
    if materials[m_bookItemIndex] == -1 then
    self.materialsIconId[m_bookItemIndex] = self.equipMakeData.materials[m_bookItemIndex].itemId
    else
        self.materialsIconId[m_bookItemIndex] = materials[m_bookItemIndex]
    end
    if materials[m_runeIndex] == -1 then
    self.materialsIconId[m_runeIndex] = self.equipMakeData.materials[m_runeIndex].itemId
    else
        self.materialsIconId[m_runeIndex] = materials[m_runeIndex]
    end

    self._requireItems[m_ironItemIndex]:InitItem(self.materialsIconId[m_ironItemIndex],self.equipMakeData.materials[m_ironItemIndex].itemCount)
    self._requireItems[m_bookItemIndex]:InitItem(self.materialsIconId[m_bookItemIndex],self.equipMakeData.materials[m_bookItemIndex].itemCount)
    self._requireItems[m_runeIndex]:InitItem(self.materialsIconId[m_runeIndex],self.equipMakeData.materials[m_runeIndex].itemCount)
    self._requireItems[m_intensifyItemIndex]:InitItem(self.equipMakeData.exmaterialId,self.equipMakeData.exmaterialCount)

    local playerLevel = UserData.GetLevel();
    if playerLevel >= m_playerDefaultUseIntensifyLevel then
        self:SelectedIntensify(true);
    else
        self:SelectedIntensify(false);
    end

    local itemData = ItemData.GetItemInfo(self.equipMakeData.exmaterialId);
    --local str = string.format(WordData.GetWordStringByKey("intensitfyDes"), itemData.name)
    self._intensitfyDes.text = itemData.name .. "装备描述"

    self._coinNeedLabel.text = self.equipMakeData.money;
    self._coinHasLabel.text = string.NumberFormat(BagMgr.GetMoney(Coin_pb.SILVER),0);
    self:RefreshMakeValue()
    
end

function EquipMake_Right:OnTextToggleChange()
    local flag = self._toggle.value
    self:SelectedIntensify(flag)
end

function EquipMake_Right:OnClick(go, id)
    if id == m_normalLevelUpBtnEventId then
        EquipMakeModule.NormalMake();
    elseif id == m_intensifyLevelUpBtnEventId then
        EquipMakeModule.IntensifyMake();
    elseif id == m_previewBtnEventId then
        self._previewUI:Show();
    elseif id == m_askMakeValueReward then
        EquipMakeModule.AskMakeValueReward();
    elseif id == m_BtnIronItem then
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self.materialsIconId[m_ironItemIndex])
    elseif id == m_BtnBookItem then
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self.materialsIconId[m_bookItemIndex])
    elseif id == m_BtnRuneItem then
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self.materialsIconId[m_runeIndex])
    elseif id == m_BtnIntensifyItem then
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self.equipMakeData.exmaterialId)
    elseif id == m_BtnIntensifyTips then
        self:ShowIntensifyTips()
    elseif id >= m_previewEventRang then
        self._previewUI:OnClick(go, id);
    end
end

function EquipMake_Right:SelectedIntensify(val)
    m_IsSelectedIntensify = val;
    --EquipMakeModule.SetIntensifyMaterial(val)
    if val then
        self._normalUpBtn.gameObject:SetActive(false);
        self._intensifyUpBtn.gameObject:SetActive(true);
    else
        self._normalUpBtn.gameObject:SetActive(true);
        self._intensifyUpBtn.gameObject:SetActive(false);
    end
end

function EquipMake_Right:ReceiveMakeValueReward(makeValue)
    self:RefreshMakeValue()
end

function EquipMake_Right:RefreshMakeValue()
    if ConfigData.GetIntValue(m_makeValueConfigDataKey) then
        local a = EquipMakeModule.GetCurrentMakeValue();
        local b = ConfigData.GetIntValue(m_makeValueConfigDataKey);
        local c = a / b;
        --self._makeValueProgress.value = EquipMakeModule.GetCurrentMakeValue() / ConfigData.GetIntValue(m_makeValueConfigDataKey);
        self._makeValueProgress.value = c;
    end
    if ConfigData.GetIntValue(m_makeValueConfigDataKey) and ConfigData.GetIntValue(m_makeValueConfigDataKey) <= EquipMakeModule.GetCurrentMakeValue() then
        --显示特效
    else
        --关闭特效
    end
end

function EquipMake_Right:ShowIntensifyTips()
    local itemData = ItemData.GetItemInfo(self.equipMakeData.exmaterialId)
    local itemName = itemData.name
    --local title = TipsMgr.GetTipByKey("common_exchange_describe")
    --local str = string.format(WordData.GetWordStringByKey("IntensifyTips"), itemName)
    local title = ""
    local content = "IntensifyTips"
    TipsMgr.TipDerscribe({title = title,content = content})
end

-- function TryPlayEffect()
--     TryPlayEffect
-- end



return EquipMake_Right