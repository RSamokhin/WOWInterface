local WorldQuestGroupFinderAddon = CreateFrame("Frame", "WorldQuestGroupFinderAddon", UIParent)
local _, L = ...;

WorldQuestGroupFinder = {}

local RegisteredEvents = {}
WorldQuestGroupFinderAddon:SetScript("OnEvent", function (self, event, ...) if (RegisteredEvents[event]) then return RegisteredEvents[event](self, event, ...) end end)

local name = "WorldQuestGroupCurrentWQFrame"
local currentWQFrame = CreateFrame("frame",name,UIParent)
	
local currentWQ = nil
local tempWQ = nil
local recentlyTimedOut = false
local recentlyInvited = false
local upToDateGroupMembersCount = 0
local currentlyApplying = false
local INVITE_TIMEOUT_DELAY = 20
local BROADCAST_PREFIX = "WQGF"

local activityIDs = {
	["419"] = GetMapNameByID(1015),
	["420"] = GetMapNameByID(1018), 
	["421"] = GetMapNameByID(1024), 
	["422"] = GetMapNameByID(1017), 
	["423"] = GetMapNameByID(1033)
}

local blacklistedQuests = { 
	[43943] = true, -- Withered Army Training
	[42725] = true, -- Sharing the Wealth
	[42880] = true, -- Meeting their Quota
	[44011] = true, -- Lost Wisp
	[43774] = true, -- Ley Race
	[43764] = true, -- Ley Race
	[43753] = true, -- Ley Race
	[43325] = true, -- Ley Race
	[43769] = true, -- Ley Race
	[43772] = true, -- Enigmatic
	[43767] = true, -- Enigmatic
	[43756] = true, -- Enigmatic
	[41327] = true, -- Supplies Needed: Stormscales
	[41237] = true, -- Supplies Needed: Stonehide Leather
	[41351] = true, -- Supplies Needed: Stonehide Leather
	[41207] = true, -- Supplies Needed: Leystone
	[41339] = true, -- Supplies Needed: Stonehide Leather
	[41298] = true, -- Supplies Needed: Fjarnskaggl
	[41315] = true, -- Supplies Needed: Leystone
	[41316] = true, -- Supplies Needed: Leystone
	[41317] = true, -- Supplies Needed: Leystone
	[41303] = true, -- Supplies Needed: Starlight Roses
	[41288] = true -- Supplies Needed: Aethril
}

-- Quests you can complete while in a raid
local raidQuests = { 
	[42820] = true, -- DANGER: Aegir Wavecrusher
	[41685] = true, -- DANGER: Ala'washte
	[44121] = true, -- DANGER: Az'jatar
	[42861] = true, -- DANGER: Boulderfall, the Eroded
	[42864] = true, -- DANGER: Captain Dargun
	[43121] = true, -- DANGER: Chief Treasurer Jabrill
	[41697] = true, -- DANGER: Colerian, Alteria, and Selenyi
	[43175] = true, -- DANGER: Deepclaw
	[41695] = true, -- DANGER: Defilia
	[42785] = true, -- DANGER: Den Mother Ylva
	[41093] = true, -- DANGER: Durguth
	[43346] = true, -- DANGER: Ealdis
	[43059] = true, -- DANGER: Fjordun
	[42806] = true, -- DANGER: Fjorlag, the Grave's Chill
	[43345] = true, -- DANGER: Harbinger of Screams
	[43079] = true, -- DANGER: Immolian
	[44190] = true, -- DANGER: Jade Darkhaven
	[44191] = true, -- DANGER: Karthax
	[43798] = true, -- DANGER: Kosumoth the Hungering
	[42964] = true, -- DANGER: Lagertha
	[44192] = true, -- DANGER: Lysanis Shadesoul
	[43152] = true, -- DANGER: Lytheron
	[44114] = true, -- DANGER: Magistrix Vilessa
	[42927] = true, -- DANGER: Malisandra
	[43098] = true, -- DANGER: Marblub the Massive
	[41696] = true, -- DANGER: Mawat'aki
	[43027] = true, -- DANGER: Mortiferous
	[43333] = true, -- DANGER: Nylaathria the Forgotten
	[41703] = true, -- DANGER: Ormagrogg
	[41816] = true, -- DANGER: Oubdob da Smasher
	[42963] = true, -- DANGER: Rulf Bonesnapper
	[42991] = true, -- DANGER: Runeseer Sigvid
	[42797] = true, -- DANGER: Scythemaster Cil'raman
	[44193] = true, -- DANGER: Sea King Tidross
	[41700] = true, -- DANGER: Shalas'aman
	[44122] = true, -- DANGER: Sorallus
	[42953] = true, -- DANGER: Soulbinder Halldora
	[43072] = true, -- DANGER: The Whisperer
	[44194] = true, -- DANGER: Torrentius
	[43040] = true, -- DANGER: Valakar the Thirsty
	[44119] = true, -- DANGER: Volshax, Breaker of Will
	[43101] = true, -- DANGER: Withdoctor Grgl-Brgl
	[41779] = true, -- DANGER: Xavrix
	[44017] = true, -- WANTED: Apothecary Faldren
	[44032] = true, -- WANTED: Apothecary Faldren
	[42636] = true, -- WANTED: Arcanist Shal'iman
	[43605] = true, -- WANTED: Arcanist Shal'iman
	[42620] = true, -- WANTED: Arcavellus
	[43606] = true, -- WANTED: Arcavellus
	[41824] = true, -- WANTED: Arru
	[44289] = true, -- WANTED: Arru
	[44301] = true, -- WANTED: Bahagar
	[44305] = true, -- WANTED: Bahagar
	[41836] = true, -- WANTED: Bodash the Hoarder
	[43616] = true, -- WANTED: Bodash the Hoarder
	[41828] = true, -- WANTED: Bristlemaul
	[44290] = true, -- WANTED: Bristlemaul
	[43426] = true, -- WANTED: Brogozog
	[43607] = true, -- WANTED: Brogozog
	[42796] = true, -- WANTED: Broodmother Shu'malis
	[44016] = true, -- WANTED: Cadraeus
	[44031] = true, -- WANTED: Cadraeus
	[43430] = true, -- WANTED: Captain Volo'ren
	[43608] = true, -- WANTED: Captain Volo'ren
	[41826] = true, -- WANTED: Crawshuk the Hungry
	[44291] = true, -- WANTED: Crawshuk the Hungry
	[44299] = true, -- WANTED: Darkshade
	[44304] = true, -- WANTED: Darkshade
	[43455] = true, -- WANTED: Devouring Darkness
	[43617] = true, -- WANTED: Devouring Darkness
	[43428] = true, -- WANTED: Doomlord Kazrok
	[43609] = true, -- WANTED: Doomlord Kazrok
	[44298] = true, -- WANTED: Dreadbog
	[44303] = true, -- WANTED: Dreadbog
	[43454] = true, -- WANTED: Egyl the Enduring
	[43620] = true, -- WANTED: Egyl the Enduring
	[43434] = true, -- WANTED: Fathnyr
	[43621] = true, -- WANTED: Fathnyr
	[43436] = true, -- WANTED: Glimar Ironfist
	[43622] = true, -- WANTED: Glimar Ironfist
	[44030] = true, -- WANTED: Guardian Thor'el
	[44013] = true, -- WANTED: Guardian Thor'el
	[41819] = true, -- WANTED: Gurbog da Basher
	[43618] = true, -- WANTED: Gurbog da Basher
	[43453] = true, -- WANTED: Hannval the Butcher
	[43623] = true, -- WANTED: Hannval the Butcher
	[44021] = true, -- WANTED: Hertha Grimdottir
	[44029] = true, -- WANTED: Hertha Grimdottir
	[43427] = true, -- WANTED: Infernal Lord
	[43610] = true, -- WANTED: Infernal Lord
	[43611] = true, -- WANTED: Inquisitor Tivos
	[42631] = true, -- WANTED: Inquisitor Tivos
	[43452] = true, -- WANTED: Isel the Hammer
	[43624] = true, -- WANTED: Isel the Hammer
	[43460] = true, -- WANTED: Kiranys Duskwhisper
	[43629] = true, -- WANTED: Kiranys Duskwhisper
	[44028] = true, -- WANTED: Lieutenant Strathmar
	[44019] = true, -- WANTED: Lieutenant Strathmar
	[44018] = true, -- WANTED: Magister Phaedris
	[44027] = true, -- WANTED: Magister Phaedris
	[41818] = true, -- WANTED: Majestic Elderhorn
	[44292] = true, -- WANTED: Majestic Elderhorn
	[44015] = true, -- WANTED: Mal'Dreth the Corruptor
	[44026] = true, -- WANTED: Mal'Dreth the Corruptor
	[43438] = true, -- WANTED: Nameless King
	[43625] = true, -- WANTED: Nameless King
	[43432] = true, -- WANTED: Normantis the Deposed
	[43612] = true, -- WANTED: Normantis the Deposed
	[44010] = true, -- WANTED: Oreth the Vile
	[43458] = true, -- WANTED: Perrexx
	[43630] = true, -- WANTED: Perrexx
	[42795] = true, -- WANTED: Sanaar
	[44300] = true, -- WANTED: Seersei
	[44302] = true, -- WANTED: Seersei
	[41844] = true, -- WANTED: Sekhan
	[44294] = true, -- WANTED: Sekhan
	[44022] = true, -- WANTED: Shal'an
	[41821] = true, -- WANTED: Shara Felbreath
	[43619] = true, -- WANTED: Shara Felbreath
	[44012] = true, -- WANTED: Siegemaster Aedrin
	[44023] = true, -- WANTED: Siegemaster Aedrin
	[43456] = true, -- WANTED: Skul'vrax
	[43631] = true, -- WANTED: Skul'vrax
	[41838] = true, -- WANTED: Slumber
	[44293] = true, -- WANTED: Slumber
	[43429] = true, -- WANTED: Syphonus
	[43613] = true, -- WANTED: Syphonus
	[43437] = true, -- WANTED: Thane Irglov
	[43626] = true, -- WANTED: Thane Irglov
	[43457] = true, -- WANTED: Theryssia
	[43632] = true, -- WANTED: Theryssia
	[43459] = true, -- WANTED: Thondrax
	[43633] = true, -- WANTED: Thondrax
	[43450] = true, -- WANTED: Tiptog the Lost
	[43627] = true, -- WANTED: Tiptog the Lost
	[43451] = true, -- WANTED: Urgev the Flayer
	[43628] = true, -- WANTED: Urgev the Flayer
	[42633] = true, -- WANTED: Vorthax
	[43614] = true, -- WANTED: Vorthax
	[43431] = true, -- WANTED: Warbringer Mox'na
	[42270] = true, -- Scourge of the Skies
	[44287] = true, -- DEADLY: Withered J'im
	[43192] = true -- Terror of the Deep
}

local pendingApplications = {}
local blacklistedLeaders = {}
local seenWorldQuests = {}

local function chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end
 
local function utf8sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end
 
  local currentIndex = startIndex
 
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "WorldQuestGroupFinder") then
		RegisterAddonMessagePrefix(BROADCAST_PREFIX)
		SLASH_WQGF1 = '/wqgf'
		SlashCmdList["WQGF"] = function (msg, editbox)
			WorldQuestGroupFinder.handleCMD(msg, editbox)	
		end
		setmetatable(WorldQuestGroupFinderConfig, {__index = WorldQuestGroupFinderConf.DefaultConfig})
	end
end

function RegisteredEvents:PLAYER_LOGIN(event)
	if (not WorldQuestGroupFinderConf.GetConfigValue("hideLoginMessage")) then
		print("|c00bfffffWorld Quest Group Finder v"..GetAddOnMetadata("WorldQuestGroupFinder", "Version").." BETA. "..L["Click on a world quest in the objective tracking window to search for a group."])
	end
	WorldQuestGroupFinder.SetHooks()
	WorldQuestGroupFinderConf.CreateConfigMenu()
	WorldQuestGroupFinder.dprint("World Quest Group Finder - "..L["Debug mode is enabled"])
	if (WorldQuestGroupFinderConf.GetConfigValue("savedCurrentWQ", "CHAR") ~= nil and currentWQ == nil) then
		C_Timer.After(1, function()
			if (IsInGroup() and C_LFGList.GetActiveEntryInfo()) then
				WorldQuestGroupFinder.dprint(L["Retrieved saved current world quest info. Still in group. Restoring..."])
				WorldQuestGroupFinder.HandleWorldQuestStart(WorldQuestGroupFinderConf.GetConfigValue("savedCurrentWQ", "CHAR"))
			else
				WorldQuestGroupFinder.dprint(L["Retrieved saved current world quest info. No longer in group. Deleting..."])
				WorldQuestGroupFinderConf.SetConfigValue("savedCurrentWQ", nil, "CHAR")
			end
		end)
	end
end

function RegisteredEvents:LFG_LIST_APPLICANT_LIST_UPDATED(event, hasNewPending, hasNewPendingWithData)
	if ( currentWQ ~= nil and hasNewPending and hasNewPendingWithData and LFGListUtil_IsEntryEmpowered()) then
		WorldQuestGroupFinder.HandleCustomAutoInvite()
	end
end

function RegisteredEvents:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	local cutPlayerName = (string.gsub(sender, "(.*)-(.*)", "%1"))
	if (prefix == BROADCAST_PREFIX and cutPlayerName ~= UnitName("player")) then
		WorldQuestGroupFinder.dprint(string.format(L["Received addon message. Sender: %s. Message: %s."], sender, message))
		if (string.find(message, "#WQS:")) then
			local tempWQ = string.gsub(message, "#WQS:(.*)#", "%1")
			tempWQ = tonumber(tempWQ)
			if (tempWQ ~= currentWQ) then
				if(IsQuestFlaggedCompleted(tempWQ)) then
					WorldQuestGroupFinder.prefixedPrint(string.format(L["Your group is now doing the world quest |c00bfffff%s|c00ffffff. You already have completed this world quest."], WorldQuestGroupFinder.GetQuestInfo(tempWQ)))
				else
					if (WorldQuestGroupFinder.HandleWorldQuestStart(tempWQ)) then
						WorldQuestGroupFinder.prefixedPrint(string.format(L["Your group is now doing the world quest |c00bfffff%s|c00ffffff."], WorldQuestGroupFinder.GetQuestInfo(tempWQ)))
					else 
						WorldQuestGroupFinder.prefixedPrint(string.format(L["Your group is now doing the world quest |c00bfffff%s|c00ffffff. You are not eligible to do this world quest."], WorldQuestGroupFinder.GetQuestInfo(tempWQ)))
					end
				end	
			end
		elseif (string.find(message, "#WQE:")) then
			local tempWQ = string.gsub(message, "#WQE:(.*)#", "%1")
			tempWQ = tonumber(tempWQ)
			WorldQuestGroupFinder.prefixedPrint(string.format(L["Your group is no longer doing the world quest |c00bfffff%s|c00ffffff."], WorldQuestGroupFinder.GetQuestInfo(tempWQ)))
			if (currentWQ == tempWQ) then
				WorldQuestGroupFinder.HandleWorldQuestEnd(tempWQ)
			end
		end
	end
end

function RegisteredEvents:QUEST_TURNED_IN(event, questID, experience, money)
	-- Hide join WQ prompts
	WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_PROMPT")
	WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_SWITCH_PROMPT")
	WorldQuestGroupFinder.dprint(string.format(L["Quest completed. (ID: %d)"], questID))
	if (currentWQ ~= nil and questID == currentWQ) then
		if (WorldQuestGroupFinderConf.GetConfigValue("notifyParty") and IsInGroup()) then
			WorldQuestGroupFinder.SendWQCompletionPartyNotification(questID)
		end
		if (WorldQuestGroupFinderConf.GetConfigValue("askToLeave")) then
			WorldQuestGroupFinder.ShowLeavePrompt()
		end
		WorldQuestGroupFinder.HandleWorldQuestEnd(currentWQ)
	end
end

function RegisteredEvents:LFG_LIST_APPLICATION_STATUS_UPDATED(event, applicationID, status)
	if (currentlyApplying) then
		local _,_,name,description,_,ilvl,_,_,_,_,_,_,author,members = C_LFGList.GetSearchResultInfo(applicationID)
		WorldQuestGroupFinder.dprint(string.format(L["Application has changed status. ID: %d. New status: %s."], applicationID, status))
		if (status == "applied") then
			pendingApplications[applicationID] = tempWQ
		end
		if (status == "invited") then
			-- Set as recently invited, to avoid the cancelled status for other applied groups
			if (WorldQuestGroupFinderConf.GetConfigValue("autoAcceptInvites") and not recentlyInvited) then
				WorldQuestGroupFinder.dprint(string.format(L["Auto-accepting group invite (ID: %d)"], applicationID))
				C_LFGList.AcceptInvite(applicationID)
			end
			recentlyInvited = true
			WorldQuestGroupFinder.StopTimeoutTimer()
		end
		if (status == "declined" or status == "invitedeclined") then
			blacklistedLeaders[author] = true
			-- If all applications have been declined, restart process. A new group will be created if nothing else is found.
			if ((C_LFGList.GetNumApplications() - 1 == 0) and not (recentlyInvited or currentWQ)) then
				WorldQuestGroupFinder.InitWQGroup(pendingApplications[applicationID], true)
			end
			table.remove(pendingApplications, applicationID)
		end
		if (status == "failed" or status == "timedout") then
			if (pendingApplications[applicationID]) then
				table.remove(pendingApplications, applicationID)
			end
		end
		if (status == "cancelled" or status == "invitedeclined") then
			-- If cancelled status was caused by the addon
			if (recentlyTimedOut or recentlyInvited or currentWQ) then
				recentlyTimedOut = false
			else
				blacklistedLeaders[author] = true
				WorldQuestGroupFinder.prefixedPrint(string.format(L["You have cancelled your apply for |c00bfffff%s|c00ffffff's group for |c00bfffff%s|c00ffffff. WQGF will not try to join this group again until you relog or clear the leaders blacklist."], author, WorldQuestGroupFinder.GetQuestInfo(pendingApplications[applicationID])))
				table.remove(pendingApplications, applicationID)
				if (C_LFGList.GetNumApplications() == 0) then
					WorldQuestGroupFinder.StopTimeoutTimer()
				end
			end
			recentlyInvited = false
		end
		if (status == "inviteaccepted") then
			recentlyInvited = false
			WorldQuestGroupFinder.prefixedPrint(string.format(L["You have joined |c00bfffff%s|c00ffffff's group for |c00bfffff%s|c00ffffff. Have fun!"], author, WorldQuestGroupFinder.GetQuestInfo(pendingApplications[applicationID])))
			WorldQuestGroupFinder.HandleWorldQuestStart(pendingApplications[applicationID])
			C_Timer.After(1, function()
				if (IsInRaid()) then
					if (not raidQuests[pendingApplications[applicationID]]) then
						WorldQuestGroupFinder.prefixedPrint(L["|c0000ffffWARNING:|c00ffffff This group is in raid mode which means you won't be able to complete the world quest. You should ask the leader to switch back to party mode if possible. The group will automatically switch to party mode if you become the leader."])
					end
				end
			end)
		end
		
		if (C_LFGList.GetNumApplications() <= 0) then
			currentlyApplying = false
		end
	end
end

function RegisteredEvents:GROUP_ROSTER_UPDATE(event)
	-- Remember that this event is often triggered multiple times
	if (currentWQ ~= nil) then
		-- Leaving the group.
		if (not IsInGroup()) then
			WorldQuestGroupFinder.HandleWorldQuestEnd(currentWQ)
		end
		if (UnitIsGroupLeader("player")) then
			-- If doing a world quest, group is not full and applicants are waiting, we will try to invite them
			if ((GetNumGroupMembers() < 5 or raidQuests[currentWQ]) and C_LFGList.GetNumApplicants() > 0) then
				WorldQuestGroupFinder.HandleCustomAutoInvite()
			end
			-- You don't want to  be in raid mode, unless it is an elite quest
			if (IsInRaid() and GetNumGroupMembers() <= 5 and not raidQuests[currentWQ]) then
				ConvertToParty()
			end
		end
	end
end

for k, v in pairs(RegisteredEvents) do
	WorldQuestGroupFinderAddon:RegisterEvent(k)
end

function WorldQuestGroupFinder.GetQuestInfo (questID)
	local tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = GetQuestTagInfo (questID)
	local title, factionID = C_TaskQuest.GetQuestInfoByQuestID (questID)
	return title, factionID, tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex
end

function WorldQuestGroupFinder.SetHooks()	
	local bkp_BonusObjectiveTracker_OnBlockClick = BonusObjectiveTracker_OnBlockClick
	function BonusObjectiveTracker_OnBlockClick(self, button)	
		if (button == "LeftButton" and not IsShiftKeyDown()) then
			tempWQ = self.TrackedQuest.questID
			WorldQuestGroupFinder.dprint(string.format(L["World quest has been clicked. ID: %d"], tempWQ))
			if (IsInGroup() and not UnitIsGroupLeader("player")) then
				WorldQuestGroupFinder.prefixedPrint(L["You are not the group leader."])
				return false
			end
			if (currentWQ ~= nil and tempWQ ~= currentWQ) then
				WorldQuestGroupFinder.dprint(string.format(L["Clicked world quest is not the same is current (%d). Showing NEW_WORLD_QUEST_PROMPT."], currentWQ))
				WorldQuestGroupFinder.ShowDialog ("NEW_WORLD_QUEST_PROMPT")
			else 
				-- No current WQ. 
				if (currentWQ == nil) then
					-- Hide join WQ prompts
					WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_PROMPT")
					WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_SWITCH_PROMPT")
					WorldQuestGroupFinder.InitWQGroup(tempWQ)
				else
					WorldQuestGroupFinder.prefixedPrint(L["You already are in a group for this world quest."])
				end
			end
		end
		bkp_BonusObjectiveTracker_OnBlockClick(self, button)
	end
	
	local bkp_BonusObjectiveTracker_OnBlockAnimInFinished = BonusObjectiveTracker_OnBlockAnimInFinished
	function BonusObjectiveTracker_OnBlockAnimInFinished(self) 
		if (WorldQuestGroupFinderConf.GetConfigValue("askZoning")) then
			local block = self:GetParent();
			local title, factionID, tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = WorldQuestGroupFinder.GetQuestInfo(block.id)
			-- If already queued for something or if the quest is in blacklist, do not prompt
			tempWQ = block.id
			if (not WorldQuestGroupFinder.IsAlreadyQueued(false) and not blacklistedQuests[tempWQ]) then
				-- Ignore pet battle and dungeon quests
				if (worldQuestType ~= LE_QUEST_TAG_TYPE_PET_BATTLE and worldQuestType ~= LE_QUEST_TAG_TYPE_DUNGEON and worldQuestType ~= LE_QUEST_TAG_TYPE_PROFESSION) then
					if (not IsInGroup() and WorldQuestGroupFinderConf.GetConfigValue("askZoningAuto")) then
						WorldQuestGroupFinder.InitWQGroup(tempWQ)
					else
						-- Check if the world quest zone has already been entered during this session
						if not seenWorldQuests[block.id] then
							-- No current WQ. 
							if (currentWQ == nil) then
								seenWorldQuests[block.id] = true
								WorldQuestGroupFinder.ShowDialog ("WORLD_QUEST_ENTERED_PROMPT", title)
							-- Already doing another WQ
							elseif (currentWQ ~= nil and tempWQ ~= currentWQ) then
								if not WorldQuestGroupFinderConf.GetConfigValue("askZoningBusy") then
									WorldQuestGroupFinder.FlagWQAsSeen(block.id)
									WorldQuestGroupFinder.ShowDialog ("WORLD_QUEST_ENTERED_SWITCH_PROMPT", title)
								end
							end
						else 
							WorldQuestGroupFinder.dprint(string.format(L["World quest #%d zone has already been visited. Dialog will not be shown."], block.id))
						end
					end
				end
			end
		end
		bkp_BonusObjectiveTracker_OnBlockAnimInFinished(self) 
	end

	local bkp_BonusObjectiveTracker_OnBlockAnimOutFinished = BonusObjectiveTracker_OnBlockAnimOutFinished
	function BonusObjectiveTracker_OnBlockAnimOutFinished(self) 
		WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_PROMPT")
		WorldQuestGroupFinder.HideDialog ("WORLD_QUEST_ENTERED_SWITCH_PROMPT")
		bkp_BonusObjectiveTracker_OnBlockAnimOutFinished(self) 
	end
			
	local bkp_ObjectiveTracker_Update = ObjectiveTracker_Update
	function ObjectiveTracker_Update(reason, id)
		bkp_ObjectiveTracker_Update(reason, id)
		if (reason and reason == OBJECTIVE_TRACKER_UPDATE_QUEST and currentWQ) then
			WorldQuestGroupFinder.AttachBorderToWQ(currentWQ)
		end
	end
		
	local bkp_C_LFGList_RemoveListing = C_LFGList.RemoveListing
	function C_LFGList.RemoveListing()
		if (currentWQ ~= nil) then
			WorldQuestGroupFinder.HandleWorldQuestEnd(currentWQ, true)
		end
		bkp_C_LFGList_RemoveListing()
	end
	
	local bkp_BonusObjectiveTracker_OnOpenDropDown = BonusObjectiveTracker_OnOpenDropDown
	function BonusObjectiveTracker_OnOpenDropDown(self)		
		local block = self.activeFrame;
		local questID = block.TrackedQuest.questID;
		
		if (tonumber(questID) ~= tonumber(currentWQ)) then
			local searchGroup = UIDropDownMenu_CreateInfo();
			searchGroup.notCheckable = true;

			searchGroup.text = L["Search or Create Group"];
			searchGroup.func = function()
				WorldQuestGroupFinder.InitWQGroup(questID);
			end;

			searchGroup.checked = false;
			UIDropDownMenu_AddButton(searchGroup, UIDROPDOWN_MENU_LEVEL);
			bkp_BonusObjectiveTracker_OnOpenDropDown(self)
		else 
			local searchGroup = UIDropDownMenu_CreateInfo();
			searchGroup.notCheckable = true;

			searchGroup.text = L["Stop grouping for this world quest"];
			searchGroup.func = function()
				if (IsInGroup() and not UnitIsGroupLeader("player")) then
					WorldQuestGroupFinder.prefixedPrint(L["You are not the group leader."])
				else
					C_LFGList.RemoveListing()
				end
			end;

			searchGroup.checked = false;
			UIDropDownMenu_AddButton(searchGroup, UIDROPDOWN_MENU_LEVEL);
		end
	end
	
	--if (IsAddOnLoaded("WorldQuestTracker")) then	
	--end
end

function WorldQuestGroupFinder.AddWorldQuestToTracker(questID)
	AddWorldQuestWatch(questID, true) 
end

function WorldQuestGroupFinder.IsAlreadyQueued(verbose)
	mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFD);
	if ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		if verbose then	WorldQuestGroupFinder.prefixedPrint(L["You are currently queued in the Dungeon Finder. Please leave the queue and try again."]) end
		return true
	end
	mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFR);
	if ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		if verbose then	WorldQuestGroupFinder.prefixedPrint(L["You are currently queued in the Raid Finder. Please leave the queue and try again."]) end
		return true
	end	
	mode, subMode = GetLFGMode(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
	if ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
		if verbose then	WorldQuestGroupFinder.prefixedPrint(L["You are currently queued in the Raid Finder. Please leave the queue and try again."]) end
		return true
	end
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			if verbose then	WorldQuestGroupFinder.prefixedPrint(L["You are currently queued for a battleground. Please leave the queue and try again."]) end
			return true
		end
	end
	return false
end

function WorldQuestGroupFinder.InitWQGroup(wqID, retry) 
	local title, factionID, tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = WorldQuestGroupFinder.GetQuestInfo(wqID)
	--print(QuestPOIGetIconInfo(wqID))
	WorldQuestGroupFinder.dprint(string.format(L["Looking for a group for a world quest. ID: %d"], wqID))
	local foundZone = false
	local foundGroup = false
	local currentZone = nil
	local retry = retry or false
	if (IsInGroup() and not UnitIsGroupLeader("player")) then
		WorldQuestGroupFinder.prefixedPrint(L["You are not the group leader."])
		return false
	end
	-- Ignore pet battle and dungeon quests
	if (worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE or worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON or worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION) then
		WorldQuestGroupFinder.prefixedPrint(L["This type of world quest cannot be accomplished as a group."])
		return false
	end
	-- Ignore blacklisted quests
	if (blacklistedQuests[wqID]) then
		WorldQuestGroupFinder.prefixedPrint(L["This world quest cannot be accomplished as a group."])
		return false
	end
	-- Check if already queued
	if (WorldQuestGroupFinder.IsAlreadyQueued(true)) then
		return false
	end
	-- Finding current zone activity ID
	for k,v in pairs( activityIDs ) do
		if (C_LFGList.GetActivityInfoExpensive(k)) then
			currentZone = k
			foundZone = true
		end
	end
	-- Special case : Eye of Azshara
	if (not foundZone and GetCurrentMapAreaID() == 1096) then
		currentZone = "419"
		foundZone = true
	end
	if (foundZone) then
		C_LFGList.RemoveListing()
		-- Clear existing applications
		if (C_LFGList.GetNumApplications() > 0) then
			for k,v in pairs( C_LFGList.GetApplications() ) do
				-- If this is retry and some applications didnt get confirmed, put group in BL
				if (retry) then
					local _,_,_,_,_,_,_,_,_,_,_,_,groupAuthor,_ = C_LFGList.GetSearchResultInfo(v)
					pendingApplications = {}
					blacklistedLeaders[groupAuthor] = true
				end
				C_LFGList.CancelApplication(v)
			end
		end
		WorldQuestGroupFinder.prefixedPrint(string.format(L["Searching for a group for world quest |c00bfffff%s|c00ffffff..."], title))
		-- Search for existing groups
		C_LFGList.ClearSearchResults()
		C_LFGList.Search(1, "#WQ:"..wqID.."#", 0, 4, C_LFGList.GetLanguageSearchFilter());
		-- Delay to let the search finish
		C_Timer.After(3, function()
			local applicationsCount = 0
			local blacklistedApplicationsCount = 0
			local searchCount, searchResults = C_LFGList.GetSearchResults()
			local currentPlayers = 1;
			if (IsInGroup()) then
				currentPlayers = GetNumGroupMembers()
			end
			for k, v in pairs( searchResults ) do
				local id,_,name,description,_,ilvl,_,_,_,_,_,_,author,members = C_LFGList.GetSearchResultInfo(v)
				-- Double check for description content, required ilvl and group members count
				if (string.find(description, "#WQ:"..wqID.."#") ~= nil and GetAverageItemLevel() > ilvl and (members + currentPlayers <= 5 or raidQuests[currentWQ]) and author ~= UnitName("player")) then
					if (blacklistedLeaders[author] == true) then
						WorldQuestGroupFinder.dprint(string.format(L["Ignoring group because leader is blacklisted. ID: %d, Name: %s, Leader: %s"], id, name, author))
						blacklistedApplicationsCount = blacklistedApplicationsCount + 1
					else 
						foundGroup = true
						currentlyApplying = true
						local canBeTank = LFDQueueFrameRoleButtonTank.checkButton:GetChecked()
						local canBeHealer = LFDQueueFrameRoleButtonHealer.checkButton:GetChecked()
						local canBeDamager = LFDQueueFrameRoleButtonDPS.checkButton:GetChecked()
						if ((canBeTank or canBeHealer or canBeDamager) == false) then
							canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
						end
						WorldQuestGroupFinder.dprint(string.format(L["Applying to group. ID: %d, Name: %s, Leader: %s"], id, name, author))
						C_LFGList.ApplyToGroup(v, "WorldQuestGroupFinder User", canBeTank, canBeHealer, canBeDamager)
						applicationsCount = applicationsCount + 1
					end
				end
			end
			C_LFGList.ClearSearchResults()
			-- No group found, creating a new one
			if (foundGroup == false) then
				if (blacklistedApplicationsCount > 0) then
					WorldQuestGroupFinder.prefixedPrint(string.format(L["You have not been applied to %d group(s) because their leader was blacklisted. You can use |c00bfffff/wqgf unbl |c00ffffffto clear the blacklist."], blacklistedApplicationsCount))
				end
				local shortTitle = utf8sub(title, 0, 31)
				local autoInviteAllState = WorldQuestGroupFinderConf.GetConfigValue("autoinvite") and WorldQuestGroupFinderConf.GetConfigValue("autoinviteUsers") and WorldQuestGroupFinderConf.GetConfigValue("autoinviteOriginal")
				if (C_LFGList.CreateListing(currentZone, shortTitle, 0, 0, "", "Doing the world quest \""..title.."\" in "..activityIDs[currentZone]..". Automatically created by World Quest Group Finder "..GetAddOnMetadata("WorldQuestGroupFinder", "Version")..". #WQ:"..wqID.."#", autoInviteAllState)) then
					WorldQuestGroupFinder.prefixedPrint(string.format(L["A new group finder entry has been created for |c00bfffff%s|c00ffffff in |c00bfffff%s|c00ffffff."], title, activityIDs[currentZone]))
					WorldQuestGroupFinder.HandleWorldQuestStart(wqID)
				else
					WorldQuestGroupFinder.prefixedPrint(string.format(L["An error has occured when trying to create a new group finder entry. Please retry."]))
					WorldQuestGroupFinder.dprint(string.format(L["Failed group data: CurrentZone: %d, Title: %s, AutoInvite: %s"], currentZone, shortTitle, tostring(autoInviteAllState)))
				end
			else 
				WorldQuestGroupFinder.prefixedPrint(string.format(L["You have been applied to |c00bfffff%d|c00ffffff group(s) for the world quest |c00bfffff%s|c00ffffff."], applicationsCount, title))
				TIMEOUT_TIMER = C_Timer.NewTicker(INVITE_TIMEOUT_DELAY, function() 
					WorldQuestGroupFinder.HandleRequestTimeout(wqID) 
					WorldQuestGroupFinder.dprint(string.format(L["The timeout timer has ended (%d seconds)"], INVITE_TIMEOUT_DELAY))
				end, 1)
			end
			return true
		end)
	else
		WorldQuestGroupFinder.prefixedPrint(L["You are not in the right location for this world quest."])
		return false
	end
end

function WorldQuestGroupFinder.HandleWorldQuestStart(wqID)
	WorldQuestGroupFinder.dprint(string.format(L["World quest starting process. ID: %d"], wqID))
	currentlyApplying = false
	if (TIMEOUT_TIMER) then	WorldQuestGroupFinder.StopTimeoutTimer() end
	WorldQuestGroupFinder.AddWorldQuestToTracker(wqID)	
	if (WorldQuestGroupFinder.AttachBorderToWQ(wqID)) then
		currentWQFrame:Show()
		pendingApplications = {}
		blacklistedLeaders = {}
		currentWQ = wqID
		WorldQuestGroupFinderConf.SetConfigValue("savedCurrentWQ", currentWQ, "CHAR")
		if (IsInGroup() and UnitIsGroupLeader("player")) then
			WorldQuestGroupFinder.BroadcastMessage("#WQS:"..wqID.."#")
		end
		tempWQ = nil
		return true
	else
		WorldQuestGroupFinder.dprint(string.format(L["World quest start process failed. ID: %d"], wqID))
		return false
	end
end
	
function WorldQuestGroupFinder.HandleWorldQuestEnd(wqID, broadcast)
	local broadcast = broadcast or false
	currentWQ = nil
	WorldQuestGroupFinder.dprint(string.format(L["World quest ending process. ID: %d"], wqID))
	WorldQuestGroupFinderConf.SetConfigValue("savedCurrentWQ", nil, "CHAR")
	BonusObjectiveTracker_UntrackWorldQuest(wqID)
	if (IsInGroup() and UnitIsGroupLeader("player") and broadcast) then
		WorldQuestGroupFinder.BroadcastMessage("#WQE:"..wqID.."#")
	end
	currentWQFrame:Hide()
end

function WorldQuestGroupFinder.FlagWQAsSeen(wqID)
	seenWorldQuests[wqID] = true
	WorldQuestGroupFinder.dprint(string.format(L["Setting quest #%d as visited"], wqID))
end

function WorldQuestGroupFinder.BroadcastMessage(msg) 
	SendAddonMessage(BROADCAST_PREFIX, msg, "PARTY")
	WorldQuestGroupFinder.dprint(string.format(L["Sending broadcast. Message: %s"], msg))
end

function WorldQuestGroupFinder.ShowDialog(...)
	local dialog = ...
	local dialogObject = StaticPopup_Show(...)
	if (dialogObject) then
		WorldQuestGroupFinder.dprint(string.format(L["Showing dialog %s"], dialog))
		dialogObject.data = tempWQ
	else
		WorldQuestGroupFinder.dprint(string.format(L["Failed to show dialog %s"], dialog))
	end
end

function WorldQuestGroupFinder.HideDialog(dialog) 
	if (StaticPopup_Visible(dialog)) then
		StaticPopup_Hide(dialog)
		WorldQuestGroupFinder.dprint(string.format(L["Hiding dialog %s"], dialog))
	end
end

function WorldQuestGroupFinder.GetInvitedApplicantsCount() 
	local applicants = C_LFGList.GetApplicants();
	local aCount = 0
	for i=1, #applicants do
		local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicants[i]);
		if (status == "invited") then
			aCount = aCount + 1
		end	
	end
	return aCount
end
	
function WorldQuestGroupFinder.StopTimeoutTimer()
	TIMEOUT_TIMER:Cancel()
	WorldQuestGroupFinder.dprint(L["The timeout timer has been stopped."])
end	
	
function WorldQuestGroupFinder.HandleCustomAutoInvite()
	-- This will not run if Original WoW auto invite is activated
	if (WorldQuestGroupFinderConf.GetConfigValue("autoinviteUsers") and not (WorldQuestGroupFinderConf.GetConfigValue("autoinvite") and WorldQuestGroupFinderConf.GetConfigValue("autoinviteOriginal"))) then
		--local autoAccept = select(9, C_LFGList.GetActiveEntryInfo());
		if (UnitIsGroupLeader("player") and (GetNumGroupMembers() < 5 or raidQuests[currentWQ])) then 
			local applicants = C_LFGList.GetApplicants();
			local applicantsWQGF = {}
			local applicantsNonWQGF = {}
			for i=1, #applicants do
				local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicants[i]);
				if (status == "applied") then
					if (comment == "WorldQuestGroupFinder User") then
						applicantsWQGF[id] = numMembers
					else
						applicantsNonWQGF[id] = numMembers
					end
				end			
			end
			-- Get current group members count, including pending invites
			upToDateGroupMembersCount = GetNumGroupMembers() + WorldQuestGroupFinder.GetInvitedApplicantsCount()
			-- If we're here then the addon is at least set to invite WQGF users
			for aid, numMembers in pairs(applicantsWQGF) do
				if ((upToDateGroupMembersCount + numMembers) <= 5 or raidQuests[currentWQ]) then
					C_LFGList.InviteApplicant(aid)
					WorldQuestGroupFinder.dprint(string.format(L["Auto-inviting WQGF user(s). New member(s): %d. Current members count: %d."], numMembers, upToDateGroupMembersCount))
					upToDateGroupMembersCount = upToDateGroupMembersCount + numMembers
					if (numMembers > 1) then
						WorldQuestGroupFinder.prefixedPrint(L["A group of World Quest Group Finder users has been invited to the group!"])
					else
						WorldQuestGroupFinder.prefixedPrint(L["A World Quest Group Finder user has been invited to the group!"])
					end
				end
			end
			-- If set to invite everyone
			if (WorldQuestGroupFinderConf.GetConfigValue("autoinvite")) then
				for aid, numMembers in pairs(applicantsNonWQGF) do
					if ((upToDateGroupMembersCount + numMembers) <= 5 or raidQuests[currentWQ]) then
						C_LFGList.InviteApplicant(aid)
						upToDateGroupMembersCount = upToDateGroupMembersCount + numMembers
						WorldQuestGroupFinder.dprint(string.format(L["Auto-inviting NON-WQGF user(s). New member(s): %d. Current members count: %d."], numMembers, upToDateGroupMembersCount))
					end
				end
			end
		end
	end
end	
	
function WorldQuestGroupFinder.HandleRequestTimeout(wqID)
	WorldQuestGroupFinder.prefixedPrint(string.format(L["None of your applications for |c00bfffff%s|c00ffffff were answered in time. Trying to find new groups..."], WorldQuestGroupFinder.GetQuestInfo(wqID)))
	recentlyTimedOut = true
	WorldQuestGroupFinder.InitWQGroup(wqID, true)
end

function WorldQuestGroupFinder.AttachBorderToWQ(wqID)
	local targetBlock = WorldQuestGroupFinder.FindWQBlock(wqID)
	if (targetBlock) then
	
		local xOffset = -12
		local yOffset = 10
		
		local trackerWidth, trackerHeight = ObjectiveTrackerFrame:GetSize()
		local blockWidth, blockHeight = targetBlock:GetSize()
			
		currentWQFrame:SetClampedToScreen(true)
		currentWQFrame:SetFrameStrata("MEDIUM")
		currentWQFrame:SetToplevel(false) 
		currentWQFrame:RegisterForDrag("LeftButton")
		
		currentWQFrame:SetSize(blockWidth+18,blockHeight+10)
		currentWQFrame:SetMovable(false)
		currentWQFrame:EnableMouse(false)
		
		currentWQFrame:SetPoint("TOPLEFT", targetBlock,"TOPLEFT", xOffset, yOffset)
		currentWQFrame:SetParent(targetBlock)
			
		currentWQFrame:SetFrameStrata("LOW")
		currentWQFrame:SetFrameLevel(0)

		currentWQFrame:SetBackdrop({
		  bgFile="Interface\\QuestionFrame\\question-background.blp", 
		  edgeFile="Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		  tile=false, edgeSize=16, --tileSize=16,
		  insets={left=5, right=5, top=5, bottom=5}
		})		
		return currentWQFrame
	else 
		return false
	end
end

function WorldQuestGroupFinder.SendWQCompletionPartyNotification (wqID)
	local title, factionID, tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = WorldQuestGroupFinder.GetQuestInfo(wqID)
	SendChatMessage("[WQGF] World quest \""..title.."\" completed! "..L[":)"], "PARTY", "", "");
end

function WorldQuestGroupFinder.ShowLeavePrompt()
	if (UnitIsGroupLeader("player")) then
		WorldQuestGroupFinder.ShowDialog ("WORLD_QUEST_FINISHED_LEADER_PROMPT")
	else 
		WorldQuestGroupFinder.ShowDialog ("WORLD_QUEST_FINISHED_PROMPT")
	end
end

function WorldQuestGroupFinder.handleCMD(msg, editbox)
	if (string.lower(msg) == "config") then
		InterfaceOptionsFrame_OpenToCategory("WorldQuestGroupFinder")
	elseif (string.lower(msg) == "data") then
		if (currentWQ ~= nil) then
			WorldQuestGroupFinder.prefixedPrint(string.format(L["Current world quest ID is |c00bfffff%s|c00ffffff."], currentWQ))
		else 
			WorldQuestGroupFinder.prefixedPrint(L["No current world quest."])
		end
		print(L["World quest zones entered this session :"])
		WorldQuestGroupFinder.dumpTable(seenWorldQuests)
	elseif (string.lower(msg) == "debug") then
		if (WorldQuestGroupFinderConf.GetConfigValue("printDebug")) then
			WorldQuestGroupFinderConf.SetConfigValue("printDebug", false)
			WorldQuestGroupFinder.prefixedPrint(L["Debug mode is now disabled."])
		else
			WorldQuestGroupFinderConf.SetConfigValue("printDebug", true)
			WorldQuestGroupFinder.prefixedPrint(L["Debug mode is now enabled."])
		end
	elseif (string.lower(msg) == "showconfig") then
		print(L["Global configuration :"])
		WorldQuestGroupFinder.dumpTable(WorldQuestGroupFinderConfig)
		print(L["Character configuration :"])
		WorldQuestGroupFinder.dumpTable(WorldQuestGroupFinderCharacterConfig)
	elseif (string.lower(msg) == "unbl") then
		blacklistedLeaders = {}
		WorldQuestGroupFinder.prefixedPrint(L["The leaders blacklist has been cleared."])
	else
		WorldQuestGroupFinder.help()
	end
end

function WorldQuestGroupFinder.help()
	print(L["|c00bfffffSlash commands (/wqgf):"])
	print(L["|c00bfffff /wqgf config : Open addon configuration"])
	print(L["|c00bfffff /wqgf unbl : Clear the leaders blacklist"])
end

function WorldQuestGroupFinder.prefixedPrint(text)
	print("|c00bfffff[WQGF]|c00ffffff "..text)
end 

function WorldQuestGroupFinder.dprint(text)
	if (WorldQuestGroupFinderConf.GetConfigValue("printDebug")) then
		print("|c00ffbfff[DEBUG]|c00ffffff "..text)
	end
end 

function WorldQuestGroupFinder.dumpTable(t)
	if type(t) == "table" then
		for k, v in pairs( t ) do
			print(k, v)
		end
	else 
		print(t)
	end
end

function WorldQuestGroupFinder.FindWQBlock(wqID)
	local tracker = ObjectiveTrackerFrame
	-- CAST OR DIE!!!
	wqID = tonumber(wqID)
	
	if (not tracker.initialized) then
		return
	end
	for i = 1, #tracker.MODULES do
		local module = tracker.MODULES [i]
		for blockName, usedBlock in pairs (module.usedBlocks) do
			if (usedBlock.id) then
				if (wqID == usedBlock.id) then
					return usedBlock
				end
			end
		end
	end
	return false
end
