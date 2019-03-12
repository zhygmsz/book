--[[
    author:{hesinian}
    time:2019-01-25 17:07:33
]]

local MainUIFastChatItem = class("MainUIFastChatItem")

function MainUIFastChatItem:ctor(index,container)
    self._index = index;


    self._container = container;
    self._go = container.gameObject;
    self._containerBg = container:GetComponent("UISprite");

    local dragger = container:GetChild(0);
    self._dragger = dragger;
    self._dragGo = dragger.gameObject;
    self._tween = dragger:GetComponent("TweenRotation");
    dragger:GetComponent("UIEvent").id = 600 + index;

    local dragDrop = dragger:GetComponent("LuaDragDropItem");
    local onDragDropStart = System.Action(self.OnDragDropStart,self);
    local onDragDropDrag = System.Action(self.OnDragDropDrag,self);
    local onDragDropRelease = System.Action_UnityEngine_Transform(self.OnDragDropRelease,self);
    dragDrop:RegisterCallBack(onDragDropStart, onDragDropDrag, onDragDropRelease);
    
    self._icon = dragger:Find("Icon"):GetComponent("UITexture");
    self._level = dragger:Find("Label"):GetComponent("UILabel");
    local remove = dragger:Find("Remove");
    self._delGo = remove.gameObject;
    remove:GetComponent("UIEvent").id = 620 + index;
    
    self._editable = true;
    self._player = nil;
    self:SetPlayer(nil);
    self:SetState(false);
end

function MainUIFastChatItem:OnDestroy()
    UnityEngine.GameObject.Destroy(self._go);
end

function MainUIFastChatItem:ResetPosition()
    self._dragger.localPosition = Vector3.zero;
end

function MainUIFastChatItem:FastChat()
    if not self._player then return; end
    if self._editable then return; end
    UI_Friend_Main.TryChat(self._player);
end

function MainUIFastChatItem:GetIndex()
    return self._index;
end

function MainUIFastChatItem:SetPlayer(player)
    self._player = player ;
    self._containerBg.enabled = not player;
    self._go:SetActive((self._player or self._editable) and true or false);
    if not player then
        self._dragGo:SetActive(false);
        return;
    end
    self._dragGo:SetActive(true);
    player:SetHeadIcon(self._icon);
    self._level.text = player:GetLevel();
    
end

function MainUIFastChatItem:GetPlayer( )
    return self._player;
end

function MainUIFastChatItem:SetState(editable)
    if editable == self._editable then return; end
    self._editable = editable;
    self._tween.enabled = editable;
    self._go:SetActive((self._player or self._editable) and true or false);
    self._delGo:SetActive(editable);
end

function MainUIFastChatItem:RegisterOnDrag(OnDragStart,OnDrag,OnDragRelease,caller)
    self._OnDragStart = OnDragStart;
    self._OnDrag = OnDrag;
    self._OnDragRelease = OnDragRelease;
    self._caller = caller;
end

function MainUIFastChatItem:OnDragDropStart()
    GameUtils.TryInvokeCallback(self._OnDragStart, self._caller, self);
end
function MainUIFastChatItem:OnDragDropDrag()
    GameUtils.TryInvokeCallback(self._OnDrag, self._caller, self);
end
function MainUIFastChatItem:OnDragDropRelease(surface)
    self:ResetPosition();
    GameUtils.TryInvokeCallback(self._OnDragRelease, self._caller, self, surface);
end


return MainUIFastChatItem;