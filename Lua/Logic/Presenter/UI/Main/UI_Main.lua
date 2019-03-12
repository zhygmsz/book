module("UI_Main",package.seeall)

local mMainUIComponents = {};

function OnCreate(self)
    require("Logic/Presenter/UI/Main/MainUI/MainUIJoyStick");
    require("Logic/Presenter/UI/Main/MainUI/MainUISkill");
    require("Logic/Presenter/UI/Main/MainUI/MainUIChat");
    require("Logic/Presenter/UI/Main/MainUI/MainUIFunBtns");
    require("Logic/Presenter/UI/Main/MainUI/MainUITask");
    require("Logic/Presenter/UI/Main/MainUI/MainUIPlayerInfo");
    require("Logic/Presenter/UI/Main/MainUI/MainUISystemInfo");
    require("Logic/Presenter/UI/Main/MainUI/MainUIFastFriendChat");
    require("Logic/Presenter/UI/Main/MainUI/MainUIEnemyInfo");
    require("Logic/Presenter/UI/Main/MainUI/MainUIEquip");
    require("Logic/Presenter/UI/Main/MainUI/MainUIAIPet");
    require("Logic/Presenter/UI/Main/MainUI/MainUINPCFunctionEntry");
    mMainUIComponents[#mMainUIComponents + 1] = MainUIJoyStick.new(self);-- -1
    mMainUIComponents[#mMainUIComponents + 1] = MainUISkill.new(self);--<100
    mMainUIComponents[#mMainUIComponents + 1] = MainUIChat.new(self);--100-200
    mMainUIComponents[#mMainUIComponents + 1] = MainUIFunBtns.new(self);--200~500
    mMainUIComponents[#mMainUIComponents + 1] = MainUITask.new(self);--300~400
    mMainUIComponents[#mMainUIComponents + 1] = MainUIPlayerInfo.new(self);--0~100
    mMainUIComponents[#mMainUIComponents + 1] = MainUISystemInfo.new(self);--nil
    mMainUIComponents[#mMainUIComponents + 1] = MainUIFastFriendChat.new(self);--600~650
    mMainUIComponents[#mMainUIComponents + 1] = MainUIEnemyInfo.new(self);--700~800
    mMainUIComponents[#mMainUIComponents + 1] = MainUIEquip.new(self);--nil
    mMainUIComponents[#mMainUIComponents + 1] = MainUIAIPet.new(self);--1000~1100
    mMainUIComponents[#mMainUIComponents + 1] = MainUINPCFunctionEntry.new(self);--1200~1210
end

function OnEnable(self)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnEnable then component:OnEnable(self); end
    end
end

function OnDisable(self)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDisable then component:OnDisable(self); end
    end
end

function OnDestroy(self)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDestroy then component:OnDestroy(self); end
    end
end

function OnClick(go, id)
    if id == 0 then
        UIMgr.ShowUI(AllUI.UI_Title);
        return;
    end
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnClick then component:OnClick(id); end
    end
end

function OnPress(press, id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnPress then component:OnPress(id,press); end
    end
end

function OnLongPress(id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnLongPress then component:OnLongPress(id); end
    end
end

function OnDrag(delta,id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDrag then component:OnDrag(delta,id); end
    end
end

function OnDragStart(id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDragStart then component:OnDragStart(id); end
    end
end

function OnDragEnd(id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDragEnd then component:OnDragEnd(id); end
    end
end

function OnDragOver(id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDragOver then component:OnDragOver(id); end
    end
end

function OnDragOut(id)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnDragOut then component:OnDragOut(id); end
    end
end

function OnAction(params)
    for i = 1,#mMainUIComponents do
        local component = mMainUIComponents[i];
        if component.OnAction then component:OnAction(params); end
    end
end