--GridTable的帮助类
module("UIGridTableUtil",package.seeall);

function CreateChild(uiFrame,prefab,count,parent,OnCreate,caller)
    if count <=0 then
        prefab.gameObject:SetActive(false);
    else
        prefab.gameObject:SetActive(true);
    end
    parent = parent or prefab.parent;
    local alreadyCount = parent.childCount;
    if alreadyCount > count and alreadyCount > 1 then
        local left = count < 1 and 1 or count;
        for i =  alreadyCount - 1 , left, -1 do
            local child = parent:GetChild(i);
            child.gameObject:SetActive(false);
            UnityEngine.GameObject.Destroy(child.gameObject);
        end
    end
    if alreadyCount < count then
        for i = alreadyCount, count-1 do
            local dup = uiFrame:DuplicateAndAdd(prefab,parent,i); 
            dup.name = string.format("clone %s",i);
        end
    end

    for i=0,count-1 do
        local child = parent:GetChild(i);
        child.gameObject:SetActive(true);
        GameUtils.TryInvokeCallback(OnCreate,caller,child,i+1);
    end
end

return UIGridTableUtil;