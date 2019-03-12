module("AIPetMgr",package.seeall);

function InitModule()
    require("Logic/System/AIPet/AIPetMgr_Dialog");
    require("Logic/System/AIPet/AIPetMgr_Fairy");
    require("Logic/System/AIPet/AIPetMgr_Intention");
    require("Logic/System/AIPet/AIPetMgr_Model");
    require("Logic/System/AIPet/AIPetMgr_Tip");
end

function InitClientData()
    AIPetMgr.Init_Dialog();
    AIPetMgr.Init_Fairy();
    AIPetMgr.Init_Model();
    AIPetMgr.Init_Intention();
    AIPetMgr.Init_Tip();
end

return AIPetMgr;



