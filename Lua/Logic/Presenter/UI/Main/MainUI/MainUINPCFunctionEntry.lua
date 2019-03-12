MainUINPCFunctionEntry = class("MainUINPCFunctionEntry");

function MainUINPCFunctionEntry:ctor(uiFrame)
	local rootSortorder = uiFrame:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	self._funEnty = {};
	self._funEnty[3] = uiFrame:Find("BottomRight/UI_Npcduihua/Offset/BtnSelect1");
	self._funEnty[2] = uiFrame:Find("BottomRight/UI_Npcduihua/Offset/BtnSelect2");
	self._funEnty[1] = uiFrame:Find("BottomRight/UI_Npcduihua/Offset/BtnSelect3");
	
	self._funEntyIcon = {};
	self._funEntyIcon[3] = uiFrame:FindComponent("UISprite", "BottomRight/UI_Npcduihua/Offset/BtnSelect1/SprIcon");
	self._funEntyIcon[2] = uiFrame:FindComponent("UISprite", "BottomRight/UI_Npcduihua/Offset/BtnSelect2/SprIcon");
	self._funEntyIcon[1] = uiFrame:FindComponent("UISprite", "BottomRight/UI_Npcduihua/Offset/BtnSelect3/SprIcon");
	
	self._funEntyLabel = {};
	self._funEntyLabel[3] = uiFrame:FindComponent("UILabel", "BottomRight/UI_Npcduihua/Offset/BtnSelect1/Label");
	self._funEntyLabel[2] = uiFrame:FindComponent("UILabel", "BottomRight/UI_Npcduihua/Offset/BtnSelect2/Label");
	self._funEntyLabel[1] = uiFrame:FindComponent("UILabel", "BottomRight/UI_Npcduihua/Offset/BtnSelect3/Label");

	
end


function MainUINPCFunctionEntry:OnEnable()
	self:DisableFunctionEnty();
	self:RegEvent();

    

end

function MainUINPCFunctionEntry:OnDisable()
	self:UnRegEvent();
end

function MainUINPCFunctionEntry:RegEvent()
	GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_ENTER_NPC_AREA, self.OnPalyerEnterArea, self);
	GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_LEAVE_NPC_AREA, self.OnPlayerLeaveArea, self);
end

function MainUINPCFunctionEntry:UnRegEvent()
	GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_LEAVE_NPC_AREA, self.OnPlayerLeaveArea, self);
	GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_ENTER_NPC_AREA, self.OnPalyerEnterArea, self);	
end


function MainUINPCFunctionEntry:OnPalyerEnterArea(npcData)
	if npcData.interactEntryGroupId > 0 then	
		self.curNpcId = npcData.id;
		self:EnableFunctionEnty(npcData.interactEntryGroupId);
	end

end

function MainUINPCFunctionEntry:OnPlayerLeaveArea(npcData)
	if npcData.id == self.curNpcId
	then
		self:DisableFunctionEnty()
	end
end

function MainUINPCFunctionEntry:EnableFunctionEnty(groupId)
	print(self.curNpcId);
	print("Enable FunctionEnty");
	local npcFunGroupDatas = NPCInteractiveFunctionEntryData.GetNPCFunDatasByGroupId(groupId);
	local sortNpcFunGroupDatas = {};
	--self:copy(npcFunGroupDatas,sortNpcFunGroupDatas);
	--排序
	table.sort(npcFunGroupDatas,function(a,b) return a.weight<b.weight end)
	self:DisableFunctionEnty()
	for i,v in pairs(npcFunGroupDatas) do
		-- print("aaaa:"..tostring(type(i)))
		-- print("bbbb:"..v.iconName);
		-- print("cccc:"..npcFunGroupDatas[i].iconName)

		self._funEntyIcon[i].spriteName = v.iconName;
		self._funEntyLabel[i].text = v.entryName;
		self._funEnty[i].gameObject:SetActive(true);
		print("self._funEnty[i]:SetActive(true);");
	end
end


function MainUINPCFunctionEntry:copy(org, res)
    for k,v in pairs(org) do
        if type(v) ~= "table" then
            res[k] = v;
        else
            res[k] = {};
            self:copy(v, res[k])
        end
    end
end



function MainUINPCFunctionEntry:DisableFunctionEnty()
	for i = 1,3,1 do
	if self._funEnty[i] ~= nil then
		self._funEnty[i].gameObject:SetActive(false);
	end
	end
	print(self.curNpcId);
	print("Disable FunctionEnty");
end

function OnClick(go,id)
	--  GameLog.Log("id %d",id)
	  if id == 1200 then
	  	GameLog.Log("id %d",id);
	  elseif id == 1201 then 
	  	GameLog.Log("id %d",id);
	  elseif id == 1202 then
	  	GameLog.Log("id %d",id);
	  end
  end




return MainUINPCFunctionEntry;