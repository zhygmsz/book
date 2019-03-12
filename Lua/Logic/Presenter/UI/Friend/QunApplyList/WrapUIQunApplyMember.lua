local BaseWrapUI = require("Logic/Presenter/UI/Common/UITableWrap/BaseWrapUI");
local WrapUIQunApplyMember  = class("WrapUIQunApplyMember",BaseWrapUI);

function WrapUIQunApplyMember:ctor(root,context)
    local subItemTran = root:Find("Member");
    self._gameObject = subItemTran.gameObject;
    self._widget = subItemTran:GetComponent("UIWidget");
    self._context = context;
    local iconApplyTexture = subItemTran:Find("SpriteApplyIcon/Texture"):GetComponent("UITexture");
    self._iconApplyTextureLoader = LoaderMgr.CreateTextureLoader(iconApplyTexture);

    self._nameApplyLabel = subItemTran:Find("LabelApplyName"):GetComponent("UILabel");
    self._levelApplyLabel = subItemTran:Find("LabelApplyLevel"):GetComponent("UILabel");
    local iconInviteTexture = subItemTran:Find("SpriteInviterIcon/Texture"):GetComponent("UITexture");
    self._iconInviteTextureLoader = LoaderMgr.CreateTextureLoader(iconInviteTexture);
    self._nameInviteLabel = subItemTran:Find("LabelInviterName"):GetComponent("UILabel");
    self._selectToggle = subItemTran:GetComponent("UIToggle");
    self._UIEvent = subItemTran:GetComponent("UIEvent");
end

function WrapUIQunApplyMember:GetType()
    return "member";
end

function WrapUIQunApplyMember:Refresh(data)
    local index = data:GetID();
    local qid = self._context:GetQunID();
    local applyID = ChatMgr.GetGroupApplyPlayerID(qid,index);
    local inviterID = ChatMgr.GetGroupApplyInviterID(qid,index);

    self._iconApplyTextureLoader:LoadObject(FriendMgr.GetIconID(applyID));
    self._nameApplyLabel.text = FriendMgr.GetNickname(applyID);
    self._levelApplyLabel.text = FriendMgr.GetLevel(applyID);

    self._iconInviteTextureLoader:LoadObject(FriendMgr.GetIconID(inviterID));
    self._nameInviteLabel.text = FriendMgr.GetCareer(inviterID);
    local selected = self._context:IsSelected(index);
    self._selectToggle:Set(selected);
    self._UIEvent.id = data:GetEventID();    
end

return WrapUIQunApplyMember;