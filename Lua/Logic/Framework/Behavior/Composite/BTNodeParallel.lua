BTNodeParallel = class("BTNodeParallel",BTNodeComposite)

function BTNodeParallel:ctor()
    BTNodeComposite.ctor(self);
end

function BTNodeParallel:dtor()
    BTNodeComposite.dtor(self);
end

function BTNodeParallel:OnStart()
end

function BTNodeParallel:OnUpdate(deltaTime,btData)
    --全部失败则返回失败,有一个成功则返回成功,有一个运行中则运行中
    local childStatus = nil;
    local runningFlag = false;
    local successFlag = false;
    for i = 1,#self._childNodes do
        childStatus = self._childNodes[i]:Tick(deltaTime,btData);
        if childStatus == BTDefine.NODE_STATUS.RUNNING then runningFlag = true; end
        if childStatus == BTDefine.NODE_STATUS.SUCCESS then successFlag = true; end
    end
    if runningFlag then return BTDefine.NODE_STATUS.RUNNING; end
    if successFlag then return BTDefine.NODE_STATUS.SUCCESS; end
    return BTDefine.NODE_STATUS.FAILURE;
end

function BTNodeParallel:OnStop()
end