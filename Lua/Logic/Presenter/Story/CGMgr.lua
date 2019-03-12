module("CGMgr",package.seeall)

function InitModule()
    local cg_play_count = UserData.ReadIntConfig("cg_play_count") + 1;
    UserData.WriteIntConfig("cg_play_count",cg_play_count);
    UserData.WriteBoolConfig("cg_play_flag",cg_play_count > 3);
end

function PlayCG()
    CGPlayer.PlayMovie("CG_LDJ.mp4");
end

return CGMgr;