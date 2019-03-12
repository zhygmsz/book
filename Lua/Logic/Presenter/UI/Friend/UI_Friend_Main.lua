module("UI_Friend_Main",package.seeall);

local PlayerContact = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/PanelContactPlayer");
local LatestContact = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/PanelContactLatest");
local QunContact = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/PanelContactQun");
local NPCContact = require("Logic/Presenter/UI/Friend/Main/UIPanelContact/PanelContactNPC");

local PanelChatPrivate = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatPrivate");
local PanelChatQun = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatQun");
local PanelChatNPC = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatNPC");
local PanelChatNone = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatNone");

local FriendChatInput = require("Logic/Presenter/UI/Friend/Main/UIInput/FriendChatInput");

local mContactManager = {};
local mContactPlayer;
local mContactLatest;
local mContactQun;
local mContactNPC;

local mTogglePlayer;
local mToggleLatest;
local mToggleQun;
local mToggleNPC;

local mChatManager = {};
local mChatPlayer;
local mChatQun;
local mChatNPC;
local mChatNone;
local mChatAIPet;

local mOpenContact;
local mOpenChatter;

local mInput;


local function OpenChatPanel(index,chatter)
    mOpenChatter = chatter;
    if mChatManager.openChat then
        mChatManager.openChat:OnDisable();
    end
    mChatManager.openChat = mChatManager[index];
    mChatManager[index]:OnEnable(chatter);
end

local function SetContactActive(panel,active)
    if active then   mOpenContact = panel;  end
    panel:SetState(active);
end
local function OnLatestPanelClick()
    SetContactActive(mContactLatest, mToggleLatest.value);
end

local function OnPlayerPanelClick()
    SetContactActive(mContactPlayer, mTogglePlayer.value);
end
local function OnQunPanelClick()
    SetContactActive(mContactQun, mToggleQun.value);
end
local function OnNPCPanelClick()
    SetContactActive(mContactNPC, mToggleNPC.value);
end

function OnCreate(ui)
    local path = "Offset/Left/Center/DragAreaFriend";
    mContactPlayer = PlayerContact.new(ui,path);
    table.insert(mContactManager,mContactPlayer);
    path = "Offset/Left/Center/DragAreaLatest";
    mContactLatest = LatestContact.new(ui,path);
    table.insert(mContactManager,mContactLatest);
    path = "Offset/Left/Center/DragAreaQun";
    mContactQun = QunContact.new(ui,path);
    table.insert(mContactManager,mContactQun);
    path = "Offset/Left/Center/DragAreaNPC";
    mContactNPC = NPCContact.new(ui,path);
    table.insert(mContactManager,mContactNPC);

    path = "Offset/Left/Top/Top";
    mToggleLatest = ui:FindComponent("UIToggle",path.."/Button15");
    mTogglePlayer = ui:FindComponent("UIToggle",path.."/Button16");
    mToggleQun = ui:FindComponent("UIToggle",path.."/Button17");
    mToggleNPC = ui:FindComponent("UIToggle",path.."/Button18");
    EventDelegate.Add(mToggleLatest.onChange, EventDelegate.Callback(OnLatestPanelClick));
    EventDelegate.Add(mTogglePlayer.onChange, EventDelegate.Callback(OnPlayerPanelClick));
    EventDelegate.Add(mToggleQun.onChange, EventDelegate.Callback(OnQunPanelClick));
    EventDelegate.Add(mToggleNPC.onChange, EventDelegate.Callback(OnNPCPanelClick));

    local basicPath = "Offset/Main/Bottom/SpriteBG";
    local inputPath = "Offset/Main/Top/InputRoot";
    mInput = FriendChatInput.new(ui,inputPath);
    path = "Offset/Main/Center/ChatPrivate";
    mChatPlayer = PanelChatPrivate.new(ui,path,basicPath,inputPath,mInput);
    mChatManager[1] = mChatPlayer;
    path = "Offset/Main/Center/ChatQun";
    mChatQun = PanelChatQun.new(ui,path,basicPath,inputPath,mInput);
    mChatManager[2] = mChatQun;
    path = "Offset/Main/Center/ChatNPC";
    mChatNPC = PanelChatNPC.new(ui,path,basicPath,inputPath);
    mChatManager[3] = mChatNPC;
    path = "Offset/Main/Center/ChatNone";
    mChatNone = PanelChatNone.new(ui,path,basicPath,inputPath);
    mChatManager[4] = mChatNone;    
end

function OnEnable(self)
    if not AllUI.UI_Relation.enable then
        UI_Relation.ShowUI(1);
    end
    if not mOpenContact then

        mToggleLatest.value = true;
    else
        mOpenContact:OnEnable();
    end
end

function OnDisable(self)
    mChatManager.openChat:OnDisable();
end

function OnDestroy(self)
    
    EventDelegate.Remove(mToggleLatest.onChange, EventDelegate.Callback(OnLatestPanelClick));
    EventDelegate.Remove(mTogglePlayer.onChange, EventDelegate.Callback(OnPlayerPanelClick));
    EventDelegate.Remove(mToggleQun.onChange, EventDelegate.Callback(OnQunPanelClick));
    EventDelegate.Remove(mToggleNPC.onChange, EventDelegate.Callback(OnNPCPanelClick));

    for i=1, #mContactManager do
        if mContactManager[i].OnDestroy then
            mContactManager[i]:OnDestroy();
        end
    end
end

function mContactManager.OnClick(id)
    for i=1, #mContactManager do
        mContactManager[i]:OnClick(id);
    end
end

function mChatManager.OnClick(id)
    if mChatManager.openChat.OnClick then
        mChatManager.openChat:OnClick(id);
    end
end

function OnClick(go, id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    -- if id == 0 then
    --     UIMgr.UnShowUI(AllUI.UI_Friend_Main);
    -- elseif id == 1 then
    --     UIMgr.UnShowUI(AllUI.UI_Friend_Main)
    --     UIMgr.ShowUI(AllUI.UI_Mail)
    -- elseif id == 2 then
    --     GameLog.Log("ShowUI Master");
    -- elseif id == 3 then
    --     GameLog.Log("ShowUI Brother");
    -- elseif id == 4 then
    --     GameLog.Log("ShowUI marriage");
    if id >= 11 and id<= 14 then -- 左边栏下的按钮组 
        
        if id == 11 then -- 添加好友界面
            UIMgr.ShowUI(AllUI.UI_Friend_Ask);
        elseif id == 13 then
            --PersonSpaceMgr.OpenPSpaceMain();
            TipsMgr.TipByFormat("个人空间未开启");
        elseif id == 14 then
            UIMgr.ShowUI(AllUI.UI_Friend_Settings);
        end
    elseif id == 15 then -- 最近联系人
    elseif id == 16 then -- 群聊
    elseif id == 17 then -- 联系人
    elseif id == 18 then -- NPC好友
    elseif id >=35 and id <=39  then
        mInput:OnClick(id);
    elseif id >= 40 and id < 2000 then
        mChatManager.OnClick(id);
    elseif id >= 2000 then
        mContactManager.OnClick(id);
    end
end

function OnPress(press,id)
    mInput:OnPress(press,id);
end

function OnDragOver(id)
	mInput:OnDragOver(id);
end

function OnDragOut(id)
	mInput:OnDragOut(id);
end


function TryChat(chatter)
    
    if not AllUI.UI_Friend_Main.enable then
        
        UIMgr.ShowUI(AllUI.UI_Friend_Main, chatter, TryChat);
    else
        SocialChatMgr.AddChater(chatter);
        mContactLatest:ResetSelect();
        mToggleLatest.value = true;
    end
end

function ShowChat(chatter)
    if not chatter then
        OpenChatPanel(4,chatter);
    elseif string.find(chatter.__cname,"Qun") then
        OpenChatPanel(2,chatter);
    elseif chatter:IsNPC() then
        OpenChatPanel(3,chatter);
    else
        OpenChatPanel(1,chatter);
    end
end


