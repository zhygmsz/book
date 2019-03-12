module("GameInit",package.seeall)

local function InitDataFunction()
	_G.DATA = {};
	--触发式加载数据的元函数定义
	DATA.CREATE_LOAD_TRIGGER = function(dataTable,...)
		local mt = {};
		mt.__args = {...};
		mt.__index = function(t,k)	
			for _,argData in pairs(mt.__args) do
				if argData.keys[k] then ResMgr.LoadBytes(argData.fileName,argData.callBack); end
			end
			return rawget(t,k); 
		end
		setmetatable(dataTable,mt);
		if dataTable.important then
			for _,argData in pairs(mt.__args) do
				ResMgr.LoadBytes(argData.fileName,argData.callBack);
			end
		end
	end
end

local function InitDataModule(fileName,important)
	local dataModule = {};
	dataModule.important = true;
	DATA[fileName] = dataModule;
	RequireModule("Logic/Data/" .. fileName);
end

function InitData()
	InitDataFunction();
	--注意按照名字排序,方便查找
	InitDataModule("AchievementData");
	InitDataModule("AIPetData");
	InitDataModule("AnimationData");
	InitDataModule("AppearanceData");
	InitDataModule("AttDefineData");
	InitDataModule("AttShowDefineData");
	InitDataModule("AudioConfigData");
	InitDataModule("ActivityData");
	InitDataModule("BuffData");
	InitDataModule("BulletData");
	InitDataModule("CampData");
	InitDataModule("CharacterTagData");
	InitDataModule("ChargeData"); 
	InitDataModule("ChatData");
	InitDataModule("ConfigData");
	InitDataModule("DialogData");
	InitDataModule("EnvelopeData");
	InitDataModule("EquipMakeData");
	InitDataModule("FashionData");
	InitDataModule("FightHelpData");
	InitDataModule("GameActionData");
	InitDataModule("GameFuncData");
	InitDataModule("GemData");
	InitDataModule("GiftData");
	InitDataModule("IllegalData");
	InitDataModule("ItemData");
	InitDataModule("ItemDropData");
	InitDataModule("LevelExpData");
	InitDataModule("LoadingUIData");
	InitDataModule("LocationData");
	InitDataModule("MapData");
	InitDataModule("NPCData");
	InitDataModule("NPCInteractiveFunctionEntryData");
	InitDataModule("PetData");
	InitDataModule("PhysiqueData");
	InitDataModule("PracticeData");
	InitDataModule("ProfessionData");
	InitDataModule("ProfessionInfoData");
	InitDataModule("PropertyData");
	InitDataModule("PuzzleData");
	InitDataModule("QuestData");
	InitDataModule("RenderInfoData");
	InitDataModule("RandomNameData");
	InitDataModule("RankData");
	InitDataModule("ResConfigData");
	InitDataModule("RideData");
	InitDataModule("ShapeData");
	InitDataModule("ShopData");
	InitDataModule("SkillData");
	InitDataModule("StoryData");
	InitDataModule("SignTipsData");
	InitDataModule("TitleData");
	InitDataModule("VersionData");
	InitDataModule("WelfareWeekPackageData");
	InitDataModule("WelfareData");
	InitDataModule("WordData");
	InitDataModule("UserGuideData");
	--注意按照名字排序,方便查找
end

return GameInit;