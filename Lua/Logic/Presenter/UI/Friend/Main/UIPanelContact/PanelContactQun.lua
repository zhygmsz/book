local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/UIPanelContactBase")
local PanelContactQun = class("PanelContactQun",Base);


---------事件驱动-----------

function PanelContactQun:ctor(ui,path)
    self.super.ctor(self, ui,path)
    
    local WrapUIQunContent = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIQunContent");
    local WrapUIQunAdd = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIQunAdd");
    local wrapUIs = {WrapUIQunContent,WrapUIQunAdd};
    self._collapseTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,self._baseEvent,5,self);
    self._collapseTable:RegisterData("FriendChatQun","WrapUIQunContent",90);
    self._selectedMember = nil;
end

function PanelContactQun:OnEnable()
    self.super.OnEnable(self);
    
    self:UpdateAllTableData();
    UI_Friend_Main.ShowChat(self._selectedMember);
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO,self.OnUpdateMemberInfo,self);
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_NEW_QUN,self.UpdateAllTableData,self);     --改变所有好友数据；
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN,self.UpdateAllTableData,self);     --改变所有好友数据；
end

function PanelContactQun:OnDisable()
    self.super.OnDisable(self);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_ADD,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_MEMBER_DELETE,self.OnUpdateMemberInfo,self);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO,self.OnUpdateMemberInfo,self);
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_NEW_QUN,self.UpdateAllTableData,self);     --改变所有好友数据；
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_REMOVE_QUN,self.UpdateAllTableData,self);     --改变所有好友数据；
end

----------Wraptable-------------
function PanelContactQun:UpdateAllTableData()
    local quns = ChatMgr.GetFriendQuns();
    self._tableDataList = quns;
    quns[#quns + 1] = UICommonCollapseWrapData.new("WrapUIQunAdd",nil,87);
    if not self._selectedMember then
        self._collapseTable:ResetAll(self._tableDataList);
        return;
    end

    local showIndex = nil;
    for i = 1, #quns do
        if quns[i] == self._selectedMember then
            showIndex = i;
            break;
        end
    end
    
    self._collapseTable:ResetAllWithShowData(quns,showIndex or 1);
end

return PanelContactQun;
