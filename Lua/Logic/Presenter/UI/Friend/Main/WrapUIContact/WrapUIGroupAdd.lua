local WrapUIGroupAdd  = class("WrapUIGroupAdd",UICommonCollapseWrapUI);
require("Logic/Presenter/UI/Friend/UI_Friend_EditGroup");

function WrapUIGroupAdd:ctor(root,baseEventID,context)
    self.super.ctor(self,itemTran,baseEventID,context);
    local subItemTran = root:Find("GroupAdd");
    self._gameObject = subItemTran.gameObject;
    self._nameLabel = subItemTran:Find("Label"):GetComponent("UILabel");
    self._countLabel = subItemTran:Find("LabelCount"):GetComponent("UILabel");
    subItemTran:GetComponent("UIEvent").id = baseEventID;
end

function WrapUIGroupAdd:OnRefresh()
    self._nameLabel.text = WordData.GetWordStringByKey("friend_group_new_group");--新建分组
    self._countLabel.text = string.format("%s/%s",FriendMgr.GetUsed_AllGroupFriendCount());
end

function WrapUIGroupAdd:OnClick(bid)
    if bid == 0 then
        UI_Friend_EditGroup.ShowGroup();
    end
end

return WrapUIGroupAdd;