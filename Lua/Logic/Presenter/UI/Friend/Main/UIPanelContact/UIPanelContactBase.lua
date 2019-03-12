
local UIPanelContactBase = class("UIPanelContactBase");

---------子UI使用和驱动

function UIPanelContactBase:OnMemberSelected(mem,wrapui)
    self._selectedMember = mem;
end

function UIPanelContactBase:IsMemberSelected(mem)
    return self._selectedMember == mem;
end

---------事件驱动-----------

function UIPanelContactBase:OnUpdateMemberInfo(mem)
    self._collapseTable:RefreshUIWithData(mem);
end

---------生命周期------------
function UIPanelContactBase:ctor(ui,path)
    self._rootGo = ui:Find(path).gameObject;
    self._baseEvent = 2010;
end

function UIPanelContactBase:OnEnable()

end

function UIPanelContactBase:OnDisable()  
end

function UIPanelContactBase:OnDestroy()  
end

function UIPanelContactBase:SetState(state)

    self._state = state;
    self._rootGo:SetActive(state);
    if state then
        self:OnEnable();
    else
        self:OnDisable();
    end
end

---------Protected方法----------
function UIPanelContactBase:OnClick(id)
    self:CheckClick(id);
end

function UIPanelContactBase:CheckClick(id)
    if not self._rootGo.activeInHierarchy then
        return false;
    end
    if id >= 2010  then
        self._collapseTable:OnClick(id);
    end
    return true;
end

return UIPanelContactBase;
