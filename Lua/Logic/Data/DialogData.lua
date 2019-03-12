module("DialogData", package.seeall);

DATA.DialogData.mGroupDatas = nil;
DATA.DialogData.mDialogDatas = nil;

DATA.DialogData.mRacialEmojiPicData = nil;

local function OnLoadDialogData(data)
	local datas = Dialog_pb.AllDialogDatas();
	datas:ParseFromString(data);

	local groupDatas = {};
	local dialogDatas = {};

	for k,v in ipairs(datas.datas) do
		groupDatas[v.dialogID] = groupDatas[v.dialogID] or {};
		table.insert(groupDatas[v.dialogID],v);

		dialogDatas[v.id] = v;
	end

	DATA.DialogData.mGroupDatas = groupDatas;
	DATA.DialogData.mDialogDatas = dialogDatas;
end

local function OnLoadRacialEmojiPicData(data)
	local datas = Dialog_pb.AllRacialEmojiPicDatas();
	datas:ParseFromString(data);

	local racialEmojiPicData = {}
	for k, v in ipairs(datas.datas) do
		if not racialEmojiPicData[v.racial] then
			racialEmojiPicData[v.racial] = {}
		end
		racialEmojiPicData[v.racial][v.emojiType] = v.resId
	end

	DATA.DialogData.mRacialEmojiPicData = racialEmojiPicData;
end

function InitModule()
	local argData1 = 
	{
		keys = { mGroupDatas = true, mDialogDatas = true },
		fileName = "DialogData.bytes",
		callBack = OnLoadDialogData,
	}
	local argData2 = 
	{
		keys = { mRacialEmojiPicData = true },
		fileName = "RacialEmojiPicData.bytes",
		callBack = OnLoadRacialEmojiPicData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.DialogData,argData1,argData2);
end

function GetDialogGroupDataByID(id)
	local dialogData = DATA.DialogData.mDialogDatas[id];
	local groupID = dialogData and dialogData.dialogID;
	return groupID and DATA.DialogData.mGroupDatas[groupID];
end

function GetDialogGroupDataByGroupID(groupID)
	return groupID and DATA.DialogData.mGroupDatas[groupID];
end

function GetRacialEmojiPicData(racial, emojiType)
	if racial and emojiType then
		return DATA.DialogData.mRacialEmojiPicData[racial][emojiType]
	end
end

return DialogData;
