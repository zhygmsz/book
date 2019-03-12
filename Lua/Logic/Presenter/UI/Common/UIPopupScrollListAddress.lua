--地址选择弹窗
local UIPopupScrollListAddress = class("UIPopupScrollListAddress");
local OPEN_ROTATION = UnityEngine.Quaternion.Euler(0,0,180);
local CLOSE_ROTATION = UnityEngine.Quaternion.Euler(0,0,90);

function UIPopupScrollListAddress:ctor(ui,path,openEventID,okEventID)
    local openBtnEvent = ui:FindComponent("UIEvent",path.."/OpenButton");
    openBtnEvent.id = openEventID;
    self._openEventID = openEventID;
    self._displayLabel = ui:FindComponent("UILabel",path.."/OpenButton/Label");
    self._openSpriteTrans = ui:Find(path.."/OpenButton/SpriteState");

    self._populistGo = ui:Find(path.."/PopupScrollList").gameObject;
    local okBtnEvent = ui:FindComponent("UIEvent",path.."/PopupScrollList/OKButton");
    okBtnEvent.id = okEventID;
    self._okEventID = okEventID;

    self._firstHelper = ui:FindComponent("UIScrollHelper",path.."/PopupScrollList/Scroll View1");
    self._firstLabel = ui:FindComponent("UILabel",path.."/PopupScrollList/Scroll View1/Label");
    self._firstAdds = nil;
    self._selectPID = 0;
    self._tempPID = 0;

    self._secondHelper = ui:FindComponent("UIScrollHelper",path.."/PopupScrollList/Scroll View2");
    self._secondLabel = ui:FindComponent("UILabel",path.."/PopupScrollList/Scroll View2/Label");
    self._secondAdds = nil;
    self._selectCID = 0;
    self._tempCID = 0;
    self:InitProvinces();

    self._populistGo:SetActive(false);
    self._openSpriteTrans.localRotation = OPEN_ROTATION;

    self:SetSelectedAddress();
end

function UIPopupScrollListAddress:InitProvinces()
    local function NoticeProvinceIndex(index) 
        local pid = self._firstAdds[index+1];
        self:SelectProvince(pid);
    end
    self._firstHelper:SetIndexChange(UIScrollHelper.ActionInt(NoticeProvinceIndex));

    self._firstAdds = LocationData.GetAllProvinces();
    local pCount = #self._firstAdds;
    if pCount == 0 then
        self._firstLabel.text = "";
        self:SelectProvince(0);
    else
        self._firstHelper.ItemCount = pCount;
        local provinces = LocationData.GetProvinceName(self._firstAdds[1]);
        for i = 2,pCount do
            provinces = provinces.."\n"..LocationData.GetProvinceName(self._firstAdds[i]);
        end
        self._firstLabel.text = provinces;
        self._firstHelper:SetShowChildIndex(0);
    end
end

function UIPopupScrollListAddress:InitCities(pid)
    local function NoticeCityIndex(index) 
        local cid = self._secondAdds[index+1];
        self:SelectCity(cid);
    end
    self._secondHelper:SetIndexChange(UIScrollHelper.ActionInt(NoticeCityIndex));

    self._secondAdds = LocationData.GetAllCities(pid);
    local cityCount = #self._secondAdds;
    if cityCount == 0 then
        self._secondLabel.text = "";
        self:SelectCity(0);
    else
        self._secondHelper.ItemCount = cityCount;
        local cities = LocationData.GetCityName(self._secondAdds[1]);
        for i = 2,#self._secondAdds do
            local cname = LocationData.GetCityName(self._secondAdds[i]);
            if #cname > 12 then
                cname = string.sub( cname,1,24);
            end
            cities = cities.."\n"..cname;
            GameLog.Log(cname.."Length ".. #cname);
        end
        self._secondLabel.text = cities;

        self._secondHelper:SetShowChildIndex(0);
    end
end

function UIPopupScrollListAddress:SelectProvince(pid)
    self._tempPID = pid;
    self:InitCities(pid);
end

function UIPopupScrollListAddress:SelectCity(cid)
    self._tempCID = cid;
end

function UIPopupScrollListAddress:OnClick(go,id)

    if id == self._openEventID and not self._openState then
        self._openState = true;
        self._openSpriteTrans.localRotation = CLOSE_ROTATION;
        self._populistGo:SetActive(true);
    elseif self._openState then
        self._openState = false;
        self._populistGo:SetActive(false);
        self._openSpriteTrans.localRotation = OPEN_ROTATION;
        if id == self._okEventID then
            self._selectCID = self._tempCID;
            self._selectPID = self._tempPID;
            self._displayLabel.text = LocationData.GetProvinceName(self._selectPID)..LocationData.GetCityName(self._selectCID);
        end
    end
end

function UIPopupScrollListAddress:GetSelectedAddress()
    if self._selectCID and self._selectCID ~= 0 then
        return self._selectCID;
    else
        return self._selectPID;
    end
end

--根据选择的id来显示
function UIPopupScrollListAddress:SetSelectedAddress(aid)
    if LocationData.IsProvince(aid) then--省代码
        self._selectPID = aid;
        self._displayLabel.text = LocationData.GetProvinceName(self._selectPID);
    elseif LocationData.IsCity(aid) then--市代码
        self._selectCID = aid;
        self._selectPID = LocationData.GetProvinceID(aid);
        self._displayLabel.text = LocationData.GetProvinceName(self._selectPID)..LocationData.GetCityName(aid);
    else
        self._selectCID = 0;
        self._selectPID = 0;
        self._displayLabel.text = WordData.GetWordStringByKey("location_input_none");
    end
end

return UIPopupScrollListAddress;