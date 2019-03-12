ModelComponent = class("ModelComponent",EntityComponent);

function ModelComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function ModelComponent:OnStart()
    self._entityModel = ModelFactory.CreateModel(self._entity._entityAtt.modelType,self);
end

function ModelComponent:OnEnable()
    self._entityModel:OnEnable();
    self._entityModel:UpdateModel();
end

function ModelComponent:OnDisable()
    self._entityModel:OnDisable();
end

function ModelComponent:OnDestroy()
    ModelFactory.DeleteModel(self._entityModel);
    self._entityModel = nil;
end

--获取root transform
function ModelComponent:GetEntityRoot()
    return self._entityModel:GetEntityRoot();
end

--获取model gameObject
function ModelComponent:GetEntityModel()
    return self._entityModel:GetEntityModel();
end

--获取bone transform
function ModelComponent:GetEntityBone(boneName)
    return self._entityModel:GetEntityBone(boneName);
end

--修改root position
function ModelComponent:SetPosition(position)
    self._entityModel:SetPosition(position);
end

--修改root forward
function ModelComponent:SetForward(forward)
    self._entityModel:SetForward(forward);
end

--刷新模型,模型相关的状态发生变化后调用(例如:时装、变身等等)
function ModelComponent:UpdateModel()
    self._entityModel:UpdateModel();
end

--播放动画(适合非战斗类角色使用)
function ModelComponent:PlayAnim(animName,exitName)
    local loadScript = self._entityModel and self._entityModel._modelLoader and self._entityModel._modelLoader._loadScript;
    if loadScript then
        local function OnAnimFinish() loadScript:PlayAnimation(self._exitName,0) end
        if not self._onAnimFinish then self._onAnimFinish = GameCore.EntityModel.OnAnimPlayFinish(OnAnimFinish); end
        if exitName then
            self._exitName = exitName;
            loadScript:PlayAnimation(animName, 0, 1, self._onAnimFinish)
        else
            loadScript:PlayAnimation(animName, 0)
        end
    end
end

--播放受击
function ModelComponent:PlayHit(deltaValue)
    local loadScript = self._entityModel and self._entityModel._modelLoader and self._entityModel._modelLoader._loadScript;
    if loadScript then loadScript:PlayHitAnimation(deltaValue); end
end

return ModelComponent;