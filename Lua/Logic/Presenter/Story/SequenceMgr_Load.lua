module("SequenceMgr",package.seeall)

--剧情资源加载流程
mOnLoadFinished = nil

--重建剧情
function ReBuidSequence(resId)
	GameLog.Log("ReBuidSequence Begin")
	local data = SequenceMgr.GetSequenceTable(resId)
	local sequenceData = SequenceMgr.GetSequenceController(resId)
	if sequenceData then
		local replaceInfoList = sequenceData.TimelineData:GetResourceList()
		if replaceInfoList.Length <= 0  then return end
		local N = replaceInfoList.Length
		for i=1,N do
			local replaceInfo = replaceInfoList[i-1]
			if replaceInfo.res == "player" then
				local tobj = UnityEngine.GameObject.Instantiate(MapMgr.GetMainPlayer():GetModelComponent():GetEntityModel());
				table.insert(data.initObjs,tobj)
				sequenceData.TimelineData:SetResourceObj(replaceInfo.res,tobj);
			elseif replaceInfo.res == "scenecamera" then
				local tobj = UnityEngine.GameObject.Instantiate(CameraMgr.GetMainCameraObj());
				table.insert(data.initObjs,tobj)
				sequenceData.TimelineData:SetResourceObj(replaceInfo.res,tobj);
			else
				if not tolua.isnull(replaceInfo.path) then 
					local obj = data.go.transform:Find(replaceInfo.path).gameObject
					sequenceData.TimelineData:SetResourceObj(replaceInfo.res,obj);
				end
			end
		end
	end
	GameLog.Log("ReBuidSequence End")
end

--加载完剧情实例资源
function EndLoadSequence(loader)
	GameLog.Log("EndLoadSequence")
	local sequenceObj = loader:GetObject()
	local resId = loader:GetResID()
	if sequenceObj == nil then
		SequenceMgr.FadeResetBack(resId)
	else
		local data = SequenceMgr.GetSequenceTable(resId)
		data.sequenceLoad = true;
		data.go = sequenceObj
		SequenceMgr.AddToRoot(sequenceObj)
		sequenceObj:SetActive(false);
		ReBuidSequence(resId)
		mOnLoadFinished()
	end
end

--销毁剧情实例 卸载asset资源
function DestoryObjRemoveAsset(resId)
	local asset = SequenceMgr.GetSequenceTable(resId)
	if asset  then
		if asset.initObjs ~= nil then
			for i=1,#asset.initObjs do
				UnityEngine.GameObject.Destroy(asset.initObjs[i]);
			end
		end
		asset.initObjs = {}
		if asset.loader ~= nil then
			LoaderMgr.DeleteLoader(asset.loader)
		end
		asset = nil
	end
end

--加载实例化剧情 Step1
function LoadAndInitSequenceObj(resId,onFinished)
	GameLog.Log("LoadAndInitSequenceObj")
    mOnLoadFinished = onFinished
	local objLoader = LoaderMgr.CreateGameObjectLoader();
	local asset = SequenceMgr.GetSequenceTable(resId)
	asset.loader = objLoader
	objLoader:LoadObject(resId,EndLoadSequence);
end
