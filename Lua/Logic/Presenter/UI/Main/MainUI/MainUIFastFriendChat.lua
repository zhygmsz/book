--[[
    author:{hesinian}
    time:2019-01-25 16:58:02
]]

MainUIFastFriendChat = class("MainUIFastFriendChat")
local MainUIFastChatItem = require("Logic/Presenter/UI/Main/Coms/MainUIFastChatItem");
function MainUIFastFriendChat:ctor(ui)
    self._rootTr = ui:Find("Bottom/Chat/FastChat");
    self._allDragItems = {};--index->MainUIFastChatItem
    self._transContainerTable = {};--UIDragDropContainer->MainUIFastChatItem
    local grid = ui:FindComponent("UIGrid", "Bottom/Chat/FastChat/Grid");
    local prefab = ui:Find("Bottom/Chat/FastChat/Grid/Container");
    local count = FastChatMgr.GetFastChatterLimit();
    UIGridTableUtil.CreateChild(ui,prefab,count,nil,self.OnContainerCreate,self);
end

function MainUIFastFriendChat:OnContainerCreate(trans,index)
    local dragItem = MainUIFastChatItem.new(index,trans);
    dragItem:RegisterOnDrag(self.OnDragDropStart,self.OnDragDropDrag,self.OnDragDropRelease,self);
    self._allDragItems[index] = dragItem;
    self._transContainerTable[trans] = dragItem;
end

function MainUIFastFriendChat:OnEnable()
    self:Refresh();
    GameEvent.Reg(EVT.FRIEND,EVT.FAST_CHAT_CHANGE,self.OnSlotChange,self);
    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnPlayerChangeAttr,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_SYNC_ALL_RELATION,self.Refresh,self);
end

function MainUIFastFriendChat:OnDisable()
    GameEvent.UnReg(EVT.FRIEND,EVT.FAST_CHAT_CHANGE,self.OnSlotChange,self);
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnPlayerChangeAttr,self);     --改变好友基本数据；
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_SYNC_ALL_RELATION,self.Refresh,self);
end

function MainUIFastFriendChat:OnDestroy()
    for i,item in ipairs(self._allDragItems) do
        item:OnDestroy();
    end
end

function MainUIFastFriendChat:OnClick(id)
    if id >= 600 and id < 620 then
        self._allDragItems[id - 600]:FastChat();
    elseif id>=620 and id <650 then
        local index = self._allDragItems[id - 620]:GetIndex();
        FastChatMgr.SetFastChatter(index,nil);
    end
end

function MainUIFastFriendChat:OnLongPress(id)
    if id >=600 and id <= 605 then
        for i,item in ipairs(self._allDragItems) do
            item:SetState(true);
        end
        TouchMgr.SetListenOnNGUIEvent(self,true,true);
    end
end

function MainUIFastFriendChat:OnPressScreen(go,state)
    if not state then return; end
    if not go then self:QuitEdit(); end
    local tr = go.transform;
    if not tr then self:QuitEdit(); end
    if (not tr:IsChildOf(self._rootTr)) then
        self:QuitEdit();
    end
end

function MainUIFastFriendChat:OnDragDropRelease(dragItem, targetTrans)
    local targetItem = targetTrans and self._transContainerTable[targetTrans];

    if (not targetTrans ) or dragItem == targetItem then  return;   end

    local sourcePlayer = dragItem:GetPlayer();
    FastChatMgr.SetFastChatter(targetItem:GetIndex(),sourcePlayer);
end

function MainUIFastFriendChat:Refresh()
    for i, item in ipairs(self._allDragItems) do
        local friend = FastChatMgr.GetFastChatter(i);
        item:SetPlayer(friend);
    end
end

--刷新属性
function MainUIFastFriendChat:OnPlayerChangeAttr( player)
    for i, item in ipairs(self._allDragItems) do
        if item:GetPlayer() == player then
            item:SetPlayer(player);
        end
    end
end

function MainUIFastFriendChat:OnSlotChange(index)
    self._allDragItems[index]:SetPlayer(FastChatMgr.GetFastChatter(index));
end

function MainUIFastFriendChat:QuitEdit()
    for i,item in ipairs(self._allDragItems) do
        item:SetState(false);
    end
    TouchMgr.SetListenOnNGUIEvent(self,false,true);
end
return MainUIFastFriendChat;