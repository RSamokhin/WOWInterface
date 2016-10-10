local WorldQuestGroupFinder, L = ...;

local function WorldQuestGroupFinder_DefaultString(L, key)
	return key;
end

setmetatable(L, { __index = WorldQuestGroupFinder_DefaultString });