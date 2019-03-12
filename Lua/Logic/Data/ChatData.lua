module("ChatData", package.seeall)

DATA.ChatData.mSysEmojiDataDic = nil
DATA.ChatData.mSysEmojiDataList = nil

local function OnLoaded(data)
    if not data then
        return
    end
    local pb = Chat_pb.AllChatSysEmojiData()
    pb:ParseFromString(data)

    local sysEmojiDataDic = {}
    for _, v in ipairs(pb.datas) do
        sysEmojiDataDic[v.id] = v
    end

    DATA.ChatData.mSysEmojiDataDic = sysEmojiDataDic
    DATA.ChatData.mSysEmojiDataList = pb.datas
end

function InitModule()
    local argData1 = 
	{
        keys = { mSysEmojiDataDic = true, mSysEmojiDataList = true },
		fileName = "ChatSysEmojiData.bytes",
		callBack = OnLoaded,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ChatData,argData1)
end

function GetSysEmojiDic()
    return DATA.ChatData.mSysEmojiDataDic
end

function GetSysEmojiList()
    return DATA.ChatData.mSysEmojiDataList
end

return ChatData