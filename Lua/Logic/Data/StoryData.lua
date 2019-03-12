module("StoryData",package.seeall)

DATA.StoryData.mStoryDataByID = nil;

function OnLoadStoryData(data)
	local datas = Story_pb.AllStoryData()
	datas:ParseFromString(data)
	
	local storyDataByID = {};
	local storyDataByName = {};

	for _,v in ipairs(datas.datas) do
		storyDataByID[v.id] = v;
	end

	DATA.StoryData.mStoryDataByID = storyDataByID;
end

function InitModule()
	local argData1 = 
	{
		keys = { mStoryDataByID = true},
		fileName = "Story.bytes",
		callBack = OnLoadStoryData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.StoryData,argData1);
end

function GetStoryDataByID(id)
	return DATA.StoryData.mStoryDataByID[id];
end

return StoryData;
