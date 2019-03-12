module("CameraRender",package.seeall);

local mEntities = {};

function RenderEntity(uiData,uiTex,entityAtt,entityIndex,physiqueID)
	if not mEntities[uiData.uiID] then mEntities[uiData.uiID] = {}; end
	local entities = mEntities[uiData.uiID];
	local entityIndex = entityIndex or 1;
	entityAtt.renderPhysiqueID = physiqueID or entityAtt.physiqueID;
	entityAtt.renderPosition = entityAtt.position + Vector3.up * (entityIndex % 8 + 1) * 10;
	entityAtt.renderLayer = CameraLayer.RenderTextureLayer;
	local entity = entities[entityIndex];
	if entity ~= nil then
		entity:GetModelComponent():UpdateModel();
	else
		entity = MapMgr.CreateEntity(EntityDefine.ENTITY_TYPE.RENDER,nil,entityAtt);
	end
	entities[entityIndex] = entity;
	local physiqueData = PhysiqueData.GetPhysique(entityAtt.renderPhysiqueID);
	if physiqueData then
		entity:GetRenderComponent():OnRender(uiTex,physiqueData.renderID);
	end
end

function DragEntity(uiData,delta,entityIndex)
	local entityIndex = entityIndex or 1;
	local entities = mEntities[uiData.uiID];
	local entity = entities and entities[entityIndex];
	if entity then entity:GetRenderComponent():OnDrag(delta); end
end

function DeleteEntity(uiData,entityIndex)
	local entityIndex = entityIndex or 1;
	local entities = mEntities[uiData.uiID];
	local entity = entities and entities[entityIndex];
	if entity then MapMgr.DestroyEntity(entity:GetType(),entity:GetID()); end
	if entities then entities[entityIndex] = nil end
end

function PlayAnim(uiData, entityIndex, animName, exitName)
	local entities = mEntities[uiData.uiID];
	local entity = entities and entities[entityIndex];
	if entity then entity:GetModelComponent():PlayAnim(animName,exitName) end
end