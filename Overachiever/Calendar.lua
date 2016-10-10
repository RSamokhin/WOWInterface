
local L = OVERACHIEVER_STRINGS

local getCalendarTextureFile


Overachiever.HOLIDAY_REV = { -- lookup table to support localization
--	["Localized holiday/event name"] = "The key we're using for this holiday/event",
	[L.HOLIDAY_DARKMOONFAIRE] = "Darmoon Faire",
	[L.HOLIDAY_BREWFEST] = "Brewfest",
	[L.HOLIDAY_HALLOWSEND] = "Hallow's End",
	[L.HOLIDAY_DAYOFTHEDEAD] = "Day of the Dead",
	[L.HOLIDAY_PIGRIMSBOUNTY] = "Pilgrim's Bounty",
	[L.HOLIDAY_WINTERVEIL] = "Feast of Winter Veil",
	-- Aliases: (used by Suggestions tab but not the title the in-game calendar uses)
	[L.HOLIDAY_WINTERVEIL_SHORT] = "Winter Veil",
}

local HOLIDAYS_OPTIONS = {
	--"Brewfest" = {}, -- Nothing for this one. "The Brewfest Diet" can be completed when it's not Brewfest (if you already bought the food).
}

local function getHolidayAutoOptions(localizedEventTitle)
	local key = Overachiever.HOLIDAY_REV[localizedEventTitle] or localizedEventTitle
	return HOLIDAYS_OPTIONS[key]
end


local function getEventEnding(title, calendarType, yearStart, monthStart, dayStart)
	local _, _, numDays = TjCalendar.StartReadingAt(yearStart, monthStart, true)
	local m = 0 -- Month offset
	local day = dayStart
	for i = 1, 100 do -- Look up to 100 days away, which should be more than enough; this is a failsafe.
		local numEvents = CalendarGetNumDayEvents(m, day)
		for e = 1, numEvents do
			local title2, hour, minute, calendarType2, sequenceType = CalendarGetDayEvent(m, day, e)
			if (sequenceType == "END" and title == title2 and calendarType == calendarType2) then
				local month, year = CalendarGetMonth(m)
				TjCalendar.StopReading()
				return year, month, day, hour, minute
			end
		end
		day = day + 1
		if (day > numDays) then
			day = 1
			m = m + 1
			_, _, numDays = CalendarGetMonth(m)
		end
	end
	TjCalendar.StopReading()
	return nil, nil, nil, nil, nil
end

local lastEvents = {}
local lastCheckedDay, lastCheckedMonth
local eventsExpireHour, eventsExpireMinute = false, false

function Overachiever.GetTodaysEvents(cachekey, unexpiredOnly, searchEndDate, checkTitleFunc)
	--return Overachiever.GetHolidayEvents(2016, 10, 5, 1, cachekey, unexpiredOnly, searchEndDate, checkTitleFunc)
	return Overachiever.GetHolidayEvents(nil, nil, nil, nil, cachekey, unexpiredOnly, searchEndDate, checkTitleFunc)
end

--/dump Overachiever.GetHolidayEvents(2016, 10, 6, "hey", true, true)
function Overachiever.GetHolidayEvents(year, month, day, hourOverride, cachekey, unexpiredOnly, searchEndDate, checkTitleFunc)
	-- Make sure to use a unique cachekey for each combination of your other arguments. Otherwise, you may get back cached data for some other arguments.
	cachekey = cachekey or 0
	local weekdayNow, monthNow, dayNow, yearNow = CalendarGetDate()
	local hourNow, minuteNow = GetGameTime()
	if (lastCheckedDay == dayNow and lastCheckedMonth == monthNow and lastEvents[cachekey]) then
		if (eventsExpireHour == false or hourNow < eventsExpireHour or (hourNow == eventsExpireHour and minuteNow < eventsExpireMinute)) then
			return lastEvents[cachekey]
		end
	end
	lastCheckedDay = dayNow
	lastCheckedMonth = monthNow
	eventsExpireHour = false
	eventsExpireMinute = false

	year = year or yearNow
	month = month or monthNow
	day = day or dayNow
	hourNow = hourOverride or hourNow

	TjCalendar.StartReadingAt(year, month)
	--TjCalendar.StartReading()

	local result = nil
	local numEvents = CalendarGetNumDayEvents(0, day)
	local expired = {}
	for e = 1, numEvents do
		local title, hour, minute, calendarType, sequenceType, eventType, texture = CalendarGetDayEvent(0, day, e)
		if (not expired[title] and calendarType == "HOLIDAY") then
			if (unexpiredOnly and sequenceType == "END" and (hour < hourNow or (hour == hourNow and minute <= minuteNow))) then
				expired[title] = true
				if (result) then  result[title] = nil;  end
			elseif (not checkTitleFunc or checkTitleFunc(title)) then
				if (not result) then  result = {};  end
				--texture = getCalendarTextureFile(texture, calendarType, sequenceType, eventType)
				if (not result[title]) then  result[title] = {};  end
				if (not result[title]["texture"] or result[title]["texture"] == "") then
					result[title]["texture"] = getCalendarTextureFile(texture, calendarType, "START", eventType)
				end
				if (not result[title]["desc"]) then
					local _, description = CalendarGetHolidayInfo(0, day, e)
					result[title]["desc"] = description
				end
				if (sequenceType == "START")  then
					result[title]["hourStart"] = hour
					result[title]["minuteStart"] = minute
				elseif (sequenceType == "END")  then
					result[title]["hourEnd"] = hour
					result[title]["minuteEnd"] = minute
					if (eventsExpireHour == false or (eventsExpireHour > hour or (eventsExpireHour == hour and eventsExpireMinute > minute))) then
						eventsExpireHour = hour
						eventsExpireMinute = minute
					end
				end
			end
		end
	end

	TjCalendar.StopReading()

	if (searchEndDate and result) then
		for title,arr in pairs(result) do
			if (not arr["hourEnd"]) then
				arr["yearEnd"], arr["monthEnd"], arr["dayEnd"], arr["hourEnd"], arr["minuteEnd"] = getEventEnding(title, "HOLIDAY", year, month, day)
				--print("getEventEnding(",title,", \"HOLIDAY\", ",month,", ",day,")")
				--print(arr["yearEnd"], arr["monthEnd"], arr["dayEnd"], arr["hourEnd"], arr["minuteEnd"])
			end
		end
	end
	lastEvents[cachekey] = result
	return result
end



-- THIS SECTION IS FROM Blizzard_Calendar.lua (since it is entirely local there)
-----------------------------------------------------------------------------------

local CALENDAR_CALENDARTYPE_TEXTURE_PATHS = {
--	["PLAYER"]				= "",
--	["GUILD_ANNOUNCEMENT"]	= "",
--	["GUILD_EVENT"]			= "",
--	["SYSTEM"]				= "",
	["HOLIDAY"]				= "Interface\\Calendar\\Holidays\\",
--	["RAID_LOCKOUT"]		= "",
--	["RAID_RESET"]			= "",
};

local CALENDAR_CALENDARTYPE_TEXTURE_APPEND = {
--	["PLAYER"] = {
--	},
--	["GUILD_ANNOUNCEMENT"] = {
--	},
--	["GUILD_EVENT"] = {
--	},
--	["SYSTEM"] = {
--	},
	["HOLIDAY"] = {
		["START"]			= "Start",
		["ONGOING"]			= "Ongoing",
		["END"]				= "End",
		["INFO"]			= "Info",
		[""]				= "",
	},
--	["RAID_LOCKOUT"] = {
--	},
--	["RAID_RESET"] = {
--	},
};

local CALENDAR_CALENDARTYPE_TCOORDS = {
	["PLAYER"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_ANNOUNCEMENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_EVENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["SYSTEM"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["HOLIDAY"] = {
		left	= 0.0,
		right	= 0.7109375,
		top		= 0.0,
		bottom	= 0.7109375,
	},
	["RAID_LOCKOUT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["RAID_RESET"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};

local CALENDAR_EVENTTYPE_TEXTURE_PATHS = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
};

local CALENDAR_EVENTTYPE_TCOORDS = {
	[CALENDAR_EVENTTYPE_RAID] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_DUNGEON] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_PVP] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_MEETING] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_OTHER] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};

local CALENDAR_CALENDARTYPE_TEXTURES = {
	["PLAYER"] = {
--		[""]				= "",
	},
	["GUILD_ANNOUNCEMENT"] = {
--		[""]				= "",
	},
	["GUILD_EVENT"] = {
--		[""]				= "",
	},
	["SYSTEM"] = {
--		[""]				= "",
	},
	["HOLIDAY"] = {
		["START"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		["ONGOING"]			= "",
		["END"]				= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
		["INFO"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		[""]				= "",
	},
	["RAID_LOCKOUT"] = {
--		[""]				= "",
	},
	["RAID_RESET"] = {
--		[""]				= "",
	},
};

local CALENDAR_EVENTTYPE_TEXTURES = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
};


function getCalendarTextureFile(textureName, calendarType, sequenceType, eventType) -- from _CalendarFrame_GetTextureFile
	local texture, tcoords;
	if ( textureName and textureName ~= "" ) then
		if ( CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURE_PATHS[calendarType]..textureName;
			if ( CALENDAR_CALENDARTYPE_TEXTURE_APPEND[calendarType] ) then
				texture = texture..CALENDAR_CALENDARTYPE_TEXTURE_APPEND[calendarType][sequenceType];
			end
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURE_PATHS[eventType]..textureName;
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType] ) then
			texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType];
			tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
		elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
			texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
			tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
		end
	elseif ( CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType] ) then
		texture = CALENDAR_CALENDARTYPE_TEXTURES[calendarType][sequenceType];
		tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
	elseif ( CALENDAR_EVENTTYPE_TEXTURES[eventType] ) then
		texture = CALENDAR_EVENTTYPE_TEXTURES[eventType];
		tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	end
	return texture, tcoords;
end

-----------------------------------------------------------------------------------



--/dump CalendarGetDayEvent(0, 4, 1)
