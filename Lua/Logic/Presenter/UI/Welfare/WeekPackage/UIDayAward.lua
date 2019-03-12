--[[
    author:{hesinian}
    time:2018-12-25 17:00:15
]]
local UIDayAward = class("UIDayAward")

function UIDayAward:ctor(ui,path,eventId)
    self._ui = ui;
    self._receivedGo = ui:Find(path.."/BtnReceived").gameObject;
    self._receivingGo = ui:Find(path.."/BtnReceiving").gameObject;
    ui:FindComponent("UIEvent",path.."/BtnReceived").id = eventId;
    ui:FindComponent("UIEvent",path.."/BtnReceiving").id = eventId + 1;

    self._timeLabel = ui:FindComponent("UILabel",path.."/TimeDay");
    self._timeGo = self._timeLabel.gameObject;
    local grid = ui:FindComponent("UIGrid",path.."/Grid");
    local prefab = ui:Find(path.."/Grid/Item");
    self._awardGrid = UICommonItemListGrid.new(ui,grid,prefab,eventId + 2);
    self._eventId = eventId;
end

function UIDayAward:Refresh(award)
    self._data = award;
    
    local received = award:IsReceived();
    self._receivedGo:SetActive(received);
    self._receivingGo:SetActive(not received);
    self._timeGo:SetActive(not award:IsAvailable());

    self._items = award:GetDropItems();
    self._awardGrid:Refresh(self._items);
end

function UIDayAward:OnClick(id)
    id = id - self._eventId;
    if id == 0 then
        AllPackageMgr.RequestReceiveDayAward(self._data);
    elseif id == 1 then
    else
        self._awardGrid:OnClick(id + self._eventId);
    end
end

return UIDayAward;