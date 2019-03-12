AINodeBase = class("AINodeCastSkill",BTNodeLeaf);

function AINodeBase:ctor()
    BTNodeLeaf.ctor(self);
end

function AINodeBase:dtor()
    BTNodeLeaf.dtor(self);
end

function AINodeBase:OnFail(tipKey,btData,serverLimit)
    if btData.autoFlag then
        btData.autoIndex = btData.autoIndex - 1;
        if btData.autoIndex <= 0 then btData.autoIndex = Common_pb.SKILL_SLOT_6; end
        --GameLog.LogError(tipKey);
    else
        if serverLimit == nil or serverLimit then
            local preTipTime = btData[tipKey] or 0;
            local curTipTime = TimeUtils.SystemTimeStamp();
            if curTipTime - preTipTime >= 1000 then btData[tipKey] = curTipTime; TipsMgr.TipByKey(tipKey); end
        end
    end
    return false;
end