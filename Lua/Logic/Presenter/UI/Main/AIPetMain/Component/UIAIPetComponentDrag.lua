local UIAIPetComponentDrag = class("UIAIPetComponentDrag");

function UIAIPetComponentDrag:ctor(ui,context,rootPath)
    self._context = context;
    self._rootTrans = ui:Find(rootPath);
    local boundPath = rootPath.."/DragLimit";
    local boundWidget = ui:FindComponent("UIWidget",boundPath);
    self._broundary = self:InitBroundry(boundWidget, ui:Find(boundPath));

    local birthTrans = ui:Find(rootPath.."/BirthPos");
    self._inactiveX = -1 * birthTrans.localPosition.x;

    local rootPath = rootPath.."/BirthPos/DragRoot";
    self._dragTrans = ui:Find(rootPath);

    self._dragDropItem = ui:FindComponent("LuaDragDropItem",rootPath);
    self._dragBoxCollider = ui:FindComponent("BoxCollider",rootPath);
    self._onDragDropStart = System.Action(self.OnDragDropStart,self);
    self._onDragDropDrag = System.Action(self.OnDragDropDrag,self);
    self._onDragDropRelease = System.Action_UnityEngine_Transform(self.OnDragDropRelease,self);
    --self._dragDropItem:SetRootTrans(self._dragTrans);
    self._dragDropItem:RegisterCallBack(self._onDragDropStart, self._onDragDropDrag, self._onDragDropRelease);

    --self._rootSpring = ui:FindComponent("SpringPosition",rootPath);
end

--回到默认位置
function UIAIPetComponentDrag:MoveDefaultWorkPos()
    local position = self._rootTrans:InverseTransformPoint(self._dragTrans.position);
    
    if  position.y <= self._bound.bottom or
        position.y >= self._bound.top or
        position.x <= self._bound.left or
        position.x >= self._bound.right
    then
        self._dragTrans.localPosition = Vector3.zero;
    end
end
--控制靠在右边屏幕部分
function UIAIPetComponentDrag:MoveDefaultInactivePos( )
    local pos = self._dragTrans.localPosition;
    pos.x = self._inactiveX;
    self._dragTrans.localPosition = pos;
end

function UIAIPetComponentDrag:OnDragDropStart()
    self._context:PlayAnimation(AIPetUIANIMATION.Drag);
end

function UIAIPetComponentDrag:OnDragDropDrag()
    --self:KeepInScreen();
end

function UIAIPetComponentDrag:OnDragDropRelease(surface)
    self._dragBoxCollider.enabled = true;
    self:PositionToState();
end

function UIAIPetComponentDrag:OnEnable()
    self._dragDropItem.enabled = true;
end

function UIAIPetComponentDrag:OnDisable()
    self._dragDropItem.enabled = false;
end

function UIAIPetComponentDrag:InitBroundry(boundWidget,boundTrans)

    self._halfWidth = boundWidget.width *0.5;
    local halfHeight = boundWidget.height * 0.5;
    local pos = self._rootTrans:InverseTransformPoint(boundTrans.position);
    --local pos = UICamera.currentCamera:WorldToScreenPoint(boundTrans.position);

    local bound = {};
    bound.left = pos.x - boundWidget.width;
    bound.right = pos.x;
    bound.top = pos.y + halfHeight;
    bound.bottom = pos.y - halfHeight;
    self._bound = bound;
end

function UIAIPetComponentDrag:PositionToState()
    local position = self._rootTrans:InverseTransformPoint(self._dragTrans.position);
        
    if  position.y < self._bound.bottom or
        position.y > self._bound.top or
        position.x < self._bound.right 
    then
        self._context:EnterState(AIPetUISTATE.Work);
        self:MoveDefaultWorkPos();
        return;
    end

    self._context:EnterState(AIPetUISTATE.Inactive);
    self:MoveDefaultInactivePos();

end

function UIAIPetComponentDrag:KeepInScreen()
    local pos = UICamera.currentCamera:WorldToScreenPoint(self._dragTrans.position);

    if pos.x < 0 then pos.x = 0; end
    local screenWidth = UnityEngine.Screen.width;
    if pos.x > screenWidth then  pos.y = screenWidth; end
    if pos.y < 0 then pos.y = 0; end
    local screenHeight = UnityEngine.Screen.height;
    if pos.y > screenHeight then pos.y = screenHeight; end
    

    pos = UICamera.currentCamera:ScreenToWorldPoint(pos);
    self._dragTrans.position = pos;
end

return UIAIPetComponentDrag;