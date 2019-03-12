BTNodeBase = class("BTNodeBase");

function BTNodeBase:ctor()
    self._nodeStatus = BTDefine.NODE_STATUS.INVALID;
end

function BTNodeBase:dtor()
    self._nodeStatus = BTDefine.NODE_STATUS.INVALID;
end

function BTNodeBase:Tick(deltaTime,btData)
    if self._nodeStatus ~= BTDefine.NODE_STATUS.RUNNING then self:OnStart(btData); end
    self._nodeStatus = self:OnUpdate(deltaTime,btData);
    if self._nodeStatus ~= BTDefine.NODE_STATUS.RUNNING then self:OnStop(btData); end
    return self._nodeStatus;
end

function BTNodeBase:OnStart(btData)
end

function BTNodeBase:OnUpdate(deltaTime,btData)
    return BTDefine.NODE_STATUS.FAILURE;
end

function BTNodeBase:OnStop()
end

function BTNodeBase:OnAbort(btData)
    self._nodeStatus = BTDefine.NODE_STATUS.INVALID;
end

function BTNodeBase:OnLog()
    print(string.format("NODE_NAME:%s NODE_STATUS:%d",self.class.__cname,self._nodeStatus));
end