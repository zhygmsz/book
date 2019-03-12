module("PuzzleData", package.seeall)

DATA.PuzzleData.mPuzzleData = nil;

local function OnLoadPuzzleData(data)
    local datas = Puzzle_pb.AllPuzzleData()
    datas:ParseFromString(data)

    local puzzleData = {};

    for k,v in ipairs(datas.datas) do
        puzzleData[v.puzzleId] = puzzleData[v.puzzleId] or {}
        puzzleData[v.puzzleId][v.pieceId] = v
    end

    DATA.PuzzleData.mPuzzleData = puzzleData;
end

function InitModule()
	local argData1 = 
	{
		keys = { mPuzzleData = true },
		fileName = "PuzzleData.bytes",
		callBack = OnLoadPuzzleData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.PuzzleData,argData1);
end

--获取一个拼图所有碎片数据
function GetPuzzleData(puzzleId)
    return DATA.PuzzleData.mPuzzleData[puzzleId]
end

return PuzzleData;