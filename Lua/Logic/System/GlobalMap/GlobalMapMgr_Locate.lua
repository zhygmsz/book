module("GlobalMapMgr",package.seeall);
local SDKGlobalMap = cyou.ldj.sdk.SDKGlobalMap
local JSON = require "cjson"

local mPOIToCoordinateCallBack = nil
local mCoordinateToPOICallBack = nil 
local mLocateCompletedCallBack = nil

--初始化地图定位服务
function  InitLocationServer(key)
    SDKGlobalMap.Instance:InitLocationServer(key)
    SDKGlobalMap.Instance:SetLocateFinishedCallback(OnLocateFinished)
    SDKGlobalMap.Instance:SetPOIToCoordinateCallback(POIToCoordinateCompleted)
    SDKGlobalMap.Instance:SetCoordinateToPOICallback(CoordinateToPOICallBack)
    SDKGlobalMap.Instance:SetOnPOIByKeyCallback(GetPOIByKeyCallBack)
    SDKGlobalMap.Instance:SetOnDistrictInChinaCallback(GetDistrictInChinaCallBack)
    SDKGlobalMap.Instance:SetOnChildrenDistrictCallback(GetChildrenDistrictCallBack)
    SDKGlobalMap.Instance:SetOnDistrictByKeywordCallback(GetDistrictByKeywordCallBack)
end

--定位结束
function OnLocateFinished()
    GameLog.Log("OnLocateFinished")
    selfLocationInfo = SDKGlobalMap.Instance:GetLocationInfo()
    selfCoordinate= SDKGlobalMap.Instance:GetSelfCoordinateVec2()
    MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_UPDATELOCATION,selfCoordinate);
   
    local function GetSelfAddInfo(info)
        selfAddressInfo= info
        if mLocateCompletedCallBack then
            mLocateCompletedCallBack(selfCoordinate,selfLocationInfo,selfAddressInfo)
        end
    end

    CoordinateToPOICompleted(selfCoordinate.x,selfCoordinate.y,0,GetSelfAddInfo)
end

--开始定位
function StartSelfLocate()
    SDKGlobalMap.Instance:StartSelfLocate()
end

function StartSelfLocateComplete(complete)
    mLocateCompletedCallBack = complete
    SDKGlobalMap.Instance:StartSelfLocate()
end

--获取当前地址
function GetCurrentAddress()
    return selfAddress
end

--获取当前地址信息
--info.address = address
--info.nationcode
--info.adcode
--info.citycode
--info.coordinate
--info.recommendAddress
function GetCurrentAddressInfo()
    return selfAddressInfo
end

--地址转换坐标
function POIToCoordinate(address)
    SDKGlobalMap.Instance:POIToCoordinate(address)
end
--地址转换坐标
function POIToCoordinateCompleted(address,complete)
    mPOIToCoordinateCallBack = complete
    SDKGlobalMap.Instance:POIToCoordinate(address)
end
--地址转换坐标的回调
--[[{
    "status": 0,
    "message": "query ok",
    "result": {
        "title": "派·酒店北京石景山八角游乐园地铁站店",
        "location": {
            "lng": 116.19854,
            "lat": 39.91396
        },
        "address_components": {
            "province": "北京市",
            "city": "北京市",
            "district": "石景山区",
            "street": "",
            "street_number": ""
        },
        "similarity": 0.8,
        "deviation": 1000,
        "reliability": 7,
        "level": 11
    }
}]]
function POIToCoordinateCallBack(obj)
    GameLog.Log("POIToCoordinateCallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    if code==0 then
        local coordinate=Vector2(jsonData["result"]["location"]["lat"],jsonData["result"]["location"]["lng"])
        local title =jsonData["result"]["title"]
        local info={}
        info.title=title
        info.coordinate=coordinate
        info.province =jsonData["result"]["address_components"]["province"]
        info.city =jsonData["result"]["address_components"]["city"]
        info.district =jsonData["result"]["address_components"]["district"]
        info.street =jsonData["result"]["address_components"]["street"]
        info.street_number =jsonData["result"]["address_components"]["street_number"]
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_POITOCOORDINATE,info);
        if mPOIToCoordinateCallBack then
            mPOIToCoordinateCallBack(info)
            mPOIToCoordinateCallBack=nil
        end
    end
end

--坐标转为地址
function CoordinateToPOI(lat,lon,g)
    SDKGlobalMap.Instance:CoordinateToPOI(lat,lon,g)
end

function CoordinateToPOICompleted(lat,lon,g,complete)
    mCoordinateToPOICallBack = complete
    SDKGlobalMap.Instance:CoordinateToPOI(lat,lon,g)
end
--坐标转为地址的回调
--[[  "status": 0,
    "message": "query ok",
    "request_id": "89665a72-8f10-11e8-b2a4-6c92bf1a7ce7",
    "result": {
        "location": {
            "lat": 39.78902,
            "lng": 116.467
        },
        "address": "北京市大兴区公园南环路",
        "formatted_addresses": {
            "recommend": "大兴区公园北环路与公园南环路交叉口北",
            "rough": "大兴区公园北环路与公园南环路交叉口北"
        },
        "address_component": {
            "nation": "中国",
            "province": "北京市",
            "city": "北京市",
            "district": "大兴区",
            "street": "公园南环路",
            "street_number": "公园南环路"
        },
        "ad_info": {
            "nation_code": "156",
            "adcode": "110115",
            "city_code": "156110000",
            "name": "中国,北京市,北京市,大兴区",
            "location": {
                "lat": 39.789021,
                "lng": 116.467003
            },
            "nation": "中国",
            "province": "北京市",
            "city": "北京市",
            "district": "大兴区"
        },
        "address_reference": {
            "street_number": {
                "id": "",
                "title": "",
                "location": {
                    "lat": 39.789009,
                    "lng": 116.467209
                },
                "_distance": 12.2,
                "_dir_desc": "西"
            },
            "town": {
                "id": "110115006",
                "title": "旧宫镇",
                "location": {
                    "lat": 39.789021,
                    "lng": 116.467003
                },
                "_distance": 0,
                "_dir_desc": "内"
            },
            "street": {
                "id": "8825115874817051678",
                "title": "公园南环路",
                "location": {
                    "lat": 39.789009,
                    "lng": 116.467209
                },
                "_distance": 12.2,
                "_dir_desc": "西"
            },
            "landmark_l2": {
                "id": "5541441421062126531",
                "title": "公园北环路与公园南环路交叉口",
                "location": {
                    "lat": 39.788189,
                    "lng": 116.467133
                },
                "_distance": 93.2,
                "_dir_desc": "北"
            }
        }
    }
}]]
function CoordinateToPOICallBack(obj)
    GameLog.Log("CoordinateToPOICallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    if code==0 then
        local coordinate=Vector2(jsonData["result"]["location"]["lat"],jsonData["result"]["location"]["lng"])
        local address =jsonData["result"]["address"]
        local ad_info =jsonData["result"]["ad_info"]
        local info ={}
        info.address = address
        info.nationcode = ad_info["nation_code"]
        info.adcode = ad_info["adcode"]
        info.citycode = ad_info["city_code"]
        info.coordinate=coordinate
        info.recommendAddress=jsonData["result"]["formatted_addresses"]["recommend"]
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_COORDINATETOPOI,info);
        if mCoordinateToPOICallBack then
            mCoordinateToPOICallBack(info)
            mCoordinateToPOICallBack= nil
        end
    end
end

--地区 关键词获取地域信息
function GetPOIByKey(region, keyword)
    SDKGlobalMap.Instance:GetPOIByKey(region, keyword)
end
--获取地域信息的回调
--[[{
    "status": 0,
    "message": "query ok",
    "count": 10,
    "data": [
        {
            "id": "16690702538416700738",
            "title": "北京石景山游乐园",
            "address": "北京市石景山区石景山路25号",
            "category": "娱乐休闲:户外活动:游乐场",
            "type": 0,
            "location": {
                "lat": 39.9122,
                "lng": 116.20856
            },
            "adcode": 110107,
            "province": "北京市",
            "city": "北京市",
            "district": "石景山区"
        },]]
function GetPOIByKeyCallBack(obj)
    GameLog.Log("GetPOIByKeyCallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    local info={}
    if code==0 then
        local citys = jsonData["data"]
        for i=1,#citys do
            local infoItem ={}
            local city = citys[i]
            local coordinate=Vector2(city["location"]["lat"],city["location"]["lng"])
            info.address = address
            info.adcode = jsonData["data"]["adcode"]
            info.coordinate=coordinate
            info.title=title
        end
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_POIBYKEY,info);
    end
end

--获取中国地域信息
function GetDistrictInChina()
    SDKGlobalMap.Instance:GetDistrictInChina()
end
--获取中国地域信息的回调
--[[ {
    "status": 0,
    "message": "query ok",
    "data_version": "20180719",
    "result": [
        [
            {
                "id": "110000",
                "name": "北京",
                "fullname": "北京市",
                "pinyin": [
                    "bei",
                    "jing"
                ],
                "location": {
                    "lat": 39.90469,
                    "lng": 116.40717
                },
                "cidx": [
                    0,
                    15
                ]
            },
            {
                "id": "120000",
                "name": "天津",
                "fullname": "天津市",
                "pinyin": [
                    "tian",
                    "jin"
                ],
                "location": {
                    "lat": 39.0851,
                    "lng": 117.19937
                },
                "cidx": [
                    16,
                    31
                ]
            },]]
function GetDistrictInChinaCallBack(obj)
    GameLog.Log("GetDistrictInChinaCallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    local info={}
    if code==0 then
        local citys = jsonData["result"]
        for i=1,#citys do
            local areas = {}
            for j=1,#citys[i] do
                local infoItem ={}
                local area = citys[i][j]
                local coordinate=Vector2(area["location"]["lat"],area["location"]["lng"])
                infoItem.fullname =area["fullname"]
                infoItem.adcode = area["id"]
                infoItem.coordinate=coordinate
                infoItem.name=area["name"]
                areas[j]=infoItem
            end
            info[i]=areas
        end
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_DISTRICTINCHINA,info);
    end
end

--根据地区编码获取子集地域

function GetChildrenDistrict(id)
    SDKGlobalMap.Instance:GetChildrenDistrict(id)
end
--根据地区编码获取子集地域的回调
--[[--[[{
    "status": 0,
    "message": "query ok",
    "data_version": "20180719",
    "result": [
        [
            {
                "id": "120101",
                "name": "和平",
                "fullname": "和平区",
                "pinyin": [
                    "he",
                    "ping"
                ],
                "location": {
                    "lat": 39.11712,
                    "lng": 117.2147
                }
            },
        ]
        ]
        ]]
function GetChildrenDistrictCallBack(obj)
    GameLog.Log("GetChildrenDistrictCallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    local info={}
    if code==0 then
        local citys = jsonData["result"]
        for i=1,#citys do
            local areas = {}
            for j=1,#citys[i] do
                local infoItem ={}
                local area = citys[i][j]
                local coordinate=Vector2(area["location"]["lat"],area["location"]["lng"])
                infoItem.fullname =area["fullname"]
                infoItem.adcode = area["id"]
                infoItem.coordinate=coordinate
                infoItem.name=area["name"]
                areas[j]=infoItem
            end
            info[i]=areas
        end
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_CHILDRENDISTRICTIN,info);
    end
end

--关键词查询地区信息
function GetDistrictByKeyword(key)
    SDKGlobalMap.Instance:GetDistrictByKeyword(key)
end
--关键词查询地区信息的回调
--[[ {
    "status": 0,
    "message": "query ok",
    "data_version": "20180719",
    "result": [
        [
            {
                "id": "120000",
                "name": "天津",
                "fullname": "天津市",
                "pinyin": [
                    "tian",
                    "jin"
                ],
                "level": 1,
                "location": {
                    "lat": 39.0851,
                    "lng": 117.19937
                },
                "address": "天津"
            },
            {
                "id": "120113402",
                "fullname": "天津医药医疗器械工业园",
                "level": 4,
                "location": {
                    "lat": 39.2244,
                    "lng": 117.02866
                },
                "address": "天津,天津医药医疗器械工业园"
            },]]
function GetDistrictByKeywordCallBack(obj)
    GameLog.Log("GetDistrictByKeywordCallBack:----->>>%s", tostring(obj))
    local flag,jsonData = xpcall(JSON.decode,traceback,obj);
    local code = flag and jsonData["status"];
    local info={}
    if code==0 then
        local citys = jsonData["result"]
        for i=1,#citys do
            local areas = {}
            for j=1,#areas do
                local infoItem ={}
                local area = areas[j]
                local coordinate=Vector2(area["location"]["lat"],area["location"]["lng"])
                infoItem.fullname =area["fullname"]
                infoItem.adcode = area["id"]
                infoItem.address =area["address"]
                infoItem.level =area["level"]
                infoItem.coordinate=coordinate
                infoItem.name=area["name"]
                areas[j]=infoItem
            end
            info[i]=areas
        end
        MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_DISTRICTBYWORD,info);
    end
end
