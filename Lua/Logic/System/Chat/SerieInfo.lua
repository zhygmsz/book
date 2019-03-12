--自定义表情系列信息

local SerieInfo = class("SerieInfo")
function SerieInfo:ctor()
    self._playerId = nil
    self._serieId = nil
    self._serieType = nil
    self._name = nil
    self._des = nil
    self._hot = nil
    self._addTime = nil
    self._updateTime = nil
end

function SerieInfo:Init(playerId, serieId, serieType, name, des, 
                        hot, addTime, updateTime)
    --
    self._playerId = playerId
    self._serieId = serieId
    self._serieType = serieType
    self._name = name
    self._des = des
    self._hot = hot
    self._addTime = addTime
    self._updateTime = updateTime
end

return SerieInfo