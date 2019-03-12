module("BulletData",package.seeall);

DATA.BulletData.mBulletDatasByID = nil;
DATA.BulletData.mBulletDatasByName = nil;
 
local function OnLoadBulletData(data)
    local datas = BulletData_pb.AllBulletData()
    datas:ParseFromString(data)

    local bulletDatasByID = {};
    local bulletDatasByName = {};

    for _,v in ipairs(datas.datas) do
        bulletDatasByID[v.bulletID] = v;
        bulletDatasByName[v.bulletName] = v;
    end

    DATA.BulletData.mBulletDatasByID = bulletDatasByID;
    DATA.BulletData.mBulletDatasByName = bulletDatasByName;
end

function InitModule()
	local argData1 = 
	{
		keys = { mBulletDatasByID = true, mBulletDatasByName = true },
		fileName = "BulletData.bytes",
		callBack = OnLoadBulletData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.BulletData,argData1);
end

function GetBulletDataByID(bulletID)
    return DATA.BulletData.mBulletDatasByID[bulletID];
end

function GetBulletDataByName(bulletName)
    return DATA.BulletData.mBulletDatasByName[bulletName];
end

return BulletData;
