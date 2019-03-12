local UIAIPetComponentMessage = class("UIAIPetComponentMessage");

function UIAIPetComponentMessage:ctor(ui,context,rootPath)
    self._context = context;
    local path = rootPath.."/BirthPos/DragRoot/ArrowTip";

    self._leftContainer = self:InitContainer(ui, path.."/SpriteLeft");
    
    self._leftContainer.Condition = function(position)
        return true;
    end

    self._currentDialog = nil;
    self._timeLimit = ConfigData.GetIntValue("AIPet_Bubble_Life") or 15;--箭头气泡存活时间 单位秒
    self._timeClose = nil;
    self._dragClose = false;
    self._enabled = false;
end

function UIAIPetComponentMessage:DisplayMessage()
    if self._currentDialog then
        self._leftContainer.Show(self._currentDialog:GetContent());
        self._timeClose = TimeUtils.SystemTimeStamp(true) + self._timeLimit;
        self._context:PlayAnimation(AIPetUIANIMATION.Answer);
    else
        self._leftContainer.Close();
        self._timeClose = nil;
    end
end

function UIAIPetComponentMessage:OnReceiveNewMessage(dialog)
    if dialog.__cname ~= "AIPetDialogPet" then return; end
    self._currentDialog = dialog;
    self:DisplayMessage();
end

function UIAIPetComponentMessage:OnEnable()
    if self._enabled then return; end
    UpdateBeat:Add(self.Update,self);
    self._timeClose = nil;
    GameEvent.Reg(EVT.AIPET, EVT.DIALOG_PLAYER,self.OnReceiveNewMessage,self);
    GameEvent.Reg(EVT.AIPET, EVT.DIALOG_AIPET,self.OnReceiveNewMessage,self);
end

function UIAIPetComponentMessage:OnDisable()
    self._timeClose = nil;
    self._currentDialog = nil;
    self._leftContainer.Close();
    GameEvent.UnReg(EVT.AIPET, EVT.DIALOG_PLAYER,self.OnReceiveNewMessage,self);
    GameEvent.UnReg(EVT.AIPET, EVT.DIALOG_AIPET,self.OnReceiveNewMessage,self);
    UpdateBeat:Remove(self.Update,self);
end

function UIAIPetComponentMessage:Update()
    
    if self._timeClose then
        local time = TimeUtils.SystemTimeStamp(true);
        if time > self._timeClose then
            self._leftContainer:Close();
        end
    end
end

function UIAIPetComponentMessage:OnPress()
    if self._timeClose then 
        self._timeClose = TimeUtils.SystemTimeStamp(true) + self._timeLimit;
    end
end

function UIAIPetComponentMessage:OnClick()
    TipsMgr.TipByFormat("AIPet 聊天正在设计中！");
end

function UIAIPetComponentMessage:OnDrag()
    if self._timeClose then 
        self._timeClose = TimeUtils.SystemTimeStamp(true) + self._timeLimit;
    end
end

function UIAIPetComponentMessage:OnDragStart(id)
    local currentT = UICamera.currentTouch;
    local delta = currentT.totalDelta;
    if (math.abs(delta.x) > math.abs(delta.y)) then
        self._dragClose = true;
        self._leftContainer.EnableDrag(false);
    end
end

function UIAIPetComponentMessage:OnDragEnd(id)    
    if self._dragClose then
        self._leftContainer:Close();
    elseif self._timeClose then 
        self._timeClose = TimeUtils.SystemTimeStamp(true) + self._timeLimit;
    end
    self._dragClose = false;
    self._leftContainer.EnableDrag(true);
end

function UIAIPetComponentMessage:InitContainer(ui, path)
    local item = {};
    local trans = ui:Find(path);
    item.go = trans.gameObject;
    item.label = ui:FindComponent("UILabel",path.."/Scroll View/Label");
    item.labelWidget = ui:FindComponent("UIWidget",path.."/Scroll View/Label");
    item.bgWidget = trans:GetComponent("UIWidget");

    item.scrollViewTrans = trans:Find("Scroll View");
    item.scrollViewPanel = item.scrollViewTrans:GetComponent("UIPanel");
    item.scrollView = trans:GetComponent("UIDragScrollView");
    item.Show = function (content)
        item.go:SetActive(true);
        item.label.text = content;
        --以下实现了文本框在3行文字以内自适应高度的效果
        local labelHeight = item.labelWidget.height;
        if labelHeight <= 72 then
            local delta = labelHeight - 24;
            item.bgWidget.height = 60 + delta;
            item.scrollViewPanel.clipOffset = Vector2.zero;
            local newPosition = item.scrollViewTrans.localPosition;
            newPosition.y = -(30 + delta);
            item.scrollViewTrans.localPosition = newPosition;
        else
            item.bgWidget.height = 108;
            local delta = item.labelWidget.height - 72;
            item.scrollViewPanel.clipOffset = Vector2.New(0,delta * 0.5);
            local newPosition = item.scrollViewTrans.localPosition;
            newPosition.y = -(48 + delta * 0.5);
            item.scrollViewTrans.localPosition = newPosition;
        end
    end
    item.Close = function ()
        item.go:SetActive(false);
    end
    item.EnableDrag = function(value)
        item.scrollView.enabled = value;
    end
    return item;
end

return UIAIPetComponentMessage;