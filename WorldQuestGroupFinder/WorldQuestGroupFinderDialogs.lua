WorldQuestGroupFinderDialogs = {}
local _, L = ...;

StaticPopupDialogs["WORLD_QUEST_FINISHED_LEADER_PROMPT"] = {
	text = L["You have completed the world quest.\n\nWould you like to leave the group or delist it from the Group Finder?"],
	button1 = L["Leave"],
	button2 = L["Stay"],
	button3 = L["Delist"],
	OnAccept = function()
		LeaveParty()
	end,
	OnAlt = function()
		C_LFGList.RemoveListing()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  
}

StaticPopupDialogs["WORLD_QUEST_FINISHED_PROMPT"] = {
	text = L["You have completed the world quest.\n\nWould you like to leave the group?"],
	button1 = L["Leave"],
	button2 = L["Stay"],
	OnAccept = function()
		LeaveParty()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  
}

StaticPopupDialogs["NEW_WORLD_QUEST_PROMPT"] = {
	text = L["You are currently grouped for another world quest.\n\nAre you sure to want to start another one?"],
	button1 = L["Yes"],
	button2 = L["Cancel"],  
	OnAccept = function(self, data)
		LeaveParty()
		C_Timer.After(1, function()
			WorldQuestGroupFinder.InitWQGroup(data)
		end)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,  
}

StaticPopupDialogs["WORLD_QUEST_ENTERED_PROMPT"] = {
	text = L["You have entered a new world quest area.\n\nWould you like to find a group for \"%s\"?"],
	button1 = L["Yes"],
	button2 = L["No"],  
	OnAccept = function(self, data)
		WorldQuestGroupFinder.InitWQGroup(data)
	end,
	timeout = 15,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  
}

StaticPopupDialogs["WORLD_QUEST_ENTERED_SWITCH_PROMPT"] = {
	text = L["You have entered a new world quest area, but are currently grouped for another world quest.\n\nWould you like to leave your current group and find another for \"%s\"?"],
	button1 = L["Yes"],
	button2 = L["No"],  
	OnAccept = function()
		LeaveParty()
		C_Timer.After(1, function(self, data)
			WorldQuestGroupFinder.InitWQGroup(data)
		end)
	end,
	timeout = 15,
	whileDead = false,
	hideOnEscape = true,
	preferredIndex = 3,  
}