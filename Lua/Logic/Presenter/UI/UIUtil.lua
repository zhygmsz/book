module("UIUtil",package.seeall);

local mIconCache = {}

local mTextureLoaderCache = {}

local mImageCallBackData = {};
local mImageCallBack = nil;

--图片下载本地目录
mDownloadPicLocalPath = "Caches/Images/download"
--语音文件下载本地目录
mDownloadVoiceLocalPath = "Caches/Voices/download"


--物品通用的品质颜色
local mWhiteColor = Color(1, 1, 1, 1)
local mWhiteColorStr = "[ffffff]"
local mGreenColor = Color(107 / 255, 197 / 255, 71 / 255, 1)
local mGreenColorStr = "[6bc547]"
local mBlueColor = Color(122 / 255, 216 / 255, 244 / 255, 1)
local mBlueColorStr = "[7ad8f4]"
local mPurpleColor = Color(220 / 255, 141 / 255, 255 / 255, 1)
local mPurpleColorStr = "[dc8dff]"
local mOrangeColor = Color(255 / 255, 179 / 255, 81 / 255, 1)
local mOrangeColorStr = "[ffb351]"

function LoadItemIcon(itemIcon,itemData)
    if itemData then
        local iconName =  itemData.icon_big;
        LoadIcon(itemIcon,iconName); 
    else
        LoadIcon(itemIcon,""); 
    end
end

--传入资源名称或资源ID 获取资源ID
function GetResID(loadResId)
    local loadResID = loadResId
    if loadResID==nil then return nil end
    local t = type(loadResID);
    if t == "number" then
     -- 是数字
    elseif t == "string" then
     -- 是字符串
        loadResID = ResConfigData.GetResConfigID(loadResId)
    end
    return loadResID
end

--设置texture
function SetTexture(loadResId,uitexture)
    local loadResID = GetResID(loadResId)
    if loadResID==nil then return end
    local function OnLoadTexture(loader)
        local tex = loader:GetObject()
        mTextureLoaderCache[loadResID].texture = tex
        for i,v in ipairs(mTextureLoaderCache[loadResID].uitextures) do
            v.mainTexture = tex
        end
        mTextureLoaderCache[loadResID].uitextures = {}
    end
    if mTextureLoaderCache[loadResID] == nil then
        mTextureLoaderCache[loadResID]= {}
        mTextureLoaderCache[loadResID].loader = LoaderMgr.CreateTextureLoader();
        mTextureLoaderCache[loadResID].uitextures = {}
        mTextureLoaderCache[loadResID].texture = nil
        mTextureLoaderCache[loadResID].loader:LoadObject(loadResID,OnLoadTexture);
    end
    if not table.contains_value(mTextureLoaderCache[loadResID].uitextures,uitexture) then
        table.insert(mTextureLoaderCache[loadResID].uitextures,uitexture)
    end
    if mTextureLoaderCache[loadResID].texture==nil then
       
    else
        uitexture.mainTexture = mTextureLoaderCache[loadResID].texture
    end
end

--移除文件
function ReleaseTexture(loadResId)
    local loadResID = GetResID(loadResId)
    if loadResID==nil then return end
    if mTextureLoaderCache[loadResID] ~= nil and mTextureLoaderCache[loadResID].loader ~= nil  then
        LoaderMgr.DeleteLoader(mTextureLoaderCache[loadResID].loader)
        mTextureLoaderCache[loadResID].uitextures = nil
        mTextureLoaderCache[loadResID].texture = nil
        mTextureLoaderCache[loadResID] = nil
    end
end

--清空texture缓存
function CleanTextureCache()
    for k,v in pairs(mTextureLoaderCache) do
        if v.loader then LoaderMgr.DeleteLoader(v.loader) end
        v.uitextures = nil
        v.texture = nil
    end
    mTextureLoaderCache={}
end

function LoadIcon(itemIcon,iconName,onLoaded)
    if iconName and iconName ~= "" then
        local iconCached = mIconCache[iconName];
        if not tolua.isnull(iconCached) then
            itemIcon.mainTexture = iconCached;
            if onLoaded then onLoaded(); end
        else
            local function OnLoadIcon(icon)
                mIconCache[iconName] = icon;
                itemIcon.mainTexture = icon;
                if onLoaded then onLoaded(); end
            end  
            --TODO 资源加载 
        end
    else
        itemIcon.mainTexture = nil;
    end
end

function LoadImage(itemIcon,iconSize,iconPath,isURL,callback, obj)
    if iconPath and iconPath ~= "" then
        local iconKey = string.format("%s_%s_%s_%s",iconPath,iconSize.compressRatio,iconSize.width,iconSize.height);
        local iconCached = mIconCache[iconKey];
        if not tolua.isnull(iconCached) then
            itemIcon.mainTexture = iconCached;
            GameUtils.TryInvokeCallback(callback, obj);
        else
            local function OnLoadFinish(path,icon)
                local callBackData = mImageCallBackData[path];
                mImageCallBackData[path] = nil;
                mIconCache[callBackData.iconKey] = icon;
                for i = 1,#callBackData.icons do       
                    callBackData.icons[i].mainTexture = icon;
                    GameUtils.TryInvokeCallback(callBackData.callback, callBackData.obj);
                end
            end
            local function OnClipFinish(srcPath,dstPath)
                local fullPath = string.format("%s/%s",UnityEngine.Application.persistentDataPath,dstPath);
                local callData = mImageCallBackData[fullPath] or {};
                mImageCallBackData[fullPath] = callData;
                callData.iconKey = iconKey;
                callData.callback = callback
                callData.obj = obj
                callData.icons = callData.icons or {};
                table.insert(callData.icons,itemIcon);
                if #callData.icons == 1 then
                    GameBase.ImageLoader.GetInstance():LoadImageAsync(fullPath,mImageCallBack);
                end
            end  
            local function OnDownLoad(localPath,remotePath,successFlag)
                if successFlag then 
                    PhotoMgr.MakeClipImage(localPath,iconSize.compressRatio,iconSize.width,iconSize.height,OnClipFinish)
                else
                    itemIcon.mainTexture = nil;
                end
            end
            if not mImageCallBack then mImageCallBack = GameBase.ImageLoader.OnLoadTexture(OnLoadFinish); end
            if isURL then
                CosMgr.DownloadFile(iconPath,mDownloadPicLocalPath,OnDownLoad);
            else
                PhotoMgr.MakeClipImage(iconPath,iconSize.compressRatio,iconSize.width,iconSize.height,OnClipFinish)
            end
        end
    else
        itemIcon.mainTexture = nil;
    end
end

function UnLoadIcon()

end

--品质框名称
function GetItemQualityBgSpName(quality)
    if quality == Item_pb.ItemInfo.WHITE then
        return "frame_common_bai"
    elseif quality == Item_pb.ItemInfo.GREEN then
        return "frame_common_lv"
    elseif quality == Item_pb.ItemInfo.BLUE then
        return "frame_common_lan"
    elseif quality == Item_pb.ItemInfo.PURPLE then
        return "frame_common_zi"
    elseif quality == Item_pb.ItemInfo.ORANGE then
        return "frame_common_cheng"
    end
    return "frame_common_bai"
end

--返回品质对应的文字颜色
function GetItemQualityColorStr(quality)
    if quality == Item_pb.ItemInfo.WHITE then
        return mWhiteColorStr
    elseif quality == Item_pb.ItemInfo.GREEN then
        return mGreenColorStr
    elseif quality == Item_pb.ItemInfo.BLUE then
        return mBlueColorStr
    elseif quality == Item_pb.ItemInfo.PURPLE then
        return mPurpleColorStr
    elseif quality == Item_pb.ItemInfo.ORANGE then
        return mOrangeColorStr
    end
    return mWhiteColorStr
end

function GetItemQualityColor(quality)
    if quality == Item_pb.ItemInfo.WHITE then
        return mWhiteColor
    elseif quality == Item_pb.ItemInfo.GREEN then
        return mGreenColor
    elseif quality == Item_pb.ItemInfo.BLUE then
        return mBlueColor
    elseif quality == Item_pb.ItemInfo.PURPLE then
        return mPurpleColor
    elseif quality == Item_pb.ItemInfo.ORANGE then
        return mOrangeColor
    end
    return mWhiteColor
end

--[[
    @desc: 根据货币类型获取其对应的spriteName
    --@coinType: 详见Coin.proto的CoinType
]]
function GetCoinSpName(coinType)
    local spName = ""

    repeat
        if not coinType then
            break
        end
        if coinType == 1 then
            spName = "icon_common_huobo02"
        elseif coinType == 2 then
            spName = "icon_common_huobo01"
        elseif coinType == 3 then
            spName = "icon_common_huobo03"
        end
    until true

    return spName
end

--复制
function Duplicate(ui,prefab,parent,count,OnItemCreat)
    local itemList = {};
    itemList[1] = {};
    itemList[1].transform = prefab;
    local parentTrans = parent or prefab.parent;
    for i=2,count do
        itemList[i]= {};
        itemList[i].transform = ui:DuplicateAndAdd(prefab,parentTrans,i);
        itemList[i].transform.name = string.format("clone %s",i);
    end
    for i=1,count do
        local contentItem = itemList[i];
        contentItem.gameObject = contentItem.transform.gameObject;
        contentItem.widget = contentItem.transform:GetComponent("UIWidget");
        OnItemCreat(contentItem,i);
    end
    return itemList;
end

function AdjustTexByLen(tex, len, isWidth)
    len = len or 100
    if len == 0 then
        return
    end
    local w = tex.mainTexture.width
    local h = tex.mainTexture.height
    local clampW = w
    local clampH = h
    if isWidth then
        clampW = len
        clampH = len * h / w
    else
        clampH = len
        clampW = len * w / h
    end
    clampW = math.floor(clampW)
    clampH = math.floor(clampH)
    tex.width = clampW
    tex.height = clampH
    return clampW, clampH
end

function AdjustInSquare(tex, len, expand)
    local w = tex.mainTexture.width
    local h = tex.mainTexture.height
    if expand then
        return AdjustTexByLen(tex, len, w < h)
    else
        return AdjustTexByLen(tex, len, w >= h)
    end
end

function AdjustInScreen(tex, rate)
    rate = rate or 0.7

    local screenW = 1334--SystemInfo.ScreenWidth()
    local screenH = 750--SystemInfo.ScreenHeight()
    local screenRate = screenW / screenH

    local w = tex.mainTexture.width
    local h = tex.mainTexture.height
    w = (w == 0 and 1 or w)
    h = (h == 0 and 1 or h)
    --pc上表情没有压缩，在这里模拟压缩后的尺寸
    local takeSize = CustomEmojiMgr.GetTakeSize()
    local clampW = takeSize.width
    local clampH = h / w * clampW
    if w < h then
        clampH = takeSize.height
        clampW = w / h * clampH
    end
    w = clampW
    h = clampH
    local texRate = w / h
    
    local clampLen = screenW * rate
    local bigRate = clampLen / w
    bigRate = bigRate > 3 and 3 or bigRate
    local targetW = clampLen
    local targetH = bigRate * h
    if texRate < screenRate then
        clampLen = screenH * rate
        bigRate = clampLen / h
        bigRate = bigRate > 3 and 3 or bigRate
        targetH = clampLen
        targetW = bigRate * w
    end
    targetW = math.floor(targetW)
    targetH = math.floor(targetH)
    tex.width = targetW
    tex.height = targetH
    return targetW, targetH
end