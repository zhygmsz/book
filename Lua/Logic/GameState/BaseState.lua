BaseState = class("BaseState")

function BaseState:ctor(root)
    self._object = UnityEngine.GameObject.New(self.class.__cname);
    self._object.transform.parent = root;
    self._object:SetActive(false);
end

function BaseState:OnEnter()
    self._object:SetActive(true);
    self._passedTime = 0;
    self._stateProgress = 0;
    self._loadingProgress = 0;
end

function BaseState:OnUpdate(deltaTime)
    self._passedTime = self._passedTime + deltaTime;
end

function BaseState:OnLateUpdate(deltaTime)

end

function BaseState:OnExit()
    self._object:SetActive(false);
end

function BaseState:AddStateProgress(progress)
    self._stateProgress = self._stateProgress + progress;
end

function BaseState:GetStateProgress()
    return self._stateProgress;
end

function BaseState:GetStateSpeed()
    return 1;
end

function BaseState:GetStateProgressDes()
    return "";
end

function BaseState:SetLoadingProgress(progress)
    self._loadingProgress = progress;
end

function BaseState:IsEnterFinish()
    return self._stateProgress + self._loadingProgress >= 2;
end