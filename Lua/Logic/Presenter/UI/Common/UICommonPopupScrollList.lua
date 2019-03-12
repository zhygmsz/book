--选择弹窗
UICommonPopupScrollList = class("UICommonPopupScrollList");
local OPEN_ROTATION = UnityEngine.Quaternion.Euler(0,0,90);
local CLOSE_ROTATION = UnityEngine.Quaternion.Euler(0,0,180);

function UICommonPopupScrollList:ctor(ui,path,openEventID,okEventID)
    local openBtnEvent = ui:FindComponent("UIEvent",path.."/OpenButton");
    openBtnEvent.id = openEventID;
    self._openEventID = openEventID;
    self._displayLabel = ui:FindComponent("UILabel",path.."/OpenButton/Label");
    self._openSpriteTrans = ui:Find(path.."/OpenButton/SpriteState");

    self._populistGo = ui:Find(path.."/PopupScrollList").gameObject;
    local okBtnEvent = ui:FindComponent("UIEvent",path.."/PopupScrollList/OKButton");
    okBtnEvent.id = okEventID;
    self._okEventID = okEventID;

    self._indexHelper = ui:FindComponent("UIScrollHelper",path.."/PopupScrollList/DragView/Scroll View");
    self._indexHelper:SetIndexChange(UIScrollHelper.ActionInt(self.OnSelected,self));

    self._optionLabel = ui:FindComponent("UILabel",path.."/PopupScrollList/DragView/Scroll View/Label");
    self._firstAdds = nil;
    self._selectedIndex = 0;
    self._tempPID = 0;

    self._populistGo:SetActive(false);
    self._openSpriteTrans.localRotation = CLOSE_ROTATION;

end

function UICommonPopupScrollList:OnSelected(index) 
    self._tempIndex = index+1;
end

--String数组[不可为空数组],默认选项
function UICommonPopupScrollList:InitOptions(optionList,defaultIndex)
    local pCount = #optionList;
    defaultIndex = defaultIndex or 1;
    if defaultIndex > pCount then
        GameLog.LogError("Error Parame: defaultIndex %s mustn't be greater than option's Count %s",defaultIndex,pCount);
        return;
    end
    self._optionList = optionList;
    self._indexHelper.ItemCount = pCount;
    self._optionLabel.text = table.concat(optionList,"\n");
    self._tempIndex = defaultIndex;
    self:SetSelectedIndex(defaultIndex);
end
function UICommonPopupScrollList:SetSelectedIndex(index)
    self._selectedIndex = index;
    self._indexHelper:SetShowChildIndex(index-1);
    self._displayLabel.text = self._optionList[index];
end

function UICommonPopupScrollList:GetSelectedIndex()
    return self._selectedIndex;
end

local function ChangeState(self)
    self._openState = not self._openState;
    self._populistGo:SetActive(self._openState);
    if not self._openState then
        self._openSpriteTrans.localRotation = CLOSE_ROTATION;
    else
        self._openSpriteTrans.localRotation = OPEN_ROTATION;
    end
end
function UICommonPopupScrollList:OnClick(id)

    if id == self._openEventID then
        ChangeState(self);
    elseif self._openState then
        ChangeState(self);
        self:SetSelectedIndex(self._tempIndex);
    end
end
return UICommonPopupScrollList;