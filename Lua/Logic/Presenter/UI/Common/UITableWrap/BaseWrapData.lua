BaseWrapData = class("BaseWrapData",nil);

function BaseWrapData:ctor(id,type,context)
    self._id = id;
    self._type = type;
    self._context = context;
end

function BaseWrapData:OnClick(id)
    GameLog.Log("No Click Handler for %s-id %s",self._type,self._id);
end

function BaseWrapData:GetType()
    return self._type or self.__cname;
end

function BaseWrapData:GetID()
    return self._id;
end

function BaseWrapData:GetEventID()
    return self._eventID;
end

function BaseWrapData:GetContent()
    return self._content;
end

return BaseWrapData;