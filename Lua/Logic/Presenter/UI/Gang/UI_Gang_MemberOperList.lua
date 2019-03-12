module("UI_Gang_MemberOperList", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf


--变量


local OperItem = class("OperItem", ContentItemClick)
function OperItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)

    --组件
    self._des = trs:Find("btn/label"):GetComponent("UILabel")
    
end

function OperItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
end

function OperItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    
end


--local方法
local function RegEvent()

end

local function UnRegEvent()

end


function OnCreate(self)
    mSelf = self
end

function OnEnable(self)
    RegEvent()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)

end

