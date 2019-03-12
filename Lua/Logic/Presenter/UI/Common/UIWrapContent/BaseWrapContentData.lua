--通用UIWrapContent数据文件，只记录数据id和UIEvent.id,即将弃用

BaseWrapContentData = class("BaseWrapContentData");

function BaseWrapContentData:ctor( id, baseEventId,callbackList,param)
    self._id = id;
    self._callBacks = callbackList;
    self._eventIDs = {};
    for i = 1, #callbackList do
        self._eventIDs[i] = baseEventId + i - 1;
    end
    self._param = param;
    self._wrapUI = nil;
end

function BaseWrapContentData:RegisterUI(wrapUI)
    self._wrapUI = wrapUI;
end

function BaseWrapContentData:GetID()
    return self._id;
end

--按钮event.id对应了回调index
function BaseWrapContentData:GetEventId(index)
    return self._eventIDs[index];
end


function BaseWrapContentData:OnClick(index)
    if self._callBacks[index] then
        if self._param then
            self._callBacks[index](self._param,self._id,self._wrapUI);
        else
            self._callBacks[index](self._id,self._wrapUI);
        end
    end
end

return BaseWrapContentData;