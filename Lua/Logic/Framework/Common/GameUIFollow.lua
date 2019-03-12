module("GameUIFollow",package.seeall);

local UtilUIFollow = GameCore.UtilUIFollow;

function InitModule()

end

function AddFollow(target,ui,targetOffset,localOffset)
    return UtilUIFollow.AddFollow(target,ui,targetOffset,localOffset);
end

function RemoveFollow(followID)
    if not followID then GameLog.LogError("follow id is nil"); return end
    UtilUIFollow.RemoveFollow(followID);
end

function ModifyTargetOffsetY(followID, newY)
    UtilUIFollow.ModifyTargetOffsetY(followID, newY);
end

function ModifyLocalOffsetY(followID, newY)
    UtilUIFollow.ModifyLocalOffsetY(followID, newY);
end

return GameUIFollow;
