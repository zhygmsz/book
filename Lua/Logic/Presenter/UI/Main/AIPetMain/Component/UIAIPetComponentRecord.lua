local UIAIPetComponentRecord = class("UIAIPetComponentRecord");
function UIAIPetComponentRecord:ctor(ui, context, uiRootPath)
    self._context = context;

    uiRootPath = uiRootPath.."/BirthPos/DragRoot"
    self._dragGo = ui:Find(uiRootPath).gameObject;
end

function UIAIPetComponentRecord:DragForCancel()
    local forCancel = UICamera.hoveredObject ~= self._dragGo;
    AIPetMgr.PrepareCancel(forCancel);
end

function UIAIPetComponentRecord:OnDisable( )
    -- body
end
function UIAIPetComponentRecord:OnEnable( )
    -- body
end

return UIAIPetComponentRecord;


