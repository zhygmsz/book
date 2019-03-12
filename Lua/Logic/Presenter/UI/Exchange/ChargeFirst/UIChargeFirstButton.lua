local UIChargeFirstButton = class("UIChargeFirstButton")

local function OnFristGridCreate(self,trans,index)
    local item = ItemData.GetItemInfo( self._drops[index].itemId);
    if not item then return; end
    trans:Find("Label"):GetComponent("UILabel").text = item.name;
    trans:Find("Count"):GetComponent("UILabel").text = self._drops[index].minCount;
    trans:GetComponent("UISprite").spriteName = item.icon_big;
    trans:GetComponent("UIEvent").id = 100+ index;
end

local function OnSecondGridCreate(self,trans,index)
    index = index + 3;
    OnFristGridCreate(self,trans,index);
end

function UIChargeFirstButton:ctor(ui)
    self._ui = ui;
    self._btnSprite = ui:FindComponent("UISprite","Offset/RewardBtnPanel/BtnDown");
    self._btnEvent = ui:FindComponent("UIEvent","Offset/RewardBtnPanel/BtnDown");
    self._btnBoxCollider = ui:FindComponent("BoxCollider","Offset/RewardBtnPanel/BtnDown");
    self._btnTips = ui:FindComponent("UILabel","Offset/RewardBtnPanel/BtnDown/labelTips");
end

function UIChargeFirstButton:ShowDay(reward)
    self._reward = reward;
    self._btnTips.text = "";
    self._btnBoxCollider.enabled=true;
    if not ChargeMgr.HasAnyCharge() then
        self._btnSprite.spriteName = "button_shouchong_05";--充点小钱的图片
        self._btnEvent.id = 23;
    elseif reward:HasReceived() then
        self._btnBoxCollider.enabled=false;
        self._btnSprite.spriteName = "button_shouchong_07";--已领取的图片
        self._btnEvent.id = 20;
    elseif reward:IsWaitReceiving() then
        self._btnSprite.spriteName = "button_shouchong_06";--领取的图片
        self._btnEvent.id = 21;
    elseif reward:IsWaitOpen() then
        self._btnSprite.spriteName = "button_shouchong_08";--未到领取时间的图片
        self._btnEvent.id = 22;
    end
    for i,v in pairs(ChargeMgr.GetFirstRewards()) do
        if v:IsWaitOpen() and i==2 then
            self._btnTips.text = WordData.GetWordStringByKey("Pay_first_message2");--明日登录领取第2日首充礼包
            break;
        elseif v:IsWaitOpen() and i==3 then
            self._btnTips.text = WordData.GetWordStringByKey("Pay_first_message3");--明日登录领取第3日首充礼包
            break;
        end
    end
end

function UIChargeFirstButton:SelectColorIdx(idx)
    self._selectColorIdx = idx;
end

function UIChargeFirstButton:OnClick(id)
    if id == 21 then
        ChargeMgr.RequestReceiveAward(self._reward,self._selectColorIdx);
    elseif id==22 then
        TipsMgr.TipByKey("Pay_first_message4");
    elseif id == 23 then
        UI_Exchange.ShowUI(4);
        UIMgr.UnShowUI(AllUI.UI_ChargeFirst);
    end
end

return UIChargeFirstButton;