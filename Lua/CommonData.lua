module("CommonData",package.seeall)

function InitModule()
    -- 因内存问题临时注释掉shadervariant的warmup
    -- local shaderVariantID = ResMgr.DefineAsset("Assets/Shader/ShaderCollection/Shaders.shadervariants");
    -- local shaderVariant = ResMgr.LoadObject(shaderVariantID);
    -- shaderVariant:WarmUp();
end

--[[
查找指定的shader
shaderAssetPath     string      在资源包内的名称
shaderEditorPath    string      在编辑器内的名称
--]]
function FindShader(shaderAssetPath,shaderEditorPath)
    if UnityEngine.Application.isEditor then
        return UnityEngine.Shader.Find(shaderEditorPath);
    else
        local shaderAssetID = ResMgr.DefineAsset(shaderAssetPath);
        local shader =  ResMgr.LoadObject(shaderAssetID);
        if shader == nil then
            return UnityEngine.Shader.Find(shaderEditorPath);
        end
        return shader
    end
end

--[[
查找指定的texture
textureAssetPath     string      在资源包内的名称
--]]
function FindTexture(textureAssetPath)
    local textureID = ResMgr.DefineAsset(textureAssetPath);
    return ResMgr.LoadObject(textureID);
end

--[[
查找指定的资源
assetPath     string      在资源包内的名称
--]]
function FindAsset(assetPath,needInstance)
    local assetID = ResMgr.DefineAsset(assetPath);
    if needInstance then
        return ResMgr.LoadInstantiateObject(assetID);
    else
        return ResMgr.LoadObject(assetID);
    end
end

return CommonData;