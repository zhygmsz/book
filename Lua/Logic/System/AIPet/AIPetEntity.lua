--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{hesinian}
    time:2019-01-03 11:15:36
]]

local AIPetEntity = class("AIPetEntity")

function AIPetEntity:ctor(info)
    self._id = info.aipetID;
    self._staticInfo = info;
    self._dressInTable = {};--
    self._clothesByPart = {};--衣服列表，按部位保存
    self._clothParts = {};--身体部位列表
    self._name = UserData.GetAIPetResume(self._id,"PetName") or info.petName;
    self._hostName = UserData.GetAIPetResume(self._id,"HostName") or info.hostName;
    self._receiveTime = nil;
    self._isAiPet = true;
end

function AIPetEntity:GetID()
    return self._id;
end
function AIPetEntity:GetIconName()
    return self._staticInfo.iconName;
end
function AIPetEntity:GetModelResID( )
    return self._staticInfo.modelResID;
end
function AIPetEntity:GetBirthPoint( )
    return self._staticInfo.birthPointID;
end
function AIPetEntity:GetAnimationAtlasID()
    return self._staticInfo.animation2DAtlas;
end
function AIPetEntity:GetNPCID()
    return self._staticInfo.npcID;
end
--星座女
function AIPetEntity:GetStar()
    return self._staticInfo.star;
end
function AIPetEntity:GetInterest()
    return self._staticInfo.interest;
end
function AIPetEntity:GetDream()
    return self._staticInfo.dream;
end
function AIPetEntity:GetFirstMeet()
    return self._staticInfo.firstBubble;
end

--所有能够装扮的部位
function AIPetEntity:GetAllParts( )
    return self._clothParts;
end

function AIPetEntity:AddCloth(cloth)
    local ctype = cloth:GetPart();
    if not self._clothesByPart[ctype] then
        self._clothesByPart[ctype] = {};
        table.insert(self._clothParts,ctype);
    end
    table.insert(self._clothesByPart[ctype],cloth);
end

function AIPetEntity:SetActiveState(state)
    if self._activeState == state then return; end
    self._activeState = state;
    if state == AiPet_pb.AS_ACTIVE then
        self:SetReceiveTime();
    end
    GameEvent.Trigger(EVT.AIPET,EVT.AIPET_ACTIVE,self);
end

function AIPetEntity:IsActive( )
    return self._activeState == AiPet_pb.AS_ACTIVE;
end

function AIPetEntity:DressCloth(cloth )
    local ctype = cloth:GetPart();
    self._dressInTable[ctype] = cloth;
end
function AIPetEntity:UndressAllClothes()
    for _,ctype in ipairs(self._clothParts) do
        self._dressInTable[ctype] = nil;
    end
end

--根据部位获得穿上的衣服，或者nil
function AIPetEntity:GetAllClothByPart(part)
    return self._clothesByPart[part];
end
--根据部位获得穿上的衣服，或者nil
function AIPetEntity:GetClothDressedByPart(part)
    return self._dressInTable[part];
end

function AIPetEntity:GetName( )
    return self._name;
end
function AIPetEntity:GetHostName( )
    return self._hostName;
end
function AIPetEntity:GetReceiveTime( )
    return self._receiveTime;
end
function AIPetEntity:SetName(name)
    self._name = name;
    UserData.SetAIPetResume(self._id,"PetName",name);
end
function AIPetEntity:SetHostName(name )
    self._hostName = name;
    UserData.SetAIPetResume(self._id,"HostName",name);
end
--秒，如果服务器没有存获取时间，那就设置当前时间为获取时间
function AIPetEntity:SetReceiveTime()
    local time = UserData.GetAIPetResume(self._id,"ReceiveTime",time);
    if time == nil then
        time = TimeUtils.SystemTimeStamp(true);
        UserData.SetAIPetResume(self._id,"ReceiveTime",time);
    else
        time = tonumber(time);
    end
    self._receiveTime = time;
end


return AIPetEntity;