--
-- Created by IntelliJ IDEA.
-- User: Jaybee
-- Date: 2014-12-12
-- Time: 14:18
-- To change this template use File | Settings | File Templates.
--

local E, L, V, P, G = unpack(ElvUI)
local AFK = E:GetModule("AFK")

local function printRaidAchievment(topframe, frameAbove, image, name, description, completed, year, month, day, wasEarnedByMe, earnedBy)
    local achi = CreateFrame("Frame", nil, topframe)
    achi:SetFrameLevel(0)
    achi:SetTemplate("Transparent")
    achi:SetSize(500, 90)
    achi:SetPoint("TOPRIGHT", frameAbove, "BOTTOMRIGHT", 0, -4)
    local textColorR, textColorG, textColorB;
    if (completed) then
        textColorR = 1;
        textColorG = 1;
        textColorB = 1;
    else
        textColorR = 0.5;
        textColorG = 0.5;
        textColorB = 0.5;
    end

    achi.logo = topframe:CreateTexture(nil, 'OVERLAY')
    achi.logo:SetSize(75, 75)
    achi.logo:SetPoint("LEFT", achi, "LEFT", 10, 0);
    achi.logo:SetTexture(image);
    achi.logo:SetDesaturated(not completed);

    achi.name = achi:CreateFontString(nil, 'OVERLAY')
    achi.name:FontTemplate(nil, 30)
    achi.name:SetText(name);
    achi.name:SetPoint("TOPLEFT", achi, "TOPLEFT", 120, -10)
    achi.name:SetTextColor(textColorR, textColorG, textColorB)

    achi.desc = achi:CreateFontString(nil, 'OVERLAY')
    achi.desc:FontTemplate(nil, 15)
    achi.desc:SetText(description);
    achi.desc:SetPoint("TOPLEFT", achi.name, "BOTTOMLEFT", 0, 0)
    achi.desc:SetTextColor(textColorR, textColorG, textColorB)
    if completed then
        achi.completed = achi:CreateFontString(nil, 'OVERLAY')
        achi.completed:FontTemplate(nil, 15)
        if day < 10 then
            day = "0" .. day
        end
        if month < 10 then
            month = "0" .. month
        end
        if (wasEarnedByMe) then
            achi.completed:SetText("20" .. year .. "-" .. month .. "-" .. day);
        else
            achi.completed:SetText("20" .. year .. "-" .. month .. "-" .. day .. " (" .. earnedBy .. ")");
        end
        achi.completed:SetPoint("BOTTOMRIGHT", achi, "BOTTOMRIGHT", -10, 10)
    else
    end

    return achi;
end

local function setLogo()
    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();
    local localizedClass, englishClass, classIndex = UnitClass("player");
    local currentSpec = GetSpecialization()
    local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
    local guildName, guildRankName = GetGuildInfo("player");
    if (guildName == "Fenimo") then
        AFK.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\FenimoElvUI\\logo.tga")
        AFK.AFKMode.bottom.faction:SetTexture("Interface\\AddOns\\FenimoElvUI\\hasselhoff.tga")
    end
    AFK.AFKMode.bottom.name:SetText(E.myname .. "-" .. E.myrealm .. " (" .. currentSpecName .. " " .. localizedClass .. " " .. math.floor(avgItemLevelEquipped + 0.5) .. "ilvl)")


    --AFK.AFKMode.achi:FontTemplate()
    local raidAchievementsHighMaul = { 8965, 8988 }
    local raidAchievementsBlackrock = { 8973, 8992 }
    local raids = { raidAchievementsHighMaul, raidAchievementsBlackrock }
    local idNumber, name, points, completed, month, day, year, description, flags, image, rewardText, isGuildAch, wasEarnedByMe, earnedBy;
    local emptyFrameAbove = CreateFrame("Frame", nil, AFK.AFKMode)
    emptyFrameAbove:SetFrameLevel(0)
    --emptyFrameAbove:SetTemplate("Transparent")
    emptyFrameAbove:SetSize(500, 1)
    emptyFrameAbove:SetPoint("TOPRIGHT", AFK.AFKMode, "TOPRIGHT", 4, 0)
    local frameAbove = emptyFrameAbove;
    for i, raid in ipairs(raids) do
        for j, achiId in ipairs(raid) do
            idNumber, name, points, completed, month, day, year, description, flags, image, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achiId);
            frameAbove = printRaidAchievment(AFK.AFKMode, frameAbove, image, name, description, completed, year, month, day, wasEarnedByMe, earnedBy);
        end
    end


    --AFK.AFKMode.achi.name:SetTextColor(classColor.r, classColor.g, classColor.b)
end



hooksecurefunc(AFK, "Initialize", setLogo)