--自定义表情信息

local EmojiInfo = class("EmojiInfo")
function EmojiInfo:ctor()
    --http接口内数据
    self._picId = ""
    self._pkgId = 0
    self._playerId = 0
    self._emojiType = 0
    self._url = ""
    self._name = ""
    self._status = 0
    self._hot = 0
    self._love = 0
    self._share = 0
    self._collect = 0
    self._addTime = 0
    self._updateTime = 0

    --额外的逻辑数据
    self._isAdd = false
    --LoadImage方法内返回的本地路径
    self._localPath = ""

    --用于表情系列上传过程中，失败标识
    self._failed = false
    --用于表情系列上传过程中，新添加的来自于本地还是已收藏
    self._fromLocalOrCollect = 1
end

function EmojiInfo:InitByJson(json)
    self._picId = json.pic_id
    self._pkgId = json.serie_id
    self._playerId = json.player_id
    self._emojiType = json.type
    self._url = json.path
    self._name = json.name
    self._status = json.status
    self._hot = json.hot
    self._love = json.love
    self._share = json.share
    self._collect = json.collect
    self._addTime = json.addtime
    self._updateTime = json.updatetime
end

function EmojiInfo:InitByPicId(picId, url, name, playerId)
    self._picId = picId
    self._url = url
    self._name = name
    self._playerId = playerId
end

function EmojiInfo:InitStatus(status)
    self._status = status
end

function EmojiInfo:GetStatus()
    return self._status
end

function EmojiInfo:SetAdd(isAdd)
    self._isAdd = isAdd
end

function EmojiInfo:CheckIsAdd()
    return self._isAdd
end

function EmojiInfo:SetPicId(picId)
    self._picId = picId
end

function EmojiInfo:GetPicId()
    return self._picId
end

function EmojiInfo:SetUrl(url)
    self._url = url
end

function EmojiInfo:GetUrl()
    return self._url
end

function EmojiInfo:GetName()
    return self._name
end

function EmojiInfo:GetPlayerId()
    return self._playerId
end

function EmojiInfo:SetPkgId(pkgId)
    self._pkgId = pkgId
end

function EmojiInfo:GetPkgId()
    return self._pkgId
end

function EmojiInfo:SetLocalPath(localPath)
    self._localPath = localPath
end

function EmojiInfo:GetLocalPath()
    return self._localPath
end

function EmojiInfo:SetFailed(failed)
    self._failed = failed
end

function EmojiInfo:GetFailed()
    return self._failed
end

function EmojiInfo:SetLocalOrCollect(localOrCollect)
    self._fromLocalOrCollect = localOrCollect
end

function EmojiInfo:GetLocalOrCollect()
    return self._fromLocalOrCollect
end

return EmojiInfo