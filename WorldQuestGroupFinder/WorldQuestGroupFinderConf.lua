WorldQuestGroupFinderConf = {}
local _, L = ...;

local DefaultConfig = {}
WorldQuestGroupFinderConfig = {}
WorldQuestGroupFinderCharacterConfig = {}

function WorldQuestGroupFinderConf.CreateConfigMenu()
	local configPanel = CreateFrame("Frame", "WorldQuestGroupFinderConfigFrame", UIParent)
	configPanel.name = "WorldQuestGroupFinder"
	configPanel.okay = function (self) return end
	configPanel.cancel = function (self) return end

	local addonName, addonTitle, addonNotes = GetAddOnInfo('WorldQuestGroupFinder')
	local configPanelText = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	configPanelText:SetPoint('TOPLEFT', 16, -16)
	configPanelText:SetText(addonTitle .. " "..GetAddOnMetadata("WorldQuestGroupFinder", "Version").." (" .. L["Brought to you by Robou, EU-Hyjal"] ..")")

	local configPanelDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')

	configPanelDesc:SetPoint('TOPLEFT', configPanelText, 'BOTTOMLEFT', 0, -8)
	configPanelDesc:SetPoint('RIGHT', configPanel, -32, 0)
	configPanelDesc:SetNonSpaceWrap(true)
	configPanelDesc:SetJustifyH('LEFT')
	configPanelDesc:SetJustifyV('TOP')
	configPanelDesc:SetText(addonNotes)
	
	local autoInviteDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	autoInviteDesc:SetPoint('TOPLEFT', configPanelDesc, 'BOTTOMLEFT', -2, -8)
	autoInviteDesc:SetText(L["Auto-invite"])

	local autoInviteUsers = WorldQuestGroupFinderConf.CreateCheckButton(L["Auto-invite WQGF users"], configPanel, L["World Quest Group Finder users will automatically be invited to the group"], "autoinviteUsers", 'InterfaceOptionsCheckButtonTemplate')
	autoInviteUsers:SetPoint('TOPLEFT', autoInviteDesc, 'BOTTOMLEFT', 0, -2)
	
	local autoInvite = WorldQuestGroupFinderConf.CreateCheckButton(L["Auto-invite everyone"], configPanel, L["Every applicant will automatically be invited to the group up to a limit of 5 players"], "autoinvite", 'InterfaceOptionsCheckButtonTemplate')
	autoInvite:SetPoint('TOPLEFT', autoInviteUsers, 'BOTTOMLEFT', 10, 2)
	WorldQuestGroupFinderConf.AddDependentCheckbox(autoInviteUsers, autoInvite, false)
	
	local autoinviteOriginal = WorldQuestGroupFinderConf.CreateCheckButton(L["Use WoW's auto-invite function"], configPanel, L["Use WoW's auto-invite function (Not recommended, will cause realm hoppers to join the group)"], "autoinviteOriginal", 'InterfaceOptionsCheckButtonTemplate')
	autoinviteOriginal:SetPoint('TOPLEFT', autoInvite, 'BOTTOMLEFT', 10, 2)
	WorldQuestGroupFinderConf.AddDependentCheckbox(autoInvite, autoinviteOriginal, false)
	
	local askToLeaveDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	askToLeaveDesc:SetPoint('TOPLEFT', autoinviteOriginal, 'BOTTOMLEFT', -20, -8)
	askToLeaveDesc:SetText(L["Show a dialog to leave the group when the world quest is completed"])

	local askToLeave = WorldQuestGroupFinderConf.CreateCheckButton(L["Enable world quest end dialog"], configPanel, L["You will be proposed to leave the group or delist it when the world quest is completed"], "askToLeave", 'InterfaceOptionsCheckButtonTemplate')
	askToLeave:SetPoint('TOPLEFT', askToLeaveDesc, 'BOTTOMLEFT', 0, -2)

	local notifyPartyDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	notifyPartyDesc:SetPoint('TOPLEFT', askToLeave, 'BOTTOMLEFT', 0, -8)
	notifyPartyDesc:SetText(L["Notify the group when the world quest is completed"])

	local notifyParty = WorldQuestGroupFinderConf.CreateCheckButton(L["Enable party notification"], configPanel, L["A message will be sent to the party when the world quest is completed"], "notifyParty", 'InterfaceOptionsCheckButtonTemplate')
	notifyParty:SetPoint('TOPLEFT', notifyPartyDesc, 'BOTTOMLEFT', 0, -2)

	local askZoningDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	askZoningDesc:SetPoint('TOPLEFT', notifyParty, 'BOTTOMLEFT', 0, -8)
	askZoningDesc:SetText(L["Propose searching for a group when entering a world quest area for the first time"])

	local askZoning = WorldQuestGroupFinderConf.CreateCheckButton(L["Enable new world quest zone detection"], configPanel, L["You will be asked if you want to search for a group when entering a new world quest zone"], "askZoning", 'InterfaceOptionsCheckButtonTemplate')
	askZoning:SetPoint('TOPLEFT', askZoningDesc, 'BOTTOMLEFT', 0, -2)

	local askZoningBusy = WorldQuestGroupFinderConf.CreateCheckButton(L["Do not propose if already grouped for another world quest"], configPanel, L["Do not propose if already grouped for another world quest"], "askZoningBusy", 'InterfaceOptionsCheckButtonTemplate')
	askZoningBusy:SetPoint('TOPLEFT', askZoning, 'BOTTOMLEFT', 10, 2)
	WorldQuestGroupFinderConf.AddDependentCheckbox(askZoning, askZoningBusy, false)

	local askZoningAuto = WorldQuestGroupFinderConf.CreateCheckButton(L["Automatically start searching if not in a group"], configPanel, L["A group will automatically be searched when entering a new world quest zone"], "askZoningAuto", 'InterfaceOptionsCheckButtonTemplate')
	askZoningAuto:SetPoint('TOPLEFT', askZoningBusy, 'BOTTOMLEFT', 0, 2)
	WorldQuestGroupFinderConf.AddDependentCheckbox(askZoning, askZoningAuto, false)

	local autoAcceptInviteDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	autoAcceptInviteDesc:SetPoint('TOPLEFT', askZoningAuto, 'BOTTOMLEFT', -10, -8)
	autoAcceptInviteDesc:SetText(L["Auto-accept group invites"])

	local autoAcceptInvite = WorldQuestGroupFinderConf.CreateCheckButton(L["Automatically accept group invites for groups applied by WQGF"], configPanel, L["Will automatically accept group invites"], "autoAcceptInvites", 'InterfaceOptionsCheckButtonTemplate')
	autoAcceptInvite:SetPoint('TOPLEFT', autoAcceptInviteDesc, 'BOTTOMLEFT', 0, -2)

	local hideLoginMessageDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	hideLoginMessageDesc:SetPoint('TOPLEFT', autoAcceptInvite, 'BOTTOMLEFT', 0, -8)
	hideLoginMessageDesc:SetText(L["WQGF login message"])

	local hideLoginMessage = WorldQuestGroupFinderConf.CreateCheckButton(L["Hide WQGF init message at login"], configPanel, L["Won't display the WQGF message at login anymore"], "hideLoginMessage", 'InterfaceOptionsCheckButtonTemplate')
	hideLoginMessage:SetPoint('TOPLEFT', hideLoginMessageDesc, 'BOTTOMLEFT', 0, -2)

	local languagesDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	languagesDesc:SetPoint('TOPLEFT', hideLoginMessage, 'BOTTOMLEFT', 0, -8)
	languagesDesc:SetText(L["The groups found by the addon are filtered by realm language according to your selection in the Group Finder interface."])

	local languagesDesc2 = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	languagesDesc2:SetPoint('TOPLEFT', languagesDesc, 'BOTTOMLEFT', 0, -4)
	languagesDesc2:SetText(L["It is recommended to select all languages to get a broader realm selection."])

	if (GetLocale() ~= "enUS" and GetLocale() ~= "enGB") then
		local translationInfo = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		translationInfo:SetPoint('TOPLEFT', languagesDesc2, 'BOTTOMLEFT', 0, -12)
		translationInfo:SetText(L["TRANSLATION_INFO"])
	end
	
	InterfaceOptions_AddCategory(configPanel)
end


function WorldQuestGroupFinderConf.AddDependentCheckbox(dependency, checkbox, reversed)
	if ( not dependency ) then
		return
	end
	local reversed = reversed or false
	assert(checkbox)
	checkbox.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end
	checkbox.Enable = function (self) getmetatable(self).__index.Enable(self) _G[self:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end
	if (reversed) then
		dependency.reverseDependentCheckbox = dependency.reverseDependentCheckbox or {}
		tinsert(dependency.reverseDependentCheckbox, control)
		if dependency:GetChecked() then
			checkbox:Disable()
		else
			checkbox:Enable()
		end
	else
		dependency.dependentCheckbox = dependency.dependentCheckbox or {}
		tinsert(dependency.dependentCheckbox, checkbox)
		if dependency:GetChecked() then
			checkbox:Enable()
		else
			checkbox:Disable()
		end
	end
end

function WorldQuestGroupFinderConf.CreateCheckButton(name, parent, tooltipText, configKey, template)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, template)
	_G[button:GetName() .. 'Text']:SetText(name)
	button:SetChecked(WorldQuestGroupFinderConf.GetConfigValue(configKey))
	button:SetScript('OnClick', function(self)
		if self:GetChecked() then
			WorldQuestGroupFinderConf.SetConfigValue(configKey, true)
		else 
			WorldQuestGroupFinderConf.SetConfigValue(configKey, false)
		end
		if ( self.dependentCheckbox ) then
			if ( self:GetChecked() ) then
				for _, control in pairs(self.dependentCheckbox) do
					control:Enable()
				end
			else
				for _, control in pairs(self.dependentCheckbox) do
					control:Disable()
				end
			end
		end
		if ( self.reverseDependentCheckbox ) then
			if ( self:GetChecked() ) then
				for _, control in pairs(self.reverseDependentCheckbox) do
					control:Disable()
				end
			else
				for _, control in pairs(self.reverseDependentCheckbox) do
					control:Enable()
				end
			end
		end
	end)
	button:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltipText, nil, nil, nil, 1, 1)
		GameTooltip:Show() end)
	button:SetScript('OnLeave', function(self) GameTooltip:Hide() end)

	return button
end

function WorldQuestGroupFinderConf.GetConfigValue(key, cType)
	local cType = cType or "GLOBAL"
	if (cType == "GLOBAL") then
		return WorldQuestGroupFinderConfig[key]
	elseif (cType == "CHAR") then
		return WorldQuestGroupFinderCharacterConfig[key]
	end
end

function WorldQuestGroupFinderConf.SetConfigValue(key, value, cType)
	local cType = cType or "GLOBAL"
	if (cType == "GLOBAL") then
		WorldQuestGroupFinderConfig[key] = value
	elseif (cType == "CHAR") then
		WorldQuestGroupFinderCharacterConfig[key] = value
	end
	WorldQuestGroupFinder.dprint(string.format(L["Changed parameter value. Parameter: %s, Value: %s, Type: %s"], key, tostring(value), cType))
end

WorldQuestGroupFinderConf.DefaultConfig = {
	autoinvite = true,
	autoinviteOriginal = false,
	autoinviteUsers = true,
	askToLeave = true,
	notifyParty = true,
	askZoning = true,
	askZoningBusy = true,
	askZoningAuto = false,
	hideLoginMessage = false,
	autoAcceptInvites = false,
	printDebug = false
}