module("AudioConfigData",package.seeall)

DATA.AudioConfigData.mAudioData = nil;
DATA.AudioConfigData.mBankData = nil;

local function OnLoadAudioConfig(data)
    local datas = Audio_pb.AllAudios()
    datas:ParseFromString(data)

    local audioDatas = {};

    for k,v in ipairs(datas.audios) do
        audioDatas[v.id] = v
    end
    
    DATA.AudioConfigData.mAudioData = audioDatas;
end

local function OnLoadBank(data)
    local datas = Audio_pb.AllBanks()
    datas:ParseFromString(data)
    
    local audioDatas = {};

    for k,v in ipairs(datas.banks) do
        audioDatas[v.id] = v;
    end

    DATA.AudioConfigData.mBankData = audioDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAudioData = true },
		fileName = "AudioDetail.bytes",
		callBack = OnLoadAudioConfig,
	}
	local argData2 = 
	{
		keys = { mBankData = true },
		fileName = "AudioBank.bytes",
		callBack = OnLoadBank,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AudioConfigData,argData1,argData2);
end

function GetAudio(id)
    return DATA.AudioConfigData.mAudioData[id]
end

function GetBankInfo(bankid)
    return DATA.AudioConfigData.mBankData[bankid];
end

return AudioConfigData
