module("UI_PersonalSpace_Main",package.seeall)

local titleLabel=nil

--朋友圈 101
local mTabFriend;
--留言板 102
local mTabMsgBoard;
--广场 103
local mTabSquare;
--回忆 104
local mTabMemory;

local mCurSelectR =101
local mInfoTabs = nil
local mInfoTab = nil
local mTagTab = nil
local mCurSelectInfo = 301
local mShowMode = 2
local mPlayerId =1
local mButtons = {}

function OnCreate(self)
    titleLabel = self:FindComponent("UILabel", "Bg/LabelTitle")
    mTabFriend = self:FindComponent("UIToggle","Bg/Tabs/TabFriend");
    mTabMsgBoard = self:FindComponent("UIToggle","Bg/Tabs/TabMsgBoard");
    --mTabSquare = self:FindComponent("UIToggle","Bg/Tabs/TabSquare");
    mTabMemory = self:FindComponent("UIToggle","Bg/Tabs/TabMemory");

    mButtons.mBtnGift = self:Find("Bottom/BtnGift").gameObject;
    mButtons.mBtnEdit = self:Find("Bottom/BtnEdit").gameObject;
    mButtons.mBtnCustom = self:Find("Bottom/BtnCustom").gameObject;
    mButtons.mBtnShare = self:Find("Bottom/BtnShare").gameObject;
    mButtons.mBtnLike = self:Find("Bottom/BtnLike").gameObject;
    mButtons.mBtnVistor = self:Find("Bottom/BtnVistor").gameObject;
    mButtons.mBtnBrowse = self:Find("Bottom/BtnBrowse").gameObject;
    mButtons.mBtnBrowseLabel = self:FindComponent("UILabel","Bottom/BtnBrowse/Label");
    mButtons.mBtnSendMsg = self:Find("Bottom/BtnSendMsg").gameObject;
    mButtons.mBtnPresent = self:Find("Bottom/BtnPresent").gameObject;
    mButtons.mBtnMeet = self:Find("Bottom/BtnMeet").gameObject;
    mButtons.mBtnStepOn = self:Find("Bottom/BtnStepOn").gameObject;
    mButtons.mBtnLeaveMsg = self:Find("Bottom/BtnLeaveMsg").gameObject;
    mInfoTabs = self:Find("Tabs").gameObject;
    mInfoTab = self:FindComponent("UIToggle","Tabs/TabInfo");
    mTagTab = self:FindComponent("UIToggle","Tabs/TabTag");
    local mInfoLabel = self:FindComponent("UILabel","Tabs/TabInfo/Label");
    local mTagLabel = self:FindComponent("UILabel","Tabs/TabTag/Label");
    mInfoLabel.text =  TipsMgr.GetTipByKey("personspace_btn_xinxi")
    mTagLabel.text =  TipsMgr.GetTipByKey("personspace_btn_biaoqian")
    -- local mBtnLikeLabel = self:FindComponent("UILabel","Bottom/BtnLike/Label");
    -- mBtnLikeLabel.text =  TipsMgr.GetTipByKey("personspace_btn_xinxi")
    local mBtnSendMsgLabel = self:FindComponent("UILabel","Bottom/BtnSendMsg/Label");
    mBtnSendMsgLabel.text =  TipsMgr.GetTipByKey("personspace_btn_sendmsg")
    local mBtnVistorLabel = self:FindComponent("UILabel","Bottom/BtnVistor/Label");
    mBtnVistorLabel.text =  TipsMgr.GetTipByKey("personspace_btn_news")
end

function OnEnable(self,playerid,mode)
    RegEvent(self)
    mPlayerId = playerid
    mShowMode = mode
    mCurSelectR = 101
    mCurSelectInfo = 301
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,MomentsUpdated);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,MomentsUpdated);
    mEvents = {};
end

function ToggleInfoTab()
    local tabshow = mCurSelectR==101 or mCurSelectR==102
    mInfoTabs:SetActive(tabshow)
    mInfoTab:Set(mCurSelectInfo == 301,true);
    mTagTab:Set(mCurSelectInfo == 302,true);
    if tabshow then 
        if mCurSelectInfo == 301 then--个人信息
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_Info,nil,nil,nil,nil,true,mPlayerId,mShowMode);
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Tag);
        elseif mCurSelectInfo == 302 then--标签
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Info);
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_Tag);
        end
    else
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Info);
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Tag);
    end
end

function InitToggle(reOpen)
    mTabFriend:Set(mCurSelectR == 101,true);
    mTabMsgBoard:Set(mCurSelectR == 102,true);
    --mTabSquare:Set(mCurSelectR == 103,true);
    mTabMemory:Set(mCurSelectR == 104,true);
end

--界面切换
function ToggleR(id,reOpen)
    if mCurSelectR ~= id or reOpen then
        mCurSelectR = id;
        if id == 101 then--朋友圈
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_Moments,nil,nil,nil,nil,true,mPlayerId,mShowMode);
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_MsgBoard);
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Memory);
        elseif id == 102 then--留言板
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Moments);
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_MsgBoard);
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Memory);
        -- elseif id == 103 then--广场
        --     UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Moments);
        --     UIMgr.UnShowUI(AllUI.UI_PersonalSpace_MsgBoard);
        elseif id == 104 then--回忆
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Moments);
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_MsgBoard);
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_Memory);
        end
    end
    InitToggle();
    ToggleBtns()
    ToggleInfoTab()
end

function ToggleBtns()
    mButtons.mBtnGift:SetActive(true)
    mButtons.mBtnEdit:SetActive(true)
    mButtons.mBtnCustom:SetActive(true)
    mButtons.mBtnShare:SetActive(true)
    
    mButtons.mBtnVistor:SetActive(mCurSelectR==101)
    mButtons.mBtnBrowse:SetActive(mCurSelectR==101)
    mButtons.mBtnSendMsg:SetActive(mCurSelectR==101)

    mButtons.mBtnLike:SetActive(false)
    mButtons.mBtnPresent:SetActive(false)
    mButtons.mBtnMeet:SetActive(false)
    mButtons.mBtnStepOn:SetActive(false)

    mButtons.mBtnLeaveMsg:SetActive(false);
end

function OnToggle(id,reOpen)
    if id <= 104 and id >= 101 then      
        ToggleR(id,reOpen);
    end
end

function CloseSecondUI()
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Info);
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Tag);
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Moments);
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_MsgBoard);
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Memory);
end

--朋友圈更新
function MomentsUpdated(playerid,momentdata,showmode)
    mShowMode = showmode
    UpdateView()
end

function UpdateView()
    ToggleR(mCurSelectR,true)
    if mShowMode== 1 then
        mButtons.mBtnBrowseLabel.text = TipsMgr.GetTipByKey("personspace_btn_everyone")
    else
        mButtons.mBtnBrowseLabel.text = TipsMgr.GetTipByKey("personspace_btn_myself")
    end
end

function OnClick(go, id)
    --切换界面
    if id >= 101 and id<= 104 then
        OnToggle(id);
    elseif id == 0 then --关闭
        CloseSecondUI()
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Main);
        PersonSpaceMgr.PopShowPlayerId()
    elseif id == 201 then --礼物按钮
    elseif id == 202 then --编辑按钮
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_InfoSetting);
    elseif id == 203 then --自定义按钮
    elseif id == 204 then --分享按钮
    elseif id == 205 then --喜欢的按钮
       
    elseif id == 206 then --看过我按钮
     
    elseif id == 207 then --我的按钮
        if mShowMode== 2 then
            mShowMode=1
            PersonSpaceMgr.OpenPSpaceOnlyOnePerson(UserData.PlayerID)
        else
            mShowMode=2
            PersonSpaceMgr.OpenPSpaceMain()
        end
        UpdateView()
    elseif id == 208 then --发一条按钮
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_EditorMsg)
    elseif id == 209 then --送礼
    elseif id == 210 then --结识
    elseif id == 211 then --踩一下
    elseif id == 212 then --留言
    elseif id == 301 then --
        mCurSelectInfo=301
        ToggleInfoTab()
    elseif id == 302 then --
        mCurSelectInfo=302
        ToggleInfoTab()
    end
end


