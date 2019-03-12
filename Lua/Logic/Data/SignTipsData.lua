module("SignTipsData",package.seeall)

DATA.SignTipsData.mTips = nil;

local function OnLoadTipsData(data)
    local datas = SignTips_pb.AllSignTips()
    datas:ParseFromString(data)

    local signTipDatas = {};

    for k,v in ipairs(datas.tips) do
        signTipDatas[v.id] = v
    end

    DATA.SignTipsData.mTips = signTipDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mTips = true },
		fileName = "SignTips.bytes",
		callBack = OnLoadTipsData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.SignTipsData,argData1);
end

function GetTipsDataById(id)
    return DATA.SignTipsData.mTips[id];
end

return SignTipsData;