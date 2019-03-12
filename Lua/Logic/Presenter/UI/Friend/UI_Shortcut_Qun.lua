module("UI_Shortcut_Qun",package.seeall)
require("Logic/Presenter/UI/Friend/UI_Friend_Main");
require("Logic/Presenter/UI/Friend/UI_Friend_QunAddPlayer");
require("Logic/Presenter/UI/Friend/UI_Friend_QunInfo");

local mNameLabel;
local mStaticsLabel;
local mIconTextureLoader;
local mButton3Label;
local mCallbacks = {};

local mQun;

function DismissQun()
    local qname = mQun:GetName();
    local function ConfirmDismissQun()
        local qname = mQun:GetName();
        ChatMgr.RequestDestoryCligroup(mQun);
    end 

    TipsMgr.TipConfirmByKey("friend_qun_dismiss_ensure",ConfirmDismissQun,nil,qname);--群解散确认
end

local function ConfirmQuitQun()
    ChatMgr.RequestLeaveCligroup(mQun);
end
local function QuitQun()
    TipsMgr.TipConfirmByKey("friend_qun_quit_ensure",ConfirmQuitQun,nil,mQun:GetName());--退出群确认
end

local function ShowInfo()
    UI_Friend_QunInfo.ShowQunInfo(mQun);
end

local function AskFriend()
    UI_Friend_QunAddPlayer.ShowQun(mQun);
end

local function QuickTalk()
    UI_Friend_Main.TryChat(mQun);
end

function OnCreate(ui)
    local path = "Offset/Bg/";
    mNameLabel = ui:FindComponent("UILabel", path.."BaseInfo/LabelName");
    mStaticsLabel = ui:FindComponent("UILabel", path.."BaseInfo/LabelCount");
    local iconTexture = ui:FindComponent("UITexture", path.."HeadBg/IconTexture");
    mIconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    local grid = ui:Find(path.."ButtonGrid");
    local labels = {};
    for i=0,grid.childCount-1 do
        local button = grid:GetChild(i);
        button:GetComponent("UIEvent").id = 1+i;
        
        labels[i+1] = button:Find("Label"):GetComponent("UILabel");
    end
    mButton3Label = labels[3];

    mCallbacks = {};
    mCallbacks[1] = ShowInfo;
    mCallbacks[2] = AskFriend;
    mCallbacks[4] = QuickTalk;

end

function OnEnable(ui)

    mNameLabel.text = mQun:GetName();
    mStaticsLabel.text = string.format("%s/%s",mQun:GetMemberCountInfo());
    mIconTextureLoader:LoadObject(mQun:GetIconID());

    if mQun:IsMyQun() then
        mButton3Label.text = WordData.GetWordStringByKey("friend_qun_dimiss");--群快捷界面，解散群组
        mCallbacks[3] = DismissQun;
    else
        mButton3Label.text = WordData.GetWordStringByKey("friend_qun_quit");--群快捷界面，退出群组
        mCallbacks[3] = QuitQun;
    end
end

function OnDisable(ui)

end

function OnClick(go, id)
    if mCallbacks[id] then
        mCallbacks[id]();
    end
    UIMgr.UnShowUI(AllUI.UI_Shortcut_Qun);
end

function ShowQun(qun)
    mQun = qun;
    UIMgr.ShowUI(AllUI.UI_Shortcut_Qun);
end

