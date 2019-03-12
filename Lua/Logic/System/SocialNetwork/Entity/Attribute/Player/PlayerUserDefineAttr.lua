--[[
    玩家标签
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerUserDefineAttr = class("PlayerUserDefineAttr",PlayerBaseAttr)

function PlayerUserDefineAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 10;
end

function PlayerUserDefineAttr:RequestSyncAttr()
    local function OnSyncAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    local flagids = table.concat({  10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,
        10010,10011,10012,10013,10014,10015,10016,10017,10018,10019,
        10020,10021,10022,10023,10024,10025,10026,10027,10028,10029,
        10030,10031,10032,10033,10034,10035,10036,10037,10038,10039,
        10040,10041,10042,10043,10044,10045,10046,10047,10048,10049,
        10050,10051,10052,10053,10054
    },",");
    local params = string.format("id=%s&flag_ids=%s",self._id,flagids);
    SocialNetworkMgr.RequestAction("AskUserDefinedFlag",params,OnSyncAttr);
end

function PlayerUserDefineAttr:Refresh(characterTag)
    self.super.Refresh(self);
    if characterTag==nil then return  end

    self._realTable.characterTag ={}
    self._realTable.characterTagFromOther ={}
    self._realTable.systemTag ={}
    self._realTable.systemTagShowing ={}

    local datas = characterTag[self._id];
    for k,v in pairs(datas) do
        local index = tonumber(k)
        if index>=10000 and index <=10009 then
            table.insert(self._realTable.characterTag,v)
        elseif index>=10010 and index <=10019 then
            table.insert(self._realTable.characterTagFromOther,v)
        elseif index>=10020 and index <=10029 then
            table.insert(self._realTable.systemTagShowing,v)
        elseif index>=10030 and index <=10054 then
            table.insert(self._realTable.systemTag,v)
        end
    end
end

--个性标签
function PlayerUserDefineAttr:GetCharacterTags()

    local tags = self._proxy.characterTag;
    if not tags then return table.emtpyTable; end

    local temptags ={}
    for i=1,#tags do
        if tags[i]>0 then
            table.insert(temptags,tags[i])
        end
    end
    return temptags;
end
--别人给的个性标签
function PlayerUserDefineAttr:GetCharacterTagsFromOther()
    local tags = self._proxy.characterTagFromOther;
    if not tags then return table.emtpyTable; end

    local temptags ={}
    for i=1,#tags do
        if tags[i]>0 then
            table.insert(temptags,tags[i])
        end
    end
    return temptags;
end
--系统给的个性标签
function PlayerUserDefineAttr:GetCharacterTagsFromSystem()
    local tags = self._proxy.systemTag;
    if not tags then return table.emtpyTable; end

    local temptags ={}
    for i=1,#tags do
        if tags[i]>0 then
            table.insert(temptags,tags[i])
        end
    end
    return temptags;
end
--系统给的个性标签
function PlayerUserDefineAttr:GetCharacterTagsFromSystemShowing()

    local tags = self._proxy.systemTagShowing;
    if not tags then return table.emtpyTable; end
    local temptags ={}
    for i=1,#tags do
        if tags[i]>0 then
            table.insert(temptags,tags[i])
        end
    end
    return temptags;
end
return PlayerUserDefineAttr;