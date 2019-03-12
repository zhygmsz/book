--[[
    author:sjz
    time:2019-3-6 19:22
    use:每周特惠-礼包赠送物品栏
]]

local UIWeekPackageGiftItem = class("UIWeekPackageGiftItem")


function UIWeekPackageGiftItem:ctor(trans,context,idx)
    self._trans = trans
    self._gameObject = trans.gameObject
    self._context = context
    self._idx = idx
    self._nameLabel = trans:Find("sp/Name"):GetComponent("UILabel")
    self._lineTabel={}
    for i=1,4 do
        self._lineTabel[i] = trans:Find("sp/Line"..i).gameObject
    end
    self._grid = trans:Find("Grid"):GetComponent("UIGrid")
    self._prefab = trans:Find("Grid/ItemPrefab")
    self._itemList={}
end

function UIWeekPackageGiftItem:OnRefresh(data)
    for i=1,4 do
        self._lineTabel[i]:SetActive(false)
    end
    local items
    if self._idx ==1 then
        self._nameLabel.fontSize = 24
        self._nameLabel.text = data:GetName();
        self._lineTabel[1]:SetActive(true)
        self._lineTabel[2]:SetActive(true)
        self._itemtable:Refresh(data:GetNormalItems())
    elseif self._idx ==2 then
        self._nameLabel.fontSize = 18
        self._nameLabel.text = "月卡额外奖励";
        self._lineTabel[3]:SetActive(true)
        self._lineTabel[4]:SetActive(true)
        self._itemtable:Refresh(data:GetMonthItems())
        self._itemtable:SetMask(not AllPackageMgr.IsMonthlyBuy());
    elseif self._idx == 3 then
        self._nameLabel.fontSize = 18
        self._nameLabel.text = "订阅额外奖励";
        self._lineTabel[3]:SetActive(true)
        self._lineTabel[4]:SetActive(true)
        self._itemtable:Refresh(data:GetSubscribeItems())
        self._itemtable:SetMask(not AllPackageMgr.IsSubscribed());
    end
end

function UIWeekPackageGiftItem:SetVisible(isVisible)
    self._gameObject:SetActive(isVisible)
end

function UIWeekPackageGiftItem:SetOnClick(eventId)
    self._itemtable = UICommonItemListGrid.new(self._context:GetUI(),self._grid,self._prefab,eventId)
end

function UIWeekPackageGiftItem:OnClick(eventId)
    self._itemtable:OnClick(eventId)
end

return UIWeekPackageGiftItem