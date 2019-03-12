module("CharacterTagData",package.seeall)

DATA.CharacterTagData.mTags = nil;
DATA.CharacterTagData.mTypedTags = nil;


local function OnLoadTags(data)
    local datas = CharacterTag_pb.AllCharacterTags();
    datas:ParseFromString(data);

    local tags = {};
    local typedtags = {};

    for i,v in ipairs(datas.tags) do
        if typedtags[v.tagtype] ==nil then
            typedtags[v.tagtype]=  {}
        end
        local item = {index = 1,id = v.id,tagtype=v.tagtype,value= v.value}
        table.insert(typedtags[v.tagtype],item)
        item.index = table.count(typedtags[v.tagtype])
        tags[v.id] = item
    end

    DATA.CharacterTagData.mTags = tags;
    DATA.CharacterTagData.mTypedTags = typedtags;
end

function InitModule()
	local argData1 = 
	{
		keys = { mTags = true, mTypedTags=true },
		fileName = "CharacterTag.bytes",
		callBack = OnLoadTags,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.CharacterTagData,argData1);
end

--获取一个标签对象
function GetCharacterTag(id)
    return DATA.CharacterTagData.mTags[id];
end

--获取某一类的标签列表
function GetCharacterTagList(tagtype)
    return DATA.CharacterTagData.mTypedTags[tagtype];
end

--获取标签文字
function GetCharacterTagString(id)
    return DATA.CharacterTagData.mTags[id].value;
end

return CharacterTagData;
