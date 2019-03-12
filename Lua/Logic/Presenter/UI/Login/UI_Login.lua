--[[
    author:{hesinian}
    time:2019-01-02 19:31:19
]]

module("UI_Login",package.seeall)

require("Logic/Presenter/UI/Login/UI_Login_GameIn");
require("Logic/Presenter/UI/Login/UI_Login_Account");
local mState = 0;

local function _ShowBg()
    UI_Login_GameIn.SetActive(false);
    UI_Login_Account.SetActive(false);
end

local function _ShowAccount()
    UI_Login_GameIn.SetActive(false);
    UI_Login_Account.SetActive(true);
end

local function _ShowGameIn()
    UI_Login_GameIn.SetActive(true);
    UI_Login_Account.SetActive(false);
end

local function ActiveUIWithState()
    if AllUI.UI_Login.enable then
        if mState == 0 then
            _ShowAccount();
        elseif mState == 1 then
            _ShowGameIn();
        elseif mState == 2 then
            _ShowBg();
        end
    else
        UIMgr.ShowUI(AllUI.UI_Login);
    end
end

function OnCreate(ui)
    UI_Login_GameIn.OnCreate(ui);
    UI_Login_Account.OnCreate(ui);
end

function OnEnable(ui)
    UI_Login_GameIn.OnEnable(ui);
    UI_Login_Account.OnEnable(ui);
    ActiveUIWithState();
end

function OnDisable(ui)
    UI_Login_GameIn.OnDisable(ui);
    UI_Login_Account.OnDisable(ui);
    mState = 0;
end

function OnClick(go, id)
    if id<50 then
        UI_Login_GameIn.OnClick(id);
    else
        UI_Login_Account.OnClick(id);
    end
end

function ShowAccount()
    mState = 0;
    ActiveUIWithState();
end

function ShowGameIn()
    mState = 1;
    ActiveUIWithState();
end

function ShowBg()
    mState = 2;
    ActiveUIWithState();
end
