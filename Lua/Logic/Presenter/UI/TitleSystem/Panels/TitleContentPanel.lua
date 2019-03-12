local TitleContentPanel = class("TitleContentPanel")
local TitleWrapUIItemInUse = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIItemInUse");
local TitleWrapUIContentUserDefine = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentUserDefine");
local TitleWrapUIContentClass = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentClass");
local TitleWrapUIContentItem = require("Logic/Presenter/UI/TitleSystem/WrapUI/TitleWrapUIContentItem");
function TitleContentPanel:ctor(ui,context)
    self._context = context;
    local path = "Offset/Left/DragAreaContent/ScrollView";
    local wrapUIs = {TitleWrapUIItemInUse,TitleWrapUIContentUserDefine,TitleWrapUIContentClass,TitleWrapUIContentItem};
    self._table = UICommonCollapseTableWrap.new(ui,path,15,wrapUIs,1000,1,self);
    self._table:RegisterData("TitleItemUserDefine","TitleWrapUIContentUserDefine",65,self);
    self._table:RegisterData("TitleGroup","TitleWrapUIContentItem",65,self);
    self._table:RegisterData("TitleClass","TitleWrapUIContentClass",65,self);
    self._classTable = {};
    self._selectedClass = nil;
    --self._selectedItem = nil;
    self._selectedGroup = nil;
    self._selectedUserDefine = nil;
    self._selectedInUse = false;
end

function TitleContentPanel:OnEnable()
    
    self._selectedClass = nil;
    --self._selectedItem = nil;
    self._selectedGroup = nil;
    self._selectedUserDefine = nil;
    self._selectedInUse = false;

    local inUseTitle = TitleMgr.GetItemInUse();
    local userDefineTitle = TitleMgr.GetItemUserDefine();
    if inUseTitle then
        self._context.SelectInUseItem();
        self._selectedInUse = true;
    else
        self._context.SelectUserItem(userDefineTitle);
        --self._selectedItem = userDefineTitle;

        self._selectedGroup = nil;
        self._selectedUserDefine = userDefineTitle;
    end

    self._wrapData = {};
    local inUseData = UICommonCollapseWrapData.new("TitleWrapUIItemInUse",nil,65);
    table.insert(self._wrapData,inUseData);
    table.insert(self._wrapData,userDefineTitle);

    local cls = TitleMgr.GetClassifies();
    
    for i,class in ipairs(cls) do
        table.insert(self._wrapData,class);
        --self._classTable[class] = class:GetGroups();
    end
    self._table:ResetAll(self._wrapData);

    GameEvent.Reg(EVT.TITLE,EVT.TITLE_PUT_ON,self.OnTitlePutOn,self);
    GameEvent.Reg(EVT.TITLE,EVT.TITLE_TAKE_OFF,self.OnTitlePutOn,self);
    
    GameEvent.Reg(EVT.TITLE,EVT.TITLE_OPEN_CHANGE,self.OnItemOpenChange,self);
    GameEvent.Reg(EVT.TITLE,EVT.TITLE_INFO_CHANGE,self.OnUserdefineRename,self);
end

function TitleContentPanel:OnDisable()
    GameEvent.UnReg(EVT.TITLE,EVT.TITLE_PUT_ON,self.OnTitlePutOn,self);
    GameEvent.UnReg(EVT.TITLE,EVT.TITLE_TAKE_OFF,self.OnTitlePutOn,self);
    GameEvent.UnReg(EVT.TITLE,EVT.TITLE_OPEN_CHANGE,self.OnItemOpenChange,self);
    GameEvent.UnReg(EVT.TITLE,EVT.TITLE_INFO_CHANGE,self.OnUserdefineRename,self);

end

function TitleContentPanel:OnClick(id)
    self._table:OnClick(id);
end

function TitleContentPanel:OnTitlePutOn(item)
    if self._selectedInUse then
        self._context.SelectInUseItem();
        return;
    end
    if item == self._selectedUserDefine then
        self._context.SelectUserItem(item);
    elseif item:GetGroup() == self._selectedGroup then
        self._context.SelectOfficialItem(item);
    end
end
function TitleContentPanel:OnUserdefineRename(item)
    if self._selectedUserDefine then
        self._context.SelectUserItem(item);
    elseif self._selectedInUse and TitleMgr.IsItemInUse(item) then
        self._context.SelectUserItem(item);
    end
end

function TitleContentPanel:OnItemOpenChange(item)
    local changeGroup = item:GetGroup();
    local changeClass = changeGroup and changeGroup:GetClass();
    if changeGroup then 
        self._table:RefreshUIWithData(changeGroup);
    end

    if self._selectedUserDefine == item then
        self._context.SelectUserItem(item);
    else
        if not changeGroup then return; end
        if not self._selectedGroup then return; end

        if self._selectedGroup == changeGroup then
            self._context.SelectOfficialItem(changeGroup:GetRepresentItem());
        end
    end
end

function TitleContentPanel:OnItemInUseSelect()
    if self._selectedInUse then return; end
    self._selectedInUse = true;
    self._selectedClass = nil;
    --self._selectedItem = nil;
    self._selectedGroup = nil;
    self._selectedUserDefine = nil;
    self:ClearOfficialItems();
    self._table:ResetAll(self._wrapData);
    self._context.SelectInUseItem();
end

function TitleContentPanel:OnItemUserSelect(item,wrapUI)
    if item == self._selectedUserDefine then return; end


    self._selectedInUse = false;
    --self._selectedItem = item;
    self._selectedGroup = nil;
    self._selectedUserDefine = item;

    self._selectedClass = nil;

    self:ClearOfficialItems();
    self._table:ResetAll(self._wrapData);

    self._context.SelectUserItem(item);
end

function TitleContentPanel:OnClassSelect(cla)
    if cla == self._selectedClass then return; end
    self._selectedInUse = false;
    self._selectedClass = cla;
    self._selectedUserDefine = nil;

    self:ClearOfficialItems();
    
    local index = 1;
    for i=1,#self._wrapData do
        if self._wrapData[i] == cla then
            index = i;
            break;
        end
    end
    local groups = self._wrapData[index]:GetGroups();
    index = index + 1;
    for i,group in ipairs(groups) do
        table.insert(self._wrapData,index,group);
    end
    --self._selectedItem = :GetRepresentItem();
    self._selectedGroup = groups[1];
    
    self._table:ResetAllWithShowData(self._wrapData,index);
    self._context.SelectOfficialItem(self._selectedGroup:GetRepresentItem());
end

function TitleContentPanel:OnItemOfficialSelect(group,wrapUI)
    self._selectedGroup = group;
    wrapUI:OnRefresh();
    self._context.SelectOfficialItem(self._selectedGroup:GetRepresentItem());
end

function TitleContentPanel:IsItemInUseSelect()
    return self._selectedInUse;
end

function TitleContentPanel:IsItemUserSelect(item)
    return self._selectedUserDefine == item;
end
function TitleContentPanel:IsClassSelect(cla)
    return self._selectedClass == cla;
end
function TitleContentPanel:IsItemOfficialSelect(group)
    return self._selectedGroup == group;
end

function TitleContentPanel:ClearOfficialItems()
    for i=#self._wrapData,1,-1 do
        local data = self._wrapData[i];
        if data.__cname == "TitleGroup" then
            table.remove(self._wrapData,i);
        end
    end
end

return TitleContentPanel;