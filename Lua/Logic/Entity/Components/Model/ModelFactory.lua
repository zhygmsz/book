module("ModelFactory",package.seeall);

local mModels = {};
local mModelCtors = {};

function CreateModel(modelType,modelComponent)
    local models = mModels[modelType];
    local model = models and models[#models];
    if not model then
        model =  mModelCtors[modelType](modelType,modelComponent);
    else
        models[#models] = nil;
        model:ctor(modelType,modelComponent);
    end
    return model;
end

function DeleteModel(model)
    local models = mModels[model:GetType()];
    if not models then
        models = {};
        mModels[model:GetType()] = models;
    end
    models[#models + 1] = model;
    model:dtor();
end

function RegModel(modelType,modelPath)
    mModelCtors[modelType] = require(modelPath).new;
end

function InitModule()
    require("Logic/Entity/Components/Model/ModelBase");
    require("Logic/Entity/Components/Model/ModelCharacter");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.EFFECT,"Logic/Entity/Components/Model/ModelEffect");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.PLAYER,"Logic/Entity/Components/Model/ModelPlayer");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.AIPET,"Logic/Entity/Components/Model/ModelCharacter");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.CHARACTER,"Logic/Entity/Components/Model/ModelCharacter");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.WALL,"Logic/Entity/Components/Model/ModelEffect");
    RegModel(EntityDefine.MODEL_PROCESS_TYPE.PLAYER_MAIN,"Logic/Entity/Components/Model/ModelPlayerMain");
end

return ModelFactory;