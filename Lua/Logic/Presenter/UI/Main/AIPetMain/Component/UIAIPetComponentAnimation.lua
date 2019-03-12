
local UIAIPetComponentAnimation = class("UIAIPetComponentAnimation");
 
function UIAIPetComponentAnimation:ctor(ui,context,rootPath)
    local path = rootPath.."/BirthPos/DragRoot/PetModel";
    local modelTrans = ui:Find(path);
    self._modelGo = modelTrans.gameObject;
    local modelSprite = modelTrans:GetComponent("UISprite");
    local spriteAni = modelTrans:GetComponent("UISpriteAnimation");
    self._atlasLoader = LoaderMgr.CreateAtlasLoader(modelSprite,spriteAni);
    
    self._animation = spriteAni;
    self._animation:SetCallBack(System.Action_string(self.OnPlayEnd,self));
    self._aniDic = {};
    self._aniDic[AIPetUIANIMATION.Random] = {};
    self._defaultType = nil; --默认动画
    self._currentAni = nil; --当前播放的动画

    self._pet = nil;
end

function UIAIPetComponentAnimation:RefreshModel()
    local pet = AIPetMgr.GetPetInUse();
    if pet == self._pet then return; end
    self._pet = pet;

    table.clear(self._aniDic[AIPetUIANIMATION.Random]);
    local anis = AIPetData.GetAll2DAnimations(pet:GetID());
    for i, ani in ipairs(anis) do
        if ani.aniType == AiPet_pb.AiPetUIAnimation.WORK_IDLE then
            self._aniDic[AIPetUIANIMATION.WorkIdle] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.INACTIVE_IDLE then
            self._aniDic[AIPetUIANIMATION.InactiveIdle] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.DRAG then
            self._aniDic[AIPetUIANIMATION.Drag] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.LISTEN then
            self._aniDic[AIPetUIANIMATION.Listen] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.ANSWER then
            self._aniDic[AIPetUIANIMATION.Answer] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.ANSWER_FAILED then
            self._aniDic[AIPetUIANIMATION.AnswerFailed] = ani;
        elseif ani.aniType == AiPet_pb.AiPetUIAnimation.WORK_RANDAM then
            table.insert(self._aniDic[AIPetUIANIMATION.Random], ani);
        end
    end

    local atlasID = pet:GetAnimationAtlasID()
    self._atlasLoader:LoadObject(atlasID); 
    local ani = self:FindConfig(self._currentAni);
    self._atlasLoader:SetPlayConfig(ani);
end

function UIAIPetComponentAnimation:OnAtlasChange( )
    if self._currentAni then
        self:Play(self._currentAni);
    end
end

--[[
    @desc: 查找动画配置信息
    author:{author}
    time:2019-02-23 15:21:20
    --@aniType: AIPetUIANIMATION 
    @return:
]]
function UIAIPetComponentAnimation:FindConfig(aniType)
    if not aniType then return; end
    local ani = self._aniDic[aniType];
    if not ani then return; end
    if aniType == AIPetUIANIMATION.Random then--随机播放
        ani = ani[math.random( 1, #ani)];
    end
    return ani;
end

--[[
    @desc: 
    author:{hesinian}
    time:2019-02-18 20:27:17
    --@aniType: AIPetUIANIMATION
	--@asDefault: 设置为默认动画，其它动画播放结束就播这个动画
    @return:
]]
function UIAIPetComponentAnimation:Play(aniType,asDefault)
    local ani = self:FindConfig(aniType);
    if not ani then GameLog.LogError("Not Found Animation By Type %s",aniType); return; end
    GameLog.Log("Play Animation Type %s",aniType);
    if asDefault then
        self._defaultType = aniType;
    end
    self._currentAni = aniType;
    
    GameLog.Log("Play Animation Name %s, from %s",ani.spriteName,ani.startIndex);
    
    self._animation:Play(ani.spriteName,ani.startIndex,ani.loop);
end

function UIAIPetComponentAnimation:OnPlayEnd(name)
    if self._defaultType then
        self:Play(self._defaultType);
    end
    GameEvent.Trigger(EVT.AIPET,EVT.AIPET_UI_ANIMATION_END,name);
end

function UIAIPetComponentAnimation:OnEnable()
    self._modelGo:SetActive(true);
    self:RefreshModel();
    
end
function UIAIPetComponentAnimation:OnDisable()
    self._modelGo:SetActive(false);
end

return UIAIPetComponentAnimation;