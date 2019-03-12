
local UIAIPetStateBase = class("UIAIPetStateBase");

function UIAIPetStateBase:ctor(context)
    self._context = context;

end
--[[
    @desc: 打开一定是打开的组建，关闭一定是关闭的组建
    author:{author}
    time:2019-02-18 11:19:24
    @return:
]]
function UIAIPetStateBase:OnEnter()
end
--[[
    @desc: 打开一定是打开的组建，关闭一定是关闭的组建
    author:{author}
    time:2019-02-18 11:19:46
    @return:
]]
function UIAIPetStateBase:OnExit()

end

------------UI交互-----------
function UIAIPetStateBase:OnPress(pressed,id)

end

function UIAIPetStateBase:OnClick(id)

end

function UIAIPetStateBase:OnDrag(delta,id)

end

function UIAIPetStateBase:OnDragStart(id)

end

function UIAIPetStateBase:OnDragEnd(id)

end

-- function UIAIPetStateBase:OnUIEnable()

-- end

-- function UIAIPetStateBase:OnUIDisable()
    
-- end


return UIAIPetStateBase;

