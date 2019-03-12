ModelBase = class("ModelBase");

function ModelBase:ctor(modelType,modelComponent)
    self._modelType = modelType;
    --当前所属对象
    self._entity = modelComponent._entity;
    --创建ROOT结点
    if tolua.isnull(self._rootGameObject) then
        self._rootGameObject = UnityEngine.GameObject.New();
        self._rootTransform = self._rootGameObject.transform;
        self._rootScript = self._rootGameObject:AddComponent(typeof(GameCore.Entity));
        if self._modelType == EntityDefine.MODEL_PROCESS_TYPE.EFFECT then
        
        elseif self._modelType == EntityDefine.MODEL_PROCESS_TYPE.WALL then
            self._rootObstacle = self._rootGameObject:AddComponent(typeof(UnityEngine.AI.NavMeshObstacle));
            self._rootObstacle.carving = true;
        else
            self._rootCollider = self._rootGameObject:AddComponent(typeof(UnityEngine.CapsuleCollider));
            self._rootCollider.isTrigger = true;
        end
    end
    --父结点
    self._rootTransform.parent = EntityDefine.ENTITY_ROOT[self._entity:GetType()];
    --名字
    self._rootGameObject.name = self._entity._entityAtt.name;
    --位置、层级
    if self._entity:IsRender() then
        self._rootGameObject.layer = self._entity._entityAtt.renderLayer;
        self._rootTransform.position = self._entity._entityAtt.renderPosition;
    else
        self._rootGameObject.layer = self._entity._entityAtt.modelLayer;
        self._rootTransform.position = self._entity._entityAtt.position;
    end
    --宽度、高度、大小
    if self._rootCollider and self._entity._entityAtt.height and self._entity._entityAtt.width then
        self._rootCollider.center = Vector3(0,self._entity._entityAtt.height * 0.5,0);
        self._rootCollider.radius = self._entity._entityAtt.width;
        self._rootCollider.height = self._entity._entityAtt.height;
    elseif self._rootObstacle and self._entity._entityAtt.size then
        self._rootObstacle.size = self._entity._entityAtt.size;
    end
    --朝向
    self._rootTransform.forward = self._entity._entityAtt.forward;
    --实体信息
    self._rootScript:Init(self._entity:GetID(),self._entity:GetType(),self._entity:GetDebugInfo());
    --模型资源
    self._modelLoader = nil;
end

function ModelBase:dtor()
    LoaderMgr.DeleteLoader(self._modelLoader);
    self._modelLoader = nil;
end

function ModelBase:OnEnable()
    self._rootGameObject:SetActive(true);
end

function ModelBase:OnDisable()
    self._rootGameObject:SetActive(false);
end

function ModelBase:GetType()
    return self._modelType;
end

function ModelBase:GetEntityRoot()
    return self._rootTransform;
end

function ModelBase:GetEntityModel()
    return self._modelLoader:GetObject();
end

function ModelBase:GetEntityBone(boneName)
    return self._modelLoader:GetBone(boneName);
end

function ModelBase:SetPosition(position)
    self._rootTransform.position = position;
end

function ModelBase:SetForward(forward)
    self._rootTransform.forward = forward;
end

function ModelBase.OnModelLoad(_,self)
    self._entity:OnModelLoad(self._modelLoader);
end

function ModelBase:OnModelReplace()
    self._entity:OnModelReplace();
end

function ModelBase:UpdateModel()

end

function ModelBase:LoadModel(resID,...) 
    if resID and resID > 0 then
        self._modelLoader:LoadObject(resID,...);
        self._modelLoader:SetActive(true);
        self._modelLoader:SetLayer(self._rootGameObject.layer);
        self._modelLoader:SetParent(self._rootTransform);
        if self._modelLoader.SetReplaceCallBack then self._modelLoader:SetReplaceCallBack(self.OnModelReplace,self); end
    end
end

return ModelBase;