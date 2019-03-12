module("UI_Tips_ConfirmPlayer", package.seeall)

--组件
local mSelf
local mConfirmWidget

--变量
local mEvents = {}
local mOriginLayer
local mOriginDepth

local mOriginOkFunc
local mOriginCancelFunc

local ConfirmWidget = class("ConfirmWidget")
function ConfirmWidget:ctor(onNewLayer, onResetLayer, ui)
    local path = "Offset/WithWidgetRoot";
    --组件
    self._gameObject = ui:FindGo(path);
    self._content = ui:FindComponent("UILabel", path .. "/Content/Label");
    self._icon = ui:FindComponent("UITexture", path.."/Content/Item/Icon");
    self._name = ui:FindComponent("UILabel", path.."/Content/Item/Name");
    self._level = ui:FindComponent("UILabel", path.."/Content/Item/Level");
    self._intimacy = ui:FindComponent("UILabel", path.."/Content/Item/Intimacy");
    self._intimacyGo = self._intimacy.gameObject;

    self._okTrs = ui:Find(path.."/EnsureBtn");
    self._okDes = ui:FindComponent("UILabel", path.."/EnsureBtn/Label");
    self._okGo = self._okTrs.gameObject;
    self._cancelTrs = ui:Find(path.."/CancelBtn");
    self._cancelDes = ui:FindComponent("UILabel", path.."/CancelBtn/Label");
    self._cancelGo = self._cancelTrs.gameObject;

    --变量
    self._isShowed = false;
    self._okPos = self._okTrs.localPosition;
    self._cancelPos = self._cancelTrs.localPosition;
    self._middlePos = Vector3(0, self._okPos.y, self._okPos.z);
    self._data = {};
    self._waitList = {};
    self._onNewLayer = onNewLayer;
    self._onResetLayer = onResetLayer;
    self._layerChanged = false;

    
end

function ConfirmWidget:OnBtnClick(call)--self._data.okFunc--self._data.cancelFunc--self._data.closeFunc
    if call and type(call) == "function" then
        call();
    end
    self:ResetLayer()
    self:CheckNext()
end

function ConfirmWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function ConfirmWidget:InitStyle()
    --如果style是nil，则按照all规则
    if not self._data.style then
        self._data.style = WordData_pb.TipTypeData.STYLE_ALL
    end
    if self._data.style == WordData_pb.TipTypeData.STYLE_OK then
        self._okGo:SetActive(true)
        self._cancelGo:SetActive(false)
        self._okTrs.localPosition = self._middlePos
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_CANCEL then
        self._okGo:SetActive(false)
        self._cancelGo:SetActive(true)
        self._cancelTrs.localPosition = self._middlePos
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_ALL then
        self._okGo:SetActive(true)
        self._cancelGo:SetActive(true)
        self._okTrs.localPosition = self._okPos
        self._cancelTrs.localPosition = self._cancelPos
    end

    self:InitBtnDes()
end

function ConfirmWidget:InitBtnDes()
    if self._data.style == WordData_pb.TipTypeData.STYLE_OK then
        if self._data.okStr and type(self._data.okStr) == "string" then
            self._okDes.text = self._data.okStr
        else
            self._okDes.text = WordData.GetWordStringByKey("UI_Common_OK");--确认
        end
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_CANCEL then
        if self._data.cancelStr and type(self._data.cancelStr) == "string" then
            self._cancelDes.text = self._data.cancelStr
        else
            self._cancelDes.text = WordData.GetWordStringByKey("UI_Common_Cancel");--"取消"
        end
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_ALL then
        if self._data.okStr and type(self._data.okStr) == "string" then
            self._okDes.text = self._data.okStr
        else
            self._okDes.text = WordData.GetWordStringByKey("UI_Common_OK");--确认
        end
        if self._data.cancelStr and type(self._data.cancelStr) == "string" then
            self._cancelDes.text = self._data.cancelStr
        else
            self._cancelDes.text = WordData.GetWordStringByKey("UI_Common_Cancel");--"取消"
        end
    end
end

function ConfirmWidget:InitPlayer()
    local player = SocialPlayerMgr.FindMemberByID(self._data.pid);
    self._level.text = player:GetLevel();
    self._name.text = player:GetRemark();
    player:SetHeadIcon(self._icon);

    if player:IsFriend() then
        self._intimacy.text = player:GetIntimacy();
        self._intimacyGo:SetActive(true);
    else
        self._intimacyGo:SetActive(false);
    end
end
    
function ConfirmWidget:GetPlayerID()
    return self._data.pid;
end

function ConfirmWidget:ResetLayer()
    if self._layerChanged and self._onResetLayer and type(self._onResetLayer) == "function" then
        self._onResetLayer()
    end
end

--检测是否需要修改layer
function ConfirmWidget:CheckNewLayer()
    self._layerChanged = false

    if self._data.newLayer and type(self._data.newLayer) == "number" 
    and self._data.newDepth and type(self._data.newDepth) == "number" then
        if self._onNewLayer and type(self._onNewLayer) == "function" then
            self._onNewLayer(self._data.newLayer, self._data.newDepth)
            self._layerChanged = true
        end
    end
end

function ConfirmWidget:DoShow(data)
    self:SetVisible(true)
    self._data = data

    self:CheckNewLayer()

    self:InitStyle()
    self._content.text = self._data.content;
    self:InitPlayer();
end

--[[
data =
{
    content = content,
    style = style,
    okFunc = okFunc,
    cancelFunc = cancelFunc,
    okStr = okStr,
    cancelStr = cancelStr,
    newLayer = newLayer,
    newDepth = newDepth,
    pid = pid;
}
--]]
function ConfirmWidget:Show(data)
    if self:IsShowed() then
        table.insert(self._waitList, data)
    else
        self:DoShow(data)
    end
end

function ConfirmWidget:CheckNext()
    if #self._waitList > 0 then
        local data = table.remove(self._waitList, 1)
        self:DoShow(data)
    else
        self:Hide()
    end
end

function ConfirmWidget:Hide()
    self:SetVisible(false)
end

function ConfirmWidget:IsShowed()
    return self._isShowed
end

--local方法
local function ResetLayer()
    UIMgr.ChangeLayer(AllUI.UI_Tips_ConfirmPlayer, mOriginLayer, mOriginDepth)
end

local function NewLayer(newLayer, newDepth)
    UIMgr.ChangeLayer(AllUI.UI_Tips_ConfirmPlayer, newLayer, newDepth)
end

local function OnShowConfirm(data)
    if data then
        mConfirmWidget:Show(data)
    end
end

--强制关闭当前显示的确认框
local function OnCloseConfirm()
    mConfirmWidget:OnBtnClick(self._data.closeFunc);
end

--当玩家属性变化
local function OnPlayerAttr(player)
    if not mConfirmWidget then return; end
    if not mConfirmWidget:IsShowed() then return; end
    if mConfirmWidget:GetPlayerID() ~= player:GetID() then return; end
    mConfirmWidget:InitPlayer();
end

local function RegEvent(self)
    GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM_PLAYER, OnShowConfirm)
    GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM_PLAYER, OnCloseConfirm)
    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,OnPlayerAttr);
end

local function UnRegEvent(self)
    GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM_PLAYER,OnShowConfirm)
    GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM_PLAYER,OnCloseConfirm)
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,OnPlayerAttr);
end

function OnCreate(self)
    mSelf = self

    mConfirmWidget = ConfirmWidget.new(NewLayer, ResetLayer, self)
    mConfirmWidget:Hide()

    mOriginLayer = AllUI.UI_Tips_ConfirmPlayer.layer
    mOriginDepth = AllUI.UI_Tips_ConfirmPlayer.depth
end

function OnEnable(self)
    RegEvent(self)
end

function OnClick(go,id)
    if not mConfirmWidget._data then return; end
    if id == 1 then
        mConfirmWidget:OnBtnClick(mConfirmWidget._data.okFunc);
    elseif id == 2 then
        mConfirmWidget:OnBtnClick(mConfirmWidget._data.cancelFunc);
    end
end

function OnDisable(self)
    UnRegEvent(self)
end