module("ChatMgr", package.seeall)

--[[
    @desc: 请求添加自定义表情
    --@picId:
	--@url:
	--@name: 
    @return:
]]
function RequestAddEmoji(picId, url, name, callback, obj)
    local function OnAdd(jsonData)
        if jsonData and callback then
            if obj then
                callback(obj, picId, url, name)
            else
                callback(picId, url, name)
            end
        end
    end
    
    local arg = {}
    table.insert(arg, "pic_id=" .. picId)
    table.insert(arg, "path=" .. url)
    table.insert(arg, "name=" .. name)
    SocialNetworkMgr.RequestAction("AddEmoticonPicture",arg, OnAdd);

end

function RequestMyAddEmoji(callback, obj)
    local function OnGet(jsonData)
        if jsonData and callback then
            if obj then
                callback(obj)
            else
                callback()
            end
        end
    end
    SocialNetworkMgr.RequestAction("GetEmoticonMyPicture",nil, OnGet);
end

return ChatMgr
