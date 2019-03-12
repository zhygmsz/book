module("UserData", package.seeall)
--主角唯一ID
UserData.PlayerID = - 1;
UserData.PlayerAtt = nil;

function InitModule()
	require("UserData_ConfigAPI");
	require("UserData_SystemInfo").InitSystemModule();
	require("UserData_Config").InitConfigModule();
	require("UserData_Control").InitControlModule();
	require("UserData_Property");
	require("UserData_Skill");
	require("UserData_ClientData");
end

--当天首次登陆，服务器计凌晨四点为界
function IsFirstTimeLoginToday()
	if PlayerAtt and PlayerAtt.roleflag then
	 	return math.ContainsBitMask(PlayerAtt.roleflag,Common_pb.RoleLdjFlag_DayFirstLogin); 
	else
		return false;
	end
end
--血蓝怒
function GetHP() return PlayerAtt.hp; end
function GetHPMax() return PlayerAtt.maxHp; end
function GetMP() return PlayerAtt.mp; end
function GetMPMax() return PlayerAtt.maxMp; end
function GetAP() return PlayerAtt.anger; end
function GetAPMax() return PlayerAtt.MaxAnger; end
--种族职业男女
function GetRacial() return PlayerAtt.racial; end
function GetProfession() return PlayerAtt.profession; end
function IsMale() return PlayerAtt.playerData.isMale; end
--等级经验
function GetLevel() return PlayerAtt.level; end
function GetExp() return PlayerAtt.experience; end
--ID名称身高形体
function GetID() return PlayerAtt.id; end
function GetName() return PlayerAtt.name; end
function GetHeight() return PlayerAtt.height; end
function GetPhysiqueID() return PlayerAtt.physiqueID; end

--
function GetCareerID() return 1; end
--
function GetAIPet() return AIPetMgr.GetPetInUse(); end
--城市
function GetLocationCityCode() return 100; end
--星座
function GetStarID() return 1 end
--结婚
function IsMarried() return false; end

function GetAchieveStars() return AchievementMgr.GetFinishedStars(); end
--服务器id
function GetServerId() return GetServer():GetID() end
function GetServer() return LoginMgr.GetCurrentServer(); end
--帮派等级
function GetGangLevel() return 1 end
--帮派贡献值
function GetGangContribute() return 150 end

--是否在战斗
function IsFighting() return false end

function GetIcon()
	local resTable = ProfessionData.GetProfessionResByRacialProfession(GetRacial(), GetProfession());
	return resTable and resTable.headIcon or "icon_head_yingmannv";
end
return UserData; 