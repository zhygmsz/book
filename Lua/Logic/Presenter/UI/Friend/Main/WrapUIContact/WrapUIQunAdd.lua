local WrapUIQunAdd  = class("WrapUIQunAdd",UICommonCollapseWrapUI);
 
function WrapUIQunAdd:ctor(root,baseEventID,context)
    local subItemTran = root:Find("QunAdd");
    self._gameObject = subItemTran.gameObject;
    self._nameLabel = subItemTran:Find("LabelName"):GetComponent("UILabel");
    subItemTran:GetComponent("UIEvent").id = baseEventID;
end

function WrapUIQunAdd:OnRefresh()
    local cur, max = ChatMgr.GetFriendQunCountInfo();
    local title = WordData.GetWordStringByKey("friend_new_qun");--新建分组，已经填了
    self._nameLabel.text = string.format("%s %s/%s",title,cur,max);
end

function WrapUIQunAdd:OnClick(pid)
    UIMgr.ShowUI(AllUI.UI_Friend_NewQun);
end

return WrapUIQunAdd;