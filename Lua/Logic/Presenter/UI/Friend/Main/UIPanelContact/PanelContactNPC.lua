local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/UIPanelContactBase")
local PanelContactNPC = class("PanelContactNPC",Base);


---------事件驱动-----------

function PanelContactNPC:ctor(ui,path)
    self.super.ctor(self, ui,path)
    
    local WrapUINPC = require("Logic/Presenter/UI/Friend/Main/WrapUIContact/WrapUINPC");
    local wrapUIs = {WrapUINPC};
    self._collapseTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,self._baseEvent,5,self);
    self._collapseTable:RegisterData("SocialPlayer","WrapUINPC",94);
    self._selectedMember = nil;
end

function PanelContactNPC:OnEnable()
    self.super.OnEnable(self);
    
    self:UpdateAllTableData();
    UI_Friend_Main.ShowChat(self._selectedMember);
end

function PanelContactNPC:OnDisable()
    self.super.OnDisable(self);
end

----------Wraptable-------------
function PanelContactNPC:UpdateAllTableData()
    local npcs = FriendMgr.GetAllNPCFriends();
    self._tableDataList = npcs;
    if not self._selectedMember then
        self._collapseTable:ResetAll(self._tableDataList);
        return;
    end

    local showIndex = nil;
    for i = 1, #npcs do
        if npcs[i] == self._selectedMember then
            showIndex = i;
            break;
        end
    end
    
    self._collapseTable:ResetAllWithShowData(npcs,showIndex or 1);
end

return PanelContactNPC;
