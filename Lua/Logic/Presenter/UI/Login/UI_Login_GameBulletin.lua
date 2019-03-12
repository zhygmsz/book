module("UI_Login_GameBulletin", package.seeall)
local mScrollView;
local mContentLabel;

local mFirstTimeOpen = true;

local function OnReceiveBullet(content)
    if not content then content = ""; end
    mContentLabel.text = content;
end

function OnCreate(self)
    local scrollViewTrans = self:Find("Root/Content/Scroll View");
    mScrollView = scrollViewTrans:GetComponent("UIScrollView");
    mContentLabel = scrollViewTrans:Find("LabelContent"):GetComponent("UILabel");
end

function OnEnable(self)
    UI_Login.ShowBg();
    OnReceiveBullet(LoginMgr.GetBulletNotice());
    GameEvent.Reg(EVT.LOGIN, EVT.LOGIN_BULLET,OnReceiveBullet);
end

function OnDisable(ui)
    mFirstTimeOpen = false;
    GameEvent.UnReg(EVT.LOGIN, EVT.LOGIN_BULLET,OnReceiveBullet);
end

function OnClick(go, id)
    UIMgr.UnShowUI(AllUI.UI_Login_GameBulletin);
    UI_Login.ShowGameIn();
end