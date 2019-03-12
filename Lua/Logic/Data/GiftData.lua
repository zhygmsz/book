module("GiftData",package.seeall);

DATA.GiftData.mAllItems = nil;

local function OnLoadAllGifts(data)
	local datas = Gift_pb.AllIGiftItems();
	datas:ParseFromString(data);
	DATA.GiftData.mAllItems = datas.giftinfos;
end 
local function OnLoadAllGiftCovers(data)
	local datas = Gift_pb.AllIGiftCovers();
	datas:ParseFromString(data);
	DATA.GiftData.mAllGiftCovers = datas.covers;
end 

function InitModule()
	local argData1 = 
	{
		keys = { mAllItems = true },
		fileName = "GiftItem.bytes",
		callBack = OnLoadAllGifts,
    }
	local argData2 = 
	{
		keys = { mAllGiftCovers = true },
		fileName = "GiftCover.bytes",
		callBack = OnLoadAllGiftCovers,
    }
	DATA.CREATE_LOAD_TRIGGER(DATA.GiftData, argData1);
end

function GetAllGifts()  
    return DATA.GiftData.mAllItems;
end 

return GiftData;