module("AllUI",package.seeall)
local mUIDefined = {}
--[[
UI定义规范
uiLayer 		必填  	UI的等级,分成10个大的等级,每个等级的Panel深度默认范围是[level * 100,level * 100 + 50]
							1级,最底层的界面,只有主界面的常驻UI使用
							2级,通过主界面的按钮打开的界面,例如背包、技能、签到、任务、队伍等等
							3级,通过2级界面打开的小界面,例如修改背包名字、选中物品后的信息展示、使用物品等等
							4级,通过3级界面打开的小界面,例如修改名字时提示花费的确认界面、提示贵重物品销毁的确认界面、购买确认等等
							5级-10级,在4级界面上打开的界面,根据需求自己处理
							11级,剧情界面
							12级,加载界面,最高级界面
							13级,非常规界面,需要自己控制层级次序的界面
							14级,属性变化提示、操作及时反馈、系统公告等等
							其它等级暂不使用
						如果是负值表示自己控制开启与关闭,不做自动处理
uiPath 			必填  	UI的脚本路径,必须包含与之名字一致的ui预设和lua脚本
							同一个系统的UI放在一起,命名统一
							名字规范：UI_系统_系统内分类
uiGroup 		选填	UI的分组,同一组的UI打开与关闭不会相互影响
uiPanelDepth	选填	UI的Panel基础深度值
							默认Panel深度是根据uiLayer来设置depth及其sortOrder
uiBackBox		选填	UI是否带半透背景遮罩,遮罩事件ID统一为-1000
							-1表示不带背景遮罩
							0表示带BoxCollider但是没有黑色背景
							1表示带BoxCollider和黑色背景,背景透明度统一
							大于等于2表示带BoxCollider和黑色背景,透明度自定义n/100
其他参数暂无设置需求
--]]
function DEFINE_UI(uiLayer, uiPath, uiGroup, uiPanelDepth, uiBackBox)
	local data = {};
	data.uiID = #mUIDefined + 1;
	data.uiName = string.match(uiPath, ".+/(.+)");
	data.uiPath = uiPath;
	data.layer = uiLayer;
	data.depth = uiPanelDepth or (math.abs(uiLayer) * 100);
	data.group = uiGroup or 0;
	data.autoOpen = true;
	if not uiBackBox or uiBackBox == -1 then data.alpha = -1;
	elseif uiBackBox == 0 then data.alpha = 0;
	elseif uiBackBox == 1 then data.alpha = 0.7;
	elseif uiBackBox >= 2 then data.alpha = uiBackBox / 100; end
	data.uiResID = ResMgr.DefineAsset("Assets/Res/UI/Prefab/" .. data.uiName .. ".prefab");
	mUIDefined[data.uiID] = data;
	AllUI[data.uiName] = data;
end

function InitModule()
	--登录系统
	reload_module("Logic.Presenter.UI.Define.UILoginDefine");
	--主界面
	reload_module("Logic.Presenter.UI.Define.UIMainDefine");
	--通用表现 引导|对话|剧情|提示|加载|调试
	reload_module("Logic.Presenter.UI.Define.UICommonDefine");
	--背包系统
	reload_module("Logic.Presenter.UI.Define.UIBagDefine");
	--常规系统(养成类、交易类等等)
	reload_module("Logic.Presenter.UI.Define.UISystemDefine");
	--社交系统
	reload_module("Logic.Presenter.UI.Define.UISocialDefine");
	--小游戏|小玩法
	reload_module("Logic.Presenter.UI.Define.UIGameDefine");
end

function GetUIData(uiID)
	return mUIDefined[uiID];
end

function GetGroupID()
	return #mUIDefined + 1;
end

function GET_MIN_DEPTH()
	return -500;
end

function GET_MAX_DEPTH()
	return 1000;
end

function GET_UI_DEPTH(data)
	if data then
		return data.depth;
	else
		return DEPTH_MAX;
	end
end

function GET_UI_DEPTH_BY_LAYER(uiLayer)
	if uiLayer then
		return math.abs(uiLayer) * 100
	else
		return GET_MIN_DEPTH()
	end
end

return AllUI;
