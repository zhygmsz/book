local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/UIPanelContactBase")

local PanelContactLatest = class("PanelContactLatest",Base);

function PanelContactLatest:ctor(ui,path)
    self.super.ctor(self, ui,path)
    
    local WrapUIPlayer = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIPlayer");
    local WrapUIQunContent = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUIQunContent");

    local wrapUIs = {WrapUIPlayer,WrapUIQunContent};
    self._collapseTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,self._baseEvent,5,self);
    self._collapseTable:RegisterData("SocialPlayer","WrapUIPlayer",94);
    self._collapseTable:RegisterData("FriendChatQun","WrapUIQunContent",94);

    self._selectedMember = nil;
end

function PanelContactLatest:OnEnable()
    if not self._selectedMember then
        self:UpdateAllTableData();
    end
    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.Reg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO,self.OnUpdateMemberInfo,self);
    GameEvent.Reg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_ITEM,self.UpdateAllTableData,self);
    UI_Friend_Main.ShowChat(self._selectedMember);
end

function PanelContactLatest:OnDisable()
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self.OnUpdateMemberInfo,self);     --改变好友基本数据；
    GameEvent.UnReg(EVT.FRIENDQUN,EVT.FRIENDQUN_BASIC_INFO,self.OnUpdateMemberInfo,self);
    GameEvent.UnReg(EVT.FRIENDCHAT,EVT.FRIENDCHAT_NEW_ITEM,self.UpdateAllTableData,self);
end

function PanelContactLatest:ResetSelect()
    self._selectedMember = nil;
end
----------Wraptable-------------
function PanelContactLatest:UpdateAllTableData()
    local mems = SocialChatMgr.GetAllChaters();
    self._tableDataList = mems;
    self._selectedMember = mems[#mems];
    self._collapseTable:ResetAll(self._tableDataList,true);
end

return PanelContactLatest;
