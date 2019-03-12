local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local JOKEIntentionProcessor = class("JOKEIntentionProcessor",BaseIntentionProcessor); 

function JOKEIntentionProcessor:ctor()
    BaseIntentionProcessor.ctor(self);
end
--[[
    {"semantic_result":{"input":"讲个笑话","final_result":[{"detail":{"joke_class":"笑话"},"intention":"JOKE","responde":{"result":{"text_jokes":[{"title":"你们听我解释啊，这不关我的事！","content":"去女友家吃饭。饭桌上给大家表演一个魔术。大喊一声：“见证奇迹的时刻到了！”岳父椅子应声而倒，全家人传过来杀人的目光。老爷子。听我解释。椅子真的不是我弄的……\r"}],"jokes":[{"mp3":"http:\/\/matrix.speech.sogou.com\/speech\/jokemp3\/676.mp3","title":"梦中富贵"}],"tts":"好的","text":"好的,为您准备笑话\"梦中富贵\""},"cmd":"joke"},"answer":"好的,为您准备笑话\"梦中富贵\""}],"res":0,"sys_time":"20181119_18:06:48"}}
]]
function JOKEIntentionProcessor:Process(jsonData,respondeTime)
    GameLog.Log("%s is Processing: %s", self.__cname,jsonData);
    -- local title = tostring(jsonData["responde"]["result"]["text_jokes"][1]["title"]);
    local content = tostring(jsonData["responde"]["result"]["text_jokes"][1]["content"]);

    local answer = tostring(jsonData["answer"]);

    AIPetMgr.NewAIDialog(content,respondeTime);

end

return JOKEIntentionProcessor;
