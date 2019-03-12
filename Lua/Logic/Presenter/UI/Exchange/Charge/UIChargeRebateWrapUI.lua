
local UIChargeRebateWrapUI = class("UIChargeRebateWrapUI",BaseWrapContentUI);

local function OnItemCreate(self,item,index)
    local temp = {};
    self._uiItems[index] = temp;
    self:InsertUIEvent(item:GetComponent("UIEvent"));
    temp.go = item.gameObject;
    temp.sprite = item:GetComponent("UISprite");
    temp.qualitySprite = item:Find("Icon_bg"):GetComponent("UISprite");
    temp.middleGo = item:Find("Middle_bg").gameObject;
    temp.rightGo = item:Find("Right_bg").gameObject;
    temp.countLabel = item:Find("Count"):GetComponent("UILabel");
end

function UIChargeRebateWrapUI:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);

    self._leftLabel = wrapItemTrans:Find("Head_bg/num"):GetComponent("UILabel");
    self._leftSprite = wrapItemTrans:Find("Head_bg/bg"):GetComponent("UISprite");
    self._gearProgress = wrapItemTrans:Find("Head_bg/HpBar"):GetComponent("UISlider");
    self._gearProgressLabel = wrapItemTrans:Find("Head_bg/HpBar/AttrValue"):GetComponent("UILabel");

    self._rightSpriteBg = wrapItemTrans:Find("Body_bg/bg"):GetComponent("UISprite");

    self._receivedGo = wrapItemTrans:Find("Body_bg/Received").gameObject;
    local receiveBtn = wrapItemTrans:Find("Body_bg/Receive");
    self._receiveBtnGo = receiveBtn.gameObject;
    self._notFinishGo = wrapItemTrans:Find("Body_bg/NotReached").gameObject;
    self:InsertUIEvent(receiveBtn:GetComponent("UIEvent"));

    self._uiItems = {};
    local grid = wrapItemTrans:Find("Body_bg/GridItem"):GetComponent("UIGrid");
    self._itemPrefab = wrapItemTrans:Find("Body_bg/GridItem/Item");
    UIGridTableUtil.CreateChild(context.GetUIFrame(),self._itemPrefab,5,nil,OnItemCreate,self);--(uiFrame,prefab,count,parent,OnCreate,caller)
    grid:Reposition();
end

function UIChargeRebateWrapUI:OnRefresh()
    local rebate = self._data;
    
    self._leftLabel.text = ChargeMgr.NumberFormatPerMille(rebate:GetLimitValue(),",");
    self._gearProgress.value = ChargeMgr.GetPaySum() / rebate:GetLimitValue();
    if ChargeMgr.GetPaySum()> rebate:GetLimitValue() then
        self._gearProgressLabel.text = tostring(rebate:GetLimitValue()).."/"..tostring(rebate:GetLimitValue());
    else
        self._gearProgressLabel.text = tostring(ChargeMgr.GetPaySum()).."/"..tostring(rebate:GetLimitValue());
    end
    if rebate:HasReceived() then
        self._leftSprite.spriteName = "frame_shanghceng_03";
        self._rightSpriteBg.spriteName = "frame_shanghceng_12";
        self._receivedGo:SetActive(true);
        self._receiveBtnGo:SetActive(false);
        self._notFinishGo:SetActive(false);
    elseif rebate:IsWaitReceiving() then
        self._leftSprite.spriteName = "frame_shanghceng_05";
        self._rightSpriteBg.spriteName = "frame_shanghceng_14";
        self._receivedGo:SetActive(false);
        self._receiveBtnGo:SetActive(true);
        self._notFinishGo:SetActive(false);
    else
        self._leftSprite.spriteName = "frame_shanghceng_04";
        self._rightSpriteBg.spriteName = "frame_shanghceng_13";
        self._receivedGo:SetActive(false);
        self._receiveBtnGo:SetActive(false);
        self._notFinishGo:SetActive(true);
    end
    self._leftSprite:MakePixelPerfect();

    local items = rebate:GetItems();
    self._items = items;
    for i=1,5 do
        if items[i] then
            self._uiItems[i].go:SetActive(true);
            local item = ItemData.GetItemInfo(items[i].id);
            if not item then
                GameLog.LogError("System:ChargeRebate,current rebate target get item %s is not find in data",items[i].id);
                self._uiItems[i].go:SetActive(false);
            else
                self._uiItems[i].sprite.spriteName = item.icon_big;
                self._uiItems[i].qualitySprite.spriteName = UIUtil.GetItemQualityBgSpName(item.quality);
                self._uiItems[i].countLabel.text = items[i].count;
                self._uiItems[i].rightGo:SetActive(false);
            end
        else
            self._uiItems[i].go:SetActive(false);
        end
    end
    --右边的花纹
    if self._uiItems[#items] then
        self._uiItems[#items].rightGo:SetActive(true);
    end
end

function UIChargeRebateWrapUI:OnClick(bid)
    if bid == 1 then
        ChargeMgr.RequestReceiveRebate(self._data);
    else
        BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, self._items[bid-1].id);
    end
end

return UIChargeRebateWrapUI;