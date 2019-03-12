module("ResMgr",package.seeall)
local mCallBacks = {};
local mSceneLoadObject;
local mSceneLoadFunc;
local mSceneAssetID = -1;
local mAssetDefined = {};
_G["GameAsset"] = {};

local function OnLoadFinish(objectType,arg1,arg2) 
    if objectType == 0 then
        --内存报警

    elseif objectType == 1 then
        --loader资源对象
        local self = mCallBacks[arg1];
        mCallBacks[arg1] = nil;
        if self then self:OnLoadFinish(arg1,arg2); end
    elseif objectType == 2 then
        --场景资源对象
        local self = mSceneLoadObject;
        local func = mSceneLoadFunc or (self and self.OnSceneLoad)
        mSceneLoadObject = nil;
        mSceneLoadFunc = nil;
        if func then func(self,arg1); end
    elseif objectType == 3 then
        --数据文件对象
    end
end

function InitModule()
    GameCore.ResMgr.Instance:InitCallBack(OnLoadFinish);
end

--[[
加载一个非GameObject对象,例如AudioClip AnimatorController Texture Shader
resID               资源ID
--]]
function LoadObject(resID)
    if resID == nil then 
        GameLog.LogError("!!!!!!!!!!!!!! resID is nil !!!!!!!!!!!!!");
    else
        return GameCore.ResMgr.Instance:LoadObject(resID);
    end
end

--[[
异步加载一个非GameObject对象
resID               资源ID
priority            加载优先级,-1最低 0默认 1自己 2文本
self                对加载过程的封装类对象
--]]
function LoadObjectAsync(resID,priority,self)
    if resID == nil then 
        GameLog.LogError("!!!!!!!!!!!!!! resID is nil !!!!!!!!!!!!!");
        return -1;
    end
    local loadIndex = GameCore.ResMgr.Instance:LoadObjectAsync(resID,priority);
    if loadIndex == -1 then
        GameLog.LogError("!!!!!!!!!!!! Failed to LoadObjectAsync %s !!!!!!!!!!!!!!!!!!" , resID)
        return -1;
    end

    mCallBacks[loadIndex] = self;
    return loadIndex;
end

--[[
加载并实例化一个GameObject对象,例如特效、角色模型等
resID               资源ID
--]]
function LoadInstantiateObject(resID,isActive)
    if resID == nil then 
        GameLog.LogError("!!!!!!!!!!!!!! resID is nil !!!!!!!!!!!!!");
    else
        return GameCore.ResMgr.Instance:LoadInstantiateObject(resID,isActive);
    end
end

--[[
异步加载并实例化一个GameObject对象
resID               资源ID
priority            加载优先级,-1最低 0默认 1自己 2文本
self                对加载过程的封装类对象
--]]
function LoadInstantiateObjectAsync(resID,priority,self,isAcitve)
    if resID == nil then 
        GameLog.LogError("!!!!!!!!!!!!!! resID is nil !!!!!!!!!!!!!");
        return -1;
    end
    local loadIndex = GameCore.ResMgr.Instance:LoadInstantiateObjectAsync(resID,isAcitve,priority);
    if loadIndex == -1 then
        GameLog.LogError("!!!!!!!!!!!! Failed to LoadObjectAsync %s !!!!!!!!!!!!!!!!!!",resID)
        return -1;
    end
    mCallBacks[loadIndex] = self;
    return loadIndex;
end

--[[
加载数据文件
--]]
function LoadBytes(fileName,callBack,...)
    local data = GameCore.ResMgr.Instance:LoadBytes(fileName);
    callBack(data,...);
end

--[[
异步加载场景
resID       资源ID
self        类对象(不提供func时默认使用self:OnSceneLoad)
func        加载回调
addMode     是否使用add模式加载场景
--]]
function LoadSceneAsync(resID,self,func,addMode)
    if resID == nil then 
        GameLog.LogError("!!!!!!!!!!!!!! resID is nil !!!!!!!!!!!!!");
    else
        mSceneLoadObject = self;
        mSceneLoadFunc = func;
        mSceneAssetID = resID;
        GameCore.ResMgr.Instance:LoadScene(resID,addMode);
    end
end

--[[
加载过渡场景
self        类对象(不提供func时默认使用self:OnSceneLoad)
func        加载回调
--]]
function LoadSwitchScene(self,func)
    mSceneLoadObject = self;
    mSceneLoadFunc = func;
    mSceneAssetID = -1;
    GameCore.ResMgr.Instance:LoadSwitchScene();
end

--[[
卸载不使用的资源
object      加载出来的对象
--]]
function UnloadObject(object)
    GameCore.ResMgr.Instance:UnloadObject(object);
end

--[[
卸载所有不使用的资源,强制清理内存
--]]
function UnloadUnusedAssets(forceUnload)
    GameCore.ResMgr.Instance:UnloadUnusedAssets(forceUnload);
end

--[[
注册资源
assetPath   string      资源路径(示例:Assets/Res/UI/Prefab/UI_Tip.prefab)
--]]
function DefineAsset(assetPath)
	local assetName = string.match(assetPath, ".+/(.+)%..+");
	local assetData = mAssetDefined[assetName];
	if assetData then return assetData.assetResID end
	local data = {};
	data.assetName = assetName;
	data.assetPath = assetPath;
	data.assetResID = GameCore.ResMgr.Instance:DefineAsset(assetPath);
	mAssetDefined[data.assetName] = data;
	GameAsset[data.assetName] = data.assetResID;
    return data.assetResID
end

--[[
停止加载
loadIndex       int         加载时返回的ID
--]]
function StopLoading(loadIndex)
    GameCore.ResMgr.Instance:StopLoading(loadIndex or -1);
end

return ResMgr;