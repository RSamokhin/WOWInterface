local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	WorldMapFrame.BorderFrame.Inset:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrameNavBar:StripTextures()
	WorldMapFrameNavBarOverlay:StripTextures()

	WorldMapFrameNavBarHomeButton:StripTextures()
	WorldMapFrameNavBarHomeButton:CreateBackdrop("Default", true)
	WorldMapFrameNavBarHomeButton.backdrop:SetPoint("TOPLEFT", WorldMapFrameNavBarHomeButton, "TOPLEFT", 0, 0)
	WorldMapFrameNavBarHomeButton.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrameNavBarHomeButton, "BOTTOMRIGHT", -15, 0)
	WorldMapFrameNavBarHomeButton:SetFrameLevel(1)
	WorldMapFrameNavBarHomeButton.text:FontTemplate()

	S:HandleDropDownBox(WorldMapLevelDropDown)
	WorldMapLevelDropDown:Point("TOPLEFT", -17, 0)

	WorldMapFrame.BorderFrame:CreateBackdrop("Transparent")
	WorldMapFrame.BorderFrame.Inset:CreateBackdrop("Default")
	WorldMapFrame.BorderFrame.Inset.backdrop:Point("TOPLEFT", WorldMapFrame.BorderFrame.Inset, "TOPLEFT", 3, -3)
	WorldMapFrame.BorderFrame.Inset.backdrop:Point("BOTTOMRIGHT", WorldMapFrame.BorderFrame.Inset, "BOTTOMRIGHT", -3, 2)

	S:HandleScrollBar(QuestScrollFrameScrollBar)

	if E.global.general.disableTutorialButtons then
		WorldMapFrameTutorialButton:Kill()
	end

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)
	-- This button is flashing. Needs review
	S:HandleButton(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, true)

	QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent")
	QuestMapFrame.DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleCloseButton(WorldMapFrameCloseButton)

	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)

	local rewardFrames = {
		['MoneyFrame'] = true,
		['XPFrame'] = true,
		['SkillPointFrame'] = true, -- this may have extra textures.. need to check on it when possible
		['HonorFrame'] = true,
		['ArtifactXPFrame'] = true,
		['TitleFrame'] = true,
	}

	local function HandleReward(frame)
		if frame.backdrop then return end
		frame.NameFrame:SetAlpha(0)
		frame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame:CreateBackdrop()
		frame.backdrop:SetOutside(frame.Icon)
		frame.Name:FontTemplate()
		frame.Count:ClearAllPoints()
		frame.Count:Point("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
		if(frame.CircleBackground) then
			frame.CircleBackground:SetAlpha(0)
			frame.CircleBackgroundGlow:SetAlpha(0)
		end
	end

	for frame, _ in pairs(rewardFrames) do
		HandleReward(MapQuestInfoRewardsFrame[frame])
	end

	-- The Icon Border should be in QualityColor
	hooksecurefunc('QuestInfo_GetRewardButton', function(_, index)
		local button = MapQuestInfoRewardsFrame.RewardButtons[index]
		if(button) then
			HandleReward(button)
			button.IconBorder:SetAlpha(0)
		end
	end)

	S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton)
	S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton)
	SquareButton_SetIcon(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, 'LEFT')

	WorldMapFrame.UIElementsFrame.BountyBoard.BountyName:FontTemplate(nil, 14, "OUTLINE")
end

S:AddCallback("SkinWorldMap", LoadSkin)