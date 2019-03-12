module("GameInit",package.seeall)

function InitCommon()
	--全局定义
    RequireModule("GameDebug");
	RequireModule("GameConfig");

	--TODO 移除
	RequireModule("Common/List");
	RequireModule("Common/MessageSub");
    
    --通用工具
	RequireModule("Logic/Framework/Common/GameTime");
	RequireModule("Logic/Framework/Common/GameLog");
	RequireModule("Logic/Framework/Common/GameTimer");
	RequireModule("Logic/Framework/Common/GameUIFollow");
	RequireModule("Logic/Framework/Common/GameTween");
	RequireModule("Logic/Framework/Common/GameNet");
	RequireModule("Logic/Framework/Common/TableUtils");
	RequireModule("Logic/Framework/Common/MathUtils");
	RequireModule("Logic/Framework/Common/StringUtils");
	RequireModule("Logic/Framework/Common/GameUtils");
	RequireModule("Logic/Framework/Common/TimeUtils");
    RequireModule("Logic/Framework/Common/GameEvent");
    
	--资源管理
	RequireModule("Logic/Framework/ResMgr/ResMgr");
    RequireModule("Logic/Framework/ResMgr/ImageMgr");
    RequireModule("Logic/Framework/ResMgr/LoaderMgr");
    RequireModule("Logic/Framework/ResMgr/UIMgr");
    
    --基础定义
	RequireModule("Logic/Proto/AllPB");
	RequireModule("Logic/Presenter/UI/Define/AllUI");
	RequireModule("Logic/Event/EventDefine");
	RequireModule("Logic/Presenter/Camera/CameraLayer");
	RequireModule("Logic/Presenter/Camera/CameraDefine");

	--通用数据
	RequireModule("CommonData");
	
	--通用表现
	RequireModule("Logic/Presenter/Touch/TouchMgr");
	RequireModule("Logic/Presenter/Camera/CameraMgr");

	--通用界面
	RequireModule("Logic/Presenter/UI/Common/UICommon");
	

	--玩家数据
	RequireModule("UserData");
end

return GameInit;