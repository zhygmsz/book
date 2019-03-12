ACTION_STORY = class("ACTION_STORY",ACTION_BASE);

function ACTION_STORY:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._storyData = StoryData.GetStoryDataByID(self._actionData.intParams[1]);
    if self._storyData then
        self._storyBegin = false;
        self._actionDone = false;
    else
        self._storyBegin = true;
        self._actionDone = true;
        GameLog.LogError("story data is null %s",self._actionData.intParams[1]);
    end
end

function ACTION_STORY:OnUpdate(deltaTime)
    if not self._storyBegin then
        self._storyBegin = true;
        GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH,self.class.OnStoryFinish,self);
        if self._storyData.seqType == 0 then
            --TODO 处理剧情衔接的流畅性
		    UIMgr.MaskUI(true,AllUI.GET_MIN_DEPTH(),AllUI.GET_UI_DEPTH(AllUI.UI_Story_Sequence))
        end
        SequenceMgr.PlaySequenceWithType(self._storyData);
    end
end

function ACTION_STORY:OnStoryFinish(storyData)
    if self._storyData == storyData then
        self._actionDone = true;
        if self._storyData.seqType == 0 then
            UIMgr.MaskUI(false);
        end
        GameEvent.UnReg(EVT.STORY,EVT.STORY_FINISH,self.class.OnStoryFinish,self);
    end
end

return ACTION_STORY;