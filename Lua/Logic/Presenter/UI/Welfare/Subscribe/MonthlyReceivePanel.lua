local MonthlyReceivePanel = class("MonthlyReceivePanel");

function MonthlyReceivePanel:RefreshAwardTime()
    local time = AllPackageMgr.GetAwardRefreshTime();
    --time = time - TimeUtils.SystemTimeStamp(true);
    self._refreshTime.text = TimeUtils.FormatTime(time,0,true);
end

function MonthlyReceivePanel:RefreshExpire()--月卡到期时间
    local expire = AllPackageMgr.GetExpireDay();
    self._expireDay.text = expire;
end

function MonthlyReceivePanel:RefreshDailyAward()--每日奖励变化
    local dailyDrops = AllPackageMgr.GetDailyAwards();
    self._dailyAwardGird:ResetWrapContent(dailyDrops);
end

function MonthlyReceivePanel:RefreshDailyButton()--每日奖励领取
    if  not AllPackageMgr.IsDailyReceived() then
        self._btnDailyLabel.text = WordData.GetWordStringByKey("month_card_daily_label")~="month_card_daily_label" and WordData.GetWordStringByKey("month_card_daily_label") or "领取";--领取每日奖励按钮文字
        self._btnDailyEvent.id = 8;
        self._btnDailySprite = WordData.GetWordStringByKey("month_card_daily_sprite");--领取每日奖励图片名
    else
        self._btnDailyLabel.text = WordData.GetWordStringByKey("month_card_daily_receive_label")~="month_card_daily_receive_label" and WordData.GetWordStringByKey("month_card_daily_receive_label") or "已领取";--领取每日奖励后按钮文字
        self._btnDailyEvent.id = 9;
        self._btnDailySprite = WordData.GetWordStringByKey("month_card_daily_receive_sprite");--领取每日奖励后图片名
    end
end

function MonthlyReceivePanel:RefreshSubscribeButton()--月卡订阅--订阅奖励领取
    if not AllPackageMgr.IsSubscribed() then
        self._btnSubscribeLabel.text = WordData.GetWordStringByKey("month_card_subscribe_label")~="month_card_subscribe_label" and WordData.GetWordStringByKey("month_card_subscribe_label") or "订阅";--订阅按钮
        self._btnSubscribeEvent.id = 5;
        self._btnSubscribeSprite = WordData.GetWordStringByKey("month_card_subscribe_sprite");--订阅图片名
    elseif not AllPackageMgr.IsSubscribedReceived() then
        self._btnSubscribeLabel.text = WordData.GetWordStringByKey("month_card_subscribe_receive_label")~="month_card_subscribe_receive_label" and WordData.GetWordStringByKey("month_card_subscribe_receive_label") or "领取";--领取订阅奖励按钮
        self._btnSubscribeEvent.id = 6;
        self._btnSubscribeSprite = WordData.GetWordStringByKey("month_card_subscribe_receive_sprite");--领取订阅奖励图片名
    else
        self._btnSubscribeLabel.text = WordData.GetWordStringByKey("month_card_subscribe_received_label")~="month_card_subscribe_received_label" and WordData.GetWordStringByKey("month_card_subscribe_received_label") or "已领取";--领取订阅奖励后按钮
        self._btnSubscribeEvent.id = 7;
        self._btnSubscribeSprite = WordData.GetWordStringByKey("month_card_subscribe_received_sprite");--领取订阅奖励后图片名
    end
end

function MonthlyReceivePanel:RefreshSubscribeAward()
    local dropItems = AllPackageMgr.GetSubscribeAwards();
    self._subscribeAwardGird:Refresh(dropItems);
end

function MonthlyReceivePanel:ctor(ui,path)
    self._ui = ui;
    self._weeklyObj = ui:Find(path.."/Refresh/WeeklyAward").gameObject;
    self._subscribeObj = ui:Find(path.."/Refresh/SubscribeAward").gameObject;

    self._refreshTime = ui:FindComponent("UILabel",path.."/Refresh/time");
    self._expireDay = ui:FindComponent("UILabel",path.."/DaysRemaining/num");
    
    local grid = ui:FindComponent("UIGrid",path.."/Refresh/SubscribeAward/Grid");
    local prefab = ui:Find(path.."/Refresh/SubscribeAward/Grid/Item");
    self._subscribeAwardGird = UICommonDropItemGrid.new(ui,grid,prefab,10);

    self._btnSubscribeLabel = ui:FindComponent("UILabel",path.."/Refresh/SubscribeAward/OclikBtn01/label");
    self._btnSubscribeEvent = ui:FindComponent("UIEvent",path.."/Refresh/SubscribeAward/OclikBtn01");
    self._btnSubscribeSprite = ui:FindComponent("UISprite",path.."/Refresh/SubscribeAward/OclikBtn01");

    self._dailyAwardGird = UIScrollDropItemGrid.new(ui,path.."/Refresh/DailyAward/Scroll View",20);

    self._btnDailyLabel = ui:FindComponent("UILabel",path.."/OneBtn/label");
    self._btnDailyEvent = ui:FindComponent("UIEvent",path.."/OneBtn");
    self._btnDailySprite = ui:FindComponent("UISprite",path.."/OneBtn");
end

function MonthlyReceivePanel:OnRefresh()
    self:RefreshAwardTime();--奖励刷新时间

    self:RefreshExpire();--月卡到期时间

    self:RefreshDailyAward();--每日奖励变化
    self:RefreshDailyButton();--每日奖励领取

    self:RefreshSubscribeButton();--订阅奖励领取
    self:RefreshSubscribeAward();--订阅奖励变化

end

function MonthlyReceivePanel:OnClick(id)
    if id == 3 then
        UI_Welfare.ShowUI(4);
    elseif id == 4 then
        --打开延迟月卡的界面
    elseif id == 5 then
        --打开订阅界面
        UI_Welfare.ShowUI(6);
    elseif id == 6 then
        AllPackageMgr.RequestGetSubscribeAward();
    elseif id == 7 then
        --已经领取订阅奖励
    elseif id == 8 then
        AllPackageMgr.RequestGetDailyAward()--订阅每日奖励
    elseif id == 9 then
        --已经领取每日奖励
    elseif id>=10 and id < 20 then
        self._subscribeAwardGird:OnClick(id);
    else
        self._dailyAwardGird:OnClick(id);
    end
end

return MonthlyReceivePanel;