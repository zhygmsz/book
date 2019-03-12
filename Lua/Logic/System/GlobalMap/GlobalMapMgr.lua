--地图管理
module("GlobalMapMgr",package.seeall);
local SDKGlobalMap = cyou.ldj.sdk.SDKGlobalMap
local JSON = require "cjson"

--玩家的位置信息
selfLocationInfo=nil
--玩家的位置坐标
selfCoordinate = Vector2(39.9107608145,116.2066733837)
--玩家位置
selfAddress ="北京市石景山区"

--个人地址信息 local info ={}
--info.address
--info.adcode
--info.nationcode 
--info.adcode
--info.citycode
--info.coordinate
--info.recommendAddress
selfAddressInfo = nil

MapZoomLevel=11

--初始化
function InitModule()
    require("Logic/System/GlobalMap/GlobalMapMgr_Locate")
    SDKGlobalMap.Instance:Init()
    InitLocationServer("YSIBZ-4R6CU-HN7VT-2MKUR-X6BLO-DGBZZ");
end

function InitPlatformMapServer(key)
end

function Init()
    SDKGlobalMap.Instance:Init()
end

function OpenMap()
    SDKGlobalMap.Instance:OpenMap()
end

function CloseMap()
    SDKGlobalMap.Instance:CloseMap()
end

function GetZoomLevel()
   return SDKGlobalMap.Instance:GetZoomLevel()
end

function MoveOffset( x,y )
    SDKGlobalMap.Instance:MoveOffset(x,y)
end

function SetCoordinate( coordinate )
    SDKGlobalMap.Instance:SetCoordinate(coordinate)
end

function DidRender()
    SDKGlobalMap.Instance:DidRender()
end

function ZoomTo(level)
    SDKGlobalMap.Instance:ZoomTo(level)
end

function SetZoomLevel(level)
    SDKGlobalMap.Instance:SetZoomLevel(level)
end

--对地图上的点进行分组 precision单位km
function MapShowDataGrouping(datatable,precision)
    local grouptable={}
    local groupindex = 1
    if datatable then
        local count =  table.getn(datatable)
        table.sort(datatable, function(a,b)
            return a.Coordinate.x<b.Coordinate.x
        end)
        local xgrouptable={}
        local index = 1
        for i=1,count-1 do
            local data1 = datatable[i]
            local data2 = datatable[i+1]
            if xgrouptable[index]==nil then 
                xgrouptable[index]={} 
                table.insert(xgrouptable[index],data1)
            end
            local coordinate1 = Vector2(data1.Coordinate.x,0)
            local coordinate2 = Vector2(data2.Coordinate.x,0)
            local dis =CaculateDiatance(coordinate1,coordinate2)
            if dis<precision then
                table.insert(xgrouptable[index],data2)
            else
                index=index+1
                if xgrouptable[index]==nil then 
                    xgrouptable[index]={} 
                end
                table.insert(xgrouptable[index],data2)
            end
        end
        local groupcount = table.getn(xgrouptable)
        for i=1,groupcount do
            local temp=xgrouptable[i]
            table.sort(temp, function(a,b)
                return a.Coordinate.y<b.Coordinate.y
            end)
            local county=table.getn(temp)
            if county>1 then
                for j=1,county-1 do
                    local data1 = temp[j]
                    local data2 = temp[j+1]
                    if grouptable[groupindex]==nil then 
                        grouptable[groupindex]={} 
                        table.insert(grouptable[groupindex],data1)
                    end
                    local averagex=0.5*(data1.Coordinate.x+data1.Coordinate.x)
                    local coordinate1 = Vector2(averagex,data1.Coordinate.y)
                    local coordinate2 = Vector2(averagex,data2.Coordinate.y)
                    local dis =CaculateDiatance(coordinate1,coordinate2)
                    if dis<precision then
                        table.insert(grouptable[groupindex],data2)
                    else
                        groupindex=groupindex+1
                        if grouptable[groupindex]==nil then 
                            grouptable[groupindex]={} 
                        end
                        table.insert(grouptable[groupindex],data2)
                    end
                end
            elseif county==1 then
                if grouptable[groupindex]==nil then 
                    grouptable[groupindex]={} 
                    table.insert(grouptable[groupindex],temp[1])
                end
                groupindex=groupindex+1
            end
        end
    end
    return grouptable
end

function GetPixelSizeAdjustment()
    local uiRoot = UIMgr.GetUIRoot()
    local pixelSizeAdjustment = uiRoot.pixelSizeAdjustment
    return pixelSizeAdjustment
end

function GetAdjustedScreenSize()
    local uiRoot = UIMgr.GetUIRoot()
    local pixelSizeAdjustment = uiRoot.pixelSizeAdjustment
    local w=SystemInfo:ScreenWidth()*pixelSizeAdjustment
    local h=SystemInfo:ScreenHeight()*pixelSizeAdjustment
    return {width=w,height=h}
end

function GetScreenSize()
    local uiRoot = UIMgr.GetUIRoot()
    local w=SystemInfo:ScreenWidth()
    local h=SystemInfo:ScreenHeight()
    return {width=w,height=h}
end

--设置地图弹出框的位置
function MapTipArchorPosition(BgObj,BgWidth,BgHeight,Coordinate)
    SetCoordinateToUIPosition(BgObj,Coordinate.x,Coordinate.y)
    local pos = BgObj.transform.localPosition
    local size=GetAdjustedScreenSize()
    local width=size.width
    local height=size.height
    local y=pos.y+BgHeight/2
    if pos.y+BgHeight >=height/2 then
        y=pos.y-BgHeight/2
    end
    local x=pos.x+BgWidth/2
    if pos.x+BgWidth >=width/2 then
        x=pos.x-BgWidth/2
    end
    BgObj.transform.localPosition = Vector3(x,y,0)
end

--打开地图UI
function  ShowMapUI()
    GlobalMapMgr.OpenMap()
end

--经纬度转换为UI坐标
function SetCoordinateToUIPosition(obj,coordinatex,coordinatey)
    local outvec=SDKGlobalMap.Instance:ConvertCoordinateToOtherCameraWorlPoint(UIMgr.GetCamera(),coordinatex,coordinatey)
    obj.transform.position = Vector3(outvec.x,outvec.y,0)
    local pos = obj.transform.localPosition
    obj.transform.localPosition = Vector3(pos.x,pos.y,0)
end

--UI坐标转换为经纬度
function UIPositionToCoordinate(obj)
    local size=GetScreenSize()
    local width=size.width
    local height=size.height
    local screenx= obj.transform.localPosition.x+width/2
    local screeny= obj.transform.localPosition.y+height/2
    local outvec=SDKGlobalMap.Instance:ConvertCameraScreenToCoordinate(screenx,screeny)
    return outvec
end

--计算两个坐标的距离
function CaculateDiatance(coordinate1,coordinate2)
   return SDKGlobalMap.Instance:GetDistance(coordinate1.x,coordinate1.y,coordinate2.x,coordinate2.y)
end

--选址
function ChangeLocation()
    GlobalMapMgr.OpenMap()
end

--地图缩放完毕
function ZoomEndTo( endLevel )
    MapZoomLevel=endLevel
    MessageSub.SendMessage(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_ZOOMENDTO,endLevel);
end


return GlobalMapMgr