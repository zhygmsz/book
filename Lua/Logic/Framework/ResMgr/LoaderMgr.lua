module("LoaderMgr",package.seeall)

local mLoaderCache = {};
local mLoaderCtors = {};
local mLoaderRoot = nil;
local mLoaderGUID = 0;

local LOADER_TYPE = 
{
    GAMEOBJECT  = 1,
    EFFECT      = 2,
    MODEL       = 3,
    TEXTURE     = 4,
    IMAGE       = 5,
    ASSET       = 6,
    ATLAS       = 7,
}

local function CreateLoader(loaderType,...)
    mLoaderGUID = mLoaderGUID + 1;
    local loaders = mLoaderCache[loaderType];
    if not loaders or #loaders <= 0 then
        local loaderCtor = mLoaderCtors[loaderType];
        local loader = loaderCtor(...);
        loader._loaderType = loaderType;
        loader._loaderRoot = mLoaderRoot;
        loader._loaderGuid = mLoaderGUID;
        loader:OnAwake();
        return loader;
    else
        local loader = loaders[#loaders];
        loaders[#loaders] = nil;
        loader._loaderGuid = mLoaderGUID;
        loader:ctor(...);
        loader:OnAwake();
        return loader;
    end
end

local function RegLoader(loaderPath,loaderType)
    local loader = require(loaderPath);
    if loaderType then mLoaderCtors[loaderType] = loader.new; end
end

function InitModule()
    mLoaderRoot = UnityEngine.GameObject.New("GAME_POOL").transform;
    UnityEngine.GameObject.DontDestroyOnLoad(mLoaderRoot.gameObject);
    RegLoader("Logic/Framework/ResMgr/BaseLoader");
    RegLoader("Logic/Framework/ResMgr/TransformLoader");
    RegLoader("Logic/Framework/ResMgr/GameObjectLoader",LOADER_TYPE.GAMEOBJECT);
    RegLoader("Logic/Framework/ResMgr/EffectLoader",LOADER_TYPE.EFFECT);
    RegLoader("Logic/Framework/ResMgr/ModelLoader",LOADER_TYPE.MODEL);
    RegLoader("Logic/Framework/ResMgr/TextureLoader",LOADER_TYPE.TEXTURE);
    RegLoader("Logic/Framework/ResMgr/ImageLoader",LOADER_TYPE.IMAGE);
    RegLoader("Logic/Framework/ResMgr/AssetLoader",LOADER_TYPE.ASSET);
    RegLoader("Logic/Framework/ResMgr/AtlasLoader",LOADER_TYPE.ATLAS);
end

function CreateGameObjectLoader(...)
    return CreateLoader(LOADER_TYPE.GAMEOBJECT,...);
end

function CreateEffectLoader(...)
    return CreateLoader(LOADER_TYPE.EFFECT,...);
end

function CreateModelLoader(...)
    return CreateLoader(LOADER_TYPE.MODEL,...);
end

function CreateTextureLoader(...)
    return CreateLoader(LOADER_TYPE.TEXTURE,...);
end

function CreateImageLoader(...)
    return CreateLoader(LOADER_TYPE.IMAGE,...);
end

function CreateAssetLoader(...)
    return CreateLoader(LOADER_TYPE.ASSET,...);
end

function CreateAtlasLoader(...)
    return CreateLoader(LOADER_TYPE.ATLAS,...);
end

function DeleteLoader(loader)
    if not loader then return end
    local loaders = mLoaderCache[loader:GetType()];
    if not loaders then
        loaders = {};
        mLoaderCache[loader:GetType()] = loaders;
    end
    loaders[#loaders + 1] = loader;
    loader:dtor();
end

function LoaderNullRoot()
    return mLoaderRoot;
end

return LoaderMgr;