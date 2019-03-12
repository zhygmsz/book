
local m_contentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")
local m_equipMakeItem = require("Logic/Presenter/UI/Intensify/Make/EquipMakeItem")
local m_equipMakeLevelItem = require("Logic/Presenter/UI/Intensify/Make/EquipMakeLevelItem");

local EquipMake_Left = class("EquipMake_Left")

local m_equipMakeLevelEventIdBase = 500;
local m_equipMakeItemEventIdBase; --20
local m_levelSelectEventId = 250;
local m_isSelectedEquipLevel = false;

function EquipMake_Left:ctor(trs, eventequipMakeItemIdBase, funcOnSelectedEquipItem)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._widgetTrs = trs:Find("widget")
    -- self.funcOnSelectedEquipItem = funcOnSelectedEquipItem;
    -- self.funOnClickEquipMakeItem = function(data)
    --     self:OnClickEquipMakeItem(data)
    -- end
    m_equipMakeItemEventIdBase = eventequipMakeItemIdBase;
    self._contentWidget = m_contentWidget.new(self._widgetTrs, funcOnSelectedEquipItem, eventequipMakeItemIdBase, m_equipMakeItem)
    self.currentEquipMakeLevelLabel = trs:Find("Title/attbg/att"):GetComponent("UILabel");
    self.currentEquipMakeLevelDownArrow = trs:Find("Title/attbg/DownArrow");
    self.currentEquipMakeLevelUpArrow = trs:Find("Title/attbg/UpArrow");
    self.levelListObj = trs:Find("LevelList");
    self.levelWidgetTrs = trs:Find("LevelList/widget");

    self.funcOnClickEquipMakeLevel = function(data)
        self:OnClickEquipMakeLevel(data)
    end
    self.levelcontentWidget = m_contentWidget.new(self.levelWidgetTrs, self.funcOnClickEquipMakeLevel, m_equipMakeLevelEventIdBase, m_equipMakeLevelItem)
    print(self.OnClickEquipMakeLevel);

    --变量
    self._isShowed = false
    --控制整个区域的刷新，选择性重置
    self._needShow = true
    self._eventIds = {}
    self._canInlayEquipList = {}
    self:CloseEquipMakeLevelSelect();
    --self:SetVisible(false)
end

--点击事件
function EquipMake_Left:OnClick(go, id)
    if id == m_levelSelectEventId then
        self:OnClickEquipMakeLevelSelect()
    elseif id > m_equipMakeLevelEventIdBase then
        self.levelcontentWidget:OnClick(id)    
    elseif id > m_equipMakeItemEventIdBase then
        self._contentWidget:OnClick(id)
    end
end

--通过玩家等级设置当前的打造等级
function EquipMake_Left:SetEquipMakeLevel(playerLevel)
    local targetLevel = self:GetEquipMakeLevel(playerLevel);
    self:RefreshEquipMakeItems(targetLevel);

    self.currentEquipMakeLevelLabel.text = tostring(targetLevel);
    self.currentEquipMakeLevelDownArrow.gameObject:SetActive(true);
    self.currentEquipMakeLevelUpArrow.gameObject:SetActive(false);
end

--通过玩家等级获取对应的打造等级
function EquipMake_Left:GetEquipMakeLevel(playerLevel)
    local allEquipMakeLevel = EquipMakeData.GetAllEquipLevel();
    local targetLevel = nil;
    for i=1,#allEquipMakeLevel do
        if playerLevel < allEquipMakeLevel[i] then
            targetLevel = allEquipMakeLevel[i];
            if i <= 1 then
                return allEquipMakeLevel[1];
            end
            if i > 1 then
                return allEquipMakeLevel[i-1];
            end
        end       
    end
    return allEquipMakeLevel[#allEquipMakeLevel];
end

--根据打造等级，刷新列表
function EquipMake_Left:RefreshEquipMakeItems(level)
    local equipMakeDatas = EquipMakeData.GetEquipMakeDatasByEquipLevelSortedByEquipType(level);
    local canMakeContentDatas = {};
    local cantMakeContentDatas = {};
    for k, v in pairs(equipMakeDatas) do
        contentData = {};
        contentData.equipName = v.equipName;
        contentData.equipLevel = v.equipLevel;
        contentData.icon = v.icon;
        contentData.id = v.id;
        contentData.equipType = v.equipType
        local canMake = EquipMakeModule.IsEquipCanMake(v.id)
        contentData.canMake = canMake
        if canMake then
            table.insert(canMakeContentDatas, contentData);
        else
            table.insert(cantMakeContentDatas, contentData);
        end
        table.sort(canMakeContentDatas, function(a, b) return a.equipType < b.equipType end)
        table.sort(cantMakeContentDatas, function(a, b) return a.equipType < b.equipType end)
        for n, m in pairs(cantMakeContentDatas) do
            table.insert(canMakeContentDatas, m)     --在这里所有的data都按顺序放到了canMakeContentDatas表中
        end
    end
    self._contentWidget:Show(canMakeContentDatas);
end

--点击等级筛选
function EquipMake_Left:OnClickEquipMakeLevelSelect()
    if m_isSelectedEquipLevel == false then
        self:OpenEquipMakeLevelSelect();
    else
        self:CloseEquipMakeLevelSelect();
    end
end

--打开等级筛选
function EquipMake_Left:OpenEquipMakeLevelSelect()
    self.currentEquipMakeLevelDownArrow.gameObject:SetActive(false);
    self.currentEquipMakeLevelUpArrow.gameObject:SetActive(true);
    self.levelListObj.gameObject:SetActive(true);

    --此部分数据以后缓存起来
    local equipMakeLevels = EquipMakeData.GetAllEquipLevel();
    local contentDatas = {};
    for k, v in pairs(equipMakeLevels) do
        contentData = {};
        contentData.level = v;       
        table.insert(contentDatas, contentData);
    end
    self.levelcontentWidget:Show(contentDatas);
    m_isSelectedEquipLevel = true;
end

--关闭等级筛选
function EquipMake_Left:CloseEquipMakeLevelSelect()
    self.currentEquipMakeLevelDownArrow.gameObject:SetActive(true);
    self.currentEquipMakeLevelUpArrow.gameObject:SetActive(false);
    self.levelListObj.gameObject:SetActive(false);
    m_isSelectedEquipLevel = false;
end

--点击等级Item的回调。刷新打造装备
function EquipMake_Left:OnClickEquipMakeLevel(data)
    self:RefreshEquipMakeItems(data.level);
    self.currentEquipMakeLevelLabel.text = tostring(data.level);
end


function EquipMake_Left:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function EquipMake_Left:AutoSelectRealIdx(realIdx)
    self._contentWidget:AutoSelectRealIdx(realIdx)
end

function EquipMake_Left:GetCurSelectData()
    return self._contentWidget:GetCurSelectData()
end

return EquipMake_Left