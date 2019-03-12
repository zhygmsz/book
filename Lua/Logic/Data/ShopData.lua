module("ShopData", package.seeall)

--商店类型，一，二级分类字典
DATA.ShopData.mShopDataDic = nil;
--商品总列表
DATA.ShopData.mShopDataList = nil;
--商品表字典
DATA.ShopData.mShopTotalDataDic = nil;

local function OnLoadShopData(data)
    local datas = Shop_pb.ShopGoods();
    datas:ParseFromString(data)

    local shopDataDic = {};
    local shopDataList = datas.goodsinfo
    local shopTotalDataDic = {};

    for _, shopData in ipairs(datas.goodsinfo) do
        shopTotalDataDic[shopData.id] = shopData;

        local shopDatasByShopId = shopDataDic[shopData.shopid];
        if not shopDatasByShopId then 
            shopDatasByShopId = {} 
            shopDataDic[shopData.shopid] = shopDatasByShopId;
        end
        local shopDatasByCategory = shopDatasByShopId[shopData.category];
        if not shopDatasByCategory then
            shopDatasByCategory = {};
            shopDatasByShopId[shopData.category] = shopDatasByCategory;
        end
        local shopDatasBySubCategory = shopDatasByCategory[shopData.subcategory]
        if not shopDatasBySubCategory then
            shopDatasBySubCategory = {}
            shopDatasByCategory[shopData.subcategory] = shopDatasBySubCategory
        end
        table.insert(shopDatasBySubCategory, shopData);
    end

    DATA.ShopData.mShopDataDic = shopDataDic;
    DATA.ShopData.mShopDataList = shopDataList;
    DATA.ShopData.mShopTotalDataDic = shopTotalDataDic;
end

function InitModule()
	local argData1 = 
	{
		keys = { mShopDataDic = true, mShopDataList = true, mShopTotalDataDic = true },
		fileName = "Shop.bytes",
		callBack = OnLoadShopData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ShopData,argData1);
end

function GetDataList(shopId, oneType, twoType)
    if not shopId or not oneType or not twoType then
        return {}
    end
    local shopIdDatas = DATA.ShopData.mShopDataDic[shopId];
    local oneDatas = shopIdDatas and shopIdDatas[oneType]
    return oneDatas and oneDatas[twoType] and oneDatas[twoType] or {}
end

function GetTotalDataList()
    return DATA.ShopData.mShopDataList;
end

function GetDataById(id)
    return DATA.ShopData.mShopTotalDataDic[id]
end

return ShopData