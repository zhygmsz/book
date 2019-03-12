local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

local EquipMakeMaterialItem = class("EquipMakeMaterialItem")

local m_itemId
local m_requireCount
local m_itemCount
function EquipMakeMaterialItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._nameLabel = trs:Find("Name"):GetComponent("UILabel");
    self._levelLabel = trs:Find("Level"):GetComponent("UILabel");
    self._count = trs:Find("count"):GetComponent("UILabel")
    self._generalItem = GeneralItem.new(trs,nil);   
    m_requireCount = requireCount;

    
end

function EquipMakeMaterialItem:InitItem(itemId,requireCount)
    m_itemId = itemId;
    m_requireCount = requireCount;
    local itemCount = BagMgr.GetCountByItemId(itemId);
    local itemCountStr = tostring(itemCount).."/"..tostring(requireCount)

    self._generalItem:ShowByItemId(m_itemId,0,true,false,false);
    self._generalItem:ShowCount(itemCountStr);
    if itemCount < requireCount then
        self._count.color =  Color.New(1, 0, 0, 1);
    else
        self._count.color =  Color.New(1, 1, 1, 1);
    end
    local nameStr = ItemData.GetItemInfo(itemId).name;
    local levelStr = ItemData.GetItemInfo(itemId).showlevel;
    self._nameLabel.text = nameStr;
end

--获取当前Item数量是否足够
function EquipMakeMaterialItem:IsItemCountEnough()
    if m_itemCount >= m_requireCount then
        return true; 
    end
    return false;
end


return EquipMakeMaterialItem