module("UI_AIPet_Home",package.seeall);
require("Logic/Presenter/UI/Common/UITableWrap/UITableWrapUtils");
local AIPetHomeModel = require("Logic/Presenter/UI/AIPet/Home/AIPetHomeModel");
--local mChatPanel = require("Logic/Presenter/UI/AIPet/Home/mChatPanel");
local AIPetHomeResume = require("Logic/Presenter/UI/AIPet/Home/AIPetHomeResume");
require("Logic/Presenter/UI/AIPet/UI_AIPet_Clothes");

local RSTATE = {idle = -1, preBegin = 0, recording = 1, prepare = 5, forCancel = 2, waitResult=3, finish = 4};
local mContentBotton;
local mResume;
local mChatPanel = {};

local mSelectPet;
local mMessaageIDs;

local function CreateTweenCom(tweenUI, tweens)
    local tweenOut = nil;
    local tweenBack = nil;
    if tweens[0].tweenGroup == 10 then
        tweenOut = tweens[0];
        tweenBack = tweens[1];
    else
        tweenOut = tweens[1];
        tweenBack = tweens[0];
    end
    return UITweenOutBack.new(tweenOut,tweenBack,false);
end

function OnPetActive(pet)
    local pid = pet:GetID();
    if pet:IsActive() then
        MapMgr.CreateEntity(EntityDefine.ENTITY_TYPE.AIPET,pid, pet);
    else
        MapMgr.DestroyEntity(EntityDefine.ENTITY_TYPE.AIPET,pid);
    end
end

function OnClickEntity(tapEntity)
    if tapEntity:GetType() == EntityDefine.ENTITY_TYPE.AIPET then
        mSelectPet = AIPetMgr.GetPetInfo(tapEntity:GetID());
        mResume:Show(mSelectPet);
        mContentBotton:TweenOut();
    end
end

function OnCreate(ui)

    local tweens = ui:Find("Offset/ButtonContent/ButtonsPanel/ButtonTweens"):GetComponents(typeof(TweenPosition));
    mContentBotton = CreateTweenCom(self,tweens);

    mResume = AIPetHomeResume.new(ui);
    mChatPanel:OnCreate(ui);
end

function OnEnable(ui)
    local petInfos = AIPetMgr.GetAllActivePets();
    for i,pet in ipairs(petInfos) do
        local pid = pet:GetID();
        --MapMgr.CreateEntity(EntityDefine.ENTITY_TYPE.AIPET,pid, pet);
    end
    
    UpdateBeat:Add(mChatPanel.OnUpdate,mChatPanel);
    mChatPanel:OnEnable();
    mResume:Show(false);

    GameEvent.Reg(EVT.AIPET,EVT.AIPET_ACTIVE,OnPetActive);
    GameEvent.Reg(EVT.AIPET,EVT.AIPET_MAIN,mResume.OnPetInUse,mResume);
    GameEvent.Reg(EVT.COMMON,EVT.CLICK_ENTITY,OnClickEntity);
    GameEvent.Reg(EVT.AIPET,EVT.DIALOG_CLEAR_ALL,mChatPanel.RefreshMsgContent);
    
end

function OnDisable(ui)
    mContentBotton:TweenBack();
    UpdateBeat:Remove(mChatPanel.OnUpdate,mChatPanel);

    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_ACTIVE,OnPetActive);
    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_MAIN,mResume.OnPetInUse,mResume);
    GameEvent.UnReg(EVT.COMMON,EVT.CLICK_ENTITY,OnClickEntity);
    GameEvent.UnReg(EVT.AIPET,EVT.DIALOG_CLEAR_ALL,mChatPanel.RefreshMsgContent);

    mMessaageIDs = nil;

end

function OnClick(go,id)
    GameLog.Log("OnClick go:%s, is:%s",go.name,id);
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_AIPet_Home);
        GameNet.SendToGate(NetCS_pb.CSLeaveInstance());
        --AIPetMgr.ShowMainPet();
    elseif id == 1 then

    elseif id == 2 then
        --mResume:Show(true);
    elseif id == 3 then
        UI_AIPet_Clothes.ShowPet(mSelectPet);
        mResume:Show(false);
        mContentBotton:TweenBack();
    elseif id == 4 then

        TipsMgr.TipByFormat("Function is not open!");    
    elseif id == 5 then
        UIMgr.ShowUI(AllUI.UI_AIPet_Settings);  
    elseif id == 11 then
        mChatPanel.tweensCom:OnClick();
    elseif id == 14 then
        GameLog.Log("发送文字信息");
        mChatPanel:SendTextMsg();
    elseif id >= 21 and id <= 25 then
        -- local pid = AIPetMgr.GetPetIDByIndex(id - 20);
        -- AIPetMgr.SetClothesSelectedPet(pid);
        -- mResume:Show(true);
        -- mContentBotton:TweenOut();
    elseif id == 100 then
        mContentBotton:TweenBack();
        mResume:Show(false)
    elseif id >= 101 and id <= 200 then
        mResume:OnClick(id);
    end
    
end

function OnPress(pressed,id)
    if id == 12 then
        if pressed then
            GameLog.Log("按住说话");
            --开启录音
            mChatPanel:StartRecord();
        else
            mChatPanel:EndRecord();
        end
    end
end

function OnDrag(delta,id)
    if id == 12 then
        mChatPanel:CheckCancel(id);
    end
end

---聊天模块--
function mChatPanel:OnCreate(ui)
    local panelPath = "Offset/ChatPanel/Offset/";
    local openSprite = ui:FindComponent("UISprite",panelPath.."OpenButton/Arrow");
    
    local wrapTablePath = panelPath.."Chat/Scroll View/TableWrapContent";
    local wrapPrefab = ui:Find(wrapTablePath.."/WrapItem");

    local OnItemCreat = function(contentItem)
        local itemTran = contentItem.transform;
        local itemServer1 = {};
        local subItemTran = itemTran:Find("LeftMessage");
        itemServer1.gameObject = subItemTran.gameObject;
        itemServer1.contentLabel = subItemTran:Find("ContentText/Label"):GetComponent("UILabel");
        itemServer1.widget = subItemTran:Find("ContentText/SpriteBg"):GetComponent("UIWidget");
        contentItem.left = itemServer1;
        local itemServer2 = {};
        local subItemTran2 = itemTran:Find("RightMessage");
        itemServer2.gameObject = subItemTran2.gameObject;
        itemServer2.contentLabel = subItemTran2:Find("ContentText/Label"):GetComponent("UILabel");
        itemServer2.widget = subItemTran2:Find("ContentText/SpriteBg"):GetComponent("UIWidget");
        contentItem.right = itemServer2;
    end

    self.wrapItemList = UITableWrapUtils.InitWrapTable(ui,wrapPrefab,10,nil,OnItemCreat);--(ui,prefab,count,parentTrans,OnItemCreat)
    local OnItemInit = function(go,wrapIndex,realIndex)
        local OnItemEnabled = function(wrapData, wrapItem)
            -- local subItem;
            -- if wrapData.dType == AIPetMgr.AIPET_DIALOG.AIPET then
            --     subItem = wrapItem.left;
            -- else
            --     subItem = wrapItem.right;
            -- end
            -- subItem.gameObject:SetActive(true);
            -- subItem.contentLabel.text = wrapData.msg;
            -- return subItem.widget, 15;
        end
        UITableWrapUtils.OnItemInit(go,wrapIndex,realIndex,self.wrapItemList, self.wrapDataList, OnItemEnabled);
    end

    local itemAlignType = UITableWrapContent.Align.Bottom;
    local dataAlignType = UITableWrapContent.Align.Bottom;

    local tableWrapContent = ui:FindComponent("UITableWrapContent",wrapTablePath);
    self.onInitItemFunc = UITableWrapContent.OnInitializeItem(OnItemInit);
    self.RefreshMsgContent = function()
        self.wrapDataList = AIPetMgr.GetDialogs();
        tableWrapContent:ResetWrapContent(table.maxn(self.wrapDataList), self.onInitItemFunc,itemAlignType,dataAlignType,true)
    end
    self.UpdateContent = function()
        local oldcount = table.maxn(self.wrapDataList);
        self.wrapDataList = AIPetMgr.GetDialogs();
        local newcount = table.maxn(self.wrapDataList);
        tableWrapContent:UpdateContent(oldcount -1, newcount);
    end

    local tweens = ui:Find("Offset/ChatPanel/Offset"):GetComponents(typeof(TweenPosition));
    
    self.tweensCom = CreateTweenCom(self,tweens);
    self.tweensCom:UseDefaultMode(openSprite);

    local textInput = ui:FindComponent("LuaUIInput",panelPath.."InputButtons/TextInput");
    self.GetInput = function()
        local value = textInput.value;
        textInput.value = "";
        return value;
    end

    local recordGo = ui:Find(panelPath.."InputButtons/RecordState").gameObject;
    local prepareGo = ui:Find(panelPath.."InputButtons/RecordState/LabelPrepare").gameObject;
    local countDownSprite = ui:FindComponent("UISprite", panelPath.."InputButtons/RecordState/SpriteSpeech");
    local recordingGo = ui:Find(panelPath.."InputButtons/RecordState/SpriteSpeech/SpriteRecording").gameObject;
    local cancelGo = ui:Find(panelPath.."InputButtons/RecordState/SpriteSpeech/SpriteForCancel").gameObject;
    self.OnUIPrepareRecord = function()
        prepareGo:SetActive(true);
        recordingGo:SetActive(false);
        cancelGo:SetActive(false);
        recordGo:SetActive(true);
    end
    self.OnUIReadyRecord = function()
        prepareGo:SetActive(false);
        recordingGo:SetActive(true);
        countDownSprite.fillAmount = 1;
    end
    self.OnUIRecording = function(cancel, fillAmount)
        recordGo:SetActive(not cancel);
        cancelingGo:SetActive(cancel);
        countDownSprite.fillAmount = fillAmount;
    end
    self.OnUIRecordFinish = function()
        recordGo:SetActive(false);
    end

    return self;
end

function mChatPanel:OnEnable()
    --self.RefreshMsgContent();
    GameTimer.AddTimer(1,1,self.RefreshMsgContent);
end

function mChatPanel:StartRecord()
    if not SystemInfo.IsMobilePlatform() or SystemInfo.IsEditor() then
        TipsMgr.TipByFormat("电脑端无法监听！");
        return;
    end
    self.state = RSTATE.prepare;--准备录音
    GameLog.Log("Start Record");
    self.OnUIPrepareRecord();
    local ret = AIPetMgr.StartRecord(self.OnRecordReady);--调用sdk开始录音；
end

function mChatPanel:SendTextMsg()
    local msg = self.GetInput();
    if msg==nil or msg=="" then
        TipsMgr.TipByFormat("输入不能为空");
    end
    AIPetMgr.CallFairyText(msg);
end

function mChatPanel:EndRecord()   
    if self.state == RSTATE.prepare then
        self:CancelRecord();
    elseif self.state == RSTATE.recording then
        self:SendRecord();
    elseif self.state == RSTATE.forCancel then
        self:CancelRecord();
    end
end

function mChatPanel:CheckCancel(id)
    if self.state == RSTATE.recording or self.state == RSTATE.forCancel then
        local hoveredOb = UICamera.hoveredObject;
    	local go = UIMgr.GetUIEventGo(AllUI.UI_AIPet_Home,id)
        self.state = (go == hoveredOb) and RSTATE.recording or RSTATE.forCancel;
        GameLog.Log("OnDrag state".. tostring(self.state));
    end
end

function mChatPanel:CancelRecord()
    GameLog.Log("CancelRecord");
    self:OnUIRecordFinish();
    
    if self.state == RSTATE.recording then
        AIPetMgr.CancelRecord();    --调用sdk取消；
    end
    self.state = RSTATE.finish;
end

function mChatPanel:SendRecord()
    GameLog.Log("SendRecord");
    self.state = RSTATE.waitResult;--发送录音
    self.OnUIRecordFinish();
    AIPetMgr.StopRecord();
end

function mChatPanel.OnRecordReady()
    local _self = mChatPanel;
    if _self.state ~= RSTATE.prepare then
        return;
    end
    _self.state = RSTATE.recording;--开始录音
    _self.startTime = GameTime.time_L;
    _self.OnUIReadyRecord();
    GameLog.Log("OnRecordReady");
end

function mChatPanel:OnReceiveNewDialog(msg)
    self:UpdateContent();
end

function mChatPanel:OnUpdate()
    if self.state == RSTATE.recording or self.state == RSTATE.forCancel then
        local timePassed = (GameTime.time_L - self.startTime);
        --GameLog.Log("on recording timepassed "..tostring(timePassed));
        if self.timeLimit<= timePassed then
            self:SendRecord();
            return;
        end
        local canceling = self.state == RSTATE.forCancel;
        self.OnUIRecording(canceling,1 - timePassed/self.timeLimit);
    end
end