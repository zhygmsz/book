local UIChargeShowCase = class("UIChargeShowCase")

local function OnFristGridCreate(self,trans,index)
    local item = ItemData.GetItemInfo( self._showItems[index].id);
    if not item then return; end
    trans:Find("Label"):GetComponent("UILabel").text = item.name;
    trans:Find("Count"):GetComponent("UILabel").text = self._showItems[index].count;
    trans:Find("Bg"):GetComponent("UISprite").spriteName = UIUtil.GetItemQualityBgSpName(item.quality);
    trans:GetComponent("UISprite").spriteName = item.icon_big;
    trans:GetComponent("UIEvent").id = 100+ index;
end
local function OnSecondGridCreate(self,trans,index)
    index = index + 3;
    OnFristGridCreate(self,trans,index);
end
function UIChargeShowCase:ctor(ui,path)
    self._ui = ui;
    self._valueLabel = ui:FindComponent("UILabel",path.."/ValueSprite/LabelValue");
    self._titleLabel = ui:FindComponent("UILabel",path.."/LabelTitle");
    self._grid1 = ui:FindComponent("UIGrid",path.."/Grid1");
    self._prefab1 = ui:Find(path.."/Grid1/Item");

    self._grid2 = ui:FindComponent("UIGrid",path.."/Grid2");
    self._prefab2 = ui:Find(path.."/Grid2/Item");
end

function UIChargeShowCase:ShowDay(reward)
    self._valueLabel.text = ChargeMgr.NumberFormatPerMille(reward:GetValue(),",");
    self._titleLabel.text = reward:GetDesc();

    local items = reward:GetItems();
    self._showItems = items;
    self._prefab2.gameObject:SetActive(true);
    local itemCount = #items;
    if itemCount <= 3 then
        self._prefab2.gameObject:SetActive(false);
        UIGridTableUtil.CreateChild(self._ui,self._prefab1,itemCount,nil,OnFristGridCreate,self);
    else
        UIGridTableUtil.CreateChild(self._ui,self._prefab1,3,nil,OnFristGridCreate,self);
        UIGridTableUtil.CreateChild(self._ui,self._prefab2,itemCount-3,nil,OnSecondGridCreate,self);
        self._grid2:Reposition();
    end
    self._grid1:Reposition();
end

function UIChargeShowCase:OnClick(id)
    if id < 100 then return; end
    id = id - 100;
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, self._showItems[id].id);
end

return UIChargeShowCase;