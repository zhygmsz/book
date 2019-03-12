--[[
    1.每个类别Class下有若干个Group；
    2.每个Group下有若干相同名字的Item称号，同Group下的Item的颜色color等级level不同；
    3.同Group下的等级有升级的概念，高等级Item启用后自动替换低等级Item(服务器确定）；
]]
local TitleClass = require("Logic/System/Title/TitleClass");
local TitleGroup = require("Logic/System/Title/TitleGroup");
local TitleItem = require("Logic/System/Title/TitleItem");
local TitleItemUserDefine = require("Logic/System/Title/TitleItemUserDefine");

module("TitleMgr",package.seeall);
local mClassifyHash;
local mGroupHash;
local mItemHash;
local mClassList;--记录顺序
local mItemInUse;
local mItemUserDefine;

local function NotifyPlayerEntity()
    local player = MapMgr.GetMainPlayer();
    if player then
        local tid = mItemInUse and mItemInUse:GetID();
        local name = mItemInUse and mItemInUse:GetName();
        player:GetPropertyComponent():SetTitle(tid,name);
        GameEvent.Trigger(EVT.TITLE,EVT.TITLE_PLAYER_RESET,player);
    end
end

local function InitStaticInfo()
    local itemList = TitleData.GetAllTitleList();
    for i,itemInfo in ipairs(itemList) do
        local tid = itemInfo.id;
        local item = nil;
        if itemInfo.isUserDefine then
            item = TitleItemUserDefine.new(itemInfo);
            mItemUserDefine = item;
        else
            item = TitleItem.new(itemInfo);
            
            local cname = itemInfo.classifyName;
            if not mClassifyHash[cname] then
                local class = TitleClass.new(cname);
                mClassifyHash[cname] = class;
                table.insert(mClassList,class);
            end
            
            local gid = itemInfo.groupID;
            if not mGroupHash[gid] then
                local cls = mClassifyHash[cname];
                mGroupHash[gid] = TitleGroup.new(gid);
                cls:AddGroup(mGroupHash[gid]);
                mGroupHash[gid]:SetClass(cls);
            end
            local group = mGroupHash[gid];
            group:AddItem(item);
            item:SetGroup(group);
        end
        mItemHash[tid] = item;
    end
end

function InitModule()
    mClassifyHash = {};
    mGroupHash = {};
    mItemHash = {};
    mClassList = {};
    InitStaticInfo();
end

--自定义称号
function GetItemUserDefine()
    return mItemUserDefine;
end
--官方称号分类
function GetClassifies()

    return mClassList;
end

function IsItemInUse(item)
    return mItemInUse == item;
end

function GetItemInUse()
    return mItemInUse;
end

function GetItemByID(tid)
    return mItemHash[tid];
end
--==============================--
function RetTitleInfo(msg)
    for _,data in ipairs(msg.title.list) do
        local tid = data.titleid;
        local item = mItemHash[tid];
        item:InitDynamicInfo(data);
    end
    local tid = msg.title.usertitle;
    if tid ~= 0 then
        mItemInUse = mItemHash[tid];
    end
    NotifyPlayerEntity();
end
--激活称号，包括用户自定义
function RetOpenTitleState(msg)
    if msg.title then
        local tid = msg.title.titleid;
        local item = mItemHash[tid];
        item:SetOpen(msg.title);
    end
end
--添加用户自定义称号,废弃
function RetAddUserDefineTitle(msg)
    mItemUserDefine:SetName(msg.strtitle)
end
--更新用户自定义称号
function RetUpdateUserDefineTitle(msg)
     mItemUserDefine:SetName(msg.strtitle);
     if IsItemInUse(mItemUserDefine) then
        NotifyPlayerEntity();
     end
end
--激活的称号过期
function RetCloseTile(msg)
    local item = mItemHash[msg.titleid];
    item:SetClose(msg);
end
-----更新视野范围内的其它玩家的称号
function RetRefreshPlayerTitle(msg)
	local player = MapMgr.GetPlayer(msg.roleid);
	if player then
		player:GetPropertyComponent():SetTitle(msg.title.titleid,msg.title.titlestr);
        GameEvent.Trigger(EVT.TITLE,EVT.TITLE_PLAYER_RESET,player);
	end
end
--设置称号
function RetUseTitle(msg)
    local oldInUse = mItemInUse;
    if msg.titleid ~= 0 then
        mItemInUse = mItemHash[msg.titleid];
    else
        mItemInUse = nil;
    end
    NotifyPlayerEntity();
    if mItemInUse then
        GameEvent.Trigger(EVT.TITLE,EVT.TITLE_PUT_ON,mItemInUse);
    end
    if oldInUse then
        GameEvent.Trigger(EVT.TITLE,EVT.TITLE_TAKE_OFF,oldInUse);
    end
end
--==============================--
--请求设定称号组
function RequestUseItem(item)
    local msg = NetCS_pb.CSSetTitle();
    msg.titleid = item:GetID();
    GameNet.SendToGate(msg);
end

--请求添加用户自定义称号
function RequestAddCustomTitle(name)
    local msg = NetCS_pb.CSAddCustomTitle();
    msg.strtitle = name;
    GameNet.SendToGate(msg);
end
--请求更新用户自定义称号
function RequestUpdateCustomTitle(name)
    local msg = NetCS_pb.CSUpdateCustomTitle();
    msg.strtitle = name;
    msg.idx = mItemUserDefine:GetID();--默认为1
    GameNet.SendToGate(msg);
end
--封装给UI使用的 添加/修改用户自定义称号
function RequestSetUserDefineName(name)
    if  mItemUserDefine:IsOpen() then
        RequestUpdateCustomTitle(name);
    else
        RequestAddCustomTitle(name);
    end
end
--脱下称号
function RequestUnuseTitle()--tid ==0 代表不使用称号
    local msg = NetCS_pb.CSSetTitle();
    msg.titleid = 0;
    GameNet.SendToGate(msg);
end

return TitleMgr;




