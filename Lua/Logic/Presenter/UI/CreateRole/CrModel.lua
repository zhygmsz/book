
local CrModel = class("CrModel",nil)

function CrModel:ctor()
    self._rpMap ={}
    self._racial = 1
    self._profession = 1
    self._racialIndex = 1
    self._professionIndex = 1
	self._playerName = ""
	self:InitData()
end

--构造数据
function CrModel:InitData()
	local tnum=ProfessionData.GetRacialKeys()
	for i=1,#tnum do
		local key = tnum[i]
		self._rpMap[i]={racial = key,professions ={}}
		local professiontable =ProfessionData.GetRacialTable(key)
		for k,v in pairs(professiontable) do
			table.insert(self._rpMap[i].professions,k)
		end
	end
	self._racial = self._rpMap[self._racialIndex].racial
	self._profession = self._rpMap[self._racialIndex].professions[self._professionIndex]
end

--获得当前职业的资源列表
function CrModel:GetCurrentJobRes()
	self._racial = self._rpMap[self._racialIndex].racial
	self._profession = self._rpMap[self._racialIndex].professions[self._professionIndex]
	local res = ProfessionData.GetProfessionResByRacialProfession(self._racial,self._profession)
	return res
end

--获得当前职业的资源列表
function CrModel:GetRacialList()
	local data ={}
	for k,v in pairs(self._rpMap) do
		local profession = v.professions[1]
		local res = ProfessionData.GetProfessionResByRacialProfession(v.racial,profession)
		if res==nil then res = {unOpen =true, headIcon =ConfigData.GetValue("Createrole_role_unopened") ,professionIcon = ConfigData.GetValue("Createrole_school_unopened")} end
		table.insert(data,res)
	end
	return data
end

--获得当前职业的资源列表
function CrModel:GetProfessionList()
	local data ={}
	local professions = self._rpMap[self._racialIndex].professions
	self._racial = self._rpMap[self._racialIndex].racial
	for k,v in pairs(professions) do
		local res = ProfessionData.GetProfessionResByRacialProfession(self._racial,v)
		if res==nil then res = {unOpen =true, headIcon =ConfigData.GetValue("Createrole_role_unopened") ,professionIcon = ConfigData.GetValue("Createrole_school_unopened")} end	
		table.insert(data,res)
	end
	return data
end

function CrModel:GetProfessionAtt()
	local proAtt = ProfessionData.GetProfessionAtt(self._profession)
	return proAtt
end

function CrModel:SetRacialIndex(index)
    self._racialIndex =index
    self._racial = self._rpMap[self._racialIndex].racial
end

function CrModel:SetProfessionIndex(index)
    self._professionIndex = index
    self._profession = self._rpMap[self._racialIndex].professions[self._professionIndex]
end

function CrModel:GetRacialIndex()
    return self._racialIndex
end

function CrModel:GetProfessionIndex()
    return self._professionIndex
end
function CrModel:SetPlayerName(name)
    self._playerName = name
end

function CrModel:GetPlayerName()
    return self._playerName
end

function CrModel:GetRacial()
    return self._racial
end

function CrModel:GetProfession()
    return self._profession
end

function CrModel:Destory()
end

return CrModel