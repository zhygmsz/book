local WrapUIChatTime  = class("WrapUIChatTime",UICommonCollapseWrapUI);

function WrapUIChatTime:ctor(root)
    local subItemTran = root:Find("Time");
    self._contentLabel = subItemTran:Find("Content/Root/Label"):GetComponent("UILabel");
    self._widget = subItemTran:GetComponent("UIWidget");
    self._gameObject = subItemTran.gameObject;
end

function WrapUIChatTime:OnRefresh()
    if not self._isActive then GameLog.Log("%s is not active", self.__cname);return; end
    local data = self._wrapData;
    local secs = data:GetContent();
    local time = TimeUtils.TimeStamp2Date(secs,true);

    local currentTime = TimeUtils.SystemDate();
    if time.year == currentTime.year and time.month == currentTime.month and time.day == currentTime.day then
        self._contentLabel.text = string.format("%02d:%02d:%02d",time.hour,time.min,time.sec);--os.date("%H:%M:%S",time);
    else
        self._contentLabel.text = string.format("%d-%02d-%02d %02d:%02d:%02d",time.year,time.month,time.day,time.hour,time.min,time.sec);
    end
end

return WrapUIChatTime;