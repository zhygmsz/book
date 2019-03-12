local UI_PickUpView = require("Logic/Presenter/UI/PersonalSpace/UI_PickUpView")

local function GetDays(year,month)
    local days ={}
    local isLeapYear = (year%4 == 0) and (year%100~=0) or (year%400 == 0)
    local lm ={1, 3, 5, 7, 8, 10, 12}
    local num = 30
    if table.contains_value(lm,month) then
        num= 31
    elseif month == 2 then
        num = isLeapYear and 29 or 28
    end
    local index=1
    for i=1,num do
        days[index] = i
        index =index+1
    end
    return days
end

local UIPickUpViewController = class("UIPickUpViewController",nil)

function UIPickUpViewController:ctor()
    self._choosePid =1
    self._chooseCid = 1

    self._chooseYear =1
    self._chooseMonth = 1
    self._chooseDay = 1

    self._years = {}

    local date = TimeUtils.SystemDate()
    local index=1
    for i=1970,date.year do
        self._years[index] = i
        index =index+1
    end
    self._months = {1,2,3,4,5,6,7,8,9,10,11,12}
    self._days ={}
end

function UIPickUpViewController:PickLocation(offset,callback)
    self._choosePid =1
    self._chooseCid = 1
    local ProvinceIds = LocationData.GetAllProvinces()
    local AllcityIds = LocationData.GetAllCities(ProvinceIds[self._choosePid])
    local showDatas  ={ProvinceIds,AllcityIds}
  
    UI_PickUpView.ShowPickWheel(2,5,showDatas,function (wheelindex,label,data)
        if wheelindex==1 then label.text = LocationData.GetProvinceName(data) end
        if wheelindex==2 then label.text = LocationData.GetCityName(data) end
    end
    ,function(result,resultData)
        local prvinceid = resultData[1]
        local cityidex = result[2]
        if self._choosePid ~= prvinceid then
            AllcityIds = LocationData.GetAllCities(prvinceid)
            UI_PickUpView.SetDataForColum(2,AllcityIds)
        end
        self._choosePid = prvinceid
        self._chooseCid = AllcityIds[cityidex]
        local pname = LocationData.GetProvinceName(self._choosePid)
        local cname =LocationData.GetCityName(self._chooseCid)
        if callback then
            callback(self._choosePid,self._chooseCid,pname,cname)
        end
    end,offset,nil,nil,nil,nil)
end

function UIPickUpViewController:GetPickedLocation()
    return self._choosePid,self._chooseCid
end


function UIPickUpViewController:PickUpData(offset,callback)
    self._chooseYear =1
    self._chooseMonth = 1
    self._chooseDay = 1
    local year = self._years[self._chooseYear]
    local month = self._months[self._chooseMonth]
    self._days = GetDays(year,month)
    local showDatas = {self._years,self._months,self._days}
    --(colum,row,datas,setitemdatacallback,pickedcallback,offset,itemwidth,itemheight,closecallback,surecallback)
    UI_PickUpView.ShowPickWheel(3,5,showDatas,nil
    ,function(result,resultData)
        local cyear = resultData[1]
        local cmonth = resultData[2]
        local cday = resultData[3]
        if self._chooseYear ~= cyear or self._chooseMonth ~= cmonth then
            self._days = GetDays(cyear,cmonth)
            UI_PickUpView.SetDataForColum(3,self._days)
        end
        self._chooseYear =cyear
        self._chooseMonth = cmonth
        self._chooseDay = cday
       
    end,offset,nil,nil,nil,function(result,resultData)
        if callback then
            self._chooseYear = resultData[1]
            self._chooseMonth = resultData[2]
            self._chooseDay = resultData[3]
            callback(self._chooseYear,self._chooseMonth,self._chooseDay)
        end
    end)
end


function UIPickUpViewController:GetPickedDate()
    return self._chooseYear,self._chooseMonth,self._chooseDay
end

return UIPickUpViewController